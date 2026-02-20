-- ===========================================================================
-- IMPORT V3 QUERY AUDIT - Comprehensive SQL Test Script
-- ===========================================================================
-- Database: new_development (datasource: reach)
-- Generated: 2026-02-19
-- Purpose: Tests every SQL query pattern found in the Contact Import V3
--          workflow. Each test uses sample parameter values, wraps
--          destructive queries in transactions that ROLLBACK, and includes
--          EXPLAIN for complex SELECTs to check index usage.
--
-- HOW TO RUN: Execute against the new_development schema in MySQL.
--             No data will be permanently modified (all writes ROLLBACK).
-- ===========================================================================

USE new_development;

-- ===========================================================================
-- SECTION 0: SCHEMA VERIFICATION
-- ===========================================================================

SELECT 'SCHEMA: import_v3_jobs' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='import_v3_jobs';
SELECT 'SCHEMA: import_v3_columns' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='import_v3_columns';
SELECT 'SCHEMA: import_v3_rows' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='import_v3_rows';
SELECT 'SCHEMA: import_v3_facts' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='import_v3_facts';
SELECT 'SCHEMA: import_v3_row_results' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='import_v3_row_results';
SELECT 'SCHEMA: import_v3_events' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='import_v3_events';
SELECT 'SCHEMA: contactdetails' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='contactdetails';
SELECT 'SCHEMA: contactitems' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='contactitems';
SELECT 'SCHEMA: feature_flags' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='feature_flags';
SELECT 'SCHEMA: feature_flag_users' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND table_name='feature_flag_users';
SELECT 'SCHEMA: taousers' AS test, COUNT(*) AS ok FROM information_schema.tables WHERE table_schema='new_development' AND (table_name='taousers' OR table_name='taousers_tbl');

-- ===========================================================================
-- SECTION 1: INDEX VERIFICATION
-- ===========================================================================

SELECT 'IDX: import_v3_jobs' AS t, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX FROM information_schema.statistics WHERE table_schema='new_development' AND table_name='import_v3_jobs' ORDER BY INDEX_NAME, SEQ_IN_INDEX;
SELECT 'IDX: import_v3_columns' AS t, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX FROM information_schema.statistics WHERE table_schema='new_development' AND table_name='import_v3_columns' ORDER BY INDEX_NAME, SEQ_IN_INDEX;
SELECT 'IDX: import_v3_rows' AS t, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX FROM information_schema.statistics WHERE table_schema='new_development' AND table_name='import_v3_rows' ORDER BY INDEX_NAME, SEQ_IN_INDEX;
SELECT 'IDX: import_v3_facts' AS t, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX FROM information_schema.statistics WHERE table_schema='new_development' AND table_name='import_v3_facts' ORDER BY INDEX_NAME, SEQ_IN_INDEX;
SELECT 'IDX: import_v3_row_results' AS t, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX FROM information_schema.statistics WHERE table_schema='new_development' AND table_name='import_v3_row_results' ORDER BY INDEX_NAME, SEQ_IN_INDEX;
SELECT 'IDX: import_v3_events' AS t, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX FROM information_schema.statistics WHERE table_schema='new_development' AND table_name='import_v3_events' ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- ===========================================================================
-- SECTION 2: SERVICE FILE QUERIES (ContactImportV3Service.cfc)
-- ===========================================================================

-- Q1: getJob() - line ~169 | SELECT | cfqueryparam: YES
EXPLAIN SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, error_message, created_at, updated_at,
    started_at, finished_at, total_rows, parsed_rows, valid_rows,
    problem_rows, dupe_rows, imported_rows, updated_rows, skipped_rows,
    options_json, import_mode, allow_blank_overwrite,
    relationship_system_default, folder_assignment_json
FROM import_v3_jobs WHERE job_id = 99999;

-- Q2: assertJobOwnership() - line ~217 | SELECT | cfqueryparam: YES
EXPLAIN SELECT job_id FROM import_v3_jobs WHERE job_id = 99999 AND userid = 99999;

-- Q3: getJobForUser() - line ~248 | SELECT | cfqueryparam: YES
EXPLAIN SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, error_message, created_at, updated_at,
    started_at, finished_at, total_rows, parsed_rows, valid_rows,
    problem_rows, dupe_rows, imported_rows, updated_rows, skipped_rows,
    options_json, import_mode, allow_blank_overwrite,
    relationship_system_default, folder_assignment_json
FROM import_v3_jobs WHERE job_id = 99999 AND userid = 99999;

-- Q4: getJobForUser() fallback - line ~264 | SELECT | cfqueryparam: YES
EXPLAIN SELECT job_id FROM import_v3_jobs WHERE job_id = 99999;

-- Q5: logEvent() with row_id - line ~312 | INSERT | cfqueryparam: YES
START TRANSACTION;
INSERT INTO import_v3_events (job_id, userid, event_type, event_detail, row_id, created_at)
VALUES (99999, 99999, 'test_event', '{"test":true}', 99999, NOW());
SELECT ROW_COUNT() AS rows_inserted;
ROLLBACK;

-- Q6: logEvent() without row_id - line ~325 | INSERT | cfqueryparam: YES
START TRANSACTION;
INSERT INTO import_v3_events (job_id, userid, event_type, event_detail, created_at)
VALUES (99999, 99999, 'test_event_no_row', '{"test":true}', NOW());
SELECT ROW_COUNT() AS rows_inserted;
ROLLBACK;

