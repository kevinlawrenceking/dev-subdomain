# Contact Import V3 - Phase 9 Production Proof Bundle

## Overview

This document provides a structured template for collecting production deployment evidence for Contact Import V3. Phase 9 executes a controlled production deployment and produces a proof bundle demonstrating the system behaves correctly with the real schema (views + base tables) and real data sizes.

**Release Date:** (TBD)
**Prepared By:** Phase 9 Production Deployment
**Last Updated:** 2026-01-26

---

## A) Production Schema Verification

### A.1 Schema Structure Evidence

Run these commands in the **production** MySQL console and paste exact output below.

#### Check contactdetails and contactitems types

```sql
-- Expected: contactdetails and contactitems are VIEWs
SHOW FULL TABLES LIKE 'contactdetails';
SHOW FULL TABLES LIKE 'contactitems';
```

**Evidence (paste output):**
```
-- contactdetails:
Tables_in_actorsbusinessoffice (contactdetails)    Table_type
contactdetails                                      VIEW

-- contactitems:
Tables_in_actorsbusinessoffice (contactitems)      Table_type
contactitems                                        VIEW
```

#### Check base tables exist

```sql
-- Expected: contactdetails_tbl and contactitems_tbl are BASE TABLEs
SHOW FULL TABLES LIKE 'contactdetails_tbl';
SHOW FULL TABLES LIKE 'contactitems_tbl';
```

**Evidence (paste output):**
```
-- contactdetails_tbl:
Tables_in_actorsbusinessoffice (contactdetails_tbl)    Table_type
contactdetails_tbl                                      BASE TABLE

-- contactitems_tbl:
Tables_in_actorsbusinessoffice (contactitems_tbl)      Table_type
contactitems_tbl                                        BASE TABLE
```

#### View definitions (confirm IsDeleted filter)

```sql
SHOW CREATE VIEW contactdetails\G
SHOW CREATE VIEW contactitems\G
```

**Evidence (paste view definitions - confirm WHERE IsDeleted <> 1 or similar):**
```
-- Paste SHOW CREATE VIEW output here
-- Confirm views include IsDeleted filter
```

### A.2 Preflight Availability Check

The `isDupeDetectionAvailable()` function now reports:
- `tables`: Whether contactdetails/contactitems exist
- `table_types`: Whether each is VIEW or BASE TABLE
- `base_tables`: Whether contactdetails_tbl/contactitems_tbl exist
- `schema`: Current database name

**Verification:** After deployment, check importv3.log for entries like:
```
DupeService: contactdetails is VIEW, indexes on contactdetails_tbl base_table_exists=true
DupeService: contactitems is VIEW, indexes on contactitems_tbl base_table_exists=true
```

**Evidence (paste relevant log entries):**
```
-- Paste log entries here
```

---

## B) Migration Apply Evidence

### B.1 Pre-Migration Table Sizes

```sql
SELECT
    table_name,
    table_rows,
    ROUND(data_length / 1024 / 1024, 2) AS data_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_mb
FROM information_schema.TABLES
WHERE table_schema = 'actorsbusinessoffice'
  AND table_name IN ('contactdetails_tbl', 'contactitems_tbl');
```

**Evidence:**
```
table_name           table_rows    data_mb    index_mb
----------------------------------------------------
contactdetails_tbl   ________      ______     ______
contactitems_tbl     ________      ______     ______
```

### B.2 Migration Execution

**Migration File:** `database/migrations/V3_2__contact_import_v3_dupe_indexes.sql`

**Execution timestamps:**
- Start: ____________
- End: ____________
- Duration: ____________

**Execution method:** (SOURCE, mysql command, etc.)
```
-- Paste execution command here
```

**Migration output:**
```
-- Paste any output from CALL AddIndexIfNotExists statements
-- Expected: CREATED or EXISTS messages for each index
```

### B.3 Rollback Readiness

**Rollback file verified:** `database/migrations/V3_2__contact_import_v3_dupe_indexes_ROLLBACK.sql`

**Rollback tested in dev:** [ ] Yes / [ ] No

---

## C) EXPLAIN Evidence

Run these EXPLAIN queries in **production** after migration and paste full output.

### C.1 buildUserDupeIndex Query

Replace `12345` with a real production userid with significant contacts.

```sql
EXPLAIN SELECT ci.contactid, ci.valueCategory, ci.valuetext
FROM contactitems ci
INNER JOIN contactdetails d ON d.contactid = ci.contactid
WHERE d.userid = 12345
  AND (d.isdeleted IS NULL OR d.isdeleted = 0)
  AND ci.itemStatus = 'Active'
  AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
  AND ci.valueCategory IN ('Email', 'Phone')\G
```

**Evidence:**
```
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table:
   partitions:
         type: ______  (PASS: ref/range, FAIL: ALL)
possible_keys:
          key: ______  (PASS: idx_*, FAIL: NULL)
      key_len:
          ref:
         rows: ______  (should be proportional to user's contacts)
     filtered:
        Extra:
```

