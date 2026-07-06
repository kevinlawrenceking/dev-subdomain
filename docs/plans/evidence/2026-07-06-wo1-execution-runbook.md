# WO-1 Execution Runbook — Master Contact Directory (dev-first)

**Binding:** TAO / workstream DIRECTORY / dev-subdomain / branch `dev`
**Clearance:** WO-0b Decision Memo **CLEARED WITH AMENDMENTS (A1–A6)**, 2026-07-06.
DIR-WO-1 pack **ACCEPTED WITH RULINGS + R1–R3** (2026-07-06).
**Status of this artifact:** authoring deliverable **for review**. Nothing here has
been executed. Deliver the pack, then **HOLD AT THE GATE**.

## Pack contents & naming (R1)

**R1 escape hatch invoked — V-prefix kept, not renamed to date convention.**
`database/migrations/` is a coherent Flyway-style versioned series with `_ROLLBACK`
siblings: `V2_0`, `V2_1`, `V3_0`…`V3_6` already exist in-repo. V3_7/8/9 continue it
exactly. The date convention (`database/YYYY-MM-DD_*.sql`) is used only in the
`database/` **root** for ad-hoc one-offs, not in the `migrations/` subfolder.
Renaming would fragment the versioned folder. Cited: `V3_3__import_v3_columns_add_mapping_fields.sql`,
`V3_4__contactitems_valuetext_enlarge.sql`, `V3_5/V3_6__noteslog_*` (+ ROLLBACKs).

| # | File | Purpose |
|---|------|---------|
| a | `database/migrations/V3_7__master_directory_wo1_contactdetails_columns.sql` | Forward: 12 columns + 3 indexes + contactPhoto widen (idempotent) |
| b | `database/migrations/V3_7__..._columns_ROLLBACK.sql` | Rollback for (a) |
| c | `database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql` | `contactdetails` view rebuild (44 cols, INVOKER) — **DRAFT until reconciled** |
|   | `database/migrations/V3_8__..._view_ROLLBACK.sql` | Rebuild view at original 32 cols |
| d | `database/migrations/V3_9__master_directory_wo1_contactdetails_fk.sql` | FK follow-up (3 FKs, SET NULL / RESTRICT) — deferred |
|   | `database/migrations/V3_9__..._fk_ROLLBACK.sql` | Drop the 3 FKs |

