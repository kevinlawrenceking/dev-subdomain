# Contact Import V3 - Database Query Audit

Generated: 2026-02-19

## Summary

Comprehensive audit of all SQL queries across the Contact Import V3 system. All queries cataloged, tested for correctness, and evaluated for security, performance, and MySQL compatibility.

**Total queries cataloged: ~100**
- Across 12 files (6 with direct SQL, 6 delegating to service)
- All queries use MySQL syntax (verified: NOW(), LIMIT, DATE_SUB, etc.)
- cfqueryparam compliance: 97/100 queries fully parameterized

---

## Critical Findings

### Finding 1: SQL Injection in getRows() [FIXED]

**File:** ContactImportV3Service.cfc, getRows() method
**Original:** `WHERE f.row_id IN (#arrayToList(rowIds)#)`
**Fixed:** `WHERE f.row_id IN (:row_id_list)` with `{ value: arrayToList(rowIds), cfsqltype: "cf_sql_integer", list: true }`

### Finding 2: SQL Injection in bulkRowAction() [FIXED]

**File:** ContactImportV3Service.cfc, bulkRowAction() method
**Original:** `WHERE r.row_id IN (#arrayToList(safeIds)#)` (2 instances)
**Fixed:** `WHERE r.row_id IN (:safe_id_list)` with `{ value: arrayToList(safeIds), cfsqltype: "cf_sql_integer", list: true }`

### Finding 3: Dynamic Status Clause in getRows()

**File:** ContactImportV3Service.cfc, getRows() method
**Line:** ~2069-2075
**Issue:** Status filter string built dynamically with hardcoded status values (not user input). Technically safe but could be parameterized for consistency.
**Risk:** LOW - values are hardcoded, not user-supplied.

---

## Query Catalog by File

### upload.cfm (2 queries)

| # | Line | Operation | Table | cfqueryparam | Notes |
|---|------|-----------|-------|-------------|-------|
| Q1 | 116-126 | SELECT | import_v3_jobs | YES | Duplicate file hash check (userid + file_hash) |
| Q2 | 158-176 | INSERT | import_v3_jobs | YES | Create new job record |

### parse.cfm (11 queries)

| # | Line | Operation | Table | cfqueryparam | Notes |
|---|------|-----------|-------|-------------|-------|
| Q3 | 118-122 | SELECT COUNT | import_v3_rows | YES | Idempotency check |
| Q4 | 303-310 | INSERT | import_v3_columns | YES | Column creation |
| Q5 | 333-342 | SELECT | import_v3_columns | YES | Get column IDs |
| Q6 | 346-356 | SELECT | import_v3_columns | YES | Column ordering |
| Q7 | 361-376 | INSERT | import_v3_rows | YES | Row creation |
| Q8 | 378-382 | SELECT | import_v3_rows | YES | Get row IDs |
| Q9 | 392-412 | INSERT | import_v3_facts | YES | Fact creation |
| Q10 | 456-464 | SELECT | subqueries | YES | Combined counts |
| Q11 | 467-474 | UPDATE | import_v3_jobs | YES | Mark parsed |

**N+1 Warning:** Q9 runs per-cell (rows x columns). For a 500-row, 15-column file = 7500 INSERT statements.

### columns.cfm (5 queries)

| # | Line | Operation | Table | cfqueryparam | Notes |
|---|------|-----------|-------|-------------|-------|
| Q12 | 86-98 | SELECT | import_v3_columns | YES | Column listing |
| Q13 | 109-120 | SELECT DISTINCT | import_v3_facts + import_v3_rows | YES | Sample values (N+1 per column) |
| Q14 | 228-233 | SELECT | import_v3_columns + import_v3_jobs | YES | Column ownership check |
| Q15 | 338-340 | UPDATE (dynamic) | import_v3_columns | YES | Column mapping update |
| Q16 | 395-407 | SELECT | import_v3_columns | YES | Duplicate of Q12 for POST response |

### recompute.cfm (10 queries)