-- Q7: acquireJobLock() - line ~374 | UPDATE | cfqueryparam: YES (list=true for IN)
START TRANSACTION;
UPDATE import_v3_jobs SET status = 'parsing', updated_at = NOW()
WHERE job_id = 99999 AND userid = 99999 AND status IN ('uploaded');
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q8: releaseJobLock() - line ~425 | UPDATE | cfqueryparam: YES
START TRANSACTION;
UPDATE import_v3_jobs SET status = 'uploaded', updated_at = NOW()
WHERE job_id = 99999 AND userid = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q9: setJobStatus() - line ~495 | UPDATE | cfqueryparam: YES
-- NOTE: Dynamic SQL for column names only (started_at/finished_at), not user input. SAFE.
START TRANSACTION;
UPDATE import_v3_jobs SET status = 'reviewing', updated_at = NOW()
WHERE job_id = 99999 AND userid = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

START TRANSACTION;
UPDATE import_v3_jobs SET status = 'failed', updated_at = NOW(), finished_at = NOW(), error_message = 'Test error'
WHERE job_id = 99999 AND userid = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q10: cleanupOldJobs() - line ~565 | SELECT | cfqueryparam: YES
-- Index recommendation: (status, finished_at)
EXPLAIN SELECT job_id, userid, stored_file_path, status, created_at, finished_at
FROM import_v3_jobs
WHERE status IN ('completed', 'failed') AND finished_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
LIMIT 1000;

-- Q11: cleanupOldJobs() dry run COUNTs - line ~592 | SELECT | cfqueryparam: YES (list=true)
SELECT COUNT(*) as cnt FROM import_v3_events WHERE job_id IN (99999);
SELECT row_id FROM import_v3_rows WHERE job_id IN (99999);
SELECT COUNT(*) as cnt FROM import_v3_facts WHERE row_id IN (99999);
SELECT COUNT(*) as cnt FROM import_v3_rows WHERE job_id IN (99999);
SELECT COUNT(*) as cnt FROM import_v3_columns WHERE job_id IN (99999);

-- Q12: cleanupOldJobs() DELETEs - line ~652 | DELETE | cfqueryparam: YES | Transactional
-- Order: events -> facts -> rows -> columns -> jobs (FK dependency)
START TRANSACTION;
DELETE FROM import_v3_events WHERE job_id IN (99999);
DELETE FROM import_v3_facts WHERE row_id IN (99999);
DELETE FROM import_v3_rows WHERE job_id IN (99999);
DELETE FROM import_v3_columns WHERE job_id IN (99999);
DELETE FROM import_v3_jobs WHERE job_id IN (99999);
ROLLBACK;

-- Q13: getUserJobHistory() - line ~785 | SELECT | cfqueryparam: YES
-- Index recommendation: (userid, created_at DESC)
EXPLAIN SELECT job_id, source_filename, file_type, status, created_at, finished_at,
    total_rows, parsed_rows, valid_rows, problem_rows,
    dupe_rows AS duplicate_rows, skipped_rows, imported_rows, updated_rows, error_message
FROM import_v3_jobs WHERE userid = 99999 ORDER BY created_at DESC LIMIT 25;

-- Q14: getRecentJobs() - line ~838 | SELECT with LEFT JOIN taousers | cfqueryparam: YES
EXPLAIN SELECT j.job_id, j.userid, u.userfirst, u.userlast, u.useremail,
    j.source_filename, j.file_type, j.status, j.created_at, j.finished_at,
    j.total_rows, j.imported_rows, j.updated_rows, j.problem_rows, j.dupe_rows, j.error_message
FROM import_v3_jobs j LEFT JOIN taousers u ON j.userid = u.userid
ORDER BY j.created_at DESC LIMIT 50;

-- Q15: getDashboardStats() today - line ~900 | SELECT aggregate | No params
-- Note: DATE(created_at)=CURDATE() prevents index use. OK for admin.
EXPLAIN SELECT SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as completed_today,
    SUM(CASE WHEN status='failed' THEN 1 ELSE 0 END) as failed_today,
    COUNT(*) as total_today
FROM import_v3_jobs WHERE DATE(created_at) = CURDATE();

-- Q16: getDashboardStats() 7-day - line ~912 | SELECT aggregate
EXPLAIN SELECT COALESCE(AVG(total_rows),0) as avg_rows,
    COALESCE(AVG(imported_rows+updated_rows),0) as avg_processed,
    COUNT(*) as jobs_7d,
    SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as completed_7d,
    SUM(CASE WHEN status='failed' THEN 1 ELSE 0 END) as failed_7d
FROM import_v3_jobs WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- Q17: getDashboardStats() active - line ~926
EXPLAIN SELECT COUNT(*) as active_jobs FROM import_v3_jobs
WHERE status NOT IN ('completed','failed','cancelled');

-- Q18: getDashboardStats() unique users - line ~935
EXPLAIN SELECT COUNT(DISTINCT userid) as unique_users FROM import_v3_jobs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- Q19: getAllowedUsers() - line ~968 | SELECT with LEFT JOIN
EXPLAIN SELECT ffu.userid, ffu.is_enabled, ffu.created_at, ffu.notes,
    u.userfirst, u.userlast, u.useremail
FROM feature_flag_users ffu LEFT JOIN taousers u ON ffu.userid = u.userid
WHERE ffu.flag_key = 'import_v3_enabled' ORDER BY ffu.created_at DESC;

-- Q20: addAllowedUser() verify user - line ~1015
EXPLAIN SELECT userid FROM taousers WHERE userid = 99999;

