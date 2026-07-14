# DIR-LNK-WO-3 — Backfill Dry Run, Prod Sizing, Multi-Primary Analysis, Exception-Process Proposal (P7 BUNDLE)

**Date:** 2026-07-14
**Binding:** project TAO master-linking (DIR-LNK series) · repo `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain` · branch `dev` · origin/dev HEAD at start `f4035887` (verified = local HEAD).
**Binding spec:** `docs/plans/TAO_Master_Contact_Linking_Revised_Technical_Specification.md` (MD5 `078d926dfb7c146278180877e32fcbdb`, re-verified this session; governs).
**Plan Lock:** `docs/plans/DIR-LNK-WO3-PLANLOCK.md` (`b8ac4ac2`, saved verbatim per P0a).
**Mode:** READ-ONLY + docs-class commits only. WO-4 is NOT authorized by this bundle.
**Read channel:** ratified pymysql, whitelist-enforced (the probe runner ABORTS on any statement not starting SELECT/SHOW/USE/WITH/SET @ — enforcement is in-code, before execution).

---

## 0. Executive result and PASS/FAIL

**All P1–P6 deliverables: PASS.** The classification engine is proven on dev (every count
self-reconciles to the populated-column totals exactly), prod is sized in aggregate with
fingerprints, the 7,644 multi-primary problem is decomposed to a **73-contact true-conflict
residue** behind two proposable rules, and the exception process + Q-4 memo are delivered
below. Zero DDL, zero DML, zero audit rows, zero prod writes, zero pushes.

| Phase | Deliverable | Result |
|---|---|---|
| P0 | Primer verbatim + commit + echo + fingerprints (dev+prod) | **PASS** (`b8ac4ac2`; fingerprints §1) |
| P1a | Reference normalization rules (conformance target declared in-file) | **PASS** (`2908076d`, rules doc) |
| P1b | PC-2 decision-table SQL, all six bucket concepts, read-only | **PASS** (`2908076d`, 3 engine files) |
| P1c | Zero DDL/DML/temp tables; .sql committed as evidence | **PASS** (whitelist-enforced) |
| P2a | Dev full classification, per-bucket ID listings | **PASS** (`0bce8d89`) |
| P2b | V3_10 retire-candidate list with per-row proof; retirement NOT executed | **PASS** (§3.3; proofs in local manifest file) |
| P2c | Duplicate-normalized analysis (dev) | **PASS** (§3.4) |
| P2d | Data handling: IDs only in repo; values in local manifest'd files | **PASS** (§8) |
| P3a | Prod buckets re-derived; drift vs WO-1 reconciled | **PASS** (§4.1) |
| P3b | Duplicate-normalized carve-out sized (the headline number) | **PASS** (§4.2) |
| P3c | Office population / spec §7.5 exposure quantified | **PASS** (§4.3) |
| P3d | No row-level prod output | **PASS** (aggregate GROUP BY only; §8) |
| P4 | Multi-primary metadata inventory + heuristics (none adopted) | **PASS** (§5) |
| P5 | Exception-process proposal (document only, no DDL) | **PASS** (§6) |
| P6 | Q-4 sequencing memo with options | **PASS** (§7) |

**Rulings requested from Kevin at this STOP:** RQ-1 carve-out adoption, RQ-2 Business-over-Fax
rule, RQ-3 duplicate-row retirement rule, RQ-4 exception-process mechanics, RQ-5 Q-4 timing
(§9 collects them).

---

## 1. Fingerprints, commits, and P0 echo of record

Read-channel fingerprints (`@@hostname` / `DATABASE()` / `CURRENT_USER()` / `NOW()` / `VERSION()`), all `A35-51-468 · kingk436@% · MySQL 8.0.41`:

| Block | Schema | Timestamp |
|---|---|---|
| P0 | new_development · actorsbusinessoffice | 2026-07-14 16:23:58 |
| P2 dev aggregate | new_development | 16:32:59 |
| P2 dev row-level | new_development | (header of rowlevel output) |
| P2 dev value-level (LOCAL) | new_development | 16:33 (manifest §8) |
| P2 drift probe | new_development | 16:35:24 |
| P3 prod aggregate | actorsbusinessoffice | 16:36:11 |
| P4 prod multi-primary | actorsbusinessoffice | 16:37:51 / 16:38:44 / 16:40:42 |
| P7 zero-write confirm | new_development | 16:41:51 |

Required-reading gists (P0b echo, recorded): (1) binding spec — master-managed snapshot model,
backfill selection rules §6.3, normalization §18, phases §19; (2) WO-1 recon — schema/view/consumer
inventory, §5B decision-table counts, R-A1 exact SQL + R-A2 canonical predicate; (3) WO-2 Phase 1
recon — G-1/G-2 gap analysis, V3_12 numbering, varchar-vocabulary rationale; (4) WO-2 Phase 4 proof
bundle — V3_12 dev apply PASS 10/10, dev-only delta, rollback cycle proven; (5) STATUS doc —
program anchor, gates, D-register, key technical facts; (6) V3_12 migration + 2 rollbacks —
governed action_type (13) and actor_type (4) vocabularies in header, audit writer policy;
(7) D-19 addendum — contact 132419 / itemID 312621 PROVEN bridge-created, WO-11 register seed.

**WO-3 commit register (all docs-class, all local, no pushes):**

| SHA | Content |
|---|---|
| `b8ac4ac2` | Plan Lock primer saved verbatim (P0a) |
| `2908076d` | P1: normalization rules + 3 engine SQL files |
| `0bce8d89` | P2: dev aggregate + row-level outputs (IDs only) |
| `e215a66d` | P3/P4: prod aggregate outputs (first capture) |
| (this commit) | P4 closure appends + this bundle |

---

## 2. P1 — Classification engine (summary; files are the artifact)

- `evidence/2026-07-14-dir-lnk-wo3-normalization-rules.md` — N-P/N-E/N-C reference rules;
  **declared conformance target for the future CFML normalizer**; candidate predicate;
  documented limitations (L-P1 leading-1 vs extension: dev incidence of extension markers = **0 rows**).
- `evidence/2026-07-14-dir-lnk-wo3-engine-aggregate.sql` — PC-2 buckets + dupnorm flag +
  R-A1 parity mode + office population. Runs on both schemas; the ONLY mode run on prod.
- `evidence/2026-07-14-dir-lnk-wo3-engine-dev-rowlevel.sql` — dev-only ID-level listings +
  PC-3 reconciliation (7 statuses documented in-file).
- `evidence/2026-07-14-dir-lnk-wo3-engine-dev-valuelevel.sql` — dev-only; output routed
  exclusively to the local working directory (§8).

**Column-name corrections of record (P1 verification obligation):**
1. Timestamps are `itemCreationDate` / `itemLastUpdated` — the primer's "itemCreatedDate/
   itemUpdatedDate" was a paraphrase (D-19 already used the correct names).
2. `contactitems_tbl` has **no `itemcategory` column** on either schema (live 1054 proof);
   the discriminator is `valueCategory` ('Phone'/'Email'/'Company'). WO-1 §1.3's numeric
   category IDs do not exist on the base table; all WO-4 SQL must use `valueCategory`.
3. dev↔prod `contactitems_tbl` are column-identical (21 columns).
4. `co_locations.phone/email` = varchar(500), matching V3_12's width rationale.

**primary_mismatch on prod is structurally zero** (DG-1: all prod primary columns empty), as the
Plan Lock required stating; on dev it is a live reconciliation status (§3.3).

---

## 3. P2 — Dev dry run (new_development, row-level authorized)

### 3.1 Canonical buckets (engine) vs R-A1 parity — fully reconciled