**PASS/FAIL:** [ ]

### C.2 getCandidateContactIds Query

```sql
EXPLAIN SELECT DISTINCT ci.contactid
FROM contactitems ci
INNER JOIN contactdetails d ON d.contactid = ci.contactid
WHERE d.userid = 12345
  AND (d.isdeleted IS NULL OR d.isdeleted = 0)
  AND ci.itemStatus = 'Active'
  AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
  AND (ci.valueCategory = 'Email' AND ci.valuetext IN ('test@example.com'))
LIMIT 100\G
```

**Evidence:**
```
-- Paste EXPLAIN output here
```

**PASS/FAIL:** [ ]

### C.3 Rows Pagination Query

Replace `123` with a real job_id.

```sql
EXPLAIN SELECT r.row_id, r.row_num, r.status, r.user_action
FROM import_v3_rows r
WHERE r.job_id = 123 AND r.status = 'ready'
ORDER BY r.row_num ASC
LIMIT 50 OFFSET 0\G
```

**Evidence:**
```
-- Paste EXPLAIN output here
-- Expected: key = IX_import_v3_rows_job_status
```

**PASS/FAIL:** [ ]

### C.4 Post-Migration Index Verification

```sql
SHOW INDEX FROM contactdetails_tbl WHERE Key_name LIKE '%dupe%' OR Key_name LIKE '%user%';
SHOW INDEX FROM contactitems_tbl WHERE Key_name LIKE '%dupe%' OR Key_name LIKE '%category%';
```

**Evidence:**
```
-- Paste SHOW INDEX output here
-- Expected indexes:
--   idx_contactdetails_tbl_dupe_v3
--   idx_contactitems_tbl_dupe_v3
--   idx_contactitems_tbl_category_status
```

---

## D) Production E2E Smoke Test

### D.1 Test Configuration

- **Test user ID:** ____________
- **Test CSV:** 5-20 rows with mix of valid contacts and known duplicates
- **Test date/time:** ____________

### D.2 Upload Phase

**Request:** `POST /ajax/importv3/upload.cfm`

**Response (redact tokens):**
```json
{
  "success": true,
  "data": {
    "job_id": ____,
    "filename": "______",
    "file_size": ____
  }
}
```

### D.3 Parse Phase

**Request:** `POST /ajax/importv3/parse.cfm?bypass=1`

**Response:**
```json
{
  "success": true,
  "data": {
    "job_id": ____,
    "total_rows": ____,
    "columns_detected": ____
  }
}
```

### D.4 Recompute Phase

**Request:** `POST /ajax/importv3/recompute.cfm?bypass=1`

**Response (key metrics):**
```json
{
  "success": true,
  "data": {
    "job": {
      "status": "reviewing",
      "total_rows": ____,
      "valid_rows": ____,
      "problem_rows": ____,
      "dupe_rows": ____
    },
    "metrics": {
      "elapsed_ms_total": ____,
      "dupe_detection_mode": "ran",
      "dupe_index_build_ms": ____,
      "dupe_index_items_total": ____,
      "dupe_index_contactids_total": ____,
      "dupe_queries_total": ____
    }
  }
}
```

### D.5 Review Phase (rows.cfm)

**Request:** `GET /ajax/importv3/rows.cfm?bypass=1&job_id=____&status=ready&limit=50`

**Response:**
```json
{
  "success": true,
  "data": {
    "rows": [...],
    "total": ____,
    "elapsed_ms": ____
  }
}
```

### D.6 Finalize Phase

**Request:** `POST /ajax/importv3/finalize.cfm?bypass=1`

**Response:**
```json
{
  "success": true,
  "data": {
    "job_id": ____,
    "status": "completed",
    "counts": {
      "imported_new": ____,
      "skipped_dupe": ____,
      "skipped_problem": ____,
      "failed": ____
    },
    "metrics": {
      "elapsed_ms_total": ____,
      "elapsed_ms_per_row_avg": ____
    }
  }
}
```

### D.7 Data Verification

```sql
-- Count contacts created by test job
SELECT COUNT(*) as created_contacts
FROM contactdetails_tbl
WHERE created_by_import_job = [JOB_ID];

-- Verify matches job record
SELECT imported_rows FROM import_v3_jobs WHERE job_id = [JOB_ID];

-- Check row_results distribution
SELECT result_code, COUNT(*) as cnt
FROM import_v3_row_results
WHERE job_id = [JOB_ID]
GROUP BY result_code;
```

**Evidence:**
```
-- Paste query results here
```

---

## E) Concurrency Proof

### E.1 Double-Click Finalize Test

**Procedure:**
1. Create a test job with 10-20 rows
2. Open browser dev tools Network tab
3. Click "Finalize Import"
4. Immediately click again (within 500ms)

**Evidence - First request:**
```json
{
  "success": true,
  "code": "",
  ...
}
```