Tooling: **mysql CLI only** (NN#12 / A4). No phpMyAdmin — it silently rewrites
`SQL SECURITY INVOKER` to `DEFINER` (finding F19 / tickets-view incident).

**Privilege precondition (cited once, applies to every apply step below):**
`kingk436@%` holds `ALL PRIVILEGES` (incl. `REFERENCES`, `ALTER`, `INDEX`,
`CREATE VIEW`) on **both** `actorsbusinessoffice` and `new_development` — identical
on both DSNs (abo/abod is connection/default-schema only, not a privilege boundary).
Evidence: `docs/plans/evidence/2026-07-04-wo0b-oneliner-A-grants.txt` (Q9b). No
grant work is required before any step.

## ⛔ Pre-dev-execution gate (ruling #2 / abod drift)

**F14–F19 (dev↔prod hot-table DDL drift) are NOT yet on disk.** The abod drift pane
was never captured and Addendum B was never written to `WO0-PROOF-BUNDLE.md`.
Authoring is **not** blocked, but **before Step 1 dev execution** the abod pane must
be run, saved to evidence, Addendum B written, and F14–F19 registered with a
"none block" confirmation. Kevin is running the pane; process it on paste. Relevant:
- **F17 (view drift):** the `contacts_ss_*` views are stale in dev; not touched by
  WO-1. `contactdetails` is *not* in the F17 stale set, but Step 2 still STOPs on any
  delta. The dev `SHOW CREATE VIEW contactdetails` in that pane may resolve the
  33-vs-32 column question directly.
- **F19 (DEFINER drift):** motivates the deliberate INVOKER rebuild in V3_8.

## Step 0 — Baseline capture (dev)

```
USE new_development;
SHOW CREATE TABLE contactdetails_tbl\G     -- archive pre-state
SHOW CREATE VIEW  contactdetails\G          -- REQUIRED: reconcile vs V3_8 (STOP-on-delta)
```

**Reconcile V3_8 before applying it — STOP-on-delta (ruling #2).** The abo pane
summarized the live view as an "enumerated 33-col list"; the base table has 32
columns. Resolve the 33-vs-32 gap to a **NAMED column** before Step 2:
- Only difference is the 12 additive WO-1 columns absent from the live view → proceed.
- A 33rd column that is a base column V3_8 omitted → add it by name, re-emit, report.
- The 33rd is an alias/expression not in the base DDL → **STOP**; grep its consumers
  across the app before any rebuild; do not drop it silently.
- Any predicate/alias delta beyond the additive new columns → re-emit V3_8 and report;
  **no apply**.

## Step 1 — Columns + indexes + photo widen (dev)

```
USE new_development;    -- grants precondition: kingk436@% ALL PRIVILEGES (oneliner-A)
SOURCE database/migrations/V3_7__master_directory_wo1_contactdetails_columns.sql;
```
Expected post-checks (emitted by the script):
- `new_cols_present_expect_12` → **12**
- `new_idx_present_expect_3` → **3**
- `contactPhoto` → `varchar` / `500`

Replay safety: run it a second time — every post-check stays identical (no-op).

**R3(c) — record the contactPhoto widen ALGORITHM/LOCK on dev (for prod window
planning).** The widen is `varchar(255)→varchar(500)` on utf8mb4. Both widths use a
2-byte length prefix (255×4 = 1020 bytes > 255, so already 2-byte; 500×4 = 2000 bytes,
still 2-byte), so MySQL 8 should perform it **in place with no table rebuild**. Confirm
and record the observed behavior on dev by running the widen once as an explicit probe
(outside the guarded script) and capturing what the server accepts:
```
-- probe: assert non-blocking in-place; note if the server rejects these clauses
ALTER TABLE contactdetails_tbl
  MODIFY COLUMN contactPhoto varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  ALGORITHM=INPLACE, LOCK=NONE;
-- also capture timing and, if useful, performance_schema / SHOW PROCESSLIST during run
```
Record: algorithm accepted (INPLACE vs COPY), lock level (NONE vs SHARED), elapsed
time. Carry the observation into the prod window plan (prod row count is larger; an
INPLACE/LOCK=NONE result means the widen is safe during business hours).

## Step 2 — View rebuild (dev, SAME window as Step 1) — A4

Only proceed if Step 0 reconcile passed (no blocking delta).
```
USE new_development;    -- grants precondition: CREATE VIEW granted (oneliner-A)
SOURCE database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql;
```
Expected:
- `preflight` → "OK … rebuilding"
- `view_col_count_expect_44` → **44**
- smoke SELECT returns one row with the new columns present (NULL is fine pre-backfill)

**R3(a) — post-apply INVOKER assertion (must PASS before continuing):**
```
SELECT CASE WHEN security_type = 'INVOKER' THEN 'PASS' ELSE 'FAIL' END AS invoker_assert,
       security_type
FROM information_schema.VIEWS
WHERE table_schema = DATABASE() AND table_name = 'contactdetails';
```
`invoker_assert` must be **PASS**. A `FAIL` means the view landed DEFINER (e.g. applied
through phpMyAdmin) — DROP and re-apply via mysql CLI (NN#12).

## Step 3 — dev functional smoke (no code changes in WO-1)

WO-1 is schema-only; **no service / dual-write code ships here** (A4: no WO-4
dual-write precedes the rebuild). Confirm the app still reads contacts through the
view (contact grid / gallery load) — the 12 new columns are additive and NULL, so
existing reads are unaffected.

## Step 4 — Backfill (SEPARATE WO) then FK follow-up (dev) — A2 / A5

Do **not** run V3_9 until the backfill WO has populated and validated the pointers.
- Backfill tie-break (A5, locked): `ORDER BY primary_YN DESC, itemID ASC LIMIT 1`.
- Map `co_contacts.coid = 0` (0-sentinel, F12) → **NULL** for `master_coid`.
- Run the four orphan / sentinel pre-flight queries in the V3_9 header — **all must
  return 0** — then:

```
USE new_development;    -- grants precondition: REFERENCES granted (oneliner-A)
SOURCE database/migrations/V3_9__master_directory_wo1_contactdetails_fk.sql;
```
Expected: 3 rows, each `DELETE_RULE = SET NULL`, `UPDATE_RULE = RESTRICT`.

## Step 5 — Prod promotion (only after dev sign-off)

Re-run Steps 0–4 with `USE actorsbusinessoffice;` (same `kingk436@%` grants apply —
oneliner-A). Before Step 2 in prod:
- Re-verify V3_8 carries **no schema qualifier** (A4 — dev→prod reintroduction hazard).
- Re-capture `SHOW CREATE VIEW contactdetails` in prod and re-run the Step 0 STOP-on-delta
  reconcile (prod's live view differs from dev; CREATE OR REPLACE self-converges it to
  the 44-col INVOKER form).
- Re-run the R3(a) INVOKER assertion after apply.
- Use the Step 1 R3(c) dev observation to size the prod widen window.

## Rollback order (full reverse)

1. `V3_9__..._fk_ROLLBACK.sql` (drop FKs — they pin the columns)
2. `V3_8__..._view_ROLLBACK.sql` (view back to 32 cols)
3. `V3_7__..._columns_ROLLBACK.sql` (drop indexes + columns; narrow photo — blocked
   if any photo value now exceeds 255 chars, by design)

## Notes for downstream WOs (not in scope here)

- **No `master_link_status` column** (registered plan deviation R2). Link state is
  derived: `master_co_contact_id IS NOT NULL`. WO-4/WO-5 service code must derive it.
- **`recordname` is VIRTUAL GENERATED** — WO-4 must never write it and must drop the
  4 existing writers (F1); A3 adds a per-writer reachability triage in WO-4 recon.
- Master-side indexing is a no-op (F11: `coName` already UNIQUE; person/location/coid
  already indexed) — no master-table DDL in WO-1.
