# DIR-LNK-WO-3 — R-B1 Reconciliation Disclosure + Rulings of Record (Addendum)

**Date:** 2026-07-14 · **Relay:** "DIR-LNK-WO-3 — ARCHITECT ACCEPT + OPERATOR RULINGS + R-B1 + PUSH GO" (4 items) · **Class:** docs-class.
**Amends:** `docs/plans/DIR-LNK-WO3-DRYRUN.md` (`35f79854`). Underlying query evidence:
`evidence/2026-07-14-dir-lnk-wo3-prod-multiprimary-output.txt` (CL-2 matrix, prod fingerprint
2026-07-14 16:40:42, aggregate-only).

## (a) RQ-1 ∩ RQ-2 overlap — CONFIRMED BY QUERY AS 153 (corrects the relay's implied 152)

The overlap was measured directly, not derived: CL-2 groups prod Phone multi_multi_primary
contacts by (primary typeset × primaries-value-identical):

| Primary typeset | primaries value-identical | contacts |
|---|---|---|
| Business + Work Fax | no | 7,324 |
| **Business + Work Fax** | **yes** | **153  ← the RQ-1 ∩ RQ-2 overlap** |
| Business | yes | 93 |
| Business | no | 72 |
| Business + Fax | no | 1 |

RQ-1 (value-identical carve-out) in this bucket = 153 + 93 = 246; RQ-2 (Business-over-Fax
typeset) = 7,324 + 153 = 7,477; both rules claim the same 153 contacts. (In-bucket
equivalence dn=1 ⇔ dn_primaries=1 holds: MM-P1 reports all_items_identical = 246 =
primaries_identical, with primaries_identical_but_secondaries_differ = 0.) Back-check of the
relay's arithmetic: coverage 246 + 7,477 − overlap = 7,643 − 73 residue → overlap = **153**.
The bundle already stated this split in §5.3 ("H-1 covers 246 — 153 inside B+WF, 93 inside
'Business'"); this addendum makes it the explicit disclosure of record.

## (b) 867 carve-out split per field (bundle §4.2 table, restated)

| Field | multi_zero_primary carve | multi_multi_primary carve | field total |
|---|---|---|---|
| Phone | 14 | 246 | **260** |
| Email | 37 | 123 | **160** |
| Company | 24 | 423 | **447** |
| **Total** | 75 | 792 | **867** |

## (c) Post-rules exception-queue derivation, end-to-end (exact, not approximate)

Start — canonical exception buckets (prod, bundle §4.1):
Phone 455 mzp + 7,643 mm = 8,098 · Email 481 + 262 = 743 · Company 207 + 423 = 630 →
**total 9,471**.

Apply RQ-1 (remove 867 per (b)): Phone 8,098−260 = 7,838 · Email 743−160 = 583 ·
Company 630−447 = 183 → **8,604**.

Apply RQ-2 (remove the B+WF contacts not already carved: 7,477 − 153 overlap = 7,324, all
Phone mm): Phone 7,838−7,324 = 514 → **total 1,280**.

Final queue composition: Phone = 441 mzp + 73 mm true-conflict residue (72 'Business'+'Business'
+ 1 'Business + Fax') = 514 · Email = 444 mzp + 139 mm = 583 · Company = 183 mzp + 0 mm = 183.
Cross-check: 514 + 583 + 183 = **1,280 exactly** — the bundle's "~1,280" is now exact. All
1,280 remain unmigrated and active per the standing multi-primary ruling; no queue is assigned
to any person.

## Rulings of record (Operator, Kevin, 2026-07-14 — relay item 3, accepted verbatim)

- **RQ-1 ADOPTED** — 867-contact value-safe carve-out migrates at WO-4. WO-4 Plan Lock must
  define the deterministic raw-representative display-form rule (which raw string populates the
  column when duplicates differ only in formatting).
- **RQ-2 ADOPTED** — Business-over-Fax primary-phone rule, scoped EXACTLY to the analyzed
  pattern (exactly one 'Business' + one 'Work Fax' primary pair). This stamp constitutes the
  product approval gate required by the multi-primary ruling. The fax item remains
  active/secondary and is never soft-deleted by this rule.
- **RQ-3 ADOPTED** — zero duplicate-row retirement at WO-4.
- **RQ-4 ADOPTED** — exception process as proposed (no DDL, no `master_correction_requests_tbl`
  reuse, no staffing named).
- **RQ-5 = OPTION (i)** — WO-4 backfills without retirement; verified retirement pass sequenced
  after WO-5 read cutover.

## Architect register updates acknowledged (relay item 1)

WO-3 ACCEPTED, PASS P0–P7; engine ratified as the classification engine of record for WO-4
(re-executed live inside WO-4's transaction — the dry run sizes, it does not freeze rows).
New register entries: **D-20** itemLastUpdated NULL fleet-wide (no recency heuristics ever) ·
**D-21** companies.coPhone/coEmail unused (offices sole master source) · WO-1 V3_10-match
refined to 2 dev exceptions (131239, 131703) · D-5 sized at 25 dev contacts.
