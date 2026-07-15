# DIR-LNK-WO-5 — P2 PACKAGE (authoring only, HELD). STOP for line review.

**Binding:** TAO-MCD-P1 · repo `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain`
· branch `dev` · HEAD `a7592171`. **Mode:** authoring only — nothing executed, no DDL/DML run, no
deploy, no push. Per the 2026-07-15 ratification relay (P1 RATIFIED; §4 OPTION 2; P2 GO).
**Channel note:** all SQL below is **operator-executed (HeidiSQL)**. CC does not execute — the D-3
DML exception expired with F-11 and does not renew for the addendum.

## File manifest (authored, HELD)
| file | purpose |
|---|---|
| `database/backfill/wo4/WO4_30_addendum_residue_cleanup.sql` | §4 Option-2 cleanup: null the 64 exception-class residue columns + 64 ADMIN_REPAIR audit rows |
| `database/backfill/wo4/WO4_31_addendum_verification.sql` | pre-flight drift guard (BLOCK A) + post-apply proof (BLOCK B/C incl. delta re-measure) |
| `database/backfill/wo4/WO4_39_addendum_rollback.sql` | audit-driven restore of the 64 residue values (append-only reversal rows) |
| `database/wo5/WO5_01_views_dev.sql` | repoint the 5 dev views to primary columns (INVOKER, no schema qualifiers, CREATE OR REPLACE) |
| `database/wo5/WO5_01_views_dev_ROLLBACK.sql` | restore all 5 prior view definitions verbatim (P1 live capture) |

## RUNBOOK — order of operations (operator, dev/new_development)
1. **WO4_31 BLOCK A** (pre-flight). Expect `phone_residue=4`, `email_residue=60`. Any other value = drift since P1 → **STOP**, do not apply.
2. **WO4_30** (addendum cleanup). Review the Step-3 sanity SELECT: must read `4 / 4 / 60 / 60`. COMMIT only if equal; else ROLLBACK and report.
3. **WO4_31 BLOCK B** (post-apply). Expect `residue_remaining_phone=0`, `residue_remaining_email=0`, `addendum_audit_rows=64`.
4. **WO5_01_views_dev.sql** (read cutover). CREATE OR REPLACE the 5 views. (Family views inherit — not touched.)
   - **In-literal-semicolon note (WO-4 lesson 7697d37b):** `contacts_ss` contains `'&nbsp;'` string
     literals with an embedded `;`. Run the file through HeidiSQL's quote-aware parser (or execute each
     `CREATE OR REPLACE …;` statement whole) — do **not** pre-split on `;` naively, or the `contacts_ss`
     statement truncates mid-literal.
5. **WO4_31 BLOCK C** (post-cutover delta re-measure). Expect **`changes_val=0`** both fields; `goes_blank`=4 (phone)/60 (email) — the intended value→blank cleanup state.
6. D-17 cache doctrine: since **zero CFM changed** (see below), no template-cache clear / liveness probe is required for readers; the view swap is live immediately for the SSP/share endpoints.
- **Rollback** (two-part): views → `WO5_01_views_dev_ROLLBACK.sql`; data → `WO4_39_addendum_rollback.sql`. Order for a full revert: views first (restore item-subquery reads), then data (restore residue) — so no reader is ever pointed at a column mid-rollback.

## VIEW REPOINT SPEC (WO5_01_views_dev.sql)
Machine-generated from the P1 live capture — only the p/e/c source expression is swapped; every other
expression (tags/col2*, Title, joins, ordering) is byte-preserved. All 5 set `SQL SECURITY INVOKER`
(RQ-6a/PC-4), no `DEFINER=`, no schema qualifiers (bleed doctrine), `CREATE OR REPLACE`.
**Validated (authoring time):** all 5 view SELECT bodies pass read-only `EXPLAIN` live on
`new_development` (2026-07-15) — executable, all column/alias refs resolve, incl. the two hand-written
structural views. Evidence: `evidence/2026-07-15-dir-lnk-wo5-p2-explain-validation.txt`.

| view | change | consumed by |
|---|---|---|
| `contacts_ss` | `col3→d.contactPhone`, `col4→d.contactEmail`, `col5→d.contactCompany` (tags/col2* unchanged) | `contacts_ss.cfm` SSP ← `contacts_table.cfm` ← `contacts_all*.cfm`, `contacts_gallery.cfm` |
| `sharez` | Company scalar subquery → `cd.contactCompany` | (no live CFM consumer found — legacy) |
| `sharezz` | Company scalar subquery → `cd.contactCompany` | `share_contact_details.cfm`, `share.cfm`, `remoteShareViewC.cfm`, `index.cfm`, `export.cfm` |
| `sharez_optimized` | Company → `d.contactCompany`; **drop `ci_company` LEFT JOIN** (also fixes multi-Company row duplication) | (no live CFM consumer — perf alternate) |
| `v_contacts_optimized` | add `contactCompany` to `base` CTE; Company → `b.contactCompany`; **drop `company_pick` CTE** | (no live CFM consumer — perf alternate) |

