DIR-LNK-WO-3 — NEW SESSION PRIMER + PLAN LOCK
Channel conventions: numbered sections, END marker closes. Echo section
count on receipt. Halt-don't-guess on anything missing. Relays carry
payloads; committed repo files count as payloads.

SECTION 1 — BINDING
project: TAO master-linking program (DIR-LNK series)
repo: kevinlawrenceking/dev-subdomain
root: C:\Users\kevin\TAO\dev-subdomain
branch: dev (origin/dev HEAD f4035887 — verify before starting)
workstream: DIR-LNK-WO-3 (backfill dry-run + exception-process review)
Authorization: Kevin, 2026-07-14 — "proceed with WO-3." This Plan Lock is
architect-drafted under that authorization; operator corrections
supersede. Scope is READ-ONLY + docs-class commits. WO-4 (backfill
execution) is NOT authorized by this document.

SECTION 2 — REQUIRED READING (read all before any work; one-line gist
each in your P0 echo; halt if any is missing)
1. docs/plans/TAO_Master_Contact_Linking_Revised_Technical_Specification.md
   (BINDING SPEC — governs over every summary including this primer)
2. docs/plans/DIR-LNK-WO1-RECON.md (incl. R-A1/R-A2 amendment sections)
3. docs/plans/DIR-LNK-WO2-PHASE1-RECON.md
4. docs/plans/evidence/2026-07-14-dir-lnk-wo2-phase4-proof-bundle.md
5. The DIR-LNK STATUS doc in docs/plans/ (committed with b28ae134)
6. database/migrations/V3_12__master_directory_wo2_audit_correction.sql
   (+ its two ROLLBACK files) — the governed action_type and actor_type
   vocabularies live in its header
7. docs/plans/evidence D-19 addendum (commit 367b057f)

SECTION 3 — STATE OF RECORD
Gate register: WO-1 CLOSED (c9fcc955) · WO-2 CLOSED (Phase 4 PASS
10/10, f4035887) · WO-3 THIS DOCUMENT · WO-4 held behind WO-3 review ·
WO-5..12 per ladder · prod DDL = WO-12 only (V3_12 tables are a
declared dev-only delta, live on new_development only).
Rulings in force (verbatim where load-bearing):
a) PC-2 DECISION TABLE (approved): one candidate -> migrate. Multiple
   candidates with exactly one designated primary -> migrate that
   primary. Multiple with no primary -> exception. Multiple with
   multiple primaries -> exception. Existing primary mismatch ->
   exception unless provenance proves authority. Duplicate normalized
   values -> report and propose a safe handling rule; do not guess.
   Only the successfully migrated primary item may be soft-deleted.
   Secondary items remain active.
b) MULTI-PRIMARY CONSTRAINTS (approved): ambiguous records are
   exceptions. No value is selected merely because it is newest,
   oldest, first, last, or most frequent. WO-3 may ANALYZE whether
   metadata supports a demonstrably safe deterministic rule. Any
   proposed rule must include counts, false-selection risk, examples
   without personal data, rollback implications, and an explicit
   product approval gate. Until approved, those records remain
   unmigrated and active. Do not assign any unresolved queue to a
   person; staffing is a separate operational decision.
c) PC-3 / V3_10 (approved): values copied by V3_10 from users' own
   contactitems are user-originated; _src stays 'user'. Reconcile
   primary columns against current active items during the dry run;
   where the primary matches the selected legacy item, that item is a
   retire-on-match candidate — soft-delete only after proof, and
   RETIREMENT IS NOT EXECUTED IN WO-3 (timing is open question Q-4).
   Conflicts -> exception. All secondary items preserved.
d) PROD READ CLASS (ratified): aggregate counts and schema/view
   inspection only; read-only; no row-level personal contact data in
   reports or prompts; no exports containing personal values; no prod
   writes; row-level prod inspection requires separate approval.
