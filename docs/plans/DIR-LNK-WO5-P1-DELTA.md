# DIR-LNK-WO-5 — P1 RECON + DELTA REPORT (read-only). STOP for architect ratification.

**Binding:** TAO-MCD-P1 · `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain`
· branch `dev` · HEAD==origin/dev==`66e49781`. **Mode:** read-only. Zero code/DDL/DML/commit-of-code.
**Channel:** ratified pymysql read-only (`kingk436@%`, MySQL 8.0.41), SELECT/SHOW/USE whitelist;
prod = SHOW/information_schema only; password decoded in-memory, never printed.
**Live evidence (this session):**
- `evidence/2026-07-15-dir-lnk-wo5-p1-live-probe-output.txt` — fresh SHOW CREATE all views BOTH schemas + dev delta buckets
- `evidence/2026-07-15-dir-lnk-wo5-p1-changes-detail.txt` — the 64 changes_val rows (new_col vs old_disp)
- `evidence/2026-07-15-dir-lnk-wo5-p1-provenance.txt` — bucket-class + audit provenance of the 64

---

## 1. View DDL recon — FRESH, both schemas (supersedes July-9 capture per proposal)

Source signal per captured view (verbatim DDL in the probe-output file):

| view | new_development | actorsbusinessoffice |
|---|---|---|
| `contacts_ss` | **item-subquery** col3/4/5 (repoint) | item-subquery |
| `contacts_ss_target/_followup/_maint` | **inherit `contacts_ss` + `suStatus='Active'`** (no item subquery) | **old inline item-subqueries, no suStatus** (D-11 drift, fresh-confirmed) |
| `sharez` | reads `contactitems_tbl` (repoint) | item-subquery |
| `sharezz` | reads `contactitems_tbl` (repoint) | reads `contactitems_tbl` |
| `sharez_optimized` | **item-subquery + suStatus** (dev-only view) | not present |
| `v_contacts_optimized` | item-subquery (repoint) | present (form differs) |

**Key structural finding (fresh):** dev `_target/_followup/_maint` select from `contacts_ss` and
carry **no** item subquery of their own → **repointing dev `contacts_ss` cascades to the family
automatically; the dev family DDL needs no p/e/c edit.** Prod family = old inline subqueries → the
prod rebuild (inheritance + `suStatus` + column reads) is the **WO-12** event that produces the
accepted visible drop-off (RQ-6(a)/H-1). Prod views are OUT of WO-5.

**Dev view authoring scope (P2):** `contacts_ss`, `sharez`, `sharezz`, `sharez_optimized`,
`v_contacts_optimized`. Family views: verify pass-through of col3/4/5 at P2, expect no change.

## 2. Reader re-inventory — reconciled (G-6 signature grep vs WO-1 §3D)

**Class A — single-value display readers, IN WO-5 scope (migrate via the view repoint):**
- `include/contacts_ss.cfm:146` — selects `col3,col4,col5 FROM #contacts_table#` (the SS view). **View-consumer → inherits the repoint, NO code change.**
- `include/contacts_table.cfm` — DataTables header/serverSide fed by SS-view col5 (view-consumer).
- `include/contacts.cfm`, `contacts_all.cfm`, `contacts_all_tabs.cfm` — list pages (verify view-consumer at P2).
- `share/share_contact_details.cfm`, `include/card.cfm`, `include/qry/contacts_gallery.cfm` — share/gallery single-value surfaces reading `sharez`/`sharezz`/SS views (view-consumers; P2 verify).

**Class B — per-item management / editor surfaces, OUT of WO-5 read-cutover (WO-6 owns):**
- `include/contact_pane.cfm:69,105,117` — renders `#valueCompany#`/`#valuetext#` from a **per-item `contactitems` loop with edit pencils** (shows every item by design). Collapsing to the primary column would change its meaning. **Preserve; do not repoint here.**
- `include/contact_info.cfm` item loops (`:686-688` company; `:589,603` email/phone via `SELcontactitems_*`) — same class; the badge at `:691-704` already reads the primary column. P2 line-verify the split.

**NEW candidates surfaced by the signature grep, absent from WO-1 §3D — triage at P2 (not assumed in-scope):**
`include/contact_view.cfm`, `include/DetailPage.cfm`, `include/getmodalcontent.cfm`,
`app/admin-datatables-reference/ajax-server.cfm`, `sched/events_completed*.cfm`. Most are likely
Class B or non-display; each re-verified before inclusion.

**Pickers / merge / import (per WO-1 §3D — re-verify at P2):** `remoteaddC.cfm`/`remoteUpdateC.cfm`
+ `qry/remoteUpdateC.cfm`; `merge_contacts_interface.cfm`; `ContactItemService:520,557` import grid.
**Auditions readers** (`auditions.cfm:471`, `auditions_new.cfm:192`) brush the **C-1 held**
auditions code — flag; treat under cherry-pick discipline, not folded into WO-5 code casually.

## 3. Per-surface delta (current vs post-cutover), dev