**Evidence - Second request:**
```json
{
  "success": false,
  "code": "ALREADY_RUNNING" OR "LOCKED",
  "message": "..."
}
```

**HTTP status of second request:** 409

### E.2 Re-Finalize Attempt

**Procedure:** After job completes, attempt to finalize again

**Evidence:**
```json
{
  "success": false,
  "code": "INVALID_STATE",
  "message": "Cannot finalize from status: completed..."
}
```

### E.3 Database Verification

```sql
-- Verify no duplicate row_results
SELECT row_id, COUNT(*) as result_count
FROM import_v3_row_results
WHERE job_id = [JOB_ID]
GROUP BY row_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows (no duplicates)

-- Verify row_results count matches intended rows
SELECT
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = [JOB_ID] AND status IN ('ready', 'dupe')) as intended,
    (SELECT COUNT(*) FROM import_v3_row_results WHERE job_id = [JOB_ID]) as actual;
-- Expected: intended = actual
```

**Evidence:**
```
-- Paste results here
```

---

## F) Post-Release Monitoring Checklist

### F.1 Log Files to Monitor

| Log File | Location | What to Watch |
|----------|----------|---------------|
| importv3.log | CF logs dir | Errors, dupe_detection modes, timing anomalies |
| exception.log | CF logs dir | Uncaught exceptions in import endpoints |
| slow_queries.log | MySQL logs | Queries > 5s on contactdetails/contactitems |

### F.2 Error Codes Indicating Regression

| Code | Meaning | Action |
|------|---------|--------|
| `CSRF_INVALID` spike | CSRF validation failing | Check session handling, token generation |
| `LOCKED` loops | Job lock not releasing | Check for stuck finalizing jobs |
| `skipped_index_too_large` | Dupe index guardrails hit | Normal for large users, monitor frequency |
| `skipped_index_timeout` | Dupe index build timeout | Investigate query performance |

### F.3 Health Check Queries

Run these periodically (daily for first week, then weekly):

```sql
-- 1. Jobs in stuck states
SELECT job_id, status, userid, updated_at,
       TIMESTAMPDIFF(MINUTE, updated_at, NOW()) as minutes_stale
FROM import_v3_jobs
WHERE status IN ('uploading', 'parsing', 'finalizing')
  AND updated_at < DATE_SUB(NOW(), INTERVAL 30 MINUTE);
-- Action if rows found: Investigate, possibly reset status

-- 2. Job counts consistency
SELECT j.job_id,
       j.total_rows as job_total,
       j.imported_rows as job_imported,
       COUNT(r.row_id) as actual_rows,
       SUM(CASE WHEN r.status = 'imported' THEN 1 ELSE 0 END) as actual_imported
FROM import_v3_jobs j
LEFT JOIN import_v3_rows r ON j.job_id = r.job_id
WHERE j.status = 'completed'
  AND j.created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY j.job_id
HAVING j.total_rows != actual_rows OR j.imported_rows != actual_imported
LIMIT 10;
-- Expected: 0 rows

-- 3. Row results distribution sanity
SELECT
    DATE(rr.created_at) as date,
    rr.result_code,
    COUNT(*) as count
FROM import_v3_row_results rr
WHERE rr.created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(rr.created_at), rr.result_code
ORDER BY date DESC, count DESC;
-- Review: failed counts should be < 5% of imported

-- 4. Dupe detection performance (from recompute metrics in logs)
-- grep for "dupe_index_build_ms" in importv3.log
-- Alert threshold: > 5000ms consistently

-- 5. Orphan detection
SELECT COUNT(*) as orphan_rows FROM import_v3_rows r
LEFT JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE j.job_id IS NULL;
-- Expected: 0

SELECT COUNT(*) as orphan_facts FROM import_v3_facts f
LEFT JOIN import_v3_rows r ON f.row_id = r.row_id
WHERE r.row_id IS NULL;
-- Expected: 0
```

---

## G) Summary Checklist

| Item | Status | Evidence Location | Verified By | Date |
|------|--------|-------------------|-------------|------|
| Schema verification (views confirmed) | [ ] | Section A | | |
| Base tables exist | [ ] | Section A | | |
| Migration applied | [ ] | Section B | | |
| Indexes created | [ ] | Section C.4 | | |
| EXPLAIN query 1 pass | [ ] | Section C.1 | | |
| EXPLAIN query 2 pass | [ ] | Section C.2 | | |
| EXPLAIN query 3 pass | [ ] | Section C.3 | | |
| E2E smoke test pass | [ ] | Section D | | |
| Concurrency test pass | [ ] | Section E | | |
| No data integrity issues | [ ] | Section E.3 | | |
| Monitoring configured | [ ] | Section F | | |

---

## H) Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Developer | | | |
| QA/Test | | | |
| DBA | | | |
| Product Owner | | | |

---

*Document Version: Phase 9.0*
*DONE_TOKEN: PHASE9_DONE*