| Field | one | multi_one_primary | multi_zero_primary (dupnorm) | multi_multi_primary (dupnorm) | none_usable/excluded |
|---|---|---|---|---|---|
| Phone canonical | 152 | 0 | 123 (2) | 0 | 2 |
| Phone parity | 152 | 0 | 125 | 0 | — |
| Email canonical | 127 | 0 | 164 (41) | 1 (0) | 1 |
| Email parity | 127 | 0 | 165 | 1 | — |
| Company canonical | 419 | 0 | 17 (3) | 0 | 36 |
| Company parity | 452 | 0 | 20 | 0 | — |

Parity mode reproduces WO-1 §5B dev numbers **exactly** (152/125, 127/165/1, 452/20).
Every canonical-vs-parity transition is enumerated by contactID (drift probe, 16:35:24):
- Phone: 131235 (all values normalize empty → none_usable), 131703 (single raw-empty item),
  131239 (2 raw items, 1 usable → moves to `one`).
- Email: 131179 (raw-empty items only).
- Company: **35 contacts one→none_usable** — their Company rows have empty `valueCompany`;
  **25 of them (27 items) carry the company text in `valuetext` instead — the D-5 defect class,
  now sized on dev.** Plus 131047/131324 (multi→one), 131046 (→none_usable).
  IDs: 130648, 131000, 131001, 131003, 131023, 131039, 131040, 131043, 131044, 131045, 131360,
  131404, 131405, 131406, 131407, 131408, 131409, 131454, 131694, 131695, 132285, 132288, 132291,
  132294, 132299, 132306, 132309, 132310, 132346, 132356, 132360, 132364, 132368, 132371, 132374.
  **WO-4 rule implication:** these contacts have NO usable Company candidate — leave the column
  unchanged (spec §6.3 no-active-items) and report them as a data-quality class. Do NOT read
  `valuetext` for Company in WO-4 without a separate ruling (PC-2: do not guess).

Denominators: dev active contacts **1,571** (total rows 1,637 — the primer's "1,636" is one row
of ordinary live drift; non-material).

### 3.2 PC-3 reconciliation of populated primary columns — totals exact

| Field | populated | retire_on_match_selected | retire_on_match_exception_bucket | retire_ambiguous_dupnorm | primary_mismatch | col_populated_no_item | master_snapshot_col_excluded |
|---|---|---|---|---|---|---|---|
| Phone | 276 | 151 (1 linked) | 121 | 2 | 1 | 1 | 0 |
| Email | 292 | 127 (1 linked) | 123 | 42 | 0 | 0 | 0 |
| Company | 436 | 418 | 13 (1 linked) | 4 | 0 | 0 | **1 = contact 132419** |

- Contact **132419** isolates exactly as predicted (R-A2/D-19): its `contactCompany` is a
  master-managed snapshot column (`_src='master'`), **out of PC-3 retire scope** — handled by
  the link machinery path, while its active bridge item 312621 remains the WO-11 target.
  The engine encodes this exclusion (`col_src='master'` guard), so WO-4 can never treat a
  master snapshot as a V3_10 retire candidate.
- **Refinement of WO-1 §5C "100% match":** under per-item normalization the engine finds
  2 non-matching Phone contacts — **131239** (`primary_mismatch`: column differs from the
  now-selected candidate) and **131703** (`col_populated_no_item`: column populated, zero usable
  items). Both → exception per PC-2 ("exception unless provenance proves authority"). Value-level
  proof rows are in the local working file (§8). The 5C claim holds for 274/276 Phone, 292/292
  Email (42 with ambiguous physical row), 435/436 Company.

### 3.3 Retire-on-match candidate register (RETIREMENT NOT EXECUTED — Q-4)

**953 items** hold a designated `retire_itemID` in the committed listing
(`evidence/2026-07-14-dir-lnk-wo3-dev-rowlevel-output.txt`, REC-P2/E2/C2 sections):
Phone 272, Email 250, Company 431. Per-row value proof (column value = item value under
normalization, raw + normalized, `norm_match=1`) is in the local value-level file (§8);
zero `norm_match=0` rows exist among selected candidates.
**48 contacts** (2+42+4) are `retire_ambiguous_dupnorm`: the column value matches MULTIPLE
physical rows that normalize identically — the value is safe, the row to retire is not
(disposition proposal §5.4/RQ-3). Per PC-3 and Q-4, nothing is soft-deleted in WO-3 or
(recommended) in WO-4.