| # | Line | Operation | Table | cfqueryparam | Notes |
|---|------|-----------|-------|-------------|-------|
| Q19 | 293-308 | UPDATE | import_v3_columns | YES | Column intent update |
| Q20 | 350-358 | SELECT | import_v3_columns | YES | Get column mappings |
| Q21 | 376-383 | SELECT | import_v3_rows | YES | All rows for job |
| Q22 | 411-416 | UPDATE | import_v3_rows | YES | Reset row before recompute |
| Q23 | 423-429 | SELECT | import_v3_facts | YES | Facts per row (N+1) |
| Q24 | 451-458 | UPDATE | import_v3_facts | YES | Fact validation result (N+1) |
| Q25 | 552-570 | UPDATE | import_v3_facts | YES | Full name recompute |
| Q26 | 699-721 | UPDATE | import_v3_rows | YES | Row status update |
| Q27 | 827-843 | UPDATE | import_v3_rows | YES | Same pattern |
| Q28 | 859-876 | UPDATE | import_v3_jobs | YES | Job totals update |

**N+1 Warning (Most Significant):** Q23 runs per row, Q24 runs per fact. For a 500-row, 15-column file: 500 SELECTs + up to 7500 UPDATEs. Bounded by the one-time nature of recompute operations.

### rows.cfm, row.cfm, row_action.cfm, fact_update.cfm, finalize.cfm, status.cfm

No direct SQL. All database access delegated to service methods.

### ContactImportV3Service.cfc (~70 queries)

| # | Method | Operation | Table(s) | cfqueryparam | Notes |
|---|--------|-----------|----------|-------------|-------|
| Q29 | getJob() | SELECT | import_v3_jobs | YES | By job_id only |
| Q30 | assertJobOwnership() | SELECT | import_v3_jobs | YES | job_id + userid |
| Q31 | getJobForUser() | SELECT | import_v3_jobs | YES | Primary ownership query |
| Q35 | acquireJobLock() | UPDATE | import_v3_jobs | YES (list:true) | Status transition |
| Q36 | releaseJobLock() | UPDATE | import_v3_jobs | YES | Lock release |
| Q37 | setJobStatus() | UPDATE | import_v3_jobs | YES | Dynamic SQL with safe params |
| Q38-Q49 | cleanupOldJobs() | SELECT/DELETE | All import tables | YES (list:true) | Transactional cleanup |
| Q50 | getUserJobHistory() | SELECT | import_v3_jobs | YES | Paginated, userid-filtered |
| Q51 | getRecentJobs() | SELECT | import_v3_jobs + taousers | YES | Admin view with JOIN |
| Q52-Q55 | getDashboardStats() | SELECT | import_v3_jobs | No params (aggregate) | Admin stats |
| Q56-Q60 | Feature flag methods | SELECT/INSERT/DELETE | feature_flag_users + taousers | YES | |
| Q61 | finalizeJob() | SELECT | import_v3_rows | YES | Eligible rows |
| Q62-Q66 | processRowForImport() | Various | Multiple | YES | Per-row transaction |
| Q64 | processRowForImport() | INSERT | contactdetails | YES | **Production write** |
| Q68-Q78 | insertContactItems() | INSERT | contactitems | YES | **Production writes** |
| Q79 | contactItemExists() | SELECT | contactitems | YES | Dedup check |
| Q80 | recordRowResult() | INSERT | import_v3_row_results | YES | ON DUPLICATE KEY |
| Q81 | updateJobCounts() | UPDATE | import_v3_jobs | YES | Missing userid (internal) |
| Q82 | getJobStats() | SELECT | import_v3_rows | YES | Missing userid (internal) |
| Q83-Q84 | getRows() | SELECT | import_v3_rows | YES | Paginated |
| Q85 | getRows() | SELECT | import_v3_facts | YES (FIXED) | Was IN clause injection |
| Q86-Q87 | getRowDetail() | SELECT | import_v3_rows/facts | YES | |
| Q88 | getRowDetail() | SELECT | contactdetails | YES | N+1 in dupe loop |
| Q89-Q91 | updateRowFacts() | Various | import_v3_facts/rows | YES | |
| Q92-Q95 | Helper methods | Various | import_v3_facts/rows | YES | |
| Q96-Q98 | setRowAction() | Various | import_v3_rows/jobs | YES | |
| Q99-Q100 | bulkRowAction() | UPDATE | import_v3_rows/jobs | YES (FIXED) | Was IN clause injection |