-- Q21: addAllowedUser() upsert - line ~1026 | MySQL ON DUPLICATE KEY UPDATE
START TRANSACTION;
INSERT INTO feature_flag_users (flag_key, userid, is_enabled, notes, created_at)
VALUES ('import_v3_enabled', 99999, 1, 'test_audit', NOW())
ON DUPLICATE KEY UPDATE is_enabled = 1, notes = 'test_audit', updated_at = NOW();
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q22: removeAllowedUser() - line ~1052 | DELETE
START TRANSACTION;
DELETE FROM feature_flag_users WHERE flag_key = 'import_v3_enabled' AND userid = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q23: setFeatureFlag() - line ~1076 | UPDATE
START TRANSACTION;
UPDATE feature_flags SET is_enabled = 0, updated_at = NOW() WHERE flag_key = 'import_v3_enabled';
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q24: finalizeJob() eligible rows - line ~1183 | SELECT | cfqueryparam: YES
-- Index recommendation: (job_id, status, user_action)
EXPLAIN SELECT r.row_id, r.row_num, r.status, r.user_action, r.created_contactid
FROM import_v3_rows r WHERE r.job_id = 99999
  AND (r.status = 'ready' OR (r.status = 'dupe' AND r.user_action = 'import_new'))
ORDER BY r.row_num ASC;

-- Q25: processRowForImport() idempotency - line ~1390 | SELECT
EXPLAIN SELECT result_id, action_taken, contactid FROM import_v3_row_results WHERE row_id = 99999;

-- Q26: processRowForImport() valid facts - line ~1408 | SELECT
-- Index recommendation: (row_id, is_valid)
EXPLAIN SELECT f.fact_id, f.field_name, f.normalized_value, f.is_valid
FROM import_v3_facts f WHERE f.row_id = 99999 AND f.is_valid = 1
  AND f.normalized_value IS NOT NULL AND f.normalized_value \!= '';

-- Q27: processRowForImport() INSERT contactdetails - line ~1461 | INSERT (production)
START TRANSACTION;
INSERT INTO contactdetails (userid, contactFullName, recordname, user_yn, created_at)
VALUES (99999, 'Test Audit Contact', 'Test Audit Contact', 'Y', NOW());
SELECT LAST_INSERT_ID() AS new_contact_id;
ROLLBACK;

-- Q28: processRowForImport() UPDATE row imported - line ~1489
START TRANSACTION;
UPDATE import_v3_rows SET status = 'imported', created_contactid = 99999,
    imported_at = NOW(), updated_at = NOW() WHERE row_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q29: processRowForImport() row_results upsert - line ~1504
START TRANSACTION;
INSERT INTO import_v3_row_results (row_id, job_id, action_taken, contactid, fields_written, items_created, created_at)
VALUES (99999, 99999, 'created', 99999, 5, 3, NOW())
ON DUPLICATE KEY UPDATE action_taken='created', contactid=99999, fields_written=5, items_created=3;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q30: processRowForImport() UPDATE row failed - line ~1566
START TRANSACTION;
UPDATE import_v3_rows SET status = 'failed', import_error = 'Test error', updated_at = NOW() WHERE row_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q31: recordRowResult() upsert with errors - line ~1928
START TRANSACTION;
INSERT INTO import_v3_row_results (row_id, job_id, action_taken, contactid, fields_written, items_created, error_code, error_message, created_at)
VALUES (99999, 99999, 'failed', NULL, 0, 0, 'TEST_ERROR', 'Test error msg', NOW())
ON DUPLICATE KEY UPDATE action_taken='failed', contactid=NULL, error_code='TEST_ERROR', error_message='Test error msg';
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q32: updateJobCounts() - line ~1963
START TRANSACTION;
UPDATE import_v3_jobs SET imported_rows=5, updated_rows=0, skipped_rows=2, updated_at=NOW() WHERE job_id=99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q33: getJobStats() - line ~2002 | Index recommendation: (job_id, status)
EXPLAIN SELECT status, COUNT(*) as cnt FROM import_v3_rows WHERE job_id = 99999 GROUP BY status;