### 3.4 Duplicate-normalized analysis (dev)

Contacts in multi buckets whose candidates ALL normalize to one value: Phone 2, Email 41,
Company 3. Group detail (norm value, member itemIDs, primaries per group) is value-level →
local file only. Dev mirrors the prod pattern: duplicates concentrate in Email.

---

## 4. P3 — Prod aggregate sizing (actorsbusinessoffice; aggregate GROUP BY only)

### 4.1 Buckets re-derived; drift vs WO-1 reconciled

Parity mode (exact R-A1 SQL shape) vs WO-1 §5B:

| Field | one | multi_one_primary | multi_zero_primary | multi_multi_primary | vs WO-1 |
|---|---|---|---|---|---|
| Phone | 15,594 | 333 | 462 | 7,644 | exact |
| Email | 24,500 | 125 | 484 | 262 | one +1 |
| Company | 25,195 | 2 | 263 | 423 | one +1 |

Active contacts 46,272 (WO-1: 46,270). The +1/+1/+2 are ordinary live drift since 2026-07-13 —
**R-A1 is confirmed reproducible.** Parity auto-migratable: Phone 15,927 (exact), Email 24,625,
Company 25,197.

Canonical mode (the engine WO-4 will actually use — empty and normalized-empty values excluded):

| Field | one | multi_one_primary | multi_zero_primary (dupnorm) | multi_multi_primary (dupnorm) | none_usable | **auto-migratable** |
|---|---|---|---|---|---|---|
| Phone | 15,434 | 328 | 455 (14) | 7,643 (246) | 42 | **15,762** |
| Email | 23,889 | 125 | 481 (37) | 262 (123) | 0 | **24,014** |
| Company | 24,875 | 2 | 207 (24) | 423 (423) | 0 | **24,877** |

The parity−canonical gap is contacts whose items are empty/normalized-empty (Phone 131 raw-empty-only
+ 42 normalized-empty; Email 614 raw-empty-only; Company 376 mostly the D-5 class) — they could never
populate a column, so **the canonical numbers are the true WO-4 workload: 64,653 column populations.**

### 4.2 The value-safe carve-out (P3b — the headline number)

Contacts in EXCEPTION buckets whose candidates all normalize to ONE identical value (migrating
it selects no candidate over another — value-identical by construction):

| Field | multi_zero_primary carve | multi_multi_primary carve | total carve | remaining exceptions |
|---|---|---|---|---|
| Phone | 14 | 246 | 260 | 7,838 |
| Email | 37 | 123 | 160 | 583 |
| Company | 24 | **423 of 423 (100%)** | 447 | 183 |
| **Total** | 75 | 792 | **867** | **8,604** |

- **Company multi_multi_primary is 100% duplicate-normalized** — every one of the 423 is the
  same company name flagged primary twice. The entire bucket is value-safe.
- Phone is the opposite: only 246 of 7,643 (3.2%) are "the same number twice." The Plan Lock's
  P4c hypothesis ("if most of the 7,644 are the same number twice") is **FALSE** — but §5 shows
  the true structure is even better than duplicates.
- If the carve-out is adopted (RQ-1), auto-migratable rises to Phone 16,022 / Email 24,174 /
  Company 25,324 = **65,520**, and the exception queue drops to 8,604.

### 4.3 Office population — spec §7.5 blank-master exposure (P3c)

Live master tables (prod = dev seed; every number matched dev exactly):

- Offices: 12,617 total → phone populated **9,747 (77.3%)**, email **8,195 (65.0%)**.
- `companies.coPhone` / `coEmail`: **0 of 10,740 populated** — there is NO company-level
  phone/email fallback; offices are the only master phone/email source (PC-1 confirmed
  structurally).
