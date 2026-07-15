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

## Fixture lifecycle (line-review relay item 5 — BINDING; execution gated on D-2/D-3/D-4 stamps)

Because dev real-data expected writes are ZERO (V3_10 already populated everything), the write
path is proven on registered fixtures. Executor per D-3. Full sequence, capture everything:

| # | Action | Gate |
|---|---|---|
| F-1 | `WO4_05_fixture_setup.sql` (8 contacts / 12 items, test user 30, zero audit rows) | sanity 8/12 before COMMIT |
| F-2 | `WO4_06_fixture_register.sql` → **commit output to docs/plans/evidence/ BEFORE any backfill script runs** (protocol a) | register committed |
| F-3 | `WO4_00_expectation_set.sql` — must show **0 real + N fixture** (protocol c): EX-P = 3 writes (F1 one, F4 rq1, F5 rq2) + 1 G-LNK excl + 1 G-WIDTH excl; EX-E = 1 (F2 m1p); EX-C = 1 (F3 rq1); F8 absent (not eligible) | exact match or STOP |
| F-4 | Run 1: WO4_10/11/12 (run_ids `...-PH1/-EM1/-CO1`) | Step-3 sanity equal + = F-3 |
| F-5 | `WO4_20_verification.sql`: V-2 exact, V-3 all 'user', V-4 vs baseline, V-7 = 0, **V-8 G-REG = 0**, V-9 fax preserved | all pass |
| F-6 | Rollback: `WO4_90` with `@@RUN_ID@@` = each of the three run_ids (one per execution); columns back to NULL; ADMIN_REPAIR rows under `-RB` | Stage-1 counts match |
| F-7 | Run 2: WO4_10/11/12 edited ONLY at the run_id suffix (`-PH2/-EM2/-CO2`, W-1 keys re-derive) — **re-fills cleanly = W-1 deadlock disproven** | writes = F-3 again |
| F-8 | Same-run_id replay: re-execute the `-PH2/-EM2/-CO2` scripts verbatim — zero inserts, zero updates | 0/0 |
| F-9 | `WO4_20_verification.sql` again | all pass |
| F-10 | `WO4_95_fixture_cleanup.sql` (soft-delete fixtures; zero audit rows; counts must match register) | 8/12 → 0/0 |
| F-11 | Paste all captured output to CC → P3 bundle (fixture register, per-case PASS/FAIL, W-1 lifecycle proof, G-REG proof, real-data zero-write evidence) → STOP | — |

Fixture BACKFILL/ADMIN_REPAIR audit rows are PERMANENT test history under `WO4-DEV-FIXTURE-*`
run_ids (protocol f, subject to the D-4 stamp). Fixture contact/item IDs stay registered forever.

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