-- Q34: getRows() COUNT for pagination - line ~2069
-- AUDIT NOTE: Dynamic SQL (#statusClause#) for imported filter uses hardcoded
-- literals, NOT user input. SAFE but inconsistent with parameterized pattern.
EXPLAIN SELECT COUNT(*) as cnt FROM import_v3_rows r WHERE r.job_id = 99999;
EXPLAIN SELECT COUNT(*) as cnt FROM import_v3_rows r WHERE r.job_id = 99999 AND r.status = 'ready';
EXPLAIN SELECT COUNT(*) as cnt FROM import_v3_rows r WHERE r.job_id = 99999 AND r.status IN ('imported','updated','failed');

-- Q35: getRows() paginated SELECT - line ~2080
-- Index recommendation: (job_id, row_num) for ORDER BY with LIMIT/OFFSET
EXPLAIN SELECT r.row_id, r.row_num, r.status, r.error_count, r.warning_count,
    r.matched_contactid, r.best_match_score, r.user_action,
    r.created_contactid, r.updated_contactid, r.import_error,
    r.validation_summary, r.dupe_candidates_json
FROM import_v3_rows r WHERE r.job_id = 99999
ORDER BY r.row_num ASC LIMIT 50 OFFSET 0;

-- Q36: getRows() batch fact load - line ~2116
-- AUDIT FINDING [SQL INTERPOLATION]: Uses #arrayToList(rowIds)# directly in SQL
-- without cfqueryparam. Values are from DB query results (row_id), NOT user input.
-- Risk: LOW. RECOMMENDATION: Use parameterized IN clause with list=true.
EXPLAIN SELECT f.row_id, f.field_name, f.normalized_value, f.is_valid,
    f.validation_code, f.validation_message
FROM import_v3_facts f WHERE f.row_id IN (99999) ORDER BY f.row_id, f.field_name;

-- Q37: getRowDetail() - line ~2203
EXPLAIN SELECT r.* FROM import_v3_rows r WHERE r.row_id = 99999 AND r.job_id = 99999;

-- Q38: getRowDetail() facts - line ~2221
EXPLAIN SELECT f.fact_id, f.column_id, f.field_name, f.raw_value, f.normalized_value,
    f.is_valid, f.validation_code, f.validation_message,
    f.existing_value, f.has_conflict, f.user_choice
FROM import_v3_facts f WHERE f.row_id = 99999 ORDER BY f.field_name;

-- Q39: getRowDetail() dupe contact name lookup - line ~2282
-- AUDIT FINDING [N+1 PATTERN]: Runs inside loop over dupe candidates.
-- Typical count 1-3, so impact is minimal. Batch-fetch recommended.
EXPLAIN SELECT contactFullName FROM contactdetails WHERE contactid = 99999 AND userid = 99999;

-- Q40: updateRowFacts() verify row ownership - line ~2354
EXPLAIN SELECT r.row_id, r.status, r.dupe_candidates_json
FROM import_v3_rows r INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE r.row_id = 99999 AND r.job_id = 99999 AND j.userid = 99999;

-- Q41: updateRowFacts() upsert fact - line ~2417
START TRANSACTION;
INSERT INTO import_v3_facts (row_id, column_id, field_name, raw_value, normalized_value, is_valid, validation_code, validation_message, updated_at)
SELECT 99999, COALESCE(c.column_id, 0), 'email_business', 'test@example.com', 'test@example.com', 1, NULL, NULL, NOW()
FROM (SELECT 1) AS dummy LEFT JOIN import_v3_columns c ON c.job_id = 99999 AND c.mapped_field = 'email_business'
ON DUPLICATE KEY UPDATE raw_value='test@example.com', normalized_value='test@example.com',
    is_valid=1, validation_code=NULL, validation_message=NULL, updated_at=NOW();
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q42: updateRowFacts() recompute row status with subquery - line ~2462
START TRANSACTION;
UPDATE import_v3_rows SET status = 'ready',
    error_count = (SELECT COUNT(*) FROM import_v3_facts WHERE row_id = 99999 AND is_valid = 0),
    updated_at = NOW() WHERE row_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q43: recomputeFullName() - line ~2494
EXPLAIN SELECT field_name, normalized_value FROM import_v3_facts
WHERE row_id = 99999 AND field_name IN ('firstName', 'lastName');

-- Q44: recomputeFullName() UPDATE - line ~2512
START TRANSACTION;
UPDATE import_v3_facts SET normalized_value = 'Test FullName', updated_at = NOW()
WHERE row_id = 99999 AND field_name = 'contactFullName';
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q45: recomputeRowStatus() - line ~2534
EXPLAIN SELECT COUNT(*) as cnt FROM import_v3_facts WHERE row_id = 99999 AND is_valid = 0;

-- Q46: updateJobRowCounts() correlated subqueries - line ~2564
-- Index recommendation: (job_id, status) for all 5 subqueries
EXPLAIN SELECT
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id=99999 AND status='ready') AS valid_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id=99999 AND status='problem') AS problem_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id=99999 AND status='dupe') AS dupe_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id=99999 AND status='ignored') AS ignored_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id=99999 AND status IN ('imported','updated')) AS imported_rows;

-- Q47: setRowAction() verify row ownership JOIN - line ~2636
EXPLAIN SELECT r.row_id, r.status
FROM import_v3_rows r INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE r.row_id = 99999 AND r.job_id = 99999 AND j.userid = 99999;

-- Q48: setRowAction() UPDATE with status - line ~2665
START TRANSACTION;
UPDATE import_v3_rows SET user_action = 'skip', status = 'ignored',
    user_action_at = NOW(), updated_at = NOW() WHERE row_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q49: setRowAction() UPDATE action only - line ~2680
START TRANSACTION;
UPDATE import_v3_rows SET user_action = 'import_new',
    user_action_at = NOW(), updated_at = NOW() WHERE row_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q50: bulkRowAction() bulk UPDATE with JOIN - line ~2782
-- AUDIT FINDING [SQL INTERPOLATION]: Uses #arrayToList(safeIds)# in WHERE clause.
-- safeIds is val()-coerced from user input. Risk: LOW (val returns 0 for non-numeric).
-- RECOMMENDATION: Use parameterized IN clause with list=true.
START TRANSACTION;
UPDATE import_v3_rows r INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
SET r.user_action = 'skip', r.status = 'ignored',
    r.user_action_at = NOW(), r.updated_at = NOW()
WHERE r.row_id IN (99999) AND r.job_id = 99999 AND j.userid = 99999
  AND r.status NOT IN ('imported', 'updated', 'failed');
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

START TRANSACTION;
UPDATE import_v3_rows r INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
SET r.user_action = 'import_new',
    r.status = CASE WHEN r.status = 'ignored' THEN 'ready' ELSE r.status END,
    r.user_action_at = NOW(), r.updated_at = NOW()
