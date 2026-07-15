# DIR-LNK-WO-4 — OPERATOR STAMP BLOCK (D-1 THROUGH D-4) — verbatim record

Addendum beside `DIR-LNK-WO4-LINEREVIEW-RELAY.md`; this block is the authorization of record
for the fixture write-path proof. Received and committed 2026-07-14.

---

DIR-LNK-WO-4 — OPERATOR STAMP BLOCK (D-1 THROUGH D-4)
Kevin, 2026-07-14. These are the four decisions the line-review relay
carried as unfilled brackets. This block is the authorization of
record. Commit it verbatim (docs-class) as an addendum beside
DIR-LNK-WO4-LINEREVIEW-RELAY.md, then execute immediately.

D-1: ADOPTED. Option B fixture-based write-path proof proceeds.

D-2: AUTHORIZED. Fixture DML on new_development only: INSERTs into
contactdetails_tbl and contactitems_tbl, test user 30 only, per the
binding fixture protocol as committed. Prohibited regardless: DML on
any non-fixture row; any prod access; any DDL.

D-3: CHANNEL = CC via the ratified pymysql connection under this
narrow write authorization. Recorded as a named exception to the
operator-executes-DML doctrine, scoped to fixture rows and the WO-4
scripts only.

D-4: ACCEPTED. Fixture BACKFILL and ADMIN_REPAIR audit rows are
permanent test history under the WO4-DEV-FIXTURE run_id family.

Execute F-1 through F-11 per the runbook. The P3 bundle must include
the explicit per-case field and expected-outcome table. STOP after
the bundle. No push without a named PUSH GO.