**Family views** `contacts_ss_target/_followup/_maint` are `SELECT … FROM contacts_ss cs` (confirmed in
both the live capture and `database/run-*-2026-04-02.cfm`) → they inherit col3/4/5 and are **intentionally
not redefined**. Prod family = old inline subqueries → rebuilt at **WO-12** (the accepted prod tab drop-off).

## CLASS-A READER DIFFS: **ZERO**
Every single-value p/e/c display path flows through a view. `contacts_ss.cfm` selects `col3/col4/col5
FROM #contacts_table#` (the view); the share CFMs `SELECT … FROM sharezz`; the gallery uses
`#contacts_table#`. None inline a p/e/c subquery. **The cutover is entirely in view DDL — no CFML
changes.** Consequence for H-1: there is no reader code to hold from prod; the prod cutover is the
WO-12 view flip alone.

## G-6 RECONCILIATION (grep signature vs inventory — zero unreconciled)
| candidate reader | classification | action |
|---|---|---|
| `contacts_ss.cfm`, `contacts_table.cfm`, `contacts_all.cfm`, `contacts_all_tabs.cfm`, `contacts_gallery.cfm`(+`qry/`) | Class-A view-consumer (reads `#contacts_table#`) | inherit repoint, **no code** |
| `share/{share_contact_details,share,remoteShareViewC,index,export}.cfm` | Class-A view-consumer (`FROM sharezz`) | inherit repoint, **no code** |
| `contact_pane.cfm`, `contact_info.cfm` item loops | Class-B per-item editor (shows all items) | **OUT** (WO-6) |
| `card.cfm`, `contact_view.cfm`, `DetailPage.cfm`, `getmodalcontent.cfm` | no single-value p/e/c subquery present | not a cutover target |
| `auditions.cfm`, `auditions_new.cfm` | item display, brush **C-1 held** auditions code | out of WO-5; cherry-pick discipline |
| `remoteaddC/remoteUpdateC`, `merge_contacts_interface.cfm`, `ContactItemService` import grid | write/edit/item surfaces | out (not display reads) |
| `admin-datatables-reference*`, `database/run-*-2026-04-02.cfm`, `verify-pending-fixes.cfm` | docs / historical view-rebuild scripts | not live readers |
**Unreconciled: 0.** No reader requires an inline-subquery repoint.

## UPDATED P4 BUCKET-(b) ENUMERATION (expected, post-addendum + cutover)
- **contacts_ss / family (Phone, Email):** `changes_val=0`; `goes_blank`=4/60 (the 64 → blank by cleanup — intended, not a defect). Evidenced by WO4_31 BLOCK C.
- **contacts_ss / sharez / sharezz (Company):** `changes_val=0` (measured live 2026-07-15: sharez/sharezz plain-LIMIT-1 Company pick == column for all 436).
- **`v_contacts_optimized` (Company):** measured `changes_val=8` (its `ORDER BY valueCompany` alpha-pick differs from the SoT column for 8 contacts). **Not user-visible — no live CFM consumer.** Harmonization-only: the cutover resolves these to the canonical column (§13.3 single-source). Logged; not addendum-treated (Company was not in the §4-ruled 64; these are non-canonical-view artifacts, not residue). Flag for architect note only.

## LINE-REVIEW CHECKLIST
1. WO4_30 scope = exactly the 64 (IDs enumerated; residue captured live into audit, not in-script). ✓ house pattern (WO4_10 shape, reversed).
2. View DDL: only p/e/c swapped, INVOKER, no DEFINER, no schema qualifiers, family untouched. ✓ machine-generated from capture.
3. Rollback: two-part (views verbatim + data audit-driven), both COMMIT-gated. ✓
4. Zero CFM diffs. ✓
5. Post-cutover P4 expectation: changes_val=0; the `v_contacts_optimized` 8 (unconsumed) is the only residual — accept as harmonization or extend? (architect call)

**STOP — combined package HELD for architect line review.** No execution, no push. On line-review
approval + named authorization the scripts commit for a WO-12-referenceable SHA; execution remains
operator-run per the runbook.
