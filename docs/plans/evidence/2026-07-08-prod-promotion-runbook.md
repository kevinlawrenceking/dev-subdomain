# WO-1 PROD Promotion Runbook — Master Contact Directory

**Binding:** TAO / `dev-subdomain` / branch `dev`
**Env:** PROD — `actorsbusinessoffice` (DSN `abo`)
**Date:** 2026-07-08 · **Author:** CC · **Executor:** Kevin (HeidiSQL / mysql CLI)
**Authorization:** Prod promotion verbally authorized by Kevin 2026-07-08 ("lets update production").
**Tooling:** **HeidiSQL for every step** — **NOT phpMyAdmin** (it rewrites `INVOKER`→`DEFINER`; F19).
Run each `.sql` via **File ▸ Load SQL file…** into a query tab, then **Execute (F9)** — HeidiSQL honors
the in-file `DELIMITER //` blocks and runs the whole script. Do **not** use the visual View editor for
Step 2 (it can rewrite `SQL SECURITY`); run the raw file. HeidiSQL shows each `SELECT`/`SHOW` result in
its own grid.
**Privilege:** `kingk436@%` holds `ALL PRIVILEGES` on `actorsbusinessoffice` (oneliner-A). No grant work.

> **CC cannot execute any of this** — no DB connection in the agent environment. Kevin runs every step
> in HeidiSQL; paste results back and CC processes them / gates the next step.

---

## Scope decisions (confirm before Step 3+)

- **D-a — Part A hot-field backfill (V3_10) on prod?**  **CC recommends YES.** Without it the
  12 new columns land empty for all existing prod contacts and only populate going forward.
  Part A denormalizes contactPhone/Email/Company for existing contacts — the payload that makes
  the columns useful now. It is a large write (~46k active contacts) but idempotent + rollback-backed
  and dev-proven (276/292/435 == ceiling). *If deferred, skip Step 4.*
- **D-b — "~380 safe records" master-linkage backfill.**  Person + company pointers only
  (`master_co_contact_id`, `master_coid`); **office pointer deferred** (no primary-office flag; UI fills
  it later). Gated on the preview (Step 5) proving the exact set. **CC recommends this shape.**

---

## Step 1 — Schema: columns + indexes + photo widen  (DDL, safe in business hours)

```sql
USE actorsbusinessoffice;
SHOW CREATE TABLE contactdetails_tbl;       -- archive pre-state (copy the cell to evidence)
```
Then Load + Execute `database/migrations/V3_7__master_directory_wo1_contactdetails_columns.sql`.
PASS = `new_cols_present_expect_12` → **12**, `new_idx_present_expect_3` → **3**,
`contactPhoto` → `varchar/500`. Replay-safe (re-run = identical no-op).

## Step 2 — Schema: view rebuild (STOP-on-delta reconcile FIRST)

```sql
USE actorsbusinessoffice;
SHOW CREATE VIEW contactdetails;            -- REQUIRED reconcile vs V3_8 (copy the cell)
```
**STOP-on-delta:** prod's live view differs from dev. The ONLY acceptable deltas are the 12 additive
WO-1 columns (absent from the live view) + the intentional DEFINER→INVOKER flip. Any *other* column /
alias / predicate delta → **halt, report, do not apply.** If clean, Load + Execute
`database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql`.
PASS = `view_col_count_expect_44` → **44**, and the INVOKER assertion returns **PASS**
(a FAIL = it landed DEFINER → DROP the view and re-run the file in a raw HeidiSQL query tab,
not the visual View editor).

## Step 3 — Schema: foreign keys  (run pre-flight, expect all 0)

Pointers are all NULL on prod (no backfill linkage yet), so the four orphan/sentinel checks in the
V3_9 header trivially return 0. Run them (`USE actorsbusinessoffice;` first), confirm 0, then
Load + Execute `database/migrations/V3_9__master_directory_wo1_contactdetails_fk.sql`.
PASS = 3 FKs, each `DELETE_RULE = SET NULL`, `UPDATE_RULE = RESTRICT`.

> After Step 3 the schema is fully promoted. Steps 4–5 are DATA writes and are independently gated.

## Step 4 — Part A hot-field backfill  (only if D-a = YES)

`USE actorsbusinessoffice;` then Load + Execute
`database/migrations/V3_10__master_directory_wo1_backfill_partA.sql`.
PASS = each `*_filled` ≤ its matching `*_ceiling` (fills exactly the active-eligible set).
Rollback: `V3_10__..._ROLLBACK.sql`. Order-independent vs V3_9 (touches no FK column).

## Step 5 — "~380 safe records" master linkage  (PROOF-FIRST — preview gates the write)

This set is **prod-only** (computed from live prod data; not rehearsable on dev). No apply migration
is finalized until the preview proves the set.

1. Run the preview (READ-ONLY): Load + Execute
   `docs/plans/evidence/2026-07-08-wo1-linkage-384-preview.sql` (each section returns its own grid).
2. Paste results back. CC checks: Section 1 count ≈ 384; Section 0c pointers all-NULL;
   Section 3 `already_linked_would_skip` = 0; Section 0a/0b resolve the `userid` + `co_locations`
   unknowns; Section 2 keyed rows eyeballed for homonyms.
3. **Only then** CC finalizes `database/migrations/V3_11__..._backfill_linkage384.sql` (transactional,
   fill-blank-only on the two pointers, driven from the Section-2 set) + its ROLLBACK, and this runbook
   gets the apply step appended.

---

## Rollback order (full reverse)

1. `V3_9__..._fk_ROLLBACK.sql`  (FKs pin the columns — drop first)
2. `V3_8__..._view_ROLLBACK.sql`  (view back to 32 cols)
3. `V3_7__..._columns_ROLLBACK.sql`  (drop indexes + columns; narrow photo — blocked if any
   photo value now exceeds 255 chars, by design)

Data rollbacks (`V3_10`, future `V3_11`) are independent and run before the schema rollback if needed.

## Residual risk — master linkage (Step 5)

The tier-1 set is name-match-based against a dirty master (`companies` 100% Unverified). Company
corroboration cuts homonym risk hard, but it is not zero. Mitigations in force: uid≠11 exclusion,
exactly-1-imdbid clean gate, fill-blank-only, full keyed rollback set, person+company only (no
speculative office pick). This is why Step 5 is preview-gated, not a blind UPDATE.
