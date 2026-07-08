# WO-1 dev apply — V3_9 foreign keys (proof) + chain complete

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-07 · **Executor:** Kevin (HeidiSQL)
**Env:** dev — `new_development` (confirmed). Applied after the Part B backfill was abandoned, so
pointer columns are all NULL — orphan pre-flight passes trivially and the FKs simply enforce future
(UI-written) pointers.

## Orphan pre-flight — PASS (all 0)
`orphan_company_loc=0 | orphan_master_person=0 | orphan_master_coid=0 | zero_sentinel=0`

## V3_9 — 3 master FKs added — PASS
- `preflight` = "OK: co_locations + co_contacts + companies present"
- Post-check (all `ON DELETE SET NULL` / `ON UPDATE RESTRICT`):
  - `fk_cd_company_location` → `co_locations.colocid`
  - `fk_cd_master_co_contact` → `co_contacts.id`
  - `fk_cd_master_coid` → `companies.coid`

## WO-1 migration chain COMPLETE on dev
V3_7 (columns/indexes/photo widen) → V3_8 (44-col INVOKER view) → V3_10 (hot-field backfill Part A)
→ V3_9 (master FKs). All applied and verified on `new_development`.

## Deliberately NOT done
- **Master-linkage backfill (Part B)** — ABANDONED on evidence (real-user yield 1,429/384 after
  excluding the userid-11 22K master dump). Linkage moves to a going-forward UI feature; pointers
  populate over time via user-confirmed matches. See
  `docs/plans/evidence/2026-07-07-wo1-backfill-partB-outcome.md` + memory.
- **Prod promotion** — separate authorized deploy. Since the backfill is abandoned, prod promotion is
  just schema (V3_7 columns + V3_8 view + V3_9 FKs) to give the future UI a place to write. Re-runs
  V3_8's STOP-on-delta safeguard against live prod first.
- **D-A** — dev `contactitems` root@ DEFINER INVOKER rebuild — still open.
