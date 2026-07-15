# DIR-LNK-WO-5 — PLAN LOCK v-final (READ CUTOVER: views + readers → primary columns)

**Binding (verified this session):** project TAO-MCD-P1 · series DIR-LNK-WO-1..12 · repo
`kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain` · branch `dev` ·
local HEAD == `origin/dev` == `66e49781` (clean). Binding spec MD5 `078d926d…` (WO-1 header).
NN#10 binding check: PROCEED.
**Status:** PLAN LOCK v-final. Folds architect-adopted critique G-1..G-8 into the proposal.
Pins RQ-6 ruling (a) + H-1 errata per the 2026-07-15 operator relay (verbatim in
`evidence/2026-07-15-dir-lnk-wo5-rq6-h1-relay-pin.md`). RQ-5i ruled/pinned `1e7af179` (out of
scope here).
**Mode of this document:** docs-class. No code, no DDL, no DML, no push.

---

## AUTHORIZATION (unchanged from proposal)
Operator approval authorizes: view DDL authoring (held for line review), dev-only view apply
(operator-executed, HeidiSQL — the D-3 exception EXPIRED and does not carry over), and read-path
code changes under the standard commit/review discipline. Prod view DDL = WO-12.

## SCOPE
Repoint every **single-value** Company/Phone/Email *display* read from `contactitems` subqueries to
the `contactdetails` primary columns, via the exposing views and the readers that render a single
primary value. RQ-6 ruling (a) governs the `_target/_followup/_maint` family filter semantics.
**contactdetails is a VIEW over `contactdetails_tbl`** (44 cols, SQL SECURITY INVOKER; V3_8/G0-2b);
readers read through views by house convention; WO-4 wrote `_tbl`. P1 re-confirms fresh.
**OUT OF SCOPE:** linking (WO-7), item retirement (post-WO-5 per RQ-5i), correction workflow (WO-9),
`contactitems` writes, prod DDL, and — per the G-2/Class-B finding below — **per-item
management/editor surfaces** (they show all items by design; WO-6 owns them).

---

## FOLDED AMENDMENTS (architect-adopted G-1..G-8)

| # | Amendment | Disposition in v-final |
|---|---|---|
| **G-1 / H-1** | Prod **reader-code** exposure was an unstated dependency. | HOLD added: WO-5 reader code is **held from prod until the WO-12 atomic sequence** (backfill → prod view flip → reader code). Between WO-5 merge and WO-12, any prod deploy is **cherry-pick-only from a pre-WO-5 base**. Stamped H-1. |
| **G-2** | Three display buckets; bucket (b) "value changes" only implicit. | P1 measures all three per surface, per field (delivered — see P1-DELTA). Bucket (b) is **non-zero in dev (64)** and is the headline STOP finding; P4 must adjudicate/validate each. |
| **G-3** | RQ-6 was a citation, not a ruling. | **RQ-6 RULED (a)** by the 2026-07-15 operator stamp; pinned with this lock. RQ-5i confirmed ruled `1e7af179`. |
| **G-4** | Two `contact_info.cfm`. | Inventory + D-17 liveness probe treat `include\contact_info.cfm` **and** `include\qry\contact_info.cfm` as distinct surfaces. |
| **G-5** | Confirm contactdetails table/view status. | **RESOLVED:** contactdetails is a VIEW over `contactdetails_tbl`; P1 re-confirms fresh. |
| **G-6** | Signature-grep completeness backstop. | P1 ran a codebase-wide signature grep; it surfaced readers **absent from WO-1 §3D** and an expanded view set. Reconciled in P1-DELTA. |
| **G-7** | Rollback = views AND code (two-part). | P2 authors a rollback **script covering every repointed view** (verbatim prior defs from P1) + code rollback = git revert. P5 rollback TEST exercises one full view cycle as mechanism proof. |
| **G-8** | Perf sanity on list surfaces. | P4 adds a timing/EXPLAIN spot-check on the main contacts list (col-read vs correlated-subquery) — expected win, must confirm no regression. |

## OPERATOR STAMP BLOCK (Kevin, 2026-07-15) — pinned
- **RQ-6: RULED (a)** — dev view definitions are truth. WO-5 authors from dev's forms including the
  `suStatus='Active'` filter; prod adopts them at WO-12; the visible prod tab change (inactive
  enrollments drop off `_target/_followup/_maint`) is **accepted** and carried on the WO-12 record.
- **H-1: ACKNOWLEDGED** — reader code held from prod until the WO-12 atomic sequence; interim prod
  deploys are cherry-pick-only from a pre-WO-5 base.
- **H-1 AMENDED (architect, 2026-07-15, on the P2 zero-reader-diff finding):** the reader-code prod
  hold is **RETIRED AS SATISFIED-BY-ARCHITECTURE.** WO-5 changes zero reader code (the cutover is
  view-DDL-only, dev and prod), so there is no reader code to hold; the **dev branch remains
  prod-safe**, and the WO-12 prod cutover = **backfill + prod view flip only.** The cherry-pick-only
  doctrine is **retained as the GENERAL rule** for any future merge that makes dev prod-unsafe — but
  no such condition exists now.

---

## PHASES

**P0 — BOOTSTRAP (this commit).** Lock to repo (this docs commit); origin HEAD verified `66e49781`;
D-11 Gate-0 view captures (`evidence/2026-07-09-…`) + WO-1 §2/§3 reader inventory re-read. DONE.

**P1 — RECON (read-only). STOP at delta report.** Fresh `SHOW CREATE` every affected view BOTH
schemas (not reused from July 9); full reader re-inventory incl. qry fragments, DataTables
server-side sources, export paths; flag any reader whose semantics change under primary-column
reads; per-surface delta (current vs post-cutover). **DELIVERED:** `DIR-LNK-WO5-P1-DELTA.md`
(this STOP). Read-only channel = ratified pymysql (SELECT/SHOW/USE; prod SHOW/information_schema
only).

**P2 — AUTHORING (no apply). STOP for line review.** View DDL per RQ-6(a): SQL SECURITY INVOKER,
no schema qualifiers in bodies (bleed doctrine); HeidiSQL apply scripts + **rollback scripts for
every repointed view** (prior defs captured verbatim in P1); reader code diffs, minimal, no
refactors, Class-A only. Re-verify every P1-surfaced candidate reader before including it.

**P3 — DEV APPLY.** Operator executes view DDL; code deploys per the established dev mechanism +
D-17 cache doctrine (template cache clear + modified-file liveness probe — this WO touches BOTH
`contact_info.cfm` files). Post-apply verification per surface.

**P4 — ACCEPTANCE.** Per-surface evidence that displayed Company/Phone/Email match the primary
columns; contacts without primaries show blank (correct post-cutover state, not a defect);
**bucket-(b) adjudication** (the 64 dev exception-class divergences — accept-as-cosmetic vs.
engine-cleanup-first, per architect ruling on the P1 finding); RQ-6(a) family behavior evidenced;
G-8 perf spot-check. Jodie eyeball-pass recommended (operator's call).

**P5 — BUNDLE + STOP.** Before/after per surface; view DDL verbatim; rollback tested (one view,
full cycle) + rollback script covering all views; dev-only delta statement (prod views unchanged
until WO-12); H-1 code-hold restated; PASS/FAIL per criterion; push set; STOP.

## HOLD POINTS
No prod DDL/DML; **no prod reader-code deploy until WO-12 (H-1)**; no `contactitems` changes; no
linking work; no item retirement; no pushes without named PUSH GO; halt-don't-guess.

END v-final.
