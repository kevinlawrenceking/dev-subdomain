# DIR-LNK-WO-4 — Line-Review Relay + W-1 Supplement (verbatim record)

Received 2026-07-14. Saved per D-16 doctrine. **NOTE OF RECORD (CC): items 3 and 4 arrived with
UNSTAMPED Kevin decision placeholders (D-1..D-4 both alternatives still bracketed). W-1/W-2
applied and all fixture assets authored HELD; zero execution occurs until the stamps arrive.**

---

DIR-LNK-WO-4 — LINE REVIEW VERDICT + NO-OP ADJUDICATION + OPTION B
Numbered items 1-6, END marker. Echo item count.

1. RECEIPT ANSWERS: END-marker — confirmed, HOLD POINTS was the final
   section of the lock; nothing followed; the omission was the
   architect's, convention now applies to lock documents. R-B2 —
   CLOSED as definitional on your simultaneous-instant proof; both
   WO-1 and WO-3 numbers correct under their own definitions;
   canonical governs forward.

2. LINE REVIEW: PASS WITH TWO AMENDMENTS. Approved: audit-driven
   design (work-queue inversion + in-transaction sanity count);
   G-LNK, definition pinned = exclude master_co_contact_id IS NOT
   NULL, all three fields; G-WIDTH, with skipped rows enumerated by
   ID and registered as a data-quality class; placement
   database/backfill/wo4/ stands (V3_10 precedent noted; WO-12 prod
   execution must reference these scripts by commit SHA; no V3_13).
   W-1 AMENDMENT (architect errata — corrects the lock's own key
   format): idempotency_key = 'BACKFILL:<field>:<contactID>:<run_id>'.
   Rationale: the run_id-less key deadlocks post-rollback
   re-application (original keys collide -> new run inserts nothing ->
   UPDATE joins nothing -> contact permanently unbackfillable
   on-script). Cross-run double-write remains prevented by the
   empty-destination selection; same-run retry still collides.
   W-2 AMENDMENT: the Step-2 UPDATE re-asserts
   (col IS NULL OR TRIM(col)='') as defense-in-depth.
   Apply W-1/W-2 to the held scripts; new local commit; no re-review
   cycle required — the fixture run is the empirical review.

3. NO-OP FINDING: ACCEPTED. V3_10 Part A already performed this
   operation on dev; zero expected real writes is the correct state.
   Option A rejected: it would ship the write path to WO-12 having
   never executed. OPTION B ADOPTED: [KEVIN D-1: ADOPTED / declined]

4. FIXTURE AUTHORIZATION (Kevin, 2026-07-14):
   [KEVIN D-2: AUTHORIZED / declined] — INSERTs into
   new_development contactdetails_tbl + contactitems_tbl, test user
   30 only, per protocol below. Prohibited regardless: any DML on
   non-fixture rows; any prod access beyond already-closed R-B2;
   any DDL.
   [KEVIN D-3: channel = CC via ratified pymysql under this narrow
   authorization / operator HeidiSQL per runbook]
   [KEVIN D-4: permanent fixture audit rows ACCEPTED / rejected]

5. FIXTURE PROTOCOL (binding): (a) register every fixture
   contactID/itemID BEFORE any script executes; commit the register.
   (b) Cases: one, multi_one_primary, rq1_carveout, rq2
   Business+WorkFax, G-LNK probe, G-WIDTH probe, PLUS one
   negative-selection true-conflict multi_multi case the scripts must
   skip. (c) Run the UNMODIFIED W-1/W-2-amended scripts; expectation
   set immediately prior must show 0 real + N fixture. (d) G-REG:
   post-run, every audit row's contactID must be in the register —
   any outsider = FAIL + rollback + STOP. (e) Lifecycle: run 1 ->
   verify (audit==writes exactly) -> audit-driven rollback
   (ADMIN_REPAIR, columns NULL) -> run 2 new run_id (re-fills; W-1
   deadlock disproven) -> same-run_id replay (zero effect) -> verify
   -> cleanup. (f) Fixture setup/cleanup write ZERO audit rows;
   fixture BACKFILL/ADMIN_REPAIR rows are permanent test history
   under WO4-DEV-FIXTURE run_ids. (g) Cleanup = soft-delete
   (IsDeleted=1) on fixture contacts + items; IDs registered
   permanently. (h) Deliver the P3 bundle per the lock, amended to
   include: fixture register, per-case PASS/FAIL, W-1 lifecycle
   proof, G-REG containment proof, and the real-data zero-write
   expectation evidence. STOP after bundle. No push without named
   PUSH GO.

6. HOLD POINTS unchanged: no prod writes; no retirement; no
   contactitems DML outside registered fixtures; no DDL;
   halt-don't-guess.
END RELAY — 6 items.

---

DIR-LNK-WO-4 — SUPPLEMENT: W-1 KEY FORMAT (TRANSIT MANGLING CORRECTION)
Single-item supplement to the 6-item relay. Echo receipt as "6 items;
W-1 key corrected by supplement."

The W-1 line arrived with its placeholders stripped ("BACKFILL:::").
Correct format, spelled to survive transit:

  idempotency_key = CONCAT('BACKFILL:', field_name, ':', contactID,
                           ':', run_id)

  Literal example:
  BACKFILL:contactPhone:900001:WO4-DEV-FIXTURE-20260714-01

Semantics per the original rationale: uniqueness is per column, per
contact, per run. Same-run retry collides (retry belt intact);
post-rollback re-application under a new run_id inserts cleanly (the
deadlock W-1 exists to fix); cross-run double-write remains prevented
by the empty-destination selection and the W-2 re-assertion. A key
lacking field and contactID would collapse a whole run to one audit
row via INSERT IGNORE — that is the failure this supplement prevents.
END SUPPLEMENT — 1 item.
