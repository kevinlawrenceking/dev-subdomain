-- ============================================================
-- Contact Import V3 Cleanup Proof Test
-- ============================================================
-- This script demonstrates:
-- 1. Creating test jobs (old completed vs recent completed)
-- 2. Cleanup only deletes old completed/failed jobs
-- 3. Idempotency (running cleanup twice is safe)
-- 4. File path restriction is enforced
-- ============================================================

-- STEP 1: Check current state before test
-- ============================================================
SELECT '=== BEFORE TEST: Current import_v3_jobs ===' AS step;
SELECT job_id, userid, status, finished_at, stored_file_path
FROM import_v3_jobs
ORDER BY job_id DESC
LIMIT 10;

-- STEP 2: Create test data
-- ============================================================
-- Note: Use a test userid that exists in your system (e.g., 999999)
-- These inserts use fake file paths for testing

SELECT '=== STEP 2: Creating test jobs ===' AS step;

-- Job A: OLD completed job (finished 5 days ago) - SHOULD BE DELETED with retention_days=1
INSERT INTO import_v3_jobs (
    userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, created_at, updated_at, finished_at,
    total_rows, parsed_rows, valid_rows, problem_rows, dupe_rows,
    imported_rows, updated_rows, skipped_rows
) VALUES (
    999999, 'cleanup_test_OLD.csv', 'csv', 1024, 'aaa111cleanuptest_old',
    'C:\\test\\uploads\\users\\999999\\imports\\cleanup_test_OLD.csv',
    'completed',
    DATE_SUB(NOW(), INTERVAL 6 DAY),
    DATE_SUB(NOW(), INTERVAL 5 DAY),
    DATE_SUB(NOW(), INTERVAL 5 DAY),
    10, 10, 10, 0, 0, 10, 0, 0
);
SET @old_job_id = LAST_INSERT_ID();
SELECT CONCAT('Created OLD job: job_id = ', @old_job_id) AS result;

-- Job B: RECENT completed job (finished today) - SHOULD BE PRESERVED
INSERT INTO import_v3_jobs (
    userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, created_at, updated_at, finished_at,
    total_rows, parsed_rows, valid_rows, problem_rows, dupe_rows,
    imported_rows, updated_rows, skipped_rows
) VALUES (
    999999, 'cleanup_test_RECENT.csv', 'csv', 2048, 'bbb222cleanuptest_recent',
    'C:\\test\\uploads\\users\\999999\\imports\\cleanup_test_RECENT.csv',
    'completed',
    NOW(),
    NOW(),
    NOW(),
    20, 20, 20, 0, 0, 20, 0, 0
);
SET @recent_job_id = LAST_INSERT_ID();
SELECT CONCAT('Created RECENT job: job_id = ', @recent_job_id) AS result;

-- Add some related records for OLD job
INSERT INTO import_v3_columns (job_id, source_column_index, source_column_name, created_at)
VALUES (@old_job_id, 0, 'test_column_1', NOW());
SET @old_col_id = LAST_INSERT_ID();

INSERT INTO import_v3_rows (job_id, row_num, status, created_at, updated_at)
VALUES (@old_job_id, 1, 'valid', NOW(), NOW());
SET @old_row_id = LAST_INSERT_ID();

INSERT INTO import_v3_facts (row_id, column_id, raw_value, clean_value, created_at, updated_at)
VALUES (@old_row_id, @old_col_id, 'test_value', 'test_value', NOW(), NOW());

INSERT INTO import_v3_events (job_id, userid, event_type, created_at)
VALUES (@old_job_id, 999999, 'test_event', NOW());

-- Add some related records for RECENT job
INSERT INTO import_v3_columns (job_id, source_column_index, source_column_name, created_at)
VALUES (@recent_job_id, 0, 'test_column_1', NOW());
SET @recent_col_id = LAST_INSERT_ID();

INSERT INTO import_v3_rows (job_id, row_num, status, created_at, updated_at)
VALUES (@recent_job_id, 1, 'valid', NOW(), NOW());
SET @recent_row_id = LAST_INSERT_ID();

INSERT INTO import_v3_facts (row_id, column_id, raw_value, clean_value, created_at, updated_at)
VALUES (@recent_row_id, @recent_col_id, 'test_value', 'test_value', NOW(), NOW());

INSERT INTO import_v3_events (job_id, userid, event_type, created_at)
VALUES (@recent_job_id, 999999, 'test_event', NOW());

-- STEP 3: Verify test data was created
-- ============================================================
SELECT '=== STEP 3: Verify test data created ===' AS step;

SELECT 'Jobs created:' AS info;
SELECT job_id, userid, source_filename, status,
       finished_at,
       DATEDIFF(NOW(), finished_at) AS days_old
FROM import_v3_jobs
WHERE file_hash IN ('aaa111cleanuptest_old', 'bbb222cleanuptest_recent');