e) CANONICAL COUNT PREDICATE (governs all DIR-LNK counts):
   IsDeleted=0 AND col IS NOT NULL AND TRIM(col)<>''.
f) AUDIT WRITER POLICY: no triggers; runtime writes via service layer;
   approved migration/backfill scripts may insert audit rows
   transactionally WITH a data change. THE WO-3 DRY RUN CHANGES NO
   DATA, THEREFORE WRITES ZERO AUDIT ROWS. First live audit use =
   WO-4's BACKFILL_FROM_CONTACTITEM rows.
g) Supersession: fill-blank semantics, PD-L1..L4, R-1, R-3 are
   historical (DIR-WO-2 record only); linked primaries are
   master-managed per the binding spec. Not directly in WO-3 scope but
   do not reintroduce them in any proposal text.
Numbers of record: prod contactdetails_tbl = 72,062 rows, zero
populated primaries, 100% _src='user' (DG-1). Prod auto-migratable
(bucket one + multi_one_primary): Phone 15,927 / Email 24,624 /
Company 25,196. Dominant prod exception: multi_multi_primary Phone
7,644. Dev: 1,636 contacts; company nonnull 436 (435 user via V3_10 +
1 master, contact 132419); V3_10 dev reconciliation = 100% item-match.
Master tables (dev seed): co_contacts 25,200 / companies 10,740 /
co_locations 12,617; companies with 0/1/>1 offices = 785/8,295/1,660.
D-14 = 81 (co_contacts.coid=0). D-18 = 1,291 duplicate-fullname groups
/ 2,786 rows. WO-11 register: one proven entry (132419/312621).
Environment: DB read channel = ratified pymysql (fingerprint before
each schema's evidence block: @@hostname, DATABASE(), CURRENT_USER()).
All DML/DDL is operator-executed (HeidiSQL) — NONE is authorized in
WO-3. contactitems_tbl carries itemCreatedDate/itemUpdatedDate (used
in D-19) — verify column names in P1.

SECTION 4 — PLAN LOCK: DIR-LNK-WO-3
Purpose: prove the backfill classification engine on dev, size prod,
analyze the multi-primary problem, and propose (not adopt) the
exception process — producing everything WO-4 needs for its own Plan
Lock.

P0 — BOOTSTRAP
  a) Save this primer verbatim to docs/plans/DIR-LNK-WO3-PLANLOCK.md;
     one docs-class local commit. (D-16 doctrine: gate documents live
     in the repo.)
  b) Echo: section count, one-line gist per required-reading file,
     read-channel fingerprint (dev + prod), origin/dev HEAD
     verification. Then proceed to P1 — no STOP unless something is
     missing or contradicts this primer.

P1 — CLASSIFICATION ENGINE (read-only SQL, authored as evidence files)
  a) Define explicit REFERENCE NORMALIZATION rules per field (spec §18
     anchor): phone (e.g. digits-only, leading-1 handling), email
     (trim/lower), company (trim/space-collapse/case rule). Document
     every rule; these become the conformance target the future CFML
     normalizer (later WO) must match — state that in-file.
  b) Implement the PC-2 decision table per field (Phone, Email,
     Company) as parameterized read-only SQL over contactitems_tbl +
     contactdetails_tbl using the canonical predicate. Buckets: one /
     multi_one_primary / multi_zero_primary / multi_multi_primary /
     primary_mismatch (dev only — prod primaries are empty per DG-1,
     so this bucket is structurally zero on prod; state that) /
     duplicate_normalized (flag within any multi bucket where all
     candidates normalize identically).
  c) Zero DDL, zero DML, zero temp tables on the server. Commit the
     .sql files as evidence (docs-class).