- Companies where ALL offices lack phone: 1,944 single-office + 212 multi-office = **2,156**;
  email: 2,907 + 359 = **3,266**.
- Companies with ZERO offices: **785** (blank master phone AND email by definition).
- Arithmetic note: `co_locations` contains **46 rows with `coid` NULL** (0 rows coid=0), which
  form one phantom GROUP-BY group — this reconciles 9,956 office-groups vs 9,955 companies-with-
  offices, and the multi-office figure 1,661 vs the record's 1,660 (the NULL group is multi-row;
  counts including it are ±1). The record numbers 785 / 8,295 / 1,660 stand.
- **§7.5 exposure:** a link to a company in these sets yields a blank master phone (2,156+785 =
  **2,941 companies, 27.4%**) and/or blank master email (3,266+785 = **4,051, 37.7%**). Spec
  default = linked primary mirrors the blank; pre-link user values are preserved as items
  (spec §7.3/§7.5). Exposure is now quantified for the WO-7/WO-8 design; cross with the
  multi-office set delivered (212 phone / 359 email of the 1,660).

---

## 5. P4 — Multi-primary metadata analysis (nothing adopted here)

### 5.1 Metadata inventory (prod, aggregate)

- `itemLastUpdated`: **NULL on 100%** of the 125,083 active p/e/c items → any
  "most-recently-edited" heuristic is IMPOSSIBLE on current data.
- `itemCreationDate`: populated on 100% — but among Phone multi-primary contacts the primary
  items' creation timestamps are all-distinct in only **14 of 7,643 (0.2%)**: the primaries were
  created in the SAME operation. **All 15,535 primary items in this bucket were created in 2021**
  — the bucket is the residue of a single 2021 import/migration era that flagged multiple items
  primary, not the product of users marking two primaries.
- `itemStatus`: prod active p/e/c items are 100% 'Active' (no Pending) — no lifecycle history
  exists (no history table; only current row state).
- `valueType`: the discriminating metadata. Among Phone multi-primary contacts, primary items
  carry all-distinct valueTypes in **7,328 of 7,643 (95.9%)**. Email/Company: 0% (same type).
- Primary-count distribution (Phone): 2 primaries 7,471 / 3 primaries 105 / 4+ 67.
  Distinct normalized values: dn=1 246 / dn=2 7,303 / dn≥3 94.

### 5.2 The decomposition (prod Phone multi_multi_primary, 7,643)

Typeset of primary-flagged items × value agreement (aggregate matrix, 16:40:42):

| Primary typeset | primaries value-identical | contacts |
|---|---|---|
| Business + Work Fax | no | 7,324 |
| Business + Work Fax | yes | 153 |
| Business | yes | 93 |
| Business | no | 72 |
| Business + Fax | no | 1 |

**97.8% (7,477) of the bucket is exactly one Business phone + one Work Fax number, both flagged
primary, created in the same 2021 operation.** The conflict is not "which phone number" — it is
"a phone and a fax were both marked primary by an importer."

### 5.3 Candidate heuristics evaluated (NOT adopted; each requires Kevin's product approval)

**H-1 — Duplicate-normalized carve-out (all candidates identical).**
Coverage: 867 contacts (75 multi_zero + 792 multi_multi; per-field §4.2).
False-selection risk: **zero at the value level by construction** — all candidates normalize to
one value, so no candidate is preferred over another; the only residual risk is a normalization
rule error, bounded by the N-P/N-E/N-C definitions and the dev proof (§3). Selection is NOT by
newest/oldest/first/last/frequency — it is by value identity, which the Plan Lock's rule b does
not prohibit.
Sanitized example (synthetic): items {"(555) 010-4477", "555-010-4477"} → both normalize to
`5550104477` → migrate `5550104477`.
Rollback: WO-4 writes audit rows (`BACKFILL_FROM_CONTACTITEM`, old_value=NULL per DG-1);
rollback = clear the columns for the run_id. No item is deleted at WO-4 (per Q-4 recommendation),
so item-state rollback is nil.
Gate: **RQ-1.**