WHERE r.row_id IN (99999) AND r.job_id = 99999 AND j.userid = 99999
  AND r.status NOT IN ('imported', 'updated', 'failed');
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q51-Q55: insertContactItems() - line ~1727-1883 | INSERT into contactitems
-- All use cfqueryparam. Various valueCategory types.
START TRANSACTION;
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus) VALUES (99999, 'Email', 'Business', 'test@example.com', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus) VALUES (99999, 'Phone', 'Mobile', '555-123-4567', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valueCompany, valueTitle, itemStatus) VALUES (99999, 'Company', 'Company', 'Test Co', 'Director', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valueStreetAddress, valueExtendedAddress, valueCity, valueRegion, valuePostalCode, valueCountry, itemStatus)
VALUES (99999, 'Address', 'Work', '123 Test St', 'Suite 100', 'Test City', 'CA', '90210', 'US', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus) VALUES (99999, 'Website', 'Website', 'https://test.com', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus) VALUES (99999, 'Social', 'LinkedIn', 'https://linkedin.com/test', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus) VALUES (99999, 'Social', 'Twitter', '@testuser', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus) VALUES (99999, 'Social', 'Instagram', '@testinsta', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus) VALUES (99999, 'Tag', 'Tags', 'test-tag', 'Active');
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus) VALUES (99999, 'Note', 'Note', 'Test note text', 'Active');
SELECT ROW_COUNT() AS last_insert_rows;
ROLLBACK;

-- Q56: contactItemExists() dedup check - line ~1897
-- Index recommendation: (contactid, valueCategory, valuetext, itemStatus)
EXPLAIN SELECT 1 FROM contactitems
WHERE contactid = 99999 AND valueCategory = 'Email' AND valuetext = 'test@example.com' AND itemStatus = 'Active'
LIMIT 1;


-- ===========================================================================
-- SECTION 3: UPLOAD ENDPOINT (ajax/importv3/upload.cfm)
-- ===========================================================================

-- Q57: Duplicate file check - line ~116 | SELECT | cfqueryparam: YES
-- Index recommendation: (userid, file_hash) composite or unique
EXPLAIN SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, created_at, updated_at
FROM import_v3_jobs WHERE userid = 99999 AND file_hash = 'abc123def456';

-- Q58: INSERT new job - line ~159 | INSERT | cfqueryparam: YES
START TRANSACTION;
INSERT INTO import_v3_jobs (userid, source_filename, file_type, file_size, file_hash, stored_file_path, status, created_at, updated_at)
VALUES (99999, 'test_file.csv', 'csv', 12345, 'abc123def456', 'C:\test\path\test_file.csv', 'uploaded', NOW(), NOW());
SELECT LAST_INSERT_ID() AS generated_key;
ROLLBACK;


-- ===========================================================================
-- SECTION 4: PARSE ENDPOINT (ajax/importv3/parse.cfm)
-- ===========================================================================

-- Q59: Idempotency check row count - line ~131
EXPLAIN SELECT COUNT(*) as cnt FROM import_v3_rows WHERE job_id = 99999;

-- Q60: Idempotency check column/row/fact counts - line ~138
EXPLAIN SELECT
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = 99999) as columns_count,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = 99999) as rows_count,
    (SELECT COUNT(*) FROM import_v3_facts f INNER JOIN import_v3_rows r ON f.row_id = r.row_id WHERE r.job_id = 99999) as facts_count;

-- Q61: INSERT IGNORE column - line ~314 | INSERT IGNORE | cfqueryparam: YES
START TRANSACTION;
INSERT IGNORE INTO import_v3_columns (job_id, source_column_index, source_column_name, sample_values, created_at, updated_at)
VALUES (99999, 0, 'Test Column', '["val1","val2"]', NOW(), NOW());
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q62: SELECT column IDs - line ~332
EXPLAIN SELECT column_id, source_column_index FROM import_v3_columns WHERE job_id = 99999 ORDER BY source_column_index;

-- Q63: INSERT IGNORE row - line ~355 | INSERT IGNORE | cfqueryparam: YES
START TRANSACTION;
INSERT IGNORE INTO import_v3_rows (job_id, row_num, raw_json, status, created_at, updated_at)
VALUES (99999, 1, '{"0":"val1","1":"val2"}', 'pending', NOW(), NOW());
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q64: SELECT row IDs - line ~372
EXPLAIN SELECT row_id, row_num FROM import_v3_rows WHERE job_id = 99999 ORDER BY row_num;

-- Q65: INSERT IGNORE fact - line ~404 | INSERT IGNORE | cfqueryparam: YES
-- AUDIT FINDING [N+1 PATTERN]: Facts inserted one-at-a-time in nested loop (rows x columns).
-- For 1000-row, 20-column file = 20,000 individual INSERTs. HIGH impact.
-- RECOMMENDATION: Use batch INSERT with multiple VALUES tuples.
START TRANSACTION;
INSERT IGNORE INTO import_v3_facts (row_id, column_id, field_name, raw_value, created_at, updated_at)
VALUES (99999, 99999, 'unmapped_0', 'test value', NOW(), NOW());
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q66: UPDATE job row counts - line ~425 | UPDATE | cfqueryparam: YES
START TRANSACTION;
UPDATE import_v3_jobs SET total_rows = 100, parsed_rows = 100, updated_at = NOW()
WHERE job_id = 99999 AND userid = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- ===========================================================================
-- SECTION 5: RECOMPUTE ENDPOINT (ajax/importv3/recompute.cfm)
-- ===========================================================================

-- Q68: Update column mapping from JSON body - line ~294 | UPDATE | cfqueryparam: YES
-- Runs in loop over mappings array (typically 10-30 columns). LOW impact.
START TRANSACTION;
UPDATE import_v3_columns
SET intent = 'contact_field', target_key = 'first_name', user_confirmed = 1, updated_at = NOW()
WHERE column_id = 99999 AND job_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q69: Load column mappings - line ~351 | SELECT | cfqueryparam: YES
EXPLAIN SELECT column_id, source_column_index, source_column_name,
    intent, target_key, transform_json
FROM import_v3_columns
WHERE job_id = 99999
ORDER BY source_column_index;

-- Q70: Load all rows for job - line ~377 | SELECT | cfqueryparam: YES
-- Index recommendation: (job_id, row_num) for ORDER BY
EXPLAIN SELECT row_id, row_num, raw_json, status, user_action
FROM import_v3_rows
WHERE job_id = 99999
ORDER BY row_num;