P2 — DEV DRY RUN (row-level permitted on new_development)
  a) Full classification of dev: per-field bucket count tables;
     per-bucket contactID/itemID listings.
  b) V3_10 reconciliation retire-candidate list: per-row proof
     (contactID, itemID, primary value = item value under
     normalization). RETIREMENT NOT EXECUTED.
  c) Duplicate-normalized analysis: within multi buckets, how many
     collapse to a single normalized value (value-safe subset).
  d) DATA HANDLING: committed evidence carries aggregates and
     ID-level listings ONLY — no phone/email values, company names
     sampled/sanitized. Full value-level detail goes to local working
     files at C:\Users\kevin\TAO\_dryrun\dir-lnk-wo3\ (outside repo)
     with a MANIFEST (path, bytes, sha256) reported in the bundle.
P3 — PROD AGGREGATE SIZING (ratified class; fingerprint first)
  a) Re-derive the R-A1 buckets per field with the P1 engine
     (aggregate GROUP BY only); reconcile any drift vs the WO-1
     numbers.
  b) Duplicate-normalized aggregate: of prod multi_multi_primary and
     multi_zero_primary sets, the count that collapses to one
     normalized value per field — the value-safe carve-out size. This
     is the single highest-value number WO-3 produces.
  c) Office population (§7.5 exposure): aggregate non-null/non-empty
     rates for co_locations.phone and co_locations.email; count of
     companies where ALL offices lack phone; same for email; cross
     with the 1,660 multi-office set.
  d) No row-level prod output of any kind.
P4 — MULTI-PRIMARY METADATA ANALYSIS (the 7,644 + dev equivalents)
  a) Inventory usable metadata (timestamps, valueType, itemStatus
     history if any). b) Evaluate candidate heuristics WITHOUT
     adopting any — for each: coverage count, false-selection risk and
     how it was measured, sanitized examples (no personal values),
     rollback implications, and the explicit statement that adoption
     requires Kevin's product approval. c) Lead with the
     normalized-identical carve-out from P3b — if most of the 7,644
     are the same number twice, the true-conflict remainder is the
     real exception queue; size both.
P5 — EXCEPTION-PROCESS PROPOSAL (document, not implementation)
  Mechanics for surfacing, reviewing, and recording backfill
  exceptions: artifact format, resolution recording, and re-run
  semantics (classification RE-EXECUTES at WO-4 time inside its
  transaction — the dry run proves the engine and sizes the work; it
  is not a frozen row list). Explicitly: backfill exceptions are NOT
  master corrections — do not reuse master_correction_requests_tbl.
  If a staging structure is genuinely warranted, PROPOSE it for a
  future migration; do not author DDL here. No staffing assignment.
P6 — Q-4 SEQUENCING MEMO (Kevin ruling requested at STOP)
  Item-retirement timing vs WO-5 read cutover: retiring a migrated
  primary item while contacts_ss/sharez still read contactitems blanks
  the user-visible primary until cutover. Analyze the window; present
  options with implications: (i) backfill at WO-4 WITHOUT retirement,
  retirement as a verified post-WO-5 pass [architect-recommended];
  (ii) retire at WO-4 and accept the window; (iii) coupled WO-4+WO-5
  deploy. PC-3's "soft-delete only after proof" is compatible with
  deferral.
P7 — BUNDLE + STOP
  DIR-LNK-WO3-DRYRUN.md (docs-class commit) containing: engine + rule
  documentation, dev results, prod aggregates with fingerprints, the
  carve-out numbers, metadata analysis, exception-process proposal,
  Q-4 memo, working-file manifest, zero-write confirmations (zero
  DDL, zero DML, zero audit rows, zero prod writes, no pushes), and
  PASS/FAIL against each P1-P6 deliverable. Report all commit SHAs.
  STOP for architect review -> Kevin rulings (exception process, Q-4,
  any carve-out adoption) -> WO-4 Plan Lock is a separate document.

SECTION 5 — HOLD POINTS
No push without a named operator PUSH GO. No DDL/DML anywhere. No
audit-table inserts. No prod row-level access. No app code, no views,
no contactitems changes, no linking-behavior work. No emojis in any
project document. Halt and surface rather than guess — the record
rewards stops.
END PRIMER — 5 sections.