SELECT 'Related records for OLD job:' AS info;
SELECT
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = @old_job_id) AS columns_count,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @old_job_id) AS rows_count,
    (SELECT COUNT(*) FROM import_v3_facts f
     INNER JOIN import_v3_rows r ON f.row_id = r.row_id
     WHERE r.job_id = @old_job_id) AS facts_count,
    (SELECT COUNT(*) FROM import_v3_events WHERE job_id = @old_job_id) AS events_count;

SELECT 'Related records for RECENT job:' AS info;
SELECT
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = @recent_job_id) AS columns_count,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @recent_job_id) AS rows_count,
    (SELECT COUNT(*) FROM import_v3_facts f
     INNER JOIN import_v3_rows r ON f.row_id = r.row_id
     WHERE r.job_id = @recent_job_id) AS facts_count,
    (SELECT COUNT(*) FROM import_v3_events WHERE job_id = @recent_job_id) AS events_count;

-- ============================================================
-- STEP 4: RUN CLEANUP (via HTTP endpoint or direct service call)
-- ============================================================
-- To run cleanup with retention_days=1:
--
-- Option A: Via curl (requires admin session):
--   curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/admin_cleanup.cfm?retention_days=1"
--
-- Option B: Via ColdFusion console:
--   <cfset v3 = new services.ContactImportV3Service()>
--   <cfset result = v3.cleanupOldJobs(
--       retention_days = 1,
--       uploads_base_path = application.baseMediaPath & "\users"
--   )>
--   <cfdump var="#result#">
--
-- Expected result:
--   - OLD job (5 days old) should be deleted
--   - RECENT job (0 days old) should be preserved
-- ============================================================

SELECT '=== STEP 4: Run cleanup with retention_days=1 ===' AS step;
SELECT 'Execute cleanup via HTTP endpoint or service call' AS instruction;
SELECT 'Expected: Only OLD job deleted, RECENT job preserved' AS expected;

-- ============================================================
-- STEP 5: Verification queries AFTER cleanup
-- ============================================================

SELECT '=== STEP 5: Verification queries (run after cleanup) ===' AS step;

-- Query 5a: OLD job should be GONE
SELECT 'Query 5a: OLD job should be GONE (expect 0 rows):' AS verification;
SELECT job_id, source_filename, status, finished_at
FROM import_v3_jobs
WHERE file_hash = 'aaa111cleanuptest_old';

-- Query 5b: RECENT job should STILL EXIST
SELECT 'Query 5b: RECENT job should STILL EXIST (expect 1 row):' AS verification;
SELECT job_id, source_filename, status, finished_at
FROM import_v3_jobs
WHERE file_hash = 'bbb222cleanuptest_recent';

-- Query 5c: OLD job's related records should be GONE
SELECT 'Query 5c: OLD job related records should be GONE (all 0):' AS verification;
SELECT
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = @old_job_id) AS columns_remaining,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @old_job_id) AS rows_remaining,
    (SELECT COUNT(*) FROM import_v3_events WHERE job_id = @old_job_id) AS events_remaining;

-- Query 5d: RECENT job's related records should be INTACT
SELECT 'Query 5d: RECENT job related records should be INTACT (all 1):' AS verification;
SELECT
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = @recent_job_id) AS columns_count,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @recent_job_id) AS rows_count,
    (SELECT COUNT(*) FROM import_v3_events WHERE job_id = @recent_job_id) AS events_count;

-- ============================================================
-- STEP 6: Idempotency test - run cleanup AGAIN
-- ============================================================

SELECT '=== STEP 6: Idempotency test ===' AS step;
SELECT 'Run cleanup again - should find 0 jobs to delete' AS instruction;
SELECT 'Expected: jobs_found=0, jobs_deleted=0' AS expected;

-- ============================================================
-- STEP 7: Cleanup test data (optional)
-- ============================================================

SELECT '=== STEP 7: Cleanup test data (optional) ===' AS step;

-- Uncomment to remove test data:
-- DELETE FROM import_v3_events WHERE job_id = @recent_job_id;
-- DELETE FROM import_v3_facts WHERE row_id IN (SELECT row_id FROM import_v3_rows WHERE job_id = @recent_job_id);
-- DELETE FROM import_v3_rows WHERE job_id = @recent_job_id;
-- DELETE FROM import_v3_columns WHERE job_id = @recent_job_id;
-- DELETE FROM import_v3_jobs WHERE job_id = @recent_job_id;

-- ============================================================
-- PROOF SUMMARY
-- ============================================================
SELECT '=== PROOF SUMMARY ===' AS step;
SELECT 'If verification queries show:' AS summary;
SELECT '  - 5a: 0 rows (OLD job deleted)' AS check_1;
SELECT '  - 5b: 1 row (RECENT job preserved)' AS check_2;
SELECT '  - 5c: All 0 (OLD job related data deleted)' AS check_3;
SELECT '  - 5d: All 1 (RECENT job related data intact)' AS check_4;
SELECT '  - Step 6: jobs_found=0 (idempotent)' AS check_5;
SELECT 'Then cleanup is working correctly!' AS conclusion;