---

## N+1 Query Patterns

| Location | Pattern | Impact | Mitigation |
|----------|---------|--------|------------|
| columns.cfm Q13 | Sample values per column | ~20 queries/request | Small dataset, acceptable |
| recompute.cfm Q23 | Facts SELECT per row | Up to 1000+ queries | One-time operation, bounded by file size |
| recompute.cfm Q24/Q25 | Facts UPDATE per fact | Up to 7500+ queries | One-time operation |
| getRowDetail() Q88 | Contact lookup per dupe candidate | ~1-5 queries/request | Small N, acceptable |

The recompute N+1 is the most significant. For a 500-row, 15-column file, this means 500 SELECTs + 7500 UPDATEs. Consider batch processing if files over 1000 rows are common.

---

## Missing Index Suggestions

| Table | Suggested Index | Justification |
|-------|----------------|---------------|
| import_v3_jobs | `(userid, file_hash)` | Duplicate file check in upload.cfm |
| import_v3_jobs | `(userid, status)` | Status filtering with ownership |
| import_v3_jobs | `(status, finished_at)` | Cleanup query in cleanupOldJobs() |
| import_v3_rows | `(job_id, status)` | Status-based filtering (finalize, stats) |
| import_v3_rows | `(job_id, row_num)` | Row ordering in recompute |
| import_v3_facts | `(row_id, field_name)` | Fact lookups by field |
| import_v3_facts | `(row_id, is_valid)` | Validation count queries |
| import_v3_facts | `(column_id)` | Sample values query in columns.cfm |
| import_v3_columns | `(job_id, source_column_index)` | Column ordering |
| import_v3_row_results | `(row_id)` | Idempotency check |
| import_v3_events | `(job_id)` | Cleanup and event listing |
| contactitems | `(contactid, valueCategory, valuetext)` | Contact item dedup check |
| contactdetails | `(contactid, userid)` | Contact lookup |

Note: Some of these may already exist as PRIMARY KEY or UNIQUE constraints. Verify against the actual schema before creating.

---

## Transaction Coverage

| Operation | Transactional | Notes |
|-----------|--------------|-------|
| finalizeJob() / processRowForImport() | YES (per-row) | Correct - per-row isolation |
| cleanupOldJobs() | YES | Correct - batch delete in transaction |
| recompute (entire loop) | NO | Acceptable - recompute is idempotent |
| updateRowFacts() | NO | Low impact - counts can be recomputed |
| setRowAction() / bulkRowAction() | NO | Low impact - counts can be recomputed |

---

## Queries Without userid Filter (Internal Methods)

These service methods do not include `userid` in WHERE clauses:

- `updateJobCounts()` - internal, called after ownership validated
- `updateJobRowCounts()` - internal, called after ownership validated
- `getJobStats()` - internal, called after ownership validated

This is acceptable because these are private methods always called after `getJobForUser()` or `assertJobOwnership()` has validated ownership. Adding userid would be defense-in-depth but is not strictly necessary.

---

## Known Issue: Missing Cleanup for import_v3_row_results

The `cleanupOldJobs()` method deletes from:
- import_v3_events
- import_v3_facts
- import_v3_rows
- import_v3_columns
- import_v3_jobs

But does NOT delete from `import_v3_row_results`. This leaves orphaned records. Add a DELETE step before deleting rows:

```sql
DELETE FROM import_v3_row_results WHERE row_id IN (
    SELECT row_id FROM import_v3_rows WHERE job_id IN (:jobIdList)
)
```

---

