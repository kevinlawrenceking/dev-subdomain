# WO-PHONEBOOK — Phase R (Recon) evidence

Date: 2026-07-03
Author: CC (Claude)
Scope: AuditionImportService.cfc email-resolution `INNER JOIN phonebook` (currently :1618-1630).
Gate status: RECON COMPLETE — STOP. Awaiting Kevin review before Phase P (Plan).

---

## R1 — History (never-functional vs orphaned-by-drop)

- Introducing commit (pickaxe `-S "INNER JOIN phonebook"` on the file):
  `c9305792` — "Add AuditionDuplicateMatcherService and ImportAuditionsLogger for
  enhanced audition import processing" — Kevin King, **2026-03-12**.
- Current line blame: `4e25a3b2c` (Kevin King, 2026-04-12) — a later readability
  refactor that MOVED the block; it did not originate the join. Origin = c9305792.
- Repo-history DDL search: `git log -S "phonebook" -- database/` returns ONLY the
  audit-doc markdown row (`| 153 | phonebook | Phone book data |`) in
  `04/03/09-database-schema.md`. **No CREATE TABLE phonebook and no DROP TABLE
  phonebook exists anywhere in repo history.**
- **VERDICT: NEVER-FUNCTIONAL.** The join has referenced a table that this repo has
  never created. Not orphaned-by-drop. The block has been dead since 2026-03-12.

## R2 — Intent (what it expects, what it feeds)

Block (current :1615-1635):
```
var contactId = 0;
if (len(trim(audData.contact_email))) {
    var qContact = queryExecute(
        "SELECT cd.contactid
         FROM contactdetails cd
         INNER JOIN phonebook pb ON pb.contactid = cd.contactid
         WHERE cd.userid = :userid AND pb.type = 'email'
           AND pb.phoneNumber = :email AND cd.IsDeleted = 0
         LIMIT 1", { userid, email }, ...);
    if (qContact.recordCount gt 0) { contactId = qContact.contactid; }
}
```
- Columns it expects from `phonebook`: `contactid`, `type` (= 'email'),
  `phoneNumber` (overloaded to hold an email string). This is a phone/email
  contact-method table that does not exist in TAO's live schema.
- Downstream of the resolved `contactId`:
  1. `projectContactId = castingContactId > 0 ? castingContactId : contactId`
     → written to `audprojects.contactid` (:1717, nullable when 0).
  2. `auditions.contactid` (flat back-compat table, :1795, nullable when 0).
  - It feeds NO xref and NO staging column. It is purely the contact link on the
    created project + flat audition row. When it stays 0, both are inserted NULL and
    **the row still imports** — the audition is created regardless.
- Note: there is a SECOND, working resolver immediately below (:1637-1652) that
  matches `contactdetails.contactFullName` by name with no phonebook dependency.
  Contact linkage by NAME already works today; only the EMAIL path is broken.

## R3 — Swallow check (does the exception escape?)

- Enclosing fn: `private struct function processRowForImport(...)` (:1551), whole body
  wrapped `try {` (:1559) … `catch (any e)` (:1879).
- The phonebook query (:1618) sits INSIDE that try but BEFORE the `transaction {`
  block (:1696).
- On `ER_NO_SUCH_TABLE`, catch :1879 runs and **swallows** the exception (no rethrow):
  - `writeLog(file="import_auditions", …)` — local log file, not error_tickets.
  - `logEvent(... event_type="row_import_error" ...)` → `import_auditions_events`.
  - `recordRowResult(action_taken="failed", error_code="IMPORT_EXCEPTION",
    error_message=left(e.message,500))` → `import_auditions_row_results`.
  - `UPDATE import_auditions_rows SET status='failed', import_error=<msg>`.
  - returns `{success:false, code:"IMPORT_EXCEPTION"}`.
- **User-visible result:** the row shows as **failed** in the finalize summary with an
  "IMPORT_EXCEPTION" / "Table 'phonebook' doesn't exist" message; the rest of the job
  continues (per-row isolation). No page crash.
