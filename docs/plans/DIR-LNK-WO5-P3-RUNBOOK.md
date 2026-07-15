# DIR-LNK-WO-5 — P3 CONSOLIDATED OPERATOR RUNBOOK (dev / new_development)

**Binding:** TAO-MCD-P1 · branch `dev` · **DEV ONLY (`new_development`)**. **Executor: Kevin (HeidiSQL).**
CC does not execute — the D-3 DML exception expired with F-11. Two sessions, in order. Do not start
SESSION 2 until SESSION 1 is COMMITTED and verified. No prod. No push.

**Scripts referenced (committed this turn; SHAs in the P2 package report):**
- `database/backfill/wo4/WO4_31_addendum_verification.sql` (BLOCK A pre-flight / B post / C delta)
- `database/backfill/wo4/WO4_30_addendum_residue_cleanup.sql`
- `database/backfill/wo4/WO4_39_addendum_rollback.sql` (only if reverting)
- `database/wo5/WO5_01_views_dev.sql`
- `database/wo5/WO5_01_views_dev_ROLLBACK.sql` (only if reverting)

Before running WO4_30 / WO4_39: set the `run_id` date suffix to today's apply date (`WO4-DEV-ADDENDUM-<YYYYMMDD>-01`).

---

## SESSION 1 — WO-4 ADDENDUM (null the 64 exception-class residue)

**1.1 Pre-flight drift guard** — run `WO4_31_addendum_verification.sql` **BLOCK A**.
- EXPECT: `phone_residue = 4`, `email_residue = 60`.
- If either differs → data drifted since P1 (2026-07-15). **STOP. Do not run WO4_30.** Paste the result and report.

**1.2 Cleanup** — run `WO4_30_addendum_residue_cleanup.sql` (one transaction).
- Read the **Step-3 sanity SELECT** before COMMIT. EXPECT exactly: `audit_phone=4, nulled_phone=4, audit_email=60, nulled_email=60`.
- COMMIT **only** if all four equal. Otherwise `ROLLBACK;` and paste the result.

**1.3 Post-apply proof** — run `WO4_31` **BLOCK B**.
- EXPECT: `residue_remaining_phone=0`, `residue_remaining_email=0`, `addendum_audit_rows=64`.
- (contactitems untouched by design — no query needed; the addendum writes only `contactdetails_tbl` + audit.)

---

## SESSION 2 — WO-5 VIEW FLIP (read cutover) + P4 acceptance

**2.0 G-8 BEFORE (capture the pre-flip baseline — do this BEFORE 2.1).**
```sql
-- plan (expect correlated-subquery reads on contactitems)
EXPLAIN SELECT contactid, col3, col4, col5 FROM contacts_ss          WHERE userid = 30;
EXPLAIN SELECT contactid, col3, col4, col5 FROM contacts_ss_followup WHERE userid = 30;
-- timing: run each 3x, note HeidiSQL's Duration (or use profiling). userid 30 = 979 contacts.
SELECT SQL_NO_CACHE contactid, col3, col4, col5 FROM contacts_ss          WHERE userid = 30;
SELECT SQL_NO_CACHE contactid, col3, col4, col5 FROM contacts_ss_followup WHERE userid = 30;
```
Record the two EXPLAIN plans + median durations as **BEFORE**.

**2.1 Flip** — run `WO5_01_views_dev.sql`.
- **Use HeidiSQL's quote-aware execution** (run the file / whole statements). `contacts_ss` contains
  `;` inside `'&nbsp;'` literals — do NOT pre-split on `;` (WO-4 lesson 7697d37b).
- 5 `CREATE OR REPLACE VIEW` statements; each should report success. Family views are NOT touched (they inherit).

**2.2 Cutover verification** — run `WO4_31` **BLOCK C** (delta re-measure).
- EXPECT: `Phone changes_val=0, goes_blank=4`; `Email changes_val=0, goes_blank=60`. This is the intended
  state — the 64 go value→blank by the addendum; nothing shows a *different* value.

**2.3 G-8 AFTER (same queries as 2.0).** Re-run the four statements from 2.0.
- EXPECT plans now read `contactdetails` columns directly (no per-row contactitems subquery); durations
  **≤ BEFORE** (a win, especially at 979 rows). Record as **AFTER**; note the delta. Any regression → report.

**2.4 P4 per-surface acceptance.**
```sql
-- (a) list surface shows the primary-column values (spot check)
SELECT contactid, col3 AS phone, col4 AS email, col5 AS company FROM contacts_ss WHERE userid = 30 LIMIT 25;
-- (b) share surface Company via sharezz == column (spot check one shared contact)
SELECT contactid, Company FROM sharezz LIMIT 25;
-- (c) the 8 v_contacts_optimized Company divergences are HARMONIZED-by-cutover (R-1; unconsumed view).
--     In the LIVE surfaces they now read the SoT column; confirm contacts_ss agrees:
SELECT contactid, col5 AS company FROM contacts_ss
 WHERE contactid IN (130878,130885,130891,130944,131069,131089,131235,131294);
```
- (a) EXPECT: displayed Phone/Email/Company == the `contactdetails` columns; contacts without a primary show blank.
- (c) EXPECT: `col5` = the canonical `contactCompany` for all 8 (the dead view's alpha-pick opinion is gone).

---

## ROLLBACK (only if a step fails and you choose to revert)
Order matters — **views first, then data**, so no reader is ever pointed at a column mid-rollback:
1. `database/wo5/WO5_01_views_dev_ROLLBACK.sql` (restores the prior item-subquery view definitions).
2. `database/backfill/wo4/WO4_39_addendum_rollback.sql` (restores the 64 residue values from the audit
   rows' `old_value`; set `@fwd` to the applied forward run_id). Sanity: `fwd_rows = restored_cols = 64`.

---

## DELIVERABLE BACK TO CC
Paste, per step: BLOCK A result; WO4_30 Step-3 counts + COMMIT/ROLLBACK; BLOCK B; the 5 view success
lines; BLOCK C delta; G-8 BEFORE/AFTER plans + durations; the 2.4 spot checks. CC assembles P4
evidence → P5 bundle → STOP. **HOLD — awaiting Kevin's execution paste.**