| surface | current read | post-cutover | change | code? |
|---|---|---|---|---|
| List (contacts_ss + family, all list CFM) | col3/4/5 = item-subquery `ORDER BY primary_YN DESC LIMIT 1` | col3/4/5 = `contactdetails` columns | value source flips | **view only** (readers inherit) |
| Share/gallery/card | sharez/sharezz item reads | column reads | value source flips | view only |
| contact_pane (Class B) | per-item loop (all items) | **unchanged** | none | none (WO-6) |
| contact_info item loops (Class B) | per-item | **unchanged** | none | none (WO-6) |

## 4. HEADLINE FINDING — bucket (b): 64 dev contacts change to a DIFFERENT value

Fresh dev delta buckets (probe-output), 1571 active contacts:

| field | shows_now | shows_after | goes_blank | **changes_val** |
|---|---|---|---|---|
| Company | 436 | 436 | 0 | 0 |
| Phone | 276 | 276 | 0 | **4** |
| Email | 291 | 292 | 0 | **60** |

- **goes_blank = 0** — no contact loses its display in dev (unpopulated column ⇔ no active item).
  My earlier "mass dev blanking" worry is DISPROVEN.
- **changes_val = 64** — 4 phone + 60 email contacts display a **genuinely different** value
  post-cutover. **All 64 normalize-DIFFER, 0 presentation-only** (detail file): e.g.
  `john@gmail.com`↔`Jane@gmail.com`, `priscilla.odom@tubitv.com`↔`podom.home@gmail.com`,
  `(424) 555-2530`↔`(310) 555-2532`.

**This refutes WO-1 §5C's "0 differ."** §5C tested set-membership only (does the column value match
*some* item); it never tested display-position equality against the live `ORDER BY primary_YN DESC
LIMIT 1`. Per-surface delta (which the proposal mandated) catches 64 real display changes.

**Root cause (provenance-proven):**
- All 64 are **exception class**: Phone 4/4 `multi_zero_primary`; Email 59 `multi_zero_primary` + 1
  `multi_multi_primary`. Multiple *different* active items, no `primary_YN='Y'` (dev barely uses it)
  → today's `LIMIT 1` returns an **arbitrary** row while the column holds a different one.
- **0 of 64 carry a WO-4 `BACKFILL_FROM_CONTACTITEM` audit row** (master_audit_tbl has 15 rows
  total: 10 backfill + 5 admin_repair). **WO-4 was conformant** — it correctly skipped the exception
  class (it only writes canonically-empty cells; these were already non-empty).
- The values are **V3_10 Part A residue (2026-07-07)** — populated *before* the ratified engine +
  RQ rulings, using a looser rule that included the exception classes the engine now excludes.

**Consequence:** **dev is NOT a faithful preview of prod WO-12** for the exception class. Prod WO-12
runs the ratified engine on empty columns → exception contacts show **blank**; dev shows a
V3_10-chosen value that diverges from legacy display for these 64. The read cutover is *safe*
(deterministic, no crash, no blank-out) but surfaces a **data-provenance** issue, not a plumbing
defect.

**DECISION REQUIRED (architect):**
1. **Accept dev residue as cosmetic** — proceed; document dev≠prod preview for the exception class;
   P4 records the 64 as known V3_10 residue. (Lowest effort; dev display shows a real, if
   arbitrarily-chosen, value.)
2. **Engine-cleanup dev first** — null the exception-class residue on dev (ratified-engine
   selection: exception ⇒ blank) before the read cutover, so dev faithfully previews prod WO-12.
   (Cleaner preview; a small WO-4 addendum; interacts with RQ-5i retirement — confirm boundary.)
3. **Designate primaries** for these 64 (WO-9 correction territory) — out of WO-5/6 scope; defer.

CC recommendation: **Option 2** for a faithful preview, scoped as a declared WO-4 addendum
(dev-only, audited, rollback), *then* cut reads over — but this is the architect's call and the
reason for this STOP.

## 5. RQ-6(a) family evidence (dev)
Dev `_target/_followup/_maint` already carry `su.suStatus='Active'` and inherit p/4/5 from
`contacts_ss` (probe-output). WO-5 dev preserves this; **no dev-visible family filter change** at
cutover. The prod family still lacks `suStatus` — adopting dev's definition at **WO-12** is what
drops inactive-enrollment contacts off the prod tabs (accepted; WO-12 record).

## 6. G-1..G-8 status at P1
G-1/H-1 folded (hold stated). G-2 measured — bucket (b)=64, escalated above. G-3 pinned (RQ-6 a).
G-4 both `contact_info.cfm` in inventory. G-5 resolved (contactdetails VIEW, re-confirmed live).
G-6 signature grep run — expanded view set + new reader candidates reconciled. G-7 rollback design
carried to P2 (all-views script + code revert). G-8 perf spot-check scheduled P4.

## 7. PASS / OPEN per P1 criterion
- Fresh view DDL both schemas — **PASS** (probe-output).
- Full reader re-inventory incl. qry/DataTables/export — **PASS** (Class A/B split + new candidates).
- Flag readers whose semantics change — **PASS** (64 bucket-(b) + Class-B preservation).
- Per-surface delta — **PASS** (§3).
- **OPEN (architect):** disposition of the 64 exception-class divergences (§4); confirm Class-B
  exclusion + new-candidate triage set for P2; confirm dev family needs no DDL edit.

**STOP — awaiting architect ratification of this delta + the §4 decision.** No P2 authoring begun.
Docs-class only; local, unpushed.
