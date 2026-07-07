# WO-0b Addendum B — abod (dev) pane: V3_8 reconcile + drift register

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-07 · **Author:** CC
**Source:** `docs/plans/evidence/2026-07-07-wo0b-pane-abod.txt` (partial: views + `contactdetails_tbl`).
**Companion to:** WO-0b Addendum (abo, 2026-07-04) in `WO0-PROOF-BUNDLE.md`.

---

## 1. V3_8 33-vs-32 RECONCILE — **RESOLVED → 32. STOP-on-delta = PROCEED.**

Live DEV `contactdetails` view column list compared against V3_8's reconstructed 32-column
block (`V3_8__...view.sql:84-115`):

- **32 columns, exact names, exact ordinal order, identical predicate.** Live view ends
  `…imdbid, recordname, avatar_yn` `FROM contactdetails_tbl WHERE (IsDeleted = 0)`; V3_8's
  existing-column block reproduces this **byte-for-byte**.
- **No 33rd column.** The abo-pane "33-col" note was a miscount; the base table and the view
  both enumerate **32**. The `recordname` VIRTUAL GENERATED col and `IsDeleted` are both
  present and accounted for (positions 31 and 21).
- **Only deltas vs the live view:** (a) the 12 additive WO-1 columns (absent from live → added
  by V3_8 = expected), (b) `SQL SECURITY DEFINER → INVOKER` (intentional, F19).

Per V3_8's own gate (`:39-46`): "Only difference is the 12 additive WO-1 columns being ABSENT
from the live view → expected; proceed." → **V3_8 comes off DRAFT for dev apply.** The 44-col
target = these 32 + 12. No re-emit required. (Prod apply re-runs the same `SHOW CREATE VIEW`
STOP-on-delta at promotion, per the runbook Step 0 — dev reconcile does not pre-clear prod.)

---

## 2. Drift register (dev vs prod / vs plan)

| ID | Finding | Impact |
|----|---------|--------|
| F-A1 | `contactPhoto` = **varchar(255)** on dev | A1 widen-to-500 **still required** (V3_7 does it). Confirmed live, not a no-op. |
| F-rec | `recordname` = **varchar(500) GENERATED ALWAYS AS (`contactFullName`) VIRTUAL** on dev | Matches prod (D1/C3). WO-4 drop-the-4-writers still applies; no change here. |
| F-coll | **No collision** — none of the 12 WO-1 columns exist on dev | V3_7 Step-0 preflight (`new_cols=12` after add) will pass cleanly. |
| F19 | **All 8 dev views are `DEFINER=kingk436@%` / `SQL SECURITY DEFINER` / `ALGORITHM=UNDEFINED`** | Matches prod's DEFINER pattern (prod's lone INVOKER = `taousers`). V3_8 deliberately converges `contactdetails` → INVOKER. Post-apply, `contactdetails` becomes the 2nd INVOKER view. Registered. |
| F-conn | **`collation_connection` drift across views:** `contacts_ss_target` = **`utf8mb4_0900_ai_ci`** vs `utf8mb4_unicode_ci` (contacts_ss/_followup/_maint) vs `utf8mb4_general_ci` (contactdetails, contactitems, sharez, sharezz) | Creation-time connection collation only (cosmetic; affects in-view string-literal comparison). `contacts_ss_target` is the outlier — likely rebuilt under a newer client. **Not blocking.** Register; keep the mysql-CLI connection collation consistent when applying V3_8. |
| F-dep | **`contacts_ss` / `_followup` / `_maint` / `_target` read `FROM contactdetails`** (the VIEW); `sharez`/`sharezz` read `contactdetails_tbl` (base) | V3_8 `DROP VIEW` + `CREATE VIEW` leaves a sub-second window where `contactdetails` is absent; the 4 dependent views error if queried mid-window. **Acceptable in the A4 same-window maintenance apply.** All columns the dependents reference (`contactID, contactFullName, userID, contactStatus`) persist → **no post-rebuild break.** |
| F-sharezz | **`sharezz` (double-z) EXISTS on dev** | Confirms D7 resolution (the actually-used view is real) on dev as well as prod. |

---

## 3. Still pending (NOT gating V3_8 — feeds F14–F18 drift + V3_9 FKs)

Kevin's paste covered the views + `contactdetails_tbl`. Remainder of the one-grid/heidi pane
still to capture for the full drift diff:
- `contactitems_tbl` DDL + `itemstatus`/`valuetype` distributions (A-Q5).
- **Master tables** `co_locations` / `companies` / `co_contacts` DDL + counts + indexes (A-Q8)
  — needed for **V3_9 FK** targets (`colocid` / `id` / `coid`); V3_9 is deferred post-backfill anyway.
- Master-table schema presence (A-Q9), collations summary (A-Q18), timezone (A-Q19), `SHOW GRANTS` (A-Q9b).

None block V3_8. They can ride the next abod pane pass (`…onegrid.sql` returns them all in one grid).

---

## 4. Verdict

- **V3_8:** reconciled → **READY for dev apply** (off DRAFT). Recommend flipping the file's DRAFT
  header to RECONCILED with a pointer to this Addendum — **that edit is a migration-file (code)
  change and is held for Kevin's go** per the commit-authorization norm.
- **V3_7:** confirmed still-needed (contactPhoto widen) + collision-free preflight.
- **WO-1 dev exec:** the view/base drift for `contactdetails` is now registered; remaining pane
  captures (master tables) are for V3_9, which is deferred. Dev Step-1 can proceed once Kevin
  approves, on the standard runbook gates.