**H-2 — Type-semantic Business-over-Fax rule (Phone only).**
Rule: when a Phone multi-primary contact's primary items are exactly one 'Business' item and one
'Work Fax' (or 'Fax') item, select the **Business** item as primary phone; the fax item remains
an ACTIVE secondary (never soft-deleted — it is not the migrated item under RQ-3/Q-4 anyway).
Coverage: 7,477 contacts (7,324 beyond H-1's 153 overlap).
Basis: product semantics — a fax number is not a person's primary phone; this is a TYPE rule,
not a newest/oldest/first/last/frequency rule, so it is analyzable under Plan Lock rule b.
False-selection risk: the case where the user genuinely intended the fax as the primary contact
number. Measured proxy: the pattern is a uniform 2021 import artifact (same-second creation,
0.2% distinct timestamps), i.e. the double-primary flag never encoded user intent. Risk is
assessed LOW but is a product judgement — hence the gate. Worst-case failure mode: the visible
primary phone shows the business line instead of the fax; the fax remains one click away as an
active item; correctable per-contact.
Sanitized example (synthetic): primaries {type Business, digits A} + {type Work Fax, digits B}
→ migrate digits A; fax item B stays active.
Rollback: identical to H-1 (audit rows + clear-by-run_id; no item deletion at WO-4).
Gate: **RQ-2.**

**H-3 — Recency (newest itemLastUpdated / itemCreationDate). REJECTED.**
`itemLastUpdated` is 100% NULL; creation timestamps are same-second for 99.8% of the bucket.
Non-deterministic on real data, and the newest/oldest class is presumptively banned by rule b.
Not proposed.

**H-4 — Positional/frequency (lowest itemID, most frequent value). REJECTED for value selection.**
Explicitly banned by rule b. (A narrow positional rule for choosing which PHYSICAL ROW to retire
among value-identical duplicates — where no VALUE selection occurs — is separately surfaced as
RQ-3, because PC-2's duplicate clause asks WO-3 to propose a safe handling rule.)

**Combined effect if RQ-1 + RQ-2 are approved:** Phone multi_multi residue = 7,643 − 246 − 7,397
covered… stated precisely: H-1 covers 246 (153 inside B+WF, 93 inside 'Business'); H-2 covers the
7,324 non-identical B+WF contacts. Residue = **72 'Business'+'Business' true conflicts + 1
'Business + Fax' = 73 contacts**. Program-wide exception queue after both rules: Phone 455−14 +
73 + 42 none_usable-class reporting… net actionable exception queue = **73 Phone mm + 441 Phone
mzp + 583 Email + 183 Company = 1,280 contacts** (vs 9,471 before analysis). All remain
unmigrated and active until rulings; no unresolved queue is assigned to any person.

### 5.4 Dev equivalents

Dev has 1 multi_multi_primary contact (Email) and 0 for Phone/Company — the prod phenomenon is
a legacy-import artifact absent from dev's younger data. The dev dry run therefore proves the
ENGINE, and prod aggregates size the WORK; both were required (Plan Lock purpose statement).

---

## 6. P5 — Exception-process proposal (document only; no DDL authored; no staffing)

Backfill exceptions are **operational migration artifacts, not master-data corrections** —
`master_correction_requests_tbl` is NOT reused (its unique guard, lifecycle, and semantics are
per-(master, field, suggestion); backfill exceptions are per-(contact, field, run) and involve
no master record).

**E-1 Surfacing.** Each WO-4 run (and each future re-run) emits, inside its run scope:
- a committed ID-level exception report: run_id, contactID, field, bucket/status, candidate
  itemIDs, exception class (the §3.2/§4 taxonomy verbatim) — repo evidence, aggregates + IDs only;
- a value-level operator review file (CSV) with raw + normalized candidate values, written to
  the operator-held local working area (same handling class as §8), manifest'd (path/bytes/sha256)
  in the run bundle. On PROD runs the value-level file is produced by the operator-executed
  script on operator-controlled storage; it never enters the repo, prompts, or reports (prod
  read class d).

**E-2 Review + resolution recording.** Resolution happens at the CLASS level, not row level:
Kevin rules on classes (e.g. RQ-1/RQ-2 style rules), and each ruling is recorded in the
DIR-LNK ruling register (Plan Lock / bundle documents, as now). Rules approved after a dry run
are ENCODED INTO THE ENGINE (a new engine version, committed as evidence) — not applied as
ad-hoc row edits. Row-level one-offs (e.g. dev 131239, 131703) are either (a) resolved by the
data owner in-app (user edits their own contact), or (b) left unmigrated — the backfill NEVER
hand-edits individual rows. No exception queue is assigned to any person by this process;
staffing is a separate operational decision.

**E-3 Re-run semantics (binding for WO-4's Plan Lock).** Classification RE-EXECUTES at WO-4
time inside its transaction; the WO-3 listings are sizing evidence, not frozen input. Between
dry run and execution, users keep editing items — frozen lists would mis-migrate. Idempotency:
WO-4 populates only blank columns (populate-only-blank guard), stamps a deterministic
`idempotency_key` per (run-family, contactID, field) on its `BACKFILL_FROM_CONTACTITEM` audit
rows (UQ_master_audit_idem enforces), and a re-run therefore re-classifies, skips populated
columns, and inserts zero duplicate audit rows.

**E-4 Staging structure: NOT warranted now.** The exception volume after rulings (~1,280) is
class-shaped; artifacts + ruling register carry it. IF a later WO wants an in-app review UI
(e.g. surfacing "this contact has two conflicting phones" to the owning user), THEN propose a
dedicated `backfill_exceptions_tbl` (run_id, contactID, field, class, candidate itemIDs JSON,
status, resolved_by, resolved_at) as its own numbered migration with rollback — deferred; no
DDL is authored or requested in WO-3.

**E-5 RQ-3 — duplicate-row retirement rule (PC-2 "propose a safe handling rule").** For
value-identical duplicates (867 carve-out contacts + 48 dev retire_ambiguous class): migrating
the value is safe; choosing which physical row to soft-delete is not value-affecting but IS
row-affecting. Proposal: **retire NONE of them at backfill time** — leave all duplicate rows
active; the post-cutover retirement pass (Q-4 option i) may then apply, with approval, the
narrow rule "among value-identical active items matching the migrated column, soft-delete all
but one, keeping the primary-flagged row if any, else the lowest itemID" — a row-hygiene rule,
never a value selection. Until RQ-3 is ruled, duplicates all stay active (display dedup is
WO-5's contacts_ss rebuild anyway).

---

## 7. P6 — Q-4 sequencing memo (ruling requested)

**The window.** WO-4 populates columns; but `contacts_ss`/`sharez*` (and the detail panes) read
`contactitems` until WO-5. A primary item soft-deleted at WO-4 vanishes from every current
surface while the populated column is not yet read anywhere → the user-visible primary goes
BLANK for the whole WO-4→WO-5 gap. Scale if retired at WO-4: ~64,653 prod primaries (dev: 953)
— i.e., effectively every migrated contact's list/detail display regresses for days-to-weeks.

**Options:**
1. **(i) Backfill at WO-4 WITHOUT retirement; retirement is a separate verified pass AFTER WO-5
   cutover** — architect-recommended, and CC concurs. No display regression ever; PC-3's
   "soft-delete only after proof" is satisfied LATER and BETTER (proof = post-cutover engine
   re-run confirming column==item, catching any user edits made between WO-4 and WO-5 via the
   still-live legacy item-edit paths). Costs: contacts_ss's `ORDER BY primary_YN DESC LIMIT 1`
   display continues to be fed by items during the gap (status quo, no new risk); the retirement
   pass is one more operator-executed, audited step (action_type `BACKFILL_FROM_CONTACTITEM`
   family / `ADMIN_REPAIR` per the governed vocabulary — exact reason string to be fixed in the
   WO-4/WO-5 plan).
2. **(ii) Retire at WO-4, accept the window** — rejected on the numbers above: a visible
   mass-blanking of primaries on every list surface is a production-scale regression with zero
   compensating benefit.
3. **(iii) Coupled WO-4+WO-5 deploy** — closes the window but couples a data migration to a
   view/consumer rewrite in one blast radius, against program doctrine (incremental, reversible,
   per-stage rollback) and against the WO ladder's separate gates.

**Recommendation: (i).** Consequences accepted and stated: items remain temporarily "duplicated"
into columns (data duplication, not divergence: the retirement-pass re-verification handles any
interim item edits); WO-5 acceptance must include the retirement-pass plan; Q-4 ruling gates
nothing in WO-4's population step itself.

---

## 8. Data handling + working-file MANIFEST (P2d)

Committed evidence contains aggregates and contactID/itemID/status listings only. No phone or
email value appears in any committed file or in this bundle; company names appear only as the
two already-public program fixtures (132419's master company name, quoted from the committed
D-19 addendum) and synthetic examples. No row-level prod output of any kind was produced —
every prod statement returns GROUP BY aggregates or counts.

Local working files (outside repo), directory `C:\Users\kevin\TAO\_dryrun\dir-lnk-wo3\`:

| Path | Bytes | SHA-256 |
|---|---|---|
| `C:\Users\kevin\TAO\_dryrun\dir-lnk-wo3\dev-valuelevel-output.txt` | 104,252 | `07d0437342dac9aff62bcb9d086381c18e2802429991d64d5144756c2609e699` |

Contents: dev-only value-level retire-on-match proofs (VAL-P1/E1/C1: raw + normalized column and
item values, norm_match flag), extension-marker incidence (VAL-P2: **0 rows**), duplicate-
normalized group detail (VAL-DUP-P/E/C). Produced 16:33; fingerprint header inside the file.

---

## 9. Rulings requested (Kevin, at this STOP)

| RQ | Question | CC position |
|---|---|---|
| RQ-1 | Adopt H-1 value-safe carve-out (867 contacts migrate; no candidate preferred) | Recommend ADOPT |
| RQ-2 | Adopt H-2 Business-over-Fax type rule (7,477 Phone contacts) | Recommend ADOPT (low risk, stated) |
| RQ-3 | Duplicate physical-row retirement rule (§6 E-5) | Recommend: retire none at WO-4; rule the row-hygiene pass with Q-4 |
| RQ-4 | Exception-process mechanics as proposed (§6 E-1..E-4) | Recommend ADOPT |
| RQ-5 | Q-4 timing | Recommend option (i) |

Also carried to the record (no ruling needed now): the D-5 Company-in-valuetext class (25 dev
contacts; prod analog inside the 376 excluded — sizing prod's D-5 class needs one aggregate in
WO-4 prep), the 614 prod raw-empty Email items and 46 NULL-coid offices as data-hygiene notes,
and the primer column-name corrections (§2).

---

## 10. Zero-write confirmations

- **Zero DDL, zero DML, zero temp tables, zero server-side objects:** every statement executed
  through the whitelist runner (SELECT/SHOW/USE/WITH only; in-code abort precedes execution).
- **Zero audit rows:** `master_audit_tbl` = 0 rows, `master_correction_requests_tbl` = 0 rows,
  live count at 16:41:51 (post-run) — the WO-3 dry run changed no data, therefore wrote no audit
  rows (Plan Lock f).
- **Zero prod writes:** prod channel issued SELECT/SHOW/USE only; aggregate output only.
- **Zero pushes:** all WO-3 commits are local; `origin/dev` remains `f4035887`. No PUSH GO
  received, none exercised.
- No app code, no views, no contactitems changes, no linking-behavior work, no emojis.

**STOP** — architect review → Kevin rulings (RQ-1..RQ-5) → WO-4 Plan Lock is a separate document.
