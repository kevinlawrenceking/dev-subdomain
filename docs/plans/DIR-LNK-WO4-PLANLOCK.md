PROPOSED — DIR-LNK-WO-4 PLAN LOCK (BACKFILL PRIMARY VALUES — DEV EXECUTION)

AUTHORIZATION
Operator approval of this document authorizes: dev-only DML on
new_development (contactdetails_tbl primary columns) + transactional
audit inserts (first live use of master_audit_tbl). Nothing else.
Prod backfill is NOT authorized here — it rides the WO-12 controlled
rollout (master_audit_tbl does not exist on prod until WO-12's DDL;
transactional audit inserts are impossible before it).

SCOPE LOCK
Populate empty primary phone/email/company columns on new_development
from the contact's own active contactitems, per the ratified engine +
adopted rulings. Zero DDL. Zero contactitems mutation (RQ-3/RQ-5i: no
retirement, no soft-deletes, no item edits). Exceptions (~1,280 class)
untouched. _src is NOT written — values are user-originated (PC-3);
the column already defaults 'user'. No view/app/linking changes. No
prod access beyond the R-B2 aggregate recount.

P0 — BOOTSTRAP
a) Save this lock to docs/plans/DIR-LNK-WO4-PLANLOCK.md (docs commit).
b) Verify origin/dev HEAD; re-read rulings addendum 1e7af179 and the
   engine files (2908076d); quote the dev bucket counts from the WO-3
   dry run as the provisional expectation set.
c) R-B2: aggregate-only prod recount of Phone multi_multi_primary;
   one-line diagnosis of 7,644 vs 7,643 (live drift vs definitional).
   No row-level prod output.

P1 — DESIGN + AUTHORING (no execution), then STOP for line review
a) RAW-REPRESENTATIVE RULE (RQ-1 obligation — Kevin stamps with this
   lock): for value-safe groups (all candidates normalize identical),
   the written display form is (i) the raw value of the single
   primary_YN='Y' row when exactly one exists; (ii) otherwise the raw
   value of the LOWEST itemID, documented in-file as a deterministic
   PRESENTATION tiebreak only — value equivalence is already proven by
   normalization, so this is not a value-selection heuristic and does
   not touch the newest/oldest/first/last/frequency prohibition.
b) Selection = the ratified engine RE-EXECUTED LIVE at run time:
   buckets one + multi_one_primary + RQ-1 carve-out + RQ-2 pattern
   (exactly one Business + one Work Fax, both primary -> Business),
   destination column canonically empty
   (IsDeleted=0 AND (col IS NULL OR TRIM(col)='')).
c) Backfill scripts per field: chunked UPDATEs (<=500 contacts per
   transaction); each chunk transactionally pairs the column write
   with one master_audit_tbl insert per populated column:
   action_type='BACKFILL_FROM_CONTACTITEM', actor_type='migration',
   actor_userid NULL, field_name, old_value NULL, new_value=<written>,
   run_id='WO4-DEV-2026MMDD-<seq>',
   idempotency_key='BACKFILL:<contactID>:<field>' (deterministic ->
   any re-run collides on UQ_master_audit_idem and skips; belt on top
   of the empty-column selection suspenders).
d) ROLLBACK (authored with the forward scripts): audit-DRIVEN reversal
   — for a named run_id, set each audited column back to old_value
   (NULL) via join to master_audit_tbl; the reversal itself INSERTS
   new audit rows (action_type='ADMIN_REPAIR',
   reason='WO-4 rollback run_id=<X>'). Audit rows are NEVER deleted or
   edited — append-only holds even in rollback.
e) Evidence discipline: repo commits carry scripts + ID/aggregate
   evidence only; value-level detail lives in the audit TABLE (its
   purpose) and local working files (manifest'd), never in committed
   docs.

P2 — OPERATOR DEV APPLY (Kevin, HeidiSQL, new_development)
Runbook delivered at the P1 STOP: fresh live classification counts
generated immediately before execution (expected-set table), per-chunk
execution with statement capture, per-chunk verification queries.

P3 — PROOF + STOP
Bundle (docs commit): before/after per-field populated counts;
audit-row count == populated-column count, exactly; idempotent re-run
proof (second run -> zero writes: empty selection + idempotency-key
collisions); exception-queue-untouched proof (bucket counts unchanged
pre/post); reconciliation of actuals vs the live expectation set with
any delta explained; run_id register; PASS/FAIL per criterion; push
set; STOP. WO-5 (read cutover) is a separate lock.

HOLD POINTS
No prod writes ever in this WO. No retirement. No contactitems DML.
No DDL. No pushes without named PUSH GO. Halt-don't-guess.

--- RECEIPT NOTE (CC, 2026-07-14): relay arrived without an END marker;
--- HOLD POINTS treated as the closing section. Flagged at the P1 STOP
--- for operator confirmation. Document above is otherwise verbatim.
