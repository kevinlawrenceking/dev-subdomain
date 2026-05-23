# Prod DB Audit — Retention Policy: `bigbrother` + `errors_tbl` (R12)

Status: **DRAFT — owner sign-off + tao-gatekeeper review required before execution.** Largest-size-ROI work in the audit (R12). All scripts archive-then-purge, idempotent, batched to avoid lock contention. Run against dev (`new_development`) first.

---

## 1. Measured state (live prod 2026-05-17)

### `bigbrother` — request/access log
- **2,302,214 rows; 363 MB (43% of the entire DB)**
- Time span: 2021-07-12 → 2026-05-23 (~5 years)
- Schema: `(id, timestamp, pgid, userid, remote_addr, query_string, remote_host, script_name, contactid, isInclude)` — timestamp default `CURRENT_TIMESTAMP`.

**Volume cliff (do not skip):**
| Period | Rows/month |
|---|---|
| 2023-12 — 2025-03 (16 months) | 39,450 – 91,224 |
| **2025-04 onward (14 months)** | **~80 – 800** |

The logger volume dropped >100× starting April 2025 and has stayed there. **Three possible causes — find out which before pruning:**
1. Intentional throttle / disabling of high-volume call sites (operational change).
2. The logger silently broke (regression nobody noticed).
3. High-volume code paths were rewritten / removed.

If (2), purging the pre-cliff corpus hides the bug. **Investigate first; then prune.**

