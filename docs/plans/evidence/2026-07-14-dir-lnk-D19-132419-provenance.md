# D-19 — Contact 132419 bridge-provenance inspection (READ-ONLY addendum)

**Date:** 2026-07-14 · **Relay:** DIR-LNK-WO-2 item 3 · **Mode:** read-only (does NOT block V3_12 migration commit `1efce776` or Phase-3 apply). Does not modify `c9fcc955`.

## Evidence (dev, ratified read channel)
**Q1 `contactdetails_tbl` 132419:** userID **30** (setup-wizard test user), master_co_contact_id 3518, master_coid 6115, `contactCompany='Morman Boling Casting'`, `contactCompany_src='master'`, `master_linked_date=2026-07-12 21:55:30`, `master_last_sync=2026-07-13 09:38:18`.

**Q2 Company `contactitems` for 132419** (2 rows; both `valueCompany='Morman Boling Casting'` = master coName, `valueType='Company'`, `primary_YN='N'`, `itemLastUpdated=NULL`):
| itemID | IsDeleted | itemStatus | itemCreationDate |
|---|---|---|---|
| 312620 | 1 (soft-deleted) | Active | 2026-07-12 21:55:29 |
| 312621 | 0 (ACTIVE) | Active | 2026-07-13 09:38:18 |

**Q3 scoped bridge candidate predicate** → matches **itemID 312621** (active).
**master_link.log:** operator pull **PENDING** (not yet arrived). Classification below rests on timing + lifecycle evidence, which item 3 accepts independently.

## Analysis
- `312620` created **21:55:29** ≈ `master_linked_date` **21:55:30** (same first-link operation, ~1s) → bridge `createCompanyItem` at first link; later soft-deleted (unlink / re-link F-3 path).
- `312621` created **2026-07-13 09:38:18** **== `master_last_sync` 09:38:18 (exact second)** → bridge `createCompanyItem` at the re-link/sync operation (after 312620 soft-deleted, `qItems.recordCount=0` → create branch, not rename).
- **Bridge signature confirmed:** `valueCompany` EXACTLY = master coName; `valueType='Company'`; `primary_YN='N'` (bridge never sets primary); never user-edited (`itemLastUpdated=NULL`); the entire Company-item lineage on this contact **originates at link operations** (no pre-link equivalent user item); test-contact provenance (userID 30). Complete bridge lifecycle: link→create 312620 → unlink softdelete → relink create 312621.

## Classification (item 3 criteria)
- **itemID 312621 (active): PROVEN bridge-created** — item creation timing tied to the link operation (`itemCreationDate == master_last_sync`, exact second), complete bridge lifecycle, exact master-name match, no pre-link equivalent user item, test-contact provenance. → **WO-11 cleanup target.**
- **itemID 312620:** bridge-created (first link) but **already soft-deleted** → no WO-11 action.
- Reminders honored: the owner userID (30) is not proof of who linked; a matching item + link log alone would be insufficient — but the **exact creation-time coincidence with the sync operation plus the full bridge lifecycle** is repository-grounded proof. Operator `master_link.log` pull (pending) should corroborate a LINK line `itemAction=created` at 09:38:18; corroborating, not required.

## WO-11 register update
**ADD (first proven target): contact 132419 / itemID 312621** — active bridge-created Company `contactitems` row, PROVEN.
- The **snapshot COLUMN** on 132419 (`contactCompany`, `_src='master'`) is handled by the standard WO-3/4/7 path (per R-A2, `c9fcc955`), NOT WO-11.
- R-A2 fixtures **128621 / 102009 remain NOT WO-11 targets** (predicate = 0; `c9fcc955`).
- WO-11 still populates its full register by running the candidate predicate fleet-wide + per-row provenance (proven-bridge rule); this addendum records one proven case, not the complete register.