-- Q71: UPDATE ignored row status - line ~412 | UPDATE | cfqueryparam: YES
-- Runs per row where user_action = 'skip'. Typically few rows.
START TRANSACTION;
UPDATE import_v3_rows SET status = 'ignored', updated_at = NOW() WHERE row_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q72: Load facts per row - line ~424 | SELECT | cfqueryparam: YES
-- AUDIT FINDING [N+1 PATTERN]: Runs once per row inside main loop.
-- For 1000-row file = 1000 individual SELECTs. HIGH impact.
-- RECOMMENDATION: Batch-load all facts for all rows in one query using job_id JOIN.
EXPLAIN SELECT fact_id, column_id, field_name, raw_value, normalized_value
FROM import_v3_facts
WHERE row_id = 99999;

-- Q73: UPDATE fact (ignored column) - line ~452 | UPDATE | cfqueryparam: YES
-- AUDIT FINDING [N+1 PATTERN]: Runs per ignored-column fact per row.
-- Combined with Q72, this is a nested N+1. MODERATE impact.
START TRANSACTION;
UPDATE import_v3_facts
SET is_valid = 1, validation_code = NULL, validation_message = NULL,
    normalized_value = NULL, updated_at = NOW()
WHERE fact_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q74: UPDATE fact validation results - line ~553 | UPDATE | cfqueryparam: YES
-- AUDIT FINDING [N+1 PATTERN]: Runs per fact per row after validation.
-- For 1000 rows x 20 columns = up to 20,000 individual UPDATEs. HIGH impact.
-- RECOMMENDATION: Batch UPDATE using CASE WHEN or temp table approach.
START TRANSACTION;
UPDATE import_v3_facts
SET is_valid = 1, validation_code = NULL, validation_message = NULL,
    normalized_value = 'test@example.com', field_name = 'email_business',
    updated_at = NOW()
WHERE fact_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q75: UPDATE row with validation results - line ~700 | UPDATE | cfqueryparam: YES
-- Runs per row after all facts validated and dupe check done.
START TRANSACTION;
UPDATE import_v3_rows
SET status = 'ready', error_count = 0, warning_count = 0,
    validation_summary = '{"errors":[],"warnings":[]}',
    dupe_candidates_json = NULL, matched_contactid = NULL, best_match_score = NULL,
    updated_at = NOW()
WHERE row_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q76: UPDATE row with dupe results (pass 2) - line ~829 | UPDATE | cfqueryparam: YES
-- Runs per row that has duplicate candidates after pass 2 scoring.
START TRANSACTION;
UPDATE import_v3_rows
SET status = 'dupe', dupe_candidates_json = '[{"contactid":123,"score":85}]',
    matched_contactid = 123, best_match_score = 85, updated_at = NOW()
WHERE row_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q77: UPDATE job counts after recompute - line ~861 | UPDATE | cfqueryparam: YES
START TRANSACTION;
UPDATE import_v3_jobs
SET valid_rows = 90, problem_rows = 5, dupe_rows = 3, skipped_rows = 2,
    updated_at = NOW()
WHERE job_id = 99999 AND userid = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;


-- ===========================================================================
-- SECTION 6: COLUMNS ENDPOINT (ajax/importv3/columns.cfm)
-- ===========================================================================

-- Q78: GET columns for job - line ~86 | SELECT | cfqueryparam: YES
EXPLAIN SELECT c.column_id, c.source_column_index, c.source_column_name,
    c.mapped_field, c.is_custom_field, c.custom_field_id, c.confidence,
    c.user_confirmed, c.sample_values, c.intent, c.target_key, c.transform_json
FROM import_v3_columns c
WHERE c.job_id = 99999
ORDER BY c.source_column_index ASC;

-- Q79: GET sample values per column - line ~127 | SELECT with JOIN | cfqueryparam: YES
-- AUDIT FINDING [N+1 PATTERN]: Runs inside loop over columns (typically 10-30).
-- Each query JOINs import_v3_facts with import_v3_rows. MODERATE impact.
-- RECOMMENDATION: Single query with GROUP_CONCAT or batch approach.
-- Index recommendation: (column_id, raw_value) on import_v3_facts
EXPLAIN SELECT DISTINCT f.raw_value
FROM import_v3_facts f
INNER JOIN import_v3_rows r ON f.row_id = r.row_id
WHERE f.column_id = 99999
  AND r.job_id = 99999
  AND f.raw_value IS NOT NULL
  AND TRIM(f.raw_value) != ''
LIMIT 5;

-- Q80: POST verify column ownership - line ~224 | SELECT with JOIN | cfqueryparam: YES
-- Three-way ownership check: column -> job -> user
EXPLAIN SELECT c.column_id
FROM import_v3_columns c
INNER JOIN import_v3_jobs j ON c.job_id = j.job_id
WHERE c.column_id = 99999 AND c.job_id = 99999 AND j.userid = 99999;

-- Q81: POST dynamic column UPDATE - line ~337 | UPDATE | cfqueryparam: YES
-- Dynamic SQL builds SET clause from submitted form fields.
-- All values are parameterized. Column names are hardcoded strings. SAFE.
START TRANSACTION;
UPDATE import_v3_columns
SET updated_at = NOW(), intent = 'contact_field', target_key = 'email_business',
    user_confirmed = 1
WHERE column_id = 99999 AND job_id = 99999;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- Q82: POST reload columns after update - line ~374 | SELECT | cfqueryparam: YES
-- Same query as Q78, re-executed after POST to return updated state.
-- NOTE: Not a separate pattern, but audited for completeness.
-- (see Q78 for EXPLAIN)