### `errors_tbl` — error log
- 5,056 rows (Phase 0's 2,532 was an InnoDB estimate; live `COUNT(*)` is 5,056); **116 MB**.
- **~17 KB blob per row** (avg of `generatedContent` + `rootCauseStackTrace`). That's where the size lives.
- ID range 1 – 5,056 contiguous (AUTO_INCREMENT, no gaps).
- **No timestamp column.** Schema has zero date/time fields. Retention must use ID-watermark (older IDs = older rows).

---

## 2. Recommended policies

### `bigbrother`
**One-time pre-cliff cleanup** (after the cliff investigation closes): archive + purge everything before 2025-04-01. Saves ~360 MB / ~2.3M rows in a single pass.
**Ongoing**: rolling **365 days** retention via monthly cron. Generous because the live volume is so small (~10 KB/month) — the storage cost is zero and a year of behavioral lookback helps debugging.
Rationale for 365 (not 90): activity-log telemetry's value tails off in weeks, but with ~80 rows/month current volume, the longer window costs nothing. Tune via the `@cutoff_date` parameter.

### `errors_tbl`
**Keep newest N rows** by ID watermark. Default `N = 1500` (≈ 3 years at current rate). Parameter-driven.
Rationale: 1,500 keeps room for regression detection across multiple deploy cycles while pruning ~70 MB of blob bloat (3,500 oldest rows × ~17 KB).
**Future fix (Go redesign or pre-migration):** add `created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP` column so time-based retention becomes possible. ID-watermark is a workaround.

---

## 3. Proposed scripts (review-before-ship)

### 3a. `bigbrother` — archive + one-time purge

```bash
# ARCHIVE (DBA runs first; verify file size before proceeding)
mysqldump -h 46.31.66.114 -u admin -p actorsbusinessoffice bigbrother \
  --where='`timestamp` < "2025-04-01"' \
  --single-transaction \
  > archive/bigbrother_pre_2025-04-01_20260517.sql
ls -lh archive/bigbrother_pre_2025-04-01_20260517.sql   # expect hundreds of MB
```

```sql
-- DRAFT migration: database/migrations/2026-05-17_audit_retention_bigbrother_onetime.sql
-- Idempotent batched purge. ONLY run after archive file is verified.
-- Set @cutoff to override; default 2025-04-01.
SET @cutoff := COALESCE(@cutoff, '2025-04-01');
SELECT CONCAT('Purging bigbrother rows where timestamp < ', @cutoff) AS plan;
SELECT COUNT(*) AS will_delete FROM bigbrother WHERE `timestamp` < @cutoff;

-- Batched DELETE to avoid long table locks. Loop until zero rows affected.
REPEAT
  DELETE FROM bigbrother WHERE `timestamp` < @cutoff LIMIT 10000;
  SELECT ROW_COUNT() AS deleted_this_batch;
UNTIL ROW_COUNT() = 0 END REPEAT;
-- (Implementation note: pure REPEAT/UNTIL isn't valid outside a procedure;
--  wrap in DELIMITER/CREATE PROCEDURE for actual run. Shown inline for review.)

SELECT COUNT(*) AS remaining_rows, MIN(`timestamp`) AS oldest FROM bigbrother;
```

```sql
-- DRAFT rollback (only meaningful if archive exists and was small enough to reload):
-- mysql -h ... actorsbusinessoffice < archive/bigbrother_pre_2025-04-01_20260517.sql
-- For 2.3M rows this is hours; treat as disaster-recovery only, not casual rollback.
```

### 3b. `bigbrother` — ongoing 365-day rolling

```sql
-- DRAFT migration: database/migrations/2026-05-17_audit_retention_bigbrother_rolling.sql
-- Wrap in a stored proc + schedule via CF cron monthly. Same batched-DELETE pattern.
DELETE FROM bigbrother
WHERE `timestamp` < DATE_SUB(CURDATE(), INTERVAL 365 DAY)
LIMIT 10000;
-- (Run repeatedly until ROW_COUNT()=0. Wrap in procedure for prod.)
```

### 3c. `errors_tbl` — archive + ID-watermark prune

```bash
# ARCHIVE: keep newest 1500; archive everything older
mysqldump -h 46.31.66.114 -u admin -p actorsbusinessoffice errors_tbl \
  --where='ID < ((SELECT MAX(ID) FROM errors_tbl) - 1500)' \
  --single-transaction \
  > archive/errors_tbl_pre_id_watermark_20260517.sql
```

Note: `mysqldump --where` cannot use subqueries on the same table; resolve the watermark first:
```sql
SELECT MAX(ID) - 1500 AS watermark FROM errors_tbl;  -- e.g. 3556
```
then pass `--where='ID < 3556'`.

```sql
-- DRAFT migration: database/migrations/2026-05-17_audit_retention_errors_tbl.sql
-- Parameter: @keep (default 1500).
SET @keep := COALESCE(@keep, 1500);
SET @watermark := (SELECT MAX(ID) - @keep FROM errors_tbl);
SELECT @watermark AS prune_below_id, COUNT(*) AS will_delete
  FROM errors_tbl WHERE ID < @watermark;

-- Batched DELETE (same procedure-wrap caveat as 3a):
DELETE FROM errors_tbl WHERE ID < @watermark LIMIT 500;
-- repeat until ROW_COUNT()=0
```

```sql
-- ROLLBACK: restore from archive.
-- mysql -h ... actorsbusinessoffice < archive/errors_tbl_pre_id_watermark_20260517.sql
-- Then OPTIMIZE TABLE errors_tbl; to reclaim space.
```

### 3d. Future fix: add `created_at` to `errors_tbl`
```sql
-- Separate migration (recommend doing in the Go cutover, not now):
ALTER TABLE errors_tbl
  ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  AFTER ID,
  ADD INDEX idx_errors_tbl_created (created_at);
-- Backfill existing rows: NULL → leave at default (they'll all be "now");
-- can't recover true creation times. Document this caveat.
```

---

## 4. Operating procedure

1. **Cliff investigation** for `bigbrother` (owner of the logging stack): determine whether the April 2025 volume drop was intentional or a regression. If regression, fix the logger before retention work; if intentional, document and proceed.
2. **tao-gatekeeper review** of these scripts (separate pass from the May 2026 audit ship-gate).
3. Run on dev first; paste row counts pre/post.
4. mysqldump archive on prod; verify file sizes; **store off-server.**
5. Run purge on prod (off-hours; batched DELETE; monitor lock waits).
6. `OPTIMIZE TABLE bigbrother; OPTIMIZE TABLE errors_tbl;` to reclaim disk after the large delete.
7. Schedule `3b` (rolling bigbrother retention) as a monthly CF cron.

---

## 5. Out of scope here
- The dev-side `cache_contact_*` work (suggested as in-flight JOB D replacement) — informs the Go redesign, not retention.
- Import-subsystem staging-table retention (Phase 0 §3 surfaced `import_v3_facts` 25 MB / 157k rows — also a candidate). Add to a follow-up retention pass once these two land.
- Compressing `errors_tbl.rootCauseStackTrace`/`generatedContent` (`ROW_FORMAT=COMPRESSED` cuts ~50%) — Go-redesign option; not appropriate for an in-place CF-era change.