- **CRITICAL for R4:** because the exception is swallowed at the row level and NEVER
  rethrown, it does **not** route through onError/ErrorService, so it will **not**
  appear in `error_tickets`. The WO's probe 4a is therefore expected to return ZERO
  even when the bug is firing — a zero there is a FALSE NEGATIVE, not exoneration.
  The real evidence surface is the import staging tables (see corrected probe 4a').
  This resolves the WO's "INCONCLUSIVE — onError routing UNPROVEN": routing is
  PROVEN ABSENT (local swallow).

## R5 — Failure-mode trace (Stage vs Finalize; partial-write / idempotency)

- The broken query lives in `processRowForImport`, called by `finalizeJob` (:1358).
  **The throw hits FINALIZE, not Stage.** Staging/parse never touches phonebook.
- The throw fires BEFORE `transaction {` (:1696) opens. Therefore **no partial write**:
  audprojects/audroles/events_tbl/auditions are all inside the transaction that never
  begins for a failing row. DB integrity intact.
- Idempotency (NN#8/NN#9): row is left `status='failed'` with a `row_results` row
  (action_taken='failed'). The idempotency guard (:1573) only short-circuits when
  action_taken='created', so a failed row is RETRIED on the next finalize — and, with
  phonebook still absent, fails again deterministically. No double-insert hazard
  (nothing was inserted). The failure is a hard block on importing any email-bearing
  row, not a data-corruption risk.

---

## R4 — SQL probes for Kevin (DO NOT run against prod from CC)

### 4a — WO-specified error_tickets probe (searchable columns derived from
### ErrorService.cfc INSERT list + 2026-04-17_error_tickets_add_root_cause.sql)
error_tickets text columns: error_message, error_detail, root_cause_type,
root_cause_message, root_cause_detail, cause_chain.
```sql
SELECT id, ticket_id, error_type, created_at, LEFT(error_message,200) AS msg
FROM error_tickets
WHERE error_message      LIKE '%phonebook%'
   OR error_detail       LIKE '%phonebook%'
   OR root_cause_type    LIKE '%phonebook%'
   OR root_cause_message LIKE '%phonebook%'
   OR root_cause_detail  LIKE '%phonebook%'
   OR cause_chain        LIKE '%phonebook%'
ORDER BY created_at DESC;
```
EXPECTED: **zero rows** (exception is swallowed pre-onError — see R3). Do not treat a
zero result as proof the bug never fired.

### 4a' — CORRECTED smoking-gun probe (staging error surfaces — where the swallow
### actually records it)
```sql
-- Per-row finalize failures that captured the phonebook error
SELECT rr.result_id, rr.job_id, rr.row_id, rr.error_code,
       LEFT(rr.error_message,300) AS error_message, rr.created_at
FROM import_auditions_row_results rr
WHERE rr.error_message LIKE '%phonebook%'
   OR rr.error_message LIKE '%ER_NO_SUCH_TABLE%'
   OR rr.error_message LIKE '%doesn''t exist%'
ORDER BY rr.created_at DESC;

-- Same signal on the rows table
SELECT row_id, job_id, status, LEFT(import_error,300) AS import_error, updated_at
FROM import_auditions_rows
WHERE import_error LIKE '%phonebook%'
   OR import_error LIKE '%doesn''t exist%'
ORDER BY updated_at DESC;
```

### 4b — Staging exposure: how many email-bearing rows were attempted
Email arrives as EAV fact `field_name='contact_email'`; the phonebook branch is
reached when that fact is non-empty and valid and the row has a project_name.
```sql
-- (i) All-time count of email-bearing audition-import rows (the trigger condition)
SELECT COUNT(DISTINCT f.row_id) AS rows_with_email
FROM import_auditions_facts f
WHERE f.field_name = 'contact_email'
  AND f.is_valid = 1
  AND f.normalized_value IS NOT NULL
  AND f.normalized_value <> '';

-- (ii) Distinct import jobs affected + total email rows
SELECT COUNT(DISTINCT r.job_id) AS jobs_affected, COUNT(*) AS email_rows
FROM import_auditions_facts f
JOIN import_auditions_rows r ON r.row_id = f.row_id
WHERE f.field_name = 'contact_email'
  AND f.is_valid = 1 AND f.normalized_value IS NOT NULL AND f.normalized_value <> '';

-- (iii) Terminal status of those email-bearing rows (did they reach finalize & fail?)
SELECT r.status, COUNT(*) AS n
FROM import_auditions_rows r
WHERE EXISTS (
  SELECT 1 FROM import_auditions_facts f
  WHERE f.row_id = r.row_id AND f.field_name='contact_email'
    AND f.is_valid=1 AND f.normalized_value IS NOT NULL AND f.normalized_value<>'')
GROUP BY r.status;
```

PRIORITY TRIGGER (per WO): flag for hotfix upgrade if **4a' hits** (phonebook error
captured in staging) OR **4b shows email-bearing rows routinely attempted**. 4a alone
will not hit due to the swallow; 4a' is the correct trigger surface.

---

## Findings summary table

| # | Question | Finding |
|---|----------|---------|
| R1 | When/who added the join; any DDL creates phonebook? | Added by c9305792 (2026-03-12, K.King); moved by 4e25a3b2c (2026-04-12). No CREATE/DROP TABLE phonebook in repo history. **NEVER-FUNCTIONAL.** |
| R2 | Expected columns / downstream feed | Expects phonebook.contactid/type/phoneNumber(=email). Feeds audprojects.contactid + auditions.contactid only; both nullable; row still imports on no-match. Name-based resolver below (:1637) already works. |
| R3 | Swallowed? | YES — caught by processRowForImport catch (:1879), not rethrown. Recorded to import_auditions_row_results + import_auditions_rows.import_error; row marked 'failed'; job continues; no page crash. Does NOT reach error_tickets. |
| R4 | Probes | 4a (error_tickets) expected zero = false-negative; 4a' (staging error cols) is the real smoking gun; 4b counts email-bearing rows attempted. Authored above for Kevin to run. |
| R5 | Stage or Finalize; partial-write/idempotency | FINALIZE (processRowForImport via finalizeJob). Throw fires pre-transaction → no partial write, DB intact. Failed rows retried on re-run, fail deterministically. No double-insert. Hard block on email-bearing rows. |

## Reachability statement (owed by prior threads)
The `INNER JOIN phonebook` at AuditionImportService.cfc:1621 is REACHABLE on the live
finalize path: gated only by `len(trim(audData.contact_email)) > 0` (:1617), not
dev-gated. Any audition-import row carrying a non-empty, valid `contact_email` and a
`project_name` reaches it during `finalizeJob` and fails ER_NO_SUCH_TABLE. Corroborated
by `auditions` having 55 rows and 0 with contactid.
