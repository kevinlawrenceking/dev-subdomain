# WO-1 PROD apply — schema promotion PROOF (V3_7 / V3_8 / V3_9)

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Env:** PROD `actorsbusinessoffice`
**Date:** 2026-07-08 · **Executor:** Kevin (HeidiSQL) · **Authorized:** Kevin 2026-07-08.
Runbook: `docs/plans/evidence/2026-07-08-prod-promotion-runbook.md`.

## Step 1 — V3_7 columns/indexes/photo widen — PASS
- `preflight` = "OK: contactdetails_tbl present in this schema"
- `new_cols_present_expect_12` = **12**
- `new_idx_present_expect_3` = **3**
- `contactPhoto` = `varchar` / **500**
- (pre-state `SHOW CREATE TABLE` archived showed contactPhoto varchar(255), no WO-1 cols — expected before-image.)

## Step 2 — V3_8 view rebuild — PASS (STOP-on-delta cleared)
- Live pre-rebuild view captured: DEFINER `kingk436@%`, **32** base columns, `WHERE IsDeleted = 0`.
  Reconcile vs V3_8's 32-col block = exact match, no 33rd column/alias/predicate → PROCEED.
- Post-apply: `security_type` = **INVOKER**, `is_updatable` = YES
- `view_col_count_expect_44` = **44**
- Smoke row (contactID 154962): new cols NULL, `contactPhone_src` = 'user' — reads through view.

## Step 3 — V3_9 three master FKs — PASS
- `preflight` = "OK: co_locations + co_contacts + companies present"
- Post-check (3 rows), all `ON DELETE SET NULL` / `ON UPDATE RESTRICT`:
  - `fk_cd_company_location` → `co_locations.colocid`
  - `fk_cd_master_coid` → `companies.coid`
  - `fk_cd_master_co_contact` → `co_contacts.id`

## Note — false-start
An initial run hit `ERROR 1072` on `company_location_id` because V3_9 was run before V3_7 had
landed the columns (operator misread order). Corrected by running V3_7 → V3_8 → V3_9 in sequence;
the 1072 was the FK step correctly refusing a missing-column base. No damage; no partial state.

## Prod state after this apply
Schema fully promoted. All pointer columns NULL (no linkage backfill yet). Data writes are separate,
independently gated:
- **Part A (V3_10)** hot-field backfill — pending decision D-a.
- **~380 tier-1 master linkage** — pending preview (`2026-07-08-wo1-linkage-384-preview.sql`) + decision D-b.