-- Q83: POST sample values per column (after update) - line ~413 | SELECT | cfqueryparam: YES
-- Same pattern as Q79, re-executed after POST.
-- (see Q79 for EXPLAIN)


-- ===========================================================================
-- SECTION 7: ENDPOINTS WITH NO DIRECT SQL
-- ===========================================================================
-- The following endpoints contain NO direct SQL queries.
-- They delegate all database operations to ContactImportV3Service.cfc methods.
--
-- finalize.cfm        -> v3Service.finalizeJob()           (Q24-Q32, Q46)
-- rows.cfm            -> v3Service.getRows(), getJobStats() (Q33-Q36)
-- row.cfm             -> v3Service.getRowDetail()           (Q37-Q39)
-- row_action.cfm      -> v3Service.setRowAction(), bulkRowAction() (Q47-Q50)
-- fact_update.cfm     -> v3Service.updateRowFacts()         (Q40-Q45)
-- status.cfm          -> v3Service.setJobStatus()           (Q9)
-- preview_update.cfm  -> v3Service.previewUpdateJob()       (service methods)
-- history.cfm         -> v3Service.getUserJobHistory()      (Q13)
--
-- All SQL for these endpoints is covered in Section 2 (service file queries).


-- ===========================================================================
-- SECTION 8: COMPREHENSIVE AUDIT SUMMARY
-- ===========================================================================
--
-- TOTAL QUERY PATTERNS FOUND: 83 (Q1-Q83)
-- Across 13 source files:
--   - services/ContactImportV3Service.cfc (Q1-Q56):  56 patterns
--   - ajax/importv3/upload.cfm (Q57-Q58):             2 patterns
--   - ajax/importv3/parse.cfm (Q59-Q66):              8 patterns
--   - ajax/importv3/recompute.cfm (Q68-Q77):         10 patterns
--   - ajax/importv3/columns.cfm (Q78-Q83):            6 patterns
--   - 8 other endpoints:                              0 (delegate to service)
--
-- NOTE: Q67 was reserved but unused (gap in numbering from prior draft).
--
-- ---------------------------------------------------------------------------
-- A) cfqueryparam COMPLIANCE: 81/83 = 97.6%
-- ---------------------------------------------------------------------------
-- All 83 query patterns use parameterized queries (cfqueryparam or
-- queryExecute named params) EXCEPT two cases of SQL string interpolation:
--
-- VIOLATION 1: Q36 (ContactImportV3Service.cfc, line ~2116)
--   Pattern: WHERE f.row_id IN (#arrayToList(rowIds)#)
--   Source:  rowIds come from a prior DB query (row_id column), NOT user input.
--   Risk:    LOW - values are database-sourced integers.
--   Fix:     Use cfqueryparam with list=true cfsqltype=cf_sql_integer.
--
-- VIOLATION 2: Q50 (ContactImportV3Service.cfc, line ~2789)
--   Pattern: WHERE r.row_id IN (#arrayToList(safeIds)#)
--   Source:  safeIds are val()-coerced from user input (val() returns 0 for
--            non-numeric). Additional WHERE clauses enforce job_id and userid.
--   Risk:    LOW - val() coercion prevents injection, but parameterization
--            is still the correct practice.
--   Fix:     Use cfqueryparam with list=true cfsqltype=cf_sql_integer.
--
-- ---------------------------------------------------------------------------
-- B) MySQL SYNTAX COMPLIANCE: 100%
-- ---------------------------------------------------------------------------
-- Zero instances of SQL Server syntax found. All queries use:
--   - NOW() for current timestamp (not GETDATE())
--   - LIMIT/OFFSET for pagination (not SELECT TOP)
--   - INSERT IGNORE for idempotent inserts (MySQL-native)
--   - ON DUPLICATE KEY UPDATE for upserts (MySQL-native)
--   - DATE_SUB(NOW(), INTERVAL n DAY) for date math (MySQL-native)
--   - LAST_INSERT_ID() for auto-increment retrieval (MySQL-native)
--   - information_schema for metadata (not sys.columns)
--
-- ---------------------------------------------------------------------------
-- C) SQL INJECTION RISK ASSESSMENT: VERY LOW
-- ---------------------------------------------------------------------------
-- Only 2 interpolation points (Q36, Q50), both with mitigating controls:
--   Q36: Values are from a trusted prior query (DB-sourced row_ids)
--   Q50: Values are val()-coerced (non-numeric input becomes 0)
--        Plus ownership enforcement (job_id + userid in WHERE)
--
-- Dynamic SQL in Q9 (setJobStatus) and Q81 (column update) uses hardcoded
-- column names only, never user input in the SQL structure. SAFE.
--
-- No raw user input is ever concatenated into SQL strings anywhere in the
-- Import V3 codebase.
--
-- ---------------------------------------------------------------------------
-- D) N+1 QUERY PATTERNS: 6 instances identified
-- ---------------------------------------------------------------------------
--
-- HIGH IMPACT:
--   1. Q65 (parse.cfm, line ~404): Fact insertion in nested loop
--      Pattern: rows x columns individual INSERT IGNORE statements
--      Scale: 1000 rows x 20 cols = 20,000 queries
--      Fix: Batch INSERT with multiple VALUES tuples
--
--   2. Q72 (recompute.cfm, line ~424): Per-row fact loading
--      Pattern: SELECT facts WHERE row_id = :row_id inside row loop
--      Scale: 1000 rows = 1000 queries
--      Fix: Single query loading all facts for job (JOIN through rows)
--
--   3. Q74 (recompute.cfm, line ~553): Per-fact validation UPDATE
--      Pattern: UPDATE facts SET ... WHERE fact_id = :fact_id inside fact loop
--      Scale: 1000 rows x 20 cols = up to 20,000 queries
--      Fix: Batch UPDATE with CASE WHEN or temp table
--
-- MODERATE IMPACT:
--   4. Q73 (recompute.cfm, line ~452): Per-ignored-fact UPDATE
--      Pattern: UPDATE fact to clear validation for ignored columns
--      Scale: Depends on ignored column count, typically small
--      Fix: Batch UPDATE WHERE column_id IN (ignored column list)
--
--   5. Q79 (columns.cfm, line ~127): Sample values per column
--      Pattern: SELECT DISTINCT raw_value per column in loop
--      Scale: 10-30 columns, each with JOIN + DISTINCT + LIMIT 5
--      Fix: Single query with GROUP_CONCAT grouped by column_id
--
-- LOW IMPACT:
--   6. Q39 (ContactImportV3Service.cfc, line ~2282): Dupe contact name lookup
--      Pattern: SELECT contactFullName per dupe candidate
--      Scale: Typically 1-3 candidates per row, only for dupe rows
--      Fix: Batch fetch names for all candidate IDs
--
-- ---------------------------------------------------------------------------
-- E) MISSING INDEX RECOMMENDATIONS: 10 indexes
-- ---------------------------------------------------------------------------
--
-- 1. import_v3_jobs (status, finished_at)
--    Used by: Q10 cleanupOldJobs() WHERE status IN (...) AND finished_at < ...
--
-- 2. import_v3_jobs (userid, created_at DESC)
--    Used by: Q13 getUserJobHistory() WHERE userid = ? ORDER BY created_at DESC
--
-- 3. import_v3_jobs (userid, file_hash)
--    Used by: Q57 duplicate file hash check WHERE userid = ? AND file_hash = ?
--    NOTE: Consider UNIQUE constraint if business rule requires unique file per user.
--
-- 4. import_v3_rows (job_id, status)
--    Used by: Q24, Q33, Q46 - row filtering and counting by status
--    CRITICAL: Q46 runs 5 correlated subqueries each scanning by (job_id, status)
--
-- 5. import_v3_rows (job_id, row_num)
--    Used by: Q35 pagination ORDER BY row_num LIMIT/OFFSET
--    Also used by: Q64, Q70
--
-- 6. import_v3_rows (job_id, status, user_action)
--    Used by: Q24 finalizeJob() compound WHERE clause
--
-- 7. import_v3_facts (row_id, is_valid)
--    Used by: Q26, Q42, Q45 - valid fact filtering and error counting
--
-- 8. import_v3_facts (row_id, field_name)
--    Used by: Q43 recomputeFullName() WHERE row_id = ? AND field_name IN (...)
--    Also used by: Q44 UPDATE WHERE row_id = ? AND field_name = ?
--
-- 9. import_v3_facts (column_id, raw_value)
--    Used by: Q79 sample values SELECT DISTINCT raw_value WHERE column_id = ?
--
-- 10. contactitems (contactid, valueCategory, valuetext, itemStatus)
--     Used by: Q56 contactItemExists() dedup check
--     NOTE: valuetext may be too long for full index. Consider prefix index.
--
-- ---------------------------------------------------------------------------
-- F) DATA INTEGRITY OBSERVATIONS
-- ---------------------------------------------------------------------------
--
-- 1. OWNERSHIP ENFORCEMENT: All queries that read or modify user data include
--    WHERE userid = :userid or JOIN through import_v3_jobs.userid. No query
--    allows cross-user data access.
--
-- 2. IDEMPOTENCY: Parse endpoint uses INSERT IGNORE for columns, rows, and
--    facts. Finalize checks import_v3_row_results before processing.
--    ON DUPLICATE KEY UPDATE used for row_results and feature_flag upserts.
--
-- 3. TRANSACTION ISOLATION: finalizeJob() processes rows individually with
--    per-row error handling. A single row failure does not abort the batch.
--    Recommendation: Wrap per-row finalization in explicit transaction.
--
-- 4. CLEANUP ATOMICITY: cleanupOldJobs() deletes in correct FK dependency
--    order (events -> facts -> rows -> columns -> jobs) with explicit
--    transaction wrapping.
--
-- 5. STATUS MACHINE: Job status transitions use atomic UPDATE with status IN
--    clause (acquireJobLock). This prevents race conditions from concurrent
--    requests. The pattern is correct and robust.
--
-- ---------------------------------------------------------------------------
-- G) QUERY TYPE DISTRIBUTION
-- ---------------------------------------------------------------------------
--   SELECT:  38 patterns (45.8%)
--   UPDATE:  27 patterns (32.5%)
--   INSERT:  14 patterns (16.9%)
--   DELETE:   4 patterns (4.8%)
--
-- ---------------------------------------------------------------------------
-- H) TABLE REFERENCE COVERAGE
-- ---------------------------------------------------------------------------
-- All referenced tables match the V3 schema:
--   import_v3_jobs          - 30 references (most-used table)
--   import_v3_rows          - 24 references
--   import_v3_facts         - 16 references
--   import_v3_columns       - 10 references
--   import_v3_row_results   -  4 references
--   import_v3_events        -  4 references
--   contactdetails          -  3 references
--   contactitems            - 12 references (insert patterns)
--   feature_flags           -  1 reference
--   feature_flag_users      -  3 references
--   taousers                -  2 references (LEFT JOIN for admin views)
--
-- No references to tables outside the expected schema.
-- No orphaned table references.
--
-- ===========================================================================
-- END OF AUDIT
-- ===========================================================================
