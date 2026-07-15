# DIR-LNK-WO-4 — Operator Runbook (Dev Backfill Apply)

**Date authored:** 2026-07-14 · **Lock:** `docs/plans/DIR-LNK-WO4-PLANLOCK.md` · **Status: HELD — do not execute until the P1 line review is accepted and the lock is operator-approved.**
**Executor:** Kevin, HeidiSQL, **`USE new_development;` first — every session, every step.** Prod is never touched by this runbook.
**Scripts:** `database/backfill/wo4/` (committed; execute from the repo files, not from pasted chat text).

## Design facts the operator should hold in mind

- The engine re-executes LIVE inside each script — WO-3's counts are provisional; **WO4_00's
  output is the contract.**
- Each field script is ONE transaction pairing audit INSERT with the column UPDATE; the
  in-transaction sanity SELECT must show equal counts before COMMIT.
- Idempotency is two-layer: empty-destination selection + deterministic
  `idempotency_key='BACKFILL:<contactID>:<field>'` under `UQ_master_audit_idem` (INSERT IGNORE
  → re-runs insert nothing and update nothing).
- Guards: G-LNK (linked contacts excluded — dev has 3, incl. 132419), G-WIDTH (raw longer than
  the destination column excluded; Phone 100 / Email 150; Company structurally exempt).
- `_src` is never written (PC-3; default 'user' already). contactitems is never written (RQ-3/RQ-5i).
- Selection cases and precedence: `one` → `multi_one_primary` → `rq2_business_over_fax`
  (Phone only) → `rq1_carveout`. Raw-representative rule (RQ-1): single primary's raw value,
  else lowest itemID among value-identical candidates; written form is TRIM(raw).

## Steps

| # | Action | Gate |
|---|---|---|
| 1 | `USE new_development;` then run `WO4_00_expectation_set.sql`; also re-run AGG-P1/E1/C1 from `docs/plans/evidence/2026-07-14-dir-lnk-wo3-engine-aggregate.sql` (EX-X baseline). **Capture all output verbatim.** | expected_writes per field must be <= 500 (else STOP: chunking decision) |
| 2 | Edit the three run_id literals' MMDD to the actual apply date in WO4_10/11/12 (keep suffixes -PH1/-EM1/-CO1). If the date is 2026-07-14 no edit is needed. | — |
| 3 | Run `WO4_10_backfill_phone.sql`. Before COMMIT: Step-3 sanity counts EQUAL each other and EQUAL EX-P's expected_writes total. | mismatch → ROLLBACK, paste output, STOP |
| 4 | Run `WO4_11_backfill_email.sql`, same gate vs EX-E. | same |
| 5 | Run `WO4_12_backfill_company.sql`, same gate vs EX-C. | same |
| 6 | Run `WO4_20_verification.sql` + re-run AGG-P1/E1/C1. Capture verbatim. | V-2 equal per run; V-3 all 'user'; V-4 == EX-0b; V-7 = 0; buckets == EX-X |
| 7 | **Idempotent re-run proof:** re-execute WO4_10/11/12 verbatim (same run_ids). Expect: Step 1 = 0 inserted, Step 2 = 0 updated. Capture verbatim. | any nonzero → STOP + report |
| 8 | Paste all captured output back to CC for the P3 proof bundle. | — |

## Rollback (only under a rollback decision, named-auth)

`WO4_90_rollback_by_runid.sql`: replace `@@RUN_ID@@` with ONE forward run_id; Stage 1 precheck
(zero DML) → review `diverged_will_skip` → Stage 2 transactional reversal (match-guarded,
audit-driven, inserts ADMIN_REPAIR rows under `<run_id>-RB`; audit rows never deleted/edited).
One run_id per execution; repeat per field run as needed.

## Expected-set provisional numbers (WO-3 dry run + P1 validation; superseded by step 1's live output)

See the P1 validation capture in `docs/plans/evidence/2026-07-14-dir-lnk-wo4-p1-expectation-validation.txt`
(read-only run of WO4_00 at authoring time). Deltas between that capture and step 1's live run
are expected to be zero-to-small (live dev drift) and must be explained in the P3 bundle.

**MATERIAL FINDING (P1 validation, 2026-07-14 17:40):** expected writes are **ZERO on all three
fields** — a follow-up structural check confirmed zero dev contacts have an empty primary column
while holding ANY usable candidate item (V3_10 Part A already populated every populatable
column). As authored, the dev apply is a structural no-op: it proves 0-write idempotency but
never exercises the write path. **Execution is HELD pending the architect/operator decision at
the P1 STOP** (accept no-op proof vs authorize a scoped fixture-based write-path proof).