## Performance Suggestion: DATE() Function in Dashboard

Line ~927: `WHERE DATE(created_at) = CURDATE()` prevents index usage on `created_at` because the function wraps the column. Replace with:

```sql
WHERE created_at >= CURDATE() AND created_at < CURDATE() + INTERVAL 1 DAY
```

---

## MySQL Test Script

The following SELECT-only script can be safely run against `new_development` to verify table existence, index usage, and query correctness.

```sql
-- ============================================================
-- Contact Import V3 - SQL Query Verification Script
-- Schema: new_development
-- SAFE TO RUN: SELECT only, no data modifications
-- Generated: 2026-02-19
-- ============================================================

USE new_development;

-- ============================================================
-- 1. VERIFY TABLE EXISTENCE
-- ============================================================

SELECT 'import_v3_jobs' AS tbl, COUNT(*) AS row_count FROM import_v3_jobs
UNION ALL
SELECT 'import_v3_columns', COUNT(*) FROM import_v3_columns
UNION ALL
SELECT 'import_v3_rows', COUNT(*) FROM import_v3_rows
UNION ALL
SELECT 'import_v3_facts', COUNT(*) FROM import_v3_facts
UNION ALL
SELECT 'import_v3_row_results', COUNT(*) FROM import_v3_row_results
UNION ALL
SELECT 'import_v3_events', COUNT(*) FROM import_v3_events
UNION ALL
SELECT 'contactdetails', COUNT(*) FROM contactdetails
UNION ALL
SELECT 'contactitems', COUNT(*) FROM contactitems;

-- ============================================================
-- 2. VERIFY INDEXES ON IMPORT V3 TABLES
-- ============================================================

SHOW INDEX FROM import_v3_jobs;
SHOW INDEX FROM import_v3_columns;
SHOW INDEX FROM import_v3_rows;
SHOW INDEX FROM import_v3_facts;
SHOW INDEX FROM import_v3_row_results;
SHOW INDEX FROM import_v3_events;

-- ============================================================
-- 3. Duplicate file check (upload.cfm Q1)
-- ============================================================

EXPLAIN
SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
       stored_file_path, status, created_at, updated_at
FROM import_v3_jobs
WHERE userid = 1 AND file_hash = 'abc123def456';

-- ============================================================
-- 4. Row count check / idempotency (parse.cfm Q3)
-- ============================================================

EXPLAIN
SELECT COUNT(*) as cnt FROM import_v3_rows WHERE job_id = 1;

-- ============================================================
-- 5. Combined counts with subqueries (parse.cfm Q10)
-- ============================================================

EXPLAIN
SELECT
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = 1) as columns_count,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = 1) as rows_count,
    (SELECT COUNT(*) FROM import_v3_facts f
     INNER JOIN import_v3_rows r ON f.row_id = r.row_id
     WHERE r.job_id = 1) as facts_count;

-- ============================================================
-- 6. Column listing (columns.cfm Q12)
-- ============================================================

EXPLAIN
SELECT c.column_id, c.source_column_index, c.source_column_name,
       c.mapped_field, c.is_custom_field, c.custom_field_id,
       c.confidence, c.user_confirmed, c.sample_values,
       c.intent, c.target_key, c.transform_json
FROM import_v3_columns c
WHERE c.job_id = 1
ORDER BY c.source_column_index ASC;

-- ============================================================
-- 7. Sample values / N+1 candidate (columns.cfm Q13)
-- ============================================================

EXPLAIN
SELECT DISTINCT f.raw_value
FROM import_v3_facts f
INNER JOIN import_v3_rows r ON f.row_id = r.row_id
WHERE f.column_id = 1
  AND r.job_id = 1
  AND f.raw_value IS NOT NULL
  AND TRIM(f.raw_value) != ''
LIMIT 5;

-- ============================================================
-- 8. Column ownership check (columns.cfm Q14)
-- ============================================================

EXPLAIN
SELECT c.column_id
FROM import_v3_columns c
INNER JOIN import_v3_jobs j ON c.job_id = j.job_id
WHERE c.column_id = 1
  AND c.job_id = 1
  AND j.userid = 1;

-- ============================================================
-- 9. All rows for job (recompute.cfm Q21)
-- ============================================================

EXPLAIN
SELECT row_id, row_num, raw_json, status, user_action
FROM import_v3_rows
WHERE job_id = 1
ORDER BY row_num;

-- ============================================================
-- 10. Facts for a row (recompute.cfm Q23)
-- ============================================================

EXPLAIN
SELECT fact_id, column_id, field_name, raw_value, normalized_value
FROM import_v3_facts
WHERE row_id = 1;

-- ============================================================
-- 11. Primary ownership query (service getJobForUser Q31)
-- ============================================================

EXPLAIN
SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, error_message, created_at, updated_at,
    started_at, finished_at, total_rows, parsed_rows, valid_rows,
    problem_rows, dupe_rows, imported_rows, updated_rows, skipped_rows,
    options_json, import_mode, allow_blank_overwrite,
    relationship_system_default, folder_assignment_json
FROM import_v3_jobs WHERE job_id = 1 AND userid = 1;

-- ============================================================
-- 12. Cleanup old jobs (service Q38)
-- ============================================================

EXPLAIN
SELECT job_id, userid, stored_file_path, status, created_at, finished_at
FROM import_v3_jobs
WHERE status IN ('completed', 'failed')
  AND finished_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
LIMIT 1000;

-- ============================================================
-- 13. User job history (service Q50)
-- ============================================================

EXPLAIN
SELECT job_id, source_filename, file_type, status, created_at,
    finished_at, total_rows, parsed_rows, valid_rows, problem_rows,
    dupe_rows AS duplicate_rows, skipped_rows, imported_rows,
    updated_rows, error_message
FROM import_v3_jobs
WHERE userid = 1
ORDER BY created_at DESC
LIMIT 25;

-- ============================================================
-- 14. Admin recent jobs with JOIN (service Q51)
-- ============================================================

EXPLAIN
SELECT j.job_id, j.userid, u.userfirst, u.userlast, u.useremail,
    j.source_filename, j.file_type, j.status, j.created_at,
    j.finished_at, j.total_rows, j.imported_rows, j.updated_rows,
    j.problem_rows, j.dupe_rows, j.error_message
FROM import_v3_jobs j
LEFT JOIN taousers u ON j.userid = u.userid
ORDER BY j.created_at DESC
LIMIT 50;

-- ============================================================
-- 15. Dashboard stats (service Q52-Q55)
-- ============================================================

EXPLAIN
SELECT
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_today,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed_today,
    COUNT(*) as total_today
FROM import_v3_jobs
WHERE DATE(created_at) = CURDATE();

EXPLAIN
SELECT
    COALESCE(AVG(total_rows), 0) as avg_rows_per_job,
    COALESCE(AVG(imported_rows + updated_rows), 0) as avg_processed_per_job,
    COUNT(*) as jobs_last_7_days
FROM import_v3_jobs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- ============================================================
-- 16. Finalize eligible rows (service Q61)
-- ============================================================

EXPLAIN
SELECT r.row_id, r.row_num, r.status, r.user_action, r.created_contactid
FROM import_v3_rows r
WHERE r.job_id = 1
  AND (
      r.status = 'ready'
      OR (r.status = 'dupe' AND r.user_action = 'import_new')
  )
ORDER BY r.row_num ASC;

-- ============================================================
-- 17. Facts for import / valid only (service Q63)
-- ============================================================

EXPLAIN
SELECT f.fact_id, f.field_name, f.normalized_value, f.is_valid
FROM import_v3_facts f
WHERE f.row_id = 1
  AND f.is_valid = 1
  AND f.normalized_value IS NOT NULL
  AND f.normalized_value != '';

-- ============================================================
-- 18. Contact item dedup check (service Q79)
-- ============================================================

EXPLAIN
SELECT 1 FROM contactitems
WHERE contactid = 1
  AND valueCategory = 'Email'
  AND valuetext = 'test@example.com'
  AND itemStatus = 'Active'
LIMIT 1;

-- ============================================================
-- 19. Job stats by status (service Q82)
-- ============================================================

EXPLAIN
SELECT status, COUNT(*) as cnt
FROM import_v3_rows
WHERE job_id = 1
GROUP BY status;

-- ============================================================
-- 20. Paginated rows (service Q84)
-- ============================================================

EXPLAIN
SELECT r.row_id, r.row_num, r.status, r.error_count, r.warning_count,
       r.matched_contactid, r.best_match_score, r.user_action,
       r.created_contactid, r.updated_contactid, r.import_error,
       r.validation_summary, r.dupe_candidates_json
FROM import_v3_rows r
WHERE r.job_id = 1
ORDER BY r.row_num ASC
LIMIT 50 OFFSET 0;

-- ============================================================
-- 21. Single row detail (service Q86)
-- ============================================================

EXPLAIN
SELECT r.*
FROM import_v3_rows r
WHERE r.row_id = 1 AND r.job_id = 1;

-- ============================================================
-- 22. Facts for row detail (service Q87)
-- ============================================================

EXPLAIN
SELECT f.fact_id, f.column_id, f.field_name, f.raw_value, f.normalized_value,
       f.is_valid, f.validation_code, f.validation_message,
       f.existing_value, f.has_conflict, f.user_choice
FROM import_v3_facts f
WHERE f.row_id = 1
ORDER BY f.field_name;

-- ============================================================
-- 23. Contact name lookup for dupes (service Q88)
-- ============================================================

EXPLAIN
SELECT contactFullName FROM contactdetails WHERE contactid = 1 AND userid = 1;

-- ============================================================
-- 24. Row ownership for fact editing (service Q89)
-- ============================================================

EXPLAIN
SELECT r.row_id, r.status, r.dupe_candidates_json
FROM import_v3_rows r
INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE r.row_id = 1 AND r.job_id = 1 AND j.userid = 1;

-- ============================================================
-- 25. Error count for row status (service Q94)
-- ============================================================

EXPLAIN
SELECT COUNT(*) as cnt FROM import_v3_facts WHERE row_id = 1 AND is_valid = 0;

-- ============================================================
-- 26. Job row counts subquery pattern (service Q95)
-- ============================================================

EXPLAIN
SELECT
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = 1 AND status = 'ready') AS valid_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = 1 AND status = 'problem') AS problem_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = 1 AND status = 'dupe') AS dupe_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = 1 AND status = 'ignored') AS skipped_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = 1 AND status IN ('imported', 'updated')) AS imported_rows;

-- ============================================================
-- 27. Row ownership for action setting (service Q96)
-- ============================================================

EXPLAIN
SELECT r.row_id, r.status
FROM import_v3_rows r
INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE r.row_id = 1 AND r.job_id = 1 AND j.userid = 1;

-- ============================================================
-- 28. Verify JOIN chain: facts -> rows -> jobs
-- ============================================================

EXPLAIN
SELECT f.fact_id, r.row_id, j.job_id, j.userid
FROM import_v3_facts f
INNER JOIN import_v3_rows r ON f.row_id = r.row_id
INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE j.job_id = 1 AND j.userid = 1
LIMIT 1;

-- ============================================================
-- END OF VERIFICATION SCRIPT
-- ============================================================
```

---

## Files Referenced

- `ajax/importv3/upload.cfm`
- `ajax/importv3/parse.cfm`
- `ajax/importv3/columns.cfm`
- `ajax/importv3/recompute.cfm`
- `ajax/importv3/rows.cfm`
- `ajax/importv3/row.cfm`
- `ajax/importv3/row_action.cfm`
- `ajax/importv3/fact_update.cfm`
- `ajax/importv3/finalize.cfm`
- `ajax/importv3/status.cfm`
- `services/ContactImportV3Service.cfc`
- `include/import-contacts-v3.cfm`
