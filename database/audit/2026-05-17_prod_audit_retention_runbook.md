# DBA Execution Runbook — R12 Retention (bigbrother + errors_tbl)

Status: scripts SHIP-gated (tao-gatekeeper). **Nothing executed.** Order: cliff investigation → dev rehearsal → prod archive → prod purge → post-verify → schedule rolling cron. Hard rule: a purge **cannot** be undone by this script; data restore = mysqldump archive.

---

## Step 0 — Pre-flight (hard gates)

| Gate | Owner | How to close |
|---|---|---|
| `bigbrother` April-2025 volume cliff investigated | Logging-stack owner | Determine: intentional throttle / removed call sites / silent regression. Document outcome. **If regression, fix the logger first; do not purge.** |
| Off-box archive destination prepared | DBA | Path with capacity ≥ ~400 MB (bigbrother pre-cliff) + ~100 MB (errors_tbl). Off-server. |
| Off-hours window scheduled | DBA + ops | Large batched DELETEs + later `OPTIMIZE TABLE` ⇒ schedule outside business hours. |
| `errors_tbl.created_at` follow-up ticket filed | DBA / Go team | Issue tracker. So this ID-watermark workaround doesn't become permanent. |

---

## Step 1 — Dev rehearsal (`new_development`)

```sql
-- Install procedures (idempotent)
SOURCE database/migrations/2026-05-17_audit_retention_bigbrother.sql;
SOURCE database/migrations/2026-05-17_audit_retention_errors_tbl.sql;

-- Negative-path proofs (each MUST emit an ERROR row and NOT delete)
CALL prune_bigbrother_pre_cliff(NULL);
CALL prune_bigbrother_pre_cliff(DATE_ADD(CURDATE(), INTERVAL 1 DAY));
CALL prune_bigbrother_rolling(10);
CALL prune_errors_tbl(100);

-- Baseline counts on dev
SELECT COUNT(*) AS bb_rows, MIN(`timestamp`) AS bb_oldest FROM bigbrother;
SELECT COUNT(*) AS et_rows, MIN(ID) AS et_min, MAX(ID) AS et_max FROM errors_tbl;

-- Dry-run on dev (mysqldump archive verified first)
CALL prune_bigbrother_pre_cliff('2025-04-01');
CALL prune_bigbrother_rolling(365);
CALL prune_errors_tbl(1500);

-- Post counts
SELECT COUNT(*) AS bb_rows_after, MIN(`timestamp`) AS bb_oldest_after FROM bigbrother;
SELECT COUNT(*) AS et_rows_after, MIN(ID) AS et_min_after, MAX(ID) AS et_max_after FROM errors_tbl;

-- Idempotency proof
SOURCE database/migrations/2026-05-17_audit_retention_bigbrother.sql;
SOURCE database/migrations/2026-05-17_audit_retention_errors_tbl.sql;
-- expect: re-installs cleanly; PLAN counts now 0 if you re-CALL the procedures
```

**Paste:** every PLAN / DONE / ERROR row + the before/after counts. Smoke-test the app on dev (notifications, error-page render, any log viewer) — confirm nothing 1146s.

---

## Step 2 — Prod archive (`actorsbusinessoffice`)

```bash
mkdir -p archive

# bigbrother pre-cliff (~360 MB expected)
mysqldump -h 46.31.66.114 -u admin -p actorsbusinessoffice bigbrother \
  --where='`timestamp` < "2025-04-01"' --single-transaction \
  > archive/bigbrother_pre_2025-04-01_20260517.sql

# errors_tbl pre-watermark (~80 MB expected)
mysql -h 46.31.66.114 -u admin -p -BNe "SELECT MAX(ID)-1500 FROM actorsbusinessoffice.errors_tbl"
# -> e.g. 3556. Plug into next command:
mysqldump -h 46.31.66.114 -u admin -p actorsbusinessoffice errors_tbl \
  --where='ID < 3556' --single-transaction \
  > archive/errors_tbl_pre_id_3556_20260517.sql

ls -lh archive/*_20260517.sql   # confirm BOTH files non-zero and roughly the expected sizes
# Copy to off-box destination, verify checksums, THEN proceed.
```

---

## Step 3 — Prod purge

```sql
-- Install
SOURCE database/migrations/2026-05-17_audit_retention_bigbrother.sql;
SOURCE database/migrations/2026-05-17_audit_retention_errors_tbl.sql;

-- One-time pre-cliff purge (bigbrother). Paste PLAN + DONE rows.
CALL prune_bigbrother_pre_cliff('2025-04-01');

-- Rolling 365 (will be a no-op right after the pre-cliff if all >365 days old were pre-2025-04)
CALL prune_bigbrother_rolling(365);

-- errors_tbl watermark
CALL prune_errors_tbl(1500);

-- Post counts (record alongside Step 1 baseline)
SELECT COUNT(*), MIN(`timestamp`), MAX(`timestamp`) FROM bigbrother;
SELECT COUNT(*), MIN(ID), MAX(ID) FROM errors_tbl;
```

---

## Step 4 — Reclaim disk (off-hours; locks the table)

```sql
OPTIMIZE TABLE bigbrother;   -- minutes; locks; off-hours only
OPTIMIZE TABLE errors_tbl;
```

Re-check `information_schema.TABLES.DATA_LENGTH+INDEX_LENGTH` for both — expect substantial reduction.

---

## Step 5 — Schedule the rolling cron (bigbrother)

Wire as a **monthly** CF scheduled task. **CALL only**, do not re-SOURCE the install script in the cron path:

- CF Admin → Scheduled Tasks → New
- Name: `prune_bigbrother_rolling_monthly`
- URL/template: a tiny CFM that runs `<cfquery datasource="abo"><cfprocresult name="r" /><cfprocparam type="in" value="365" cfsqltype="cf_sql_integer"/>CALL prune_bigbrother_rolling(?)</cfquery>` (or equivalent `cfstoredproc`)
- Schedule: 1st of each month, 03:00 local
- Add cflog of the PLAN/DONE rows for audit.

Do **not** schedule `prune_errors_tbl` — it's ID-watermark, not time-based; better run quarterly by hand until the `created_at` future-fix lands.

---

## Step 6 — Rollback playbook

| Scenario | Action |
|---|---|
| Procedures broken; need to remove install | `SOURCE 2026-05-17_audit_retention_bigbrother_ROLLBACK.sql;` and the errors_tbl equivalent. Drops procedures only. |
| Need deleted rows back (regret / wrong cutoff) | `mysql -h ... actorsbusinessoffice < archive/bigbrother_pre_2025-04-01_20260517.sql` (and the errors_tbl archive). Hours-long for bigbrother. Treat as disaster-recovery, not casual rollback. |

---

## Gatekeeper-flagged things that are NOT script-enforced

- **Cliff investigation closure** is a Step 0 gate; the script cannot detect whether the logger is broken.
- **`OPTIMIZE TABLE`** is intentionally manual (it locks); never auto-run by the procedures.
- **Archive existence + off-box copy** is a DBA precondition. The procedures will happily delete rows whether or not the archive exists; that's why Step 2 is a hard sequence point.
- **Owner approval of `p_keep=1500` for `errors_tbl`** — adjust the parameter if 1,500 isn't right for your retention/regression-detection needs.

---

## Filed follow-ups

- [ ] `errors_tbl.created_at` ALTER (separate migration; preserves true creation time going forward).
- [ ] Next audit pass to cover import-staging retention (`import_v3_facts` 25 MB / 157k rows).
- [ ] `ROW_FORMAT=COMPRESSED` evaluation for `errors_tbl` (Go-redesign option; ~50% size cut on blobs).
