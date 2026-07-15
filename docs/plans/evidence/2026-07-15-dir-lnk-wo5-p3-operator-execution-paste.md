# DIR-LNK-WO-5 — P3 OPERATOR EXECUTION CAPTURE (dev / new_development)

**Executor:** Kevin (HeidiSQL), `new_development`, 2026-07-15. **CC did not execute** (D-3 DML
exception expired with F-11; read-only pymysql side-checks only). Two sessions, in order, per
`DIR-LNK-WO5-P3-RUNBOOK.md`. This file is the verbatim-intent transcription of the operator's
execution paste; values below are **operator-attested**. Where the paste marked
`--- PASTE: … grid ---`, the operator distilled the grid to summary counts; the raw HeidiSQL grids
and the Relationships:All screenshot are **retained by the operator**.

---

## 1. STATE CHECK (session resumed next day; SESSION-1 WO4_30 already committed)
- `addendum_audit_rows = 64` (the 64 ADMIN_REPAIR rows persisted across the day; commit durable).

## 2. SESSION 1 — WO-4 ADDENDUM CLOSURE
- **BLOCK A, original run (pre-commit, prior day):** `phone_residue = 4`, `email_residue = 60`
  — exactly the P1 expectation. WO4_30 Step-3 sanity gate read `4 / 4 / 60 / 60` and **COMMITTED**.
- **BLOCK A, rerun (post-commit, this session):** `0 / 0` — no drift; residue gone.
- **BLOCK B (post-apply proof):** `residue_remaining_phone = 0`, `residue_remaining_email = 0`,
  `addendum_audit_rows = 64` under run_id **`WO4-DEV-ADDENDUM-20260715-01`** (64 ADMIN_REPAIR rows).
- `contactitems` untouched by design (addendum writes only `contactdetails_tbl` + audit).

## 3. G-8 BEFORE (pre-flip baseline, captured before 2.1)
- `EXPLAIN contacts_ss WHERE userid = 30`          → **10 subqueries, 3 filesort**.
- `EXPLAIN contacts_ss_followup WHERE userid = 30` → **10 subqueries, 3 filesort**.
- Pre-flip `col3/col4/col5` value listing captured (the long listing).
- **CAVEAT (operator):** timed `COUNT` durations were **not captured on either side** — one COUNT
  was lost to a batch-fragment paste mangle. G-8's substance is therefore proven by **plan
  comparison**, not wall-clock: the three filesort item-pick subqueries (phone/email/company) are
  eliminated post-flip and the plans are strictly lighter. Timing is not claimed.

## 4. FLIP EXECUTION — `database/wo5/WO5_01_views_dev.sql` (HeidiSQL quote-aware splitter)
- **6 of 7 executed statements succeeded** = `USE` + all **5 `CREATE OR REPLACE VIEW`**
  (`contacts_ss`, `sharez`, `sharezz`, `sharez_optimized`, `v_contacts_optimized`) — DDL echoes
  observed for the `sharez` / `sharezz` / `sharez_optimized` bodies.
- The **1 failure was a paste-fragment 1064** (`wup WHERE userid = 30`) — chat/statement-tail
  contamination in the editor, **zero schema effect**.
- **`utf8mb3` deprecation warnings** on apply = legacy charset refs **byte-preserved from the P1
  captures by design** (only the p/e/c source expression was swapped). Logged as a hygiene backlog
  note; not a WO-5 change.

## 5. G-8 AFTER (post-flip)
- `contacts_ss`:          **7 subqueries, ZERO filesort**; `COUNT = 979` (== before).
- `contacts_ss_followup`: **7 subqueries, ZERO filesort**; `COUNT = 68`.
- Delta: the 3 item-pick filesort subqueries removed on each; row cardinality unchanged (979).

## 6. FOLLOWUP MEMBERSHIP CLOSURE (no pre-flip COUNT existed for `_followup`)
- Architect recount vs **base tables** returned **75** — too wide: it joined `_tbl` and omitted
  `contacts_ss`'s own filtering (the `_tbl`-vs-view lesson again).
- **Closure:** replicated the view's **own definition verbatim** (`information_schema.VIEWS`
  `VIEW_DEFINITION`) with `userid = 30` → **68 EXACT** (== §5 post-flip COUNT). Membership is
  **enrollment-driven and flip-independent**.
- **WO-12 carry-forward note:** `contacts_ss_followup` predicates on **SystemType + suStatus only**;
  `IsDeleted` filtering is **inherited from the joined views, not explicit**. Record this in the prod
  family rebuild.

## 7. BLOCK C + ORACLE (post-cutover delta re-measure)
- Detail grids captured (retained by operator). Summary, inverse-direction mismatch check:
  - `phone_mismatch = 0`, `email_mismatch = 0`, `company_mismatch = 0`.
  - `goes_blank` = **exactly the addendum set** (the 64: 4 phone + 60 email; e.g. contact `130647`
    email photographed blank in transition).
  - `changes_val = 0` — **satisfied** (nothing shows a *different* value; the only movement is the
    intended value→blank cleanup from the addendum).

## 8. HARMONIZED IDS (R-1) — 8 unconsumed `v_contacts_optimized` alpha-pick divergences
- Post-flip, **all 8 serve the SoT `contactCompany` column** (the dead view's alpha-pick opinion is
  gone): `130878, 130885, 130891, 130944, 131069, 131089, 131235, 131294`. Harmonized-by-cutover,
  not user-visible (no live CFM consumer).

## 9. EYEBALL — Jodie pass (Relationships:All, user 30): **PASS**
- Full-page screenshot, architect row-level verify:
  - Footer **"Showing 1 to 500 of 979 entries"** (== `contacts_ss` COUNT).
  - Value rows match the DB capture: `132214` BFR Management, `131171` aj@ajwedding.com,
    `131680` SH Entertainment, `131068` Criminal Minds.
  - Blanks render blank; partial rows correct; family tabs present.
- Screenshot **retained by operator**.

## 10. SESSION INCIDENTS (no schema/data effect)
- **Three batch-fragment 1064s** from paste contamination (chat text / statement tails); **zero
  schema or data impact** each. Statement-at-a-time + cleared-editor discipline adopted mid-session.
- **One architect side-check error chain** (read-only): guessed column `fusystemtypeid`, guessed
  literal `'Followup'`, `_tbl`-vs-view recount — all resolved by look-don't-guess; **no DB effect**.

---

**Channel:** SESSION 1 + SESSION 2 both operator-run (HeidiSQL). CC read-only pymysql
(`kingk436@%`, MySQL 8.0.41) for side-checks only. No prod. No push executed by CC.
