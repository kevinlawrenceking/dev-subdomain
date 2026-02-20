-- ============================================================================
-- Contact Import V3 - SQL Query Test Script
-- ============================================================================
--
-- Purpose:
--   This script validates every SQL query pattern used in the Contact Import V3
--   workflow. It verifies schema correctness, query syntax, index coverage,
--   referential integrity, and data consistency WITHOUT modifying any data.
--
-- Safety:
--   - READ-ONLY: All write queries use WHERE 1=0 or are wrapped in ROLLBACK.
--   - No INSERTs, UPDATEs, or DELETEs touch real data.
--   - Safe to run against development or production.
--
-- Database:
--   - Schema: new_development (dev) / actorsbusinessoffice (prod)
--   - Datasource: reach
--   - Engine: MySQL (NOT SQL Server)
--
-- Source files covered:
--   - ajax/importv3/upload.cfm      - ajax/importv3/parse.cfm
--   - ajax/importv3/columns.cfm     - ajax/importv3/rows.cfm
--   - ajax/importv3/row.cfm         - ajax/importv3/row_action.cfm
--   - ajax/importv3/fact_update.cfm  - ajax/importv3/finalize.cfm
--   - ajax/importv3/status.cfm      - services/ContactImportV3Service.cfc
--
-- How to run:
--   mysql -u <user> -p new_development < import_v3_query_tests.sql
--
-- ============================================================================

USE new_development;

-- ============================================================================
-- SECTION 1: SCHEMA VERIFICATION
-- ============================================================================
-- Confirms all required tables and columns exist in the current schema.
-- ============================================================================

-- ---- 1.1  Required tables ----

-- TEST: Verify import_v3_jobs table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'import_v3_jobs' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_jobs') AS table_exists;

-- TEST: Verify import_v3_columns table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'import_v3_columns' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_columns') AS table_exists;

-- TEST: Verify import_v3_rows table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'import_v3_rows' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_rows') AS table_exists;

-- TEST: Verify import_v3_facts table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'import_v3_facts' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_facts') AS table_exists;

-- TEST: Verify import_v3_events table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'import_v3_events' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_events') AS table_exists;

-- TEST: Verify import_v3_row_results table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'import_v3_row_results' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_row_results') AS table_exists;

-- TEST: Verify feature_flags table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'feature_flags' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feature_flags') AS table_exists;

-- TEST: Verify feature_flag_users table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'feature_flag_users' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feature_flag_users') AS table_exists;

-- TEST: Verify contactdetails table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'contactdetails' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactdetails') AS table_exists;

-- TEST: Verify contactitems table exists
-- EXPECT: 1 row with table_exists = 1
SELECT 'contactitems' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactitems') AS table_exists;

-- TEST: Verify taousers table/view exists (used by admin queries)
-- EXPECT: 1 row with table_or_view_exists >= 1
SELECT 'taousers' AS table_name, (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'taousers') + (SELECT COUNT(*) FROM information_schema.VIEWS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'taousers') AS table_or_view_exists;

-- ---- 1.2  Required columns ----

-- TEST: Verify import_v3_jobs columns
-- EXPECT: column_count = 24
SELECT 'import_v3_jobs cols' AS chk, COUNT(*) AS col_count, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS cols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_jobs' AND COLUMN_NAME IN ('job_id','userid','source_filename','file_type','file_size','file_hash','stored_file_path','status','error_message','created_at','updated_at','started_at','finished_at','total_rows','parsed_rows','valid_rows','problem_rows','dupe_rows','imported_rows','updated_rows','skipped_rows','options_json','import_mode','allow_blank_overwrite');

-- TEST: Verify import_v3_columns columns
-- EXPECT: column_count = 12
SELECT 'import_v3_columns cols' AS chk, COUNT(*) AS col_count, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS cols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_columns' AND COLUMN_NAME IN ('column_id','job_id','source_column_index','source_column_name','mapped_field','is_custom_field','custom_field_id','confidence','user_confirmed','sample_values','intent','target_key');

-- TEST: Verify import_v3_rows columns
-- EXPECT: column_count = 19
SELECT 'import_v3_rows cols' AS chk, COUNT(*) AS col_count, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS cols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_rows' AND COLUMN_NAME IN ('row_id','job_id','row_num','raw_json','status','error_count','warning_count','matched_contactid','best_match_score','user_action','created_contactid','updated_contactid','import_error','validation_summary','dupe_candidates_json','imported_at','user_action_at','created_at','updated_at');

-- TEST: Verify import_v3_facts columns
-- EXPECT: column_count = 14
SELECT 'import_v3_facts cols' AS chk, COUNT(*) AS col_count, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS cols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_facts' AND COLUMN_NAME IN ('fact_id','row_id','column_id','field_name','raw_value','normalized_value','is_valid','validation_code','validation_message','existing_value','has_conflict','user_choice','created_at','updated_at');

-- TEST: Verify import_v3_events columns
-- EXPECT: column_count = 7
SELECT 'import_v3_events cols' AS chk, COUNT(*) AS col_count, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS cols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_events' AND COLUMN_NAME IN ('event_id','job_id','userid','event_type','event_detail','row_id','created_at');

-- TEST: Verify import_v3_row_results columns
-- EXPECT: column_count = 10
SELECT 'import_v3_row_results cols' AS chk, COUNT(*) AS col_count, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS cols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_row_results' AND COLUMN_NAME IN ('result_id','row_id','job_id','action_taken','contactid','fields_written','items_created','error_code','error_message','created_at');

-- TEST: Verify feature_flag_users columns
-- EXPECT: column_count = 6
SELECT 'feature_flag_users cols' AS chk, COUNT(*) AS col_count, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS cols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feature_flag_users' AND COLUMN_NAME IN ('flag_key','userid','is_enabled','notes','created_at','updated_at');

-- TEST: Verify feature_flags columns
-- EXPECT: column_count = 3
SELECT 'feature_flags cols' AS chk, COUNT(*) AS col_count, GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) AS cols FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feature_flags' AND COLUMN_NAME IN ('flag_key','is_enabled','updated_at');

-- ============================================================================
-- SECTION 2: INDEX VERIFICATION
-- ============================================================================
-- Confirms indexes exist that support frequent query patterns.
-- ============================================================================

-- TEST: Verify index on import_v3_jobs.userid (getJobForUser, getUserJobHistory)
-- EXPECT: index_count >= 1
SELECT 'import_v3_jobs.userid' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_jobs' AND COLUMN_NAME = 'userid';

-- TEST: Verify index on import_v3_jobs.file_hash (duplicate file check in upload.cfm)
-- EXPECT: index_count >= 1
SELECT 'import_v3_jobs.file_hash' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_jobs' AND COLUMN_NAME = 'file_hash';

-- TEST: Verify index on import_v3_jobs.status (acquireJobLock, cleanupOldJobs, getDashboardStats)
-- EXPECT: index_count >= 1
SELECT 'import_v3_jobs.status' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_jobs' AND COLUMN_NAME = 'status';

-- TEST: Verify index on import_v3_rows.job_id (getRows, getJobStats, finalizeJob)
-- EXPECT: index_count >= 1
SELECT 'import_v3_rows.job_id' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_rows' AND COLUMN_NAME = 'job_id';

-- TEST: Verify index on import_v3_rows.status (getRows with statusFilter, getJobStats)
-- EXPECT: index_count >= 1
SELECT 'import_v3_rows.status' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_rows' AND COLUMN_NAME = 'status';

-- TEST: Verify index on import_v3_facts.row_id (getRowDetail, processRowForImport, batch fact loading)
-- EXPECT: index_count >= 1
SELECT 'import_v3_facts.row_id' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_facts' AND COLUMN_NAME = 'row_id';

-- TEST: Verify index on import_v3_facts.field_name (search subquery, recomputeFullName)
-- EXPECT: index_count >= 1
SELECT 'import_v3_facts.field_name' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_facts' AND COLUMN_NAME = 'field_name';

-- TEST: Verify index on import_v3_events.job_id (cleanupOldJobs event deletion)
-- EXPECT: index_count >= 1
SELECT 'import_v3_events.job_id' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_events' AND COLUMN_NAME = 'job_id';

-- TEST: Verify index on import_v3_row_results.row_id (idempotency check in processRowForImport)
-- EXPECT: index_count >= 1
SELECT 'import_v3_row_results.row_id' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_row_results' AND COLUMN_NAME = 'row_id';

-- TEST: Verify index on import_v3_columns.job_id (columns.cfm column listing)
-- EXPECT: index_count >= 1
SELECT 'import_v3_columns.job_id' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_columns' AND COLUMN_NAME = 'job_id';

-- TEST: Verify index on feature_flag_users.flag_key (getAllowedUsers)
-- EXPECT: index_count >= 1
SELECT 'feature_flag_users.flag_key' AS idx_check, COUNT(*) AS index_count FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'feature_flag_users' AND COLUMN_NAME = 'flag_key';

-- TEST: Verify composite index on import_v3_jobs (userid, file_hash) for dupe check
-- EXPECT: composite_idx >= 1 (both columns in same index)
SELECT 'jobs_userid_hash' AS idx_check, COUNT(DISTINCT INDEX_NAME) AS composite_idx FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_jobs' AND INDEX_NAME IN (SELECT INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_jobs' AND COLUMN_NAME = 'userid') AND COLUMN_NAME = 'file_hash';

-- ============================================================================
-- SECTION 3: TEST DATA SETUP (transaction - rolled back in Section 99)
-- ============================================================================
-- Creates ephemeral test data used by Sections 4-26.
-- All data is created inside a transaction and ROLLED BACK in Section 99.
-- IMPORTANT: We use @test_* user variables to track IDs across statements.
-- ============================================================================

START TRANSACTION;

-- Use a sentinel userid that should not exist in production
SET @test_userid = 999999;

-- 3.1 Insert test job
INSERT INTO import_v3_jobs (
    userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, import_mode, allow_blank_overwrite,
    total_rows, parsed_rows, valid_rows, problem_rows, dupe_rows,
    imported_rows, updated_rows, skipped_rows,
    created_at, updated_at
) VALUES (
    @test_userid, 'test_contacts.csv', 'csv', 1234, 'abc123def456abc123def456abc123def456abc123def456abc123def456abcd1234',
    '/tmp/test/test_contacts.csv', 'reviewing', 'create_only', 0,
    5, 5, 2, 1, 1,
    0, 0, 0,
    NOW(), NOW()
);
SET @test_job_id = LAST_INSERT_ID();
SELECT 'Test job created' AS step, @test_job_id AS job_id;

-- 3.2 Insert test columns
INSERT INTO import_v3_columns (job_id, source_column_index, source_column_name, mapped_field, sample_values, intent, created_at, updated_at)
VALUES
    (@test_job_id, 0, 'First Name', 'firstName', 'John,Jane,Bob', 'map', NOW(), NOW()),
    (@test_job_id, 1, 'Last Name', 'lastName', 'Doe,Smith,Jones', 'map', NOW(), NOW()),
    (@test_job_id, 2, 'Email', 'email_business', 'john@test.com,jane@test.com', 'map', NOW(), NOW()),
    (@test_job_id, 3, 'Phone', 'phone_work', '555-1234,555-5678', 'map', NOW(), NOW()),
    (@test_job_id, 4, 'Company', 'company', 'Acme Inc,Widget Corp', 'map', NOW(), NOW());
SET @test_col1_id = LAST_INSERT_ID();
SET @test_col2_id = @test_col1_id + 1;
SET @test_col3_id = @test_col1_id + 2;
SET @test_col4_id = @test_col1_id + 3;
SET @test_col5_id = @test_col1_id + 4;
SELECT 'Test columns created' AS step, @test_col1_id AS first_col_id;

-- 3.3 Insert test rows (ready, problem, dupe, ignored, imported)
INSERT INTO import_v3_rows (job_id, row_num, raw_json, status, error_count, warning_count, user_action, dupe_candidates_json, created_at, updated_at)
VALUES
    (@test_job_id, 1, '{"firstName":"John","lastName":"Doe"}', 'ready', 0, 0, NULL, NULL, NOW(), NOW()),
    (@test_job_id, 2, '{"firstName":"Jane","lastName":"Smith"}', 'ready', 0, 0, NULL, NULL, NOW(), NOW()),
    (@test_job_id, 3, '{"firstName":"Bad","email":"notanemail"}', 'problem', 1, 0, NULL, NULL, NOW(), NOW()),
    (@test_job_id, 4, '{"firstName":"Dupe","lastName":"Contact"}', 'dupe', 0, 0, 'import_new', '[{"contactid":1,"score":90,"reasons":["name match"]}]', NOW(), NOW()),
    (@test_job_id, 5, '{"firstName":"Skip","lastName":"Me"}', 'ignored', 0, 0, 'skip', NULL, NOW(), NOW());
SET @test_row1_id = LAST_INSERT_ID();
SET @test_row2_id = @test_row1_id + 1;
SET @test_row3_id = @test_row1_id + 2;
SET @test_row4_id = @test_row1_id + 3;
SET @test_row5_id = @test_row1_id + 4;
SELECT 'Test rows created' AS step, @test_row1_id AS first_row_id;

-- 3.4 Insert test facts for each row
INSERT INTO import_v3_facts (row_id, column_id, field_name, raw_value, normalized_value, is_valid, created_at, updated_at) VALUES
    -- Row 1: John Doe (ready)
    (@test_row1_id, @test_col1_id, 'firstName', 'John', 'John', 1, NOW(), NOW()),
    (@test_row1_id, @test_col2_id, 'lastName', 'Doe', 'Doe', 1, NOW(), NOW()),
    (@test_row1_id, @test_col3_id, 'email_business', 'john@test.com', 'john@test.com', 1, NOW(), NOW()),
    (@test_row1_id, @test_col4_id, 'phone_work', '555-1234', '555-1234', 1, NOW(), NOW()),
    (@test_row1_id, @test_col5_id, 'company', 'Acme Inc', 'Acme Inc', 1, NOW(), NOW()),
    (@test_row1_id, 0, 'contactFullName', 'John Doe', 'John Doe', 1, NOW(), NOW()),
    -- Row 2: Jane Smith (ready)
    (@test_row2_id, @test_col1_id, 'firstName', 'Jane', 'Jane', 1, NOW(), NOW()),
    (@test_row2_id, @test_col2_id, 'lastName', 'Smith', 'Smith', 1, NOW(), NOW()),
    (@test_row2_id, @test_col3_id, 'email_business', 'jane@test.com', 'jane@test.com', 1, NOW(), NOW()),
    (@test_row2_id, 0, 'contactFullName', 'Jane Smith', 'Jane Smith', 1, NOW(), NOW()),
    -- Row 3: Bad data (problem)
    (@test_row3_id, @test_col1_id, 'firstName', 'Bad', 'Bad', 1, NOW(), NOW()),
    (@test_row3_id, @test_col3_id, 'email_business', 'notanemail', NULL, 0, NOW(), NOW()),
    -- Row 4: Dupe Contact
    (@test_row4_id, @test_col1_id, 'firstName', 'Dupe', 'Dupe', 1, NOW(), NOW()),
    (@test_row4_id, @test_col2_id, 'lastName', 'Contact', 'Contact', 1, NOW(), NOW()),
    (@test_row4_id, 0, 'contactFullName', 'Dupe Contact', 'Dupe Contact', 1, NOW(), NOW()),
    -- Row 5: Skip Me (ignored)
    (@test_row5_id, @test_col1_id, 'firstName', 'Skip', 'Skip', 1, NOW(), NOW()),
    (@test_row5_id, @test_col2_id, 'lastName', 'Me', 'Me', 1, NOW(), NOW()),
    (@test_row5_id, 0, 'contactFullName', 'Skip Me', 'Skip Me', 1, NOW(), NOW());
SELECT 'Test facts created' AS step, (SELECT COUNT(*) FROM import_v3_facts WHERE row_id BETWEEN @test_row1_id AND @test_row5_id) AS fact_count;

-- 3.5 Insert a test event
INSERT INTO import_v3_events (job_id, userid, event_type, event_detail, created_at)
VALUES (@test_job_id, @test_userid, 'test_event', '{"test":true}', NOW());
SET @test_event_id = LAST_INSERT_ID();
SELECT 'Test event created' AS step, @test_event_id AS event_id;

-- 3.6 Verify test data integrity before proceeding
SELECT 'TEST DATA SUMMARY' AS section,
    (SELECT COUNT(*) FROM import_v3_jobs WHERE job_id = @test_job_id) AS jobs,
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = @test_job_id) AS columns_count,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id) AS rows_count,
    (SELECT COUNT(*) FROM import_v3_facts WHERE row_id BETWEEN @test_row1_id AND @test_row5_id) AS facts,
    (SELECT COUNT(*) FROM import_v3_events WHERE job_id = @test_job_id) AS events;

-- ============================================================================
-- SECTION 4: getJob / getJobForUser (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 4.1: getJob - fetch by job_id only
-- Source: getJob() method
-- EXPECT: 1 row with all columns populated
SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, error_message, created_at, updated_at,
    started_at, finished_at, total_rows, parsed_rows, valid_rows,
    problem_rows, dupe_rows, imported_rows, updated_rows, skipped_rows,
    options_json, import_mode, allow_blank_overwrite
FROM import_v3_jobs
WHERE job_id = @test_job_id;

-- TEST 4.2: getJobForUser - fetch with ownership filter
-- Source: getJobForUser() method
-- EXPECT: 1 row when userid matches
SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, error_message, created_at, updated_at,
    started_at, finished_at, total_rows, parsed_rows, valid_rows,
    problem_rows, dupe_rows, imported_rows, updated_rows, skipped_rows,
    options_json, import_mode, allow_blank_overwrite
FROM import_v3_jobs
WHERE job_id = @test_job_id AND userid = @test_userid;

-- TEST 4.3: getJobForUser - wrong userid returns 0 rows
-- EXPECT: 0 rows
SELECT job_id FROM import_v3_jobs WHERE job_id = @test_job_id AND userid = 0;

-- TEST 4.4: getJobForUser fallback - existence check
-- Source: getJobForUser() when userid mismatch, checks if job_id exists at all
-- EXPECT: 1 row (job exists)
SELECT job_id FROM import_v3_jobs WHERE job_id = @test_job_id;

-- TEST 4.5: assertJobOwnership
-- Source: assertJobOwnership() method
-- EXPECT: 1 row when ownership is valid
SELECT job_id FROM import_v3_jobs WHERE job_id = @test_job_id AND userid = @test_userid;

-- ============================================================================
-- SECTION 5: Duplicate File Check (upload.cfm)
-- ============================================================================

-- TEST 5.1: Check for existing file by userid + file_hash
-- Source: upload.cfm duplicate check query
-- EXPECT: 1 row (our test job matches)
SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, created_at, updated_at
FROM import_v3_jobs
WHERE userid = @test_userid AND file_hash = 'abc123def456abc123def456abc123def456abc123def456abc123def456abcd1234';

-- TEST 5.2: No match for different hash
-- EXPECT: 0 rows
SELECT job_id FROM import_v3_jobs WHERE userid = @test_userid AND file_hash = 'aaaa0000bbbb1111cccc2222dddd3333eeee4444ffff5555aaaa6666bbbb77778888';

-- TEST 5.3: INSERT new job (WHERE 1=0 - never executes)
-- Source: upload.cfm new job insert
-- EXPECT: 0 rows affected (syntax validation only)
INSERT INTO import_v3_jobs (
    userid, source_filename, file_type, file_size, file_hash,
    stored_file_path, status, created_at, updated_at
) SELECT
    999998, 'syntax_test.csv', 'csv', 100, 'deadbeef',
    '/tmp/test.csv', 'uploaded', NOW(), NOW()
FROM DUAL WHERE 1=0;

-- ============================================================================
-- SECTION 6: setJobStatus (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 6.1: Basic status update (WHERE 1=0 - syntax check only)
-- Source: setJobStatus() method
-- EXPECT: 0 rows affected
UPDATE import_v3_jobs SET status = 'finalizing', updated_at = NOW(), started_at = NOW()
WHERE job_id = @test_job_id AND userid = @test_userid AND 1=0;

-- TEST 6.2: Status update with finished_at (for completed/failed/cancelled)
-- EXPECT: 0 rows affected
UPDATE import_v3_jobs SET status = 'completed', updated_at = NOW(), finished_at = NOW()
WHERE job_id = @test_job_id AND userid = @test_userid AND 1=0;

-- TEST 6.3: Status update with error_message (for failed)
-- EXPECT: 0 rows affected
UPDATE import_v3_jobs SET status = 'failed', updated_at = NOW(), finished_at = NOW(), error_message = 'Test error'
WHERE job_id = @test_job_id AND userid = @test_userid AND 1=0;

-- TEST 6.4: status.cfm manual transition - reset finished_at on re-open
-- Source: status.cfm section J
-- EXPECT: 0 rows affected
UPDATE import_v3_jobs SET status = 'reviewing', updated_at = NOW(), finished_at = NULL, error_message = NULL
WHERE job_id = @test_job_id AND userid = @test_userid AND 1=0;

-- TEST 6.5: status.cfm manual transition - cancel sets finished_at
-- EXPECT: 0 rows affected
UPDATE import_v3_jobs SET status = 'cancelled', updated_at = NOW(), finished_at = NOW()
WHERE job_id = @test_job_id AND userid = @test_userid AND 1=0;

-- ============================================================================
-- SECTION 7: acquireJobLock / releaseJobLock (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 7.1: acquireJobLock for finalize - UPDATE with status IN filter
-- Source: acquireJobLock() method, purpose=finalize
-- Uses parameterized IN list (status IN (:status_list))
-- EXPECT: 0 rows affected (WHERE 1=0)
UPDATE import_v3_jobs SET status = 'finalizing', updated_at = NOW()
WHERE job_id = @test_job_id AND userid = @test_userid AND status IN ('reviewing') AND 1=0;

-- TEST 7.2: acquireJobLock for parse - UPDATE with status IN filter
-- Source: acquireJobLock() method, purpose=parse
-- EXPECT: 0 rows affected (WHERE 1=0)
UPDATE import_v3_jobs SET status = 'parsing', updated_at = NOW()
WHERE job_id = @test_job_id AND userid = @test_userid AND status IN ('uploaded') AND 1=0;

-- TEST 7.3: releaseJobLock - revert finalizing to reviewing
-- Source: releaseJobLock() method
-- EXPECT: 0 rows affected (WHERE 1=0)
UPDATE import_v3_jobs SET status = 'reviewing', updated_at = NOW()
WHERE job_id = @test_job_id AND userid = @test_userid AND 1=0;

-- TEST 7.4: Verify ROW_COUNT() check pattern works
-- The service checks qResult.recordCount (affected rows) to determine lock success
-- EXPECT: ROW_COUNT() = 0 (no rows matched AND 1=0)
UPDATE import_v3_jobs SET status = 'finalizing', updated_at = NOW()
WHERE job_id = @test_job_id AND userid = @test_userid AND status IN ('reviewing') AND 1=0;
SELECT ROW_COUNT() AS affected_rows;

-- ============================================================================
-- SECTION 8: logEvent (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 8.1: logEvent without row_id
-- Source: logEvent() method (row_id = 0 branch)
-- EXPECT: 0 rows affected (WHERE 1=0)
INSERT INTO import_v3_events (job_id, userid, event_type, event_detail, created_at)
SELECT @test_job_id, @test_userid, 'test_syntax', '{"test":true}', NOW()
FROM DUAL WHERE 1=0;

-- TEST 8.2: logEvent with row_id
-- Source: logEvent() method (row_id > 0 branch)
-- EXPECT: 0 rows affected (WHERE 1=0)
INSERT INTO import_v3_events (job_id, userid, event_type, event_detail, row_id, created_at)
SELECT @test_job_id, @test_userid, 'row_test', '{"test":true}', @test_row1_id, NOW()
FROM DUAL WHERE 1=0;

-- TEST 8.3: Verify test event was inserted in section 3
-- EXPECT: 1 row
SELECT event_id, job_id, userid, event_type, event_detail, created_at
FROM import_v3_events
WHERE job_id = @test_job_id AND event_type = 'test_event';

-- ============================================================================
-- SECTION 9: getJobStats (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 9.1: Row status grouping
-- Source: getJobStats() method
-- EXPECT: Multiple rows with status counts (ready=2, problem=1, dupe=1, ignored=1)
SELECT status, COUNT(*) AS cnt
FROM import_v3_rows
WHERE job_id = @test_job_id
GROUP BY status;

-- TEST 9.2: Verify total matches sum of individual statuses
-- EXPECT: total_check = 1 (totals match)
SELECT
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id) AS total_rows,
    (SELECT SUM(cnt) FROM (SELECT COUNT(*) AS cnt FROM import_v3_rows WHERE job_id = @test_job_id GROUP BY status) sub) AS sum_by_status,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id) =
    (SELECT SUM(cnt) FROM (SELECT COUNT(*) AS cnt FROM import_v3_rows WHERE job_id = @test_job_id GROUP BY status) sub) AS total_check;

-- ============================================================================
-- SECTION 10: getRows - Paginated, Filtered, Search (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 10.1: Basic paginated row listing (page 1, pageSize 50)
-- Source: getRows() method, statusFilter=all
-- EXPECT: 5 rows (all test rows)
SELECT r.row_id, r.row_num, r.status, r.error_count, r.warning_count,
       r.matched_contactid, r.best_match_score, r.user_action,
       r.created_contactid, r.updated_contactid, r.import_error,
       r.validation_summary, r.dupe_candidates_json
FROM import_v3_rows r
WHERE r.job_id = @test_job_id
ORDER BY r.row_num ASC
LIMIT 50 OFFSET 0;

-- TEST 10.2: Filtered by status = ready
-- EXPECT: 2 rows
SELECT COUNT(*) AS cnt FROM import_v3_rows r
WHERE r.job_id = @test_job_id AND r.status = 'ready';

-- TEST 10.3: Filtered by status = imported (includes imported, updated, failed)
-- Source: getRows() imported filter maps to IN (imported,updated,failed)
-- EXPECT: 0 rows (no imported rows yet)
SELECT COUNT(*) AS cnt FROM import_v3_rows r
WHERE r.job_id = @test_job_id AND r.status IN ('imported','updated','failed');

-- TEST 10.4: Count query for pagination
-- Source: getRows() count subquery
-- EXPECT: cnt = 5
SELECT COUNT(*) AS cnt FROM import_v3_rows r WHERE r.job_id = @test_job_id;

-- TEST 10.5: Search via facts subquery
-- Source: getRows() search clause with LIKE on normalized_value
-- EXPECT: 1 row (John Doe)
SELECT COUNT(*) AS cnt FROM import_v3_rows r
WHERE r.job_id = @test_job_id
AND r.row_id IN (
    SELECT DISTINCT f.row_id FROM import_v3_facts f
    WHERE f.row_id IN (SELECT r2.row_id FROM import_v3_rows r2 WHERE r2.job_id = @test_job_id)
      AND f.field_name IN ('first_name','last_name','contactFullName','email_business','email_personal','company','phone_work','phone_mobile')
      AND f.normalized_value LIKE '%John%'
);

-- TEST 10.6: Batch fact loading for row list
-- Source: getRows() batch fact SELECT with IN(:row_id_list)
-- EXPECT: Multiple rows (all facts for test rows)
SELECT f.row_id, f.field_name, f.normalized_value, f.is_valid,
       f.validation_code, f.validation_message
FROM import_v3_facts f
WHERE f.row_id IN (@test_row1_id, @test_row2_id, @test_row3_id, @test_row4_id, @test_row5_id)
ORDER BY f.row_id, f.field_name;

-- ============================================================================
-- SECTION 11: getRowDetail (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 11.1: Fetch single row by row_id + job_id
-- Source: getRowDetail() method
-- EXPECT: 1 row
SELECT r.* FROM import_v3_rows r
WHERE r.row_id = @test_row1_id AND r.job_id = @test_job_id;

-- TEST 11.2: Fetch facts for a row (full detail)
-- Source: getRowDetail() facts query
-- EXPECT: 6 rows (all facts for row 1)
SELECT f.fact_id, f.column_id, f.field_name, f.raw_value, f.normalized_value,
       f.is_valid, f.validation_code, f.validation_message,
       f.existing_value, f.has_conflict, f.user_choice
FROM import_v3_facts f
WHERE f.row_id = @test_row1_id
ORDER BY f.field_name;

-- TEST 11.3: Dupe candidate contact name lookup
-- Source: getRowDetail() dupe candidate enrichment
-- EXPECT: Query succeeds (may return 0 rows if contactid=1 does not belong to test user)
SELECT contactFullName FROM contactdetails WHERE contactid = 1 AND userid = @test_userid;

-- TEST 11.4: Row not found (bad row_id)
-- EXPECT: 0 rows
SELECT r.* FROM import_v3_rows r WHERE r.row_id = 0 AND r.job_id = @test_job_id;

-- ============================================================================
-- SECTION 12: setRowAction (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 12.1: Row ownership check via INNER JOIN
-- Source: setRowAction() ownership query
-- EXPECT: 1 row
SELECT r.row_id, r.status
FROM import_v3_rows r
INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE r.row_id = @test_row1_id AND r.job_id = @test_job_id AND j.userid = @test_userid;

-- TEST 12.2: Set action to ignore with status change (WHERE 1=0)
-- Source: setRowAction() when dbAction=skip and newStatus=ignored
-- EXPECT: 0 rows affected
UPDATE import_v3_rows SET user_action = 'skip', status = 'ignored', user_action_at = NOW(), updated_at = NOW()
WHERE row_id = @test_row1_id AND 1=0;

-- TEST 12.3: Set action to import_new without status change (WHERE 1=0)
-- Source: setRowAction() when dbAction=import_new and no status override
-- EXPECT: 0 rows affected
UPDATE import_v3_rows SET user_action = 'import_new', user_action_at = NOW(), updated_at = NOW()
WHERE row_id = @test_row4_id AND 1=0;

-- TEST 12.4: Restore ignored row to ready (import_new on ignored row)
-- Source: setRowAction() when dbAction=import_new and current status=ignored
-- EXPECT: 0 rows affected
UPDATE import_v3_rows SET user_action = 'import_new', status = 'ready', user_action_at = NOW(), updated_at = NOW()
WHERE row_id = @test_row5_id AND 1=0;

-- ============================================================================
-- SECTION 13: bulkRowAction (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 13.1: Bulk ignore - UPDATE with INNER JOIN, IN list, status exclusion
-- Source: bulkRowAction() when dbAction=skip, newStatus=ignored
-- EXPECT: 0 rows affected (WHERE 1=0)
UPDATE import_v3_rows r
INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
SET r.user_action = 'skip', r.status = 'ignored', r.user_action_at = NOW(), r.updated_at = NOW()
WHERE r.row_id IN (@test_row1_id, @test_row2_id)
  AND r.job_id = @test_job_id
  AND j.userid = @test_userid
  AND r.status NOT IN ('imported', 'updated', 'failed')
  AND 1=0;

-- TEST 13.2: Bulk create - UPDATE with CASE for restoring ignored rows
-- Source: bulkRowAction() when dbAction=import_new, uses CASE WHEN for status
-- EXPECT: 0 rows affected (WHERE 1=0)
UPDATE import_v3_rows r
INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
SET r.user_action = 'import_new',
    r.status = CASE WHEN r.status = 'ignored' THEN 'ready' ELSE r.status END,
    r.user_action_at = NOW(), r.updated_at = NOW()
WHERE r.row_id IN (@test_row4_id, @test_row5_id)
  AND r.job_id = @test_job_id
  AND j.userid = @test_userid
  AND r.status NOT IN ('imported', 'updated', 'failed')
  AND 1=0;

-- TEST 13.3: row_action.cfm select_all_filter query
-- Source: row_action.cfm when applying action to all rows of a given status
-- EXPECT: 2 rows (ready rows)
SELECT row_id FROM import_v3_rows
WHERE job_id = @test_job_id AND status = 'ready';

-- ============================================================================
-- SECTION 14: updateRowFacts (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 14.1: Row ownership check with INNER JOIN
-- Source: updateRowFacts() ownership query
-- EXPECT: 1 row
SELECT r.row_id, r.status, r.dupe_candidates_json
FROM import_v3_rows r
INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE r.row_id = @test_row1_id AND r.job_id = @test_job_id AND j.userid = @test_userid;

-- TEST 14.2: Fact upsert via INSERT...SELECT...ON DUPLICATE KEY UPDATE
-- Source: updateRowFacts() fact upsert query
-- EXPECT: 0 rows affected (WHERE 1=0)
INSERT INTO import_v3_facts (row_id, column_id, field_name, raw_value, normalized_value, is_valid, validation_code, validation_message, updated_at)
SELECT @test_row1_id, COALESCE(c.column_id, 0), 'email_business', 'new@test.com', 'new@test.com', 1, NULL, NULL, NOW()
FROM (SELECT 1) AS dummy
LEFT JOIN import_v3_columns c ON c.job_id = @test_job_id AND c.mapped_field = 'email_business'
WHERE 1=0
ON DUPLICATE KEY UPDATE raw_value = 'new@test.com', normalized_value = 'new@test.com', is_valid = 1, validation_code = NULL, validation_message = NULL, updated_at = NOW();

-- TEST 14.3: Row status update with error_count subquery
-- Source: updateRowFacts() recompute row status
-- EXPECT: 0 rows affected (WHERE 1=0)
UPDATE import_v3_rows
SET status = 'ready',
    error_count = (SELECT COUNT(*) FROM import_v3_facts WHERE row_id = @test_row1_id AND is_valid = 0),
    updated_at = NOW()
WHERE row_id = @test_row1_id AND 1=0;

-- ============================================================================
-- SECTION 15: recomputeFullName / recomputeRowStatus (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 15.1: Fetch firstName and lastName for full name rebuild
-- Source: recomputeFullName() method
-- EXPECT: 2 rows (firstName and lastName facts)
SELECT field_name, normalized_value
FROM import_v3_facts
WHERE row_id = @test_row1_id AND field_name IN ('firstName', 'lastName');

-- TEST 15.2: Update contactFullName fact (WHERE 1=0)
-- Source: recomputeFullName() update query
-- EXPECT: 0 rows affected
UPDATE import_v3_facts
SET normalized_value = 'John Doe', updated_at = NOW()
WHERE row_id = @test_row1_id AND field_name = 'contactFullName' AND 1=0;

-- TEST 15.3: Count invalid facts for recomputeRowStatus
-- Source: recomputeRowStatus() method
-- EXPECT: cnt = 0 for row 1 (all valid), cnt = 1 for row 3 (has invalid email)
SELECT @test_row1_id AS row_id, 'ready_row' AS label,
    (SELECT COUNT(*) FROM import_v3_facts WHERE row_id = @test_row1_id AND is_valid = 0) AS invalid_count;
SELECT @test_row3_id AS row_id, 'problem_row' AS label,
    (SELECT COUNT(*) FROM import_v3_facts WHERE row_id = @test_row3_id AND is_valid = 0) AS invalid_count;

-- ============================================================================
-- SECTION 16: updateJobRowCounts (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 16.1: Subquery-based job count update
-- Source: updateJobRowCounts() method
-- EXPECT: 0 rows affected (WHERE 1=0)
UPDATE import_v3_jobs j
SET j.valid_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'ready'),
    j.problem_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'problem'),
    j.dupe_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'dupe'),
    j.skipped_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'ignored'),
    j.imported_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status IN ('imported', 'updated')),
    j.updated_at = NOW()
WHERE j.job_id = @test_job_id AND 1=0;

-- TEST 16.2: Verify current counts match expected from test data
-- EXPECT: valid=2, problem=1, dupe=1, ignored=1
SELECT
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id AND status = 'ready') AS valid_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id AND status = 'problem') AS problem_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id AND status = 'dupe') AS dupe_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id AND status = 'ignored') AS ignored_rows,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id AND status IN ('imported', 'updated')) AS imported_rows;

-- ============================================================================
-- SECTION 17: columns.cfm Queries
-- ============================================================================

-- TEST 17.1: List columns for a job
-- Source: columns.cfm GET handler
-- EXPECT: 5 columns
SELECT column_id, job_id, source_column_index, source_column_name,
       mapped_field, is_custom_field, custom_field_id, confidence,
       user_confirmed, sample_values, intent, target_key
FROM import_v3_columns
WHERE job_id = @test_job_id
ORDER BY source_column_index;

-- TEST 17.2: Distinct sample values from facts for a column
-- Source: columns.cfm sample value query
-- EXPECT: Values from firstName column
SELECT DISTINCT f.raw_value
FROM import_v3_facts f
INNER JOIN import_v3_rows r ON f.row_id = r.row_id
WHERE f.column_id = @test_col1_id
  AND r.job_id = @test_job_id
  AND f.raw_value IS NOT NULL
  AND TRIM(f.raw_value) != ''
LIMIT 5;

-- TEST 17.3: Column ownership check via INNER JOIN
-- Source: columns.cfm POST handler ownership validation
-- EXPECT: 1 row
SELECT c.column_id
FROM import_v3_columns c
INNER JOIN import_v3_jobs j ON c.job_id = j.job_id
WHERE c.column_id = @test_col1_id AND j.userid = @test_userid;

-- TEST 17.4: Column mapping update (WHERE 1=0)
-- Source: columns.cfm POST handler
-- EXPECT: 0 rows affected
UPDATE import_v3_columns SET mapped_field = 'firstName', user_confirmed = 1, updated_at = NOW()
WHERE column_id = @test_col1_id AND 1=0;

-- ============================================================================
-- SECTION 18: parse.cfm Queries (INSERT IGNORE, idempotency checks)
-- ============================================================================

-- TEST 18.1: INSERT IGNORE into columns (idempotent re-parse)
-- Source: parse.cfm column insertion
-- EXPECT: 0 rows affected (rows already exist from section 3)
INSERT IGNORE INTO import_v3_columns (job_id, source_column_index, source_column_name, sample_values, created_at, updated_at)
VALUES (@test_job_id, 0, 'First Name', 'John,Jane,Bob', NOW(), NOW());
SELECT ROW_COUNT() AS cols_inserted_on_reparse;

-- TEST 18.2: INSERT IGNORE into rows (idempotent re-parse)
-- Source: parse.cfm row insertion
-- EXPECT: 0 rows affected (rows already exist) - requires unique index on (job_id, row_num)
INSERT IGNORE INTO import_v3_rows (job_id, row_num, raw_json, status, created_at, updated_at)
VALUES (@test_job_id, 1, '{"firstName":"John","lastName":"Doe"}', 'pending', NOW(), NOW());
SELECT ROW_COUNT() AS rows_inserted_on_reparse;

-- TEST 18.3: Idempotency count check for parsed rows
-- Source: parse.cfm checks existing row count before parsing
-- EXPECT: cnt = 5
SELECT COUNT(*) AS cnt FROM import_v3_rows WHERE job_id = @test_job_id;

-- TEST 18.4: Multi-table count check
-- Source: parse.cfm pre-parse verification
-- EXPECT: All counts > 0
SELECT
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = @test_job_id) AS col_count,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id) AS row_count,
    (SELECT COUNT(*) FROM import_v3_facts WHERE row_id IN (SELECT row_id FROM import_v3_rows WHERE job_id = @test_job_id)) AS fact_count;

-- ============================================================================
-- SECTION 19: finalizeJob - Eligible Row Selection (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 19.1: Eligible rows query (ready OR dupe+import_new)
-- Source: finalizeJob() method, section B
-- EXPECT: 3 rows (2 ready + 1 dupe with import_new)
SELECT r.row_id, r.row_num, r.status, r.user_action, r.created_contactid
FROM import_v3_rows r
WHERE r.job_id = @test_job_id
  AND (
      r.status = 'ready'
      OR (r.status = 'dupe' AND r.user_action = 'import_new')
  )
ORDER BY r.row_num ASC;

-- TEST 19.2: Verify problem and ignored rows are excluded
-- EXPECT: 0 rows (the conditions are mutually exclusive)
SELECT r.row_id, r.status, r.user_action
FROM import_v3_rows r
WHERE r.job_id = @test_job_id
  AND (
      r.status = 'ready'
      OR (r.status = 'dupe' AND r.user_action = 'import_new')
  )
  AND r.status IN ('problem', 'ignored');

-- ============================================================================
-- SECTION 20: processRowForImport (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 20.1: Idempotency check - row_results lookup
-- Source: processRowForImport() idempotency check
-- EXPECT: 0 rows (no results yet for our test rows)
SELECT result_id, action_taken, contactid
FROM import_v3_row_results
WHERE row_id = @test_row1_id;

-- TEST 20.2: Load valid facts for import
-- Source: processRowForImport() facts query
-- EXPECT: 6 rows (all valid facts for row 1)
SELECT f.fact_id, f.field_name, f.normalized_value, f.is_valid
FROM import_v3_facts f
WHERE f.row_id = @test_row1_id
  AND f.is_valid = 1
  AND f.normalized_value IS NOT NULL
  AND f.normalized_value != '';

-- TEST 20.3: contactdetails INSERT (WHERE 1=0 - syntax check)
-- Source: processRowForImport() section D1
-- EXPECT: 0 rows affected
INSERT INTO contactdetails (userid, contactFullName, recordname, user_yn, created_at)
SELECT @test_userid, 'Syntax Test', 'Syntax Test', 'Y', NOW()
FROM DUAL WHERE 1=0;

-- TEST 20.4: contactitems INSERT - Email (WHERE 1=0)
-- Source: insertContactItems() email insert
-- EXPECT: 0 rows affected
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
SELECT 0, 'Email', 'Business', 'test@test.com', 'Active'
FROM DUAL WHERE 1=0;

-- TEST 20.5: contactitems INSERT - Phone (WHERE 1=0)
-- Source: insertContactItems() phone insert
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
SELECT 0, 'Phone', 'Work', '555-1234', 'Active'
FROM DUAL WHERE 1=0;

-- TEST 20.6: contactitems INSERT - Company (WHERE 1=0)
-- Source: insertContactItems() company insert
INSERT INTO contactitems (contactid, valueCategory, valueType, valueCompany, valueTitle, itemStatus)
SELECT 0, 'Company', 'Company', 'Acme Inc', 'Engineer', 'Active'
FROM DUAL WHERE 1=0;

-- TEST 20.7: contactitems INSERT - Address (WHERE 1=0)
-- Source: insertContactItems() address insert
INSERT INTO contactitems (contactid, valueCategory, valueType, valueStreetAddress, valueExtendedAddress, valueCity, valueRegion, valuePostalCode, valueCountry, itemStatus)
SELECT 0, 'Address', 'Work', '123 Main St', 'Suite 100', 'Los Angeles', 'CA', '90001', 'US', 'Active'
FROM DUAL WHERE 1=0;

-- TEST 20.8: contactitems INSERT - Social (WHERE 1=0)
-- Source: insertContactItems() social media inserts
INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
SELECT 0, 'Social', 'LinkedIn', 'https://linkedin.com/in/test', 'Active'
FROM DUAL WHERE 1=0;

-- TEST 20.9: contactItemExists deduplication check
-- Source: contactItemExists() method
-- EXPECT: Query runs successfully (may return 0 rows)
SELECT 1 FROM contactitems
WHERE contactid = 0 AND valueCategory = 'Email' AND valuetext = 'test@test.com' AND itemStatus = 'Active'
LIMIT 1;

-- TEST 20.10: Update row to imported status (WHERE 1=0)
-- Source: processRowForImport() section D3
UPDATE import_v3_rows
SET status = 'imported', created_contactid = 12345, imported_at = NOW(), updated_at = NOW()
WHERE row_id = @test_row1_id AND 1=0;

-- TEST 20.11: Record row result (INSERT...ON DUPLICATE KEY UPDATE)
-- Source: processRowForImport() section D4 and recordRowResult()
-- EXPECT: 0 rows affected (WHERE 1=0)
INSERT INTO import_v3_row_results (
    row_id, job_id, action_taken, contactid, fields_written, items_created, created_at
) SELECT
    @test_row1_id, @test_job_id, 'created', 12345, 6, 3, NOW()
FROM DUAL WHERE 1=0
ON DUPLICATE KEY UPDATE
    action_taken = VALUES(action_taken), contactid = VALUES(contactid), fields_written = VALUES(fields_written), items_created = VALUES(items_created);

-- TEST 20.12: Record failure result with error fields
-- Source: recordRowResult() with error_code and error_message
INSERT INTO import_v3_row_results (
    row_id, job_id, action_taken, contactid, fields_written, items_created, error_code, error_message, created_at
) SELECT
    @test_row3_id, @test_job_id, 'failed', NULL, 0, 0, 'NO_VALID_FACTS', 'No valid fields to import', NOW()
FROM DUAL WHERE 1=0
ON DUPLICATE KEY UPDATE
    action_taken = 'failed', contactid = NULL, error_code = 'NO_VALID_FACTS', error_message = 'No valid fields to import';

-- TEST 20.13: Row status update to failed on error
-- Source: processRowForImport() error handler
UPDATE import_v3_rows
SET status = 'failed', import_error = 'Test error message', updated_at = NOW()
WHERE row_id = @test_row1_id AND 1=0;

-- ============================================================================
-- SECTION 21: updateJobCounts - Post-Finalize (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 21.1: Direct count update (WHERE 1=0)
-- Source: updateJobCounts() method
-- EXPECT: 0 rows affected
UPDATE import_v3_jobs SET
    imported_rows = 2,
    updated_rows = 0,
    skipped_rows = 1,
    updated_at = NOW()
WHERE job_id = @test_job_id AND 1=0;

-- ============================================================================
-- SECTION 22: getUserJobHistory / getRecentJobs / getDashboardStats
-- ============================================================================

-- TEST 22.1: getUserJobHistory
-- Source: getUserJobHistory() method
-- EXPECT: 1 row (our test job)
SELECT job_id, source_filename, file_type, status, created_at, finished_at,
    total_rows, parsed_rows, valid_rows, problem_rows,
    dupe_rows AS duplicate_rows, skipped_rows, imported_rows, updated_rows, error_message
FROM import_v3_jobs
WHERE userid = @test_userid
ORDER BY created_at DESC
LIMIT 25;

-- TEST 22.2: getRecentJobs with LEFT JOIN taousers
-- Source: getRecentJobs() method
-- EXPECT: Query runs (test job appears with NULL user details since userid 999999 likely absent from taousers)
SELECT j.job_id, j.userid, u.userfirst, u.userlast, u.useremail,
    j.source_filename, j.file_type, j.status, j.created_at, j.finished_at,
    j.total_rows, j.imported_rows, j.updated_rows, j.problem_rows, j.dupe_rows, j.error_message
FROM import_v3_jobs j
LEFT JOIN taousers u ON j.userid = u.userid
WHERE j.job_id = @test_job_id
ORDER BY j.created_at DESC
LIMIT 50;

-- TEST 22.3: getDashboardStats - Today counts with CURDATE()
-- Source: getDashboardStats() method
-- EXPECT: Query runs, returns aggregate data
SELECT
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_today,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_today,
    COUNT(*) AS total_today
FROM import_v3_jobs
WHERE DATE(created_at) = CURDATE();

-- TEST 22.4: getDashboardStats - 7-day averages with DATE_SUB
-- Source: getDashboardStats() method
SELECT
    COALESCE(AVG(total_rows), 0) AS avg_rows_per_job,
    COALESCE(AVG(imported_rows + updated_rows), 0) AS avg_processed_per_job,
    COUNT(*) AS jobs_last_7_days,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_last_7_days,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_last_7_days
FROM import_v3_jobs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- TEST 22.5: getDashboardStats - Active jobs count
SELECT COUNT(*) AS active_jobs
FROM import_v3_jobs
WHERE status NOT IN ('completed', 'failed', 'cancelled');

-- TEST 22.6: getDashboardStats - Unique users in last 7 days
SELECT COUNT(DISTINCT userid) AS unique_users
FROM import_v3_jobs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- ============================================================================
-- SECTION 23: cleanupOldJobs (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 23.1: Find eligible jobs for cleanup
-- Source: cleanupOldJobs() eligible jobs query
-- EXPECT: Query runs (our test job has status=reviewing so will NOT match)
SELECT job_id, userid, stored_file_path, status, created_at, finished_at
FROM import_v3_jobs
WHERE status IN ('completed', 'failed')
  AND finished_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
LIMIT 1000;

-- TEST 23.2: Dry-run count queries
-- Source: cleanupOldJobs() dry_run=true branch
-- These use parameterized IN lists - testing syntax with literal values
SELECT COUNT(*) AS event_count FROM import_v3_events WHERE job_id IN (@test_job_id);
SELECT COUNT(*) AS row_count FROM import_v3_rows WHERE job_id IN (@test_job_id);
SELECT COUNT(*) AS col_count FROM import_v3_columns WHERE job_id IN (@test_job_id);

-- TEST 23.3: Row-based cascade counts
-- Source: cleanupOldJobs() counts facts and row_results by row_id list
SELECT COUNT(*) AS fact_count FROM import_v3_facts
WHERE row_id IN (SELECT row_id FROM import_v3_rows WHERE job_id = @test_job_id);

SELECT COUNT(*) AS result_count FROM import_v3_row_results
WHERE row_id IN (SELECT row_id FROM import_v3_rows WHERE job_id = @test_job_id);

-- TEST 23.4: DELETE order syntax check (WHERE 1=0 - no data touched)
-- Source: cleanupOldJobs() transaction block
-- FK dependency order: events -> facts -> row_results -> rows -> columns -> jobs
DELETE FROM import_v3_events WHERE job_id IN (0) AND 1=0;
DELETE FROM import_v3_facts WHERE row_id IN (0) AND 1=0;
DELETE FROM import_v3_row_results WHERE row_id IN (0) AND 1=0;
DELETE FROM import_v3_rows WHERE job_id IN (0) AND 1=0;
DELETE FROM import_v3_columns WHERE job_id IN (0) AND 1=0;
DELETE FROM import_v3_jobs WHERE job_id IN (0) AND 1=0;

-- ============================================================================
-- SECTION 24: Feature Flag Queries (ContactImportV3Service.cfc)
-- ============================================================================

-- TEST 24.1: getAllowedUsers with LEFT JOIN taousers
-- Source: getAllowedUsers() method
-- EXPECT: Query runs (may return 0 rows if no users in allowlist)
SELECT ffu.userid, ffu.is_enabled, ffu.created_at, ffu.notes,
       u.userfirst, u.userlast, u.useremail
FROM feature_flag_users ffu
LEFT JOIN taousers u ON ffu.userid = u.userid
WHERE ffu.flag_key = 'import_v3_enabled'
ORDER BY ffu.created_at DESC;

-- TEST 24.2: addAllowedUser - verify user exists check
-- Source: addAllowedUser() user existence check
SELECT userid FROM taousers WHERE userid = @test_userid;

-- TEST 24.3: addAllowedUser INSERT...ON DUPLICATE KEY UPDATE (WHERE 1=0)
-- Source: addAllowedUser() method
INSERT INTO feature_flag_users (flag_key, userid, is_enabled, notes, created_at)
SELECT 'import_v3_enabled', @test_userid, 1, 'test', NOW()
FROM DUAL WHERE 1=0
ON DUPLICATE KEY UPDATE is_enabled = 1, notes = 'test', updated_at = NOW();

-- TEST 24.4: removeAllowedUser DELETE (WHERE 1=0)
-- Source: removeAllowedUser() method
DELETE FROM feature_flag_users
WHERE flag_key = 'import_v3_enabled' AND userid = @test_userid AND 1=0;

-- TEST 24.5: setFeatureFlag UPDATE (WHERE 1=0)
-- Source: setFeatureFlag() method
UPDATE feature_flags SET is_enabled = 1, updated_at = NOW()
WHERE flag_key = 'import_v3_enabled' AND 1=0;

-- ============================================================================
-- SECTION 25: Data Integrity and Consistency Checks
-- ============================================================================

-- TEST 25.1: No orphan rows (all rows reference valid jobs)
-- EXPECT: orphan_count = 0
SELECT 'orphan_rows' AS check_name,
    (SELECT COUNT(*) FROM import_v3_rows r
     WHERE NOT EXISTS (SELECT 1 FROM import_v3_jobs j WHERE j.job_id = r.job_id)) AS orphan_count;

-- TEST 25.2: No orphan facts (all facts reference valid rows)
-- EXPECT: orphan_count = 0
SELECT 'orphan_facts' AS check_name,
    (SELECT COUNT(*) FROM import_v3_facts f
     WHERE NOT EXISTS (SELECT 1 FROM import_v3_rows r WHERE r.row_id = f.row_id)) AS orphan_count;

-- TEST 25.3: No orphan events (all events reference valid jobs)
-- EXPECT: orphan_count = 0
SELECT 'orphan_events' AS check_name,
    (SELECT COUNT(*) FROM import_v3_events e
     WHERE NOT EXISTS (SELECT 1 FROM import_v3_jobs j WHERE j.job_id = e.job_id)) AS orphan_count;

-- TEST 25.4: No orphan row_results (all results reference valid rows)
-- EXPECT: orphan_count = 0
SELECT 'orphan_row_results' AS check_name,
    (SELECT COUNT(*) FROM import_v3_row_results rr
     WHERE NOT EXISTS (SELECT 1 FROM import_v3_rows r WHERE r.row_id = rr.row_id)) AS orphan_count;

-- TEST 25.5: All job statuses are valid values
-- EXPECT: invalid_count = 0
SELECT 'invalid_job_status' AS check_name,
    (SELECT COUNT(*) FROM import_v3_jobs
     WHERE status NOT IN ('created','uploaded','parsing','parsed','mapping','reviewing','finalizing','completed','failed','cancelled')) AS invalid_count;

-- TEST 25.6: All row statuses are valid values
-- EXPECT: invalid_count = 0
SELECT 'invalid_row_status' AS check_name,
    (SELECT COUNT(*) FROM import_v3_rows
     WHERE status NOT IN ('pending','ready','problem','dupe','ignored','imported','updated','failed')) AS invalid_count;

-- TEST 25.7: Fact counts match row error_count
-- EXPECT: mismatched = 0 (or shows rows that need recompute)
SELECT 'fact_error_count_mismatch' AS check_name,
    COUNT(*) AS mismatched
FROM import_v3_rows r
WHERE r.job_id = @test_job_id
  AND r.error_count != (
      SELECT COUNT(*) FROM import_v3_facts f WHERE f.row_id = r.row_id AND f.is_valid = 0
  );

-- ============================================================================
-- SECTION 26: EXPLAIN Plan Checks (Performance Validation)
-- ============================================================================
-- These verify that frequent queries use indexes effectively.
-- Look for type=ref or type=range (good) vs type=ALL (table scan, bad).
-- ============================================================================

-- TEST 26.1: EXPLAIN getJobForUser
EXPLAIN SELECT * FROM import_v3_jobs WHERE job_id = @test_job_id AND userid = @test_userid;

-- TEST 26.2: EXPLAIN duplicate file check
EXPLAIN SELECT * FROM import_v3_jobs WHERE userid = @test_userid AND file_hash = 'abc123';

-- TEST 26.3: EXPLAIN getJobStats
EXPLAIN SELECT status, COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id GROUP BY status;

-- TEST 26.4: EXPLAIN paginated rows
EXPLAIN SELECT * FROM import_v3_rows WHERE job_id = @test_job_id ORDER BY row_num LIMIT 50 OFFSET 0;

-- TEST 26.5: EXPLAIN batch fact load
EXPLAIN SELECT * FROM import_v3_facts WHERE row_id IN (@test_row1_id, @test_row2_id);

-- TEST 26.6: EXPLAIN search subquery
EXPLAIN SELECT DISTINCT f.row_id FROM import_v3_facts f
WHERE f.row_id IN (SELECT r2.row_id FROM import_v3_rows r2 WHERE r2.job_id = @test_job_id)
  AND f.field_name IN ('first_name','last_name','contactFullName','email_business')
  AND f.normalized_value LIKE '%John%';

-- TEST 26.7: EXPLAIN cleanupOldJobs eligible query
EXPLAIN SELECT * FROM import_v3_jobs WHERE status IN ('completed','failed') AND finished_at < DATE_SUB(NOW(), INTERVAL 30 DAY) LIMIT 1000;

-- TEST 26.8: EXPLAIN getAllowedUsers
EXPLAIN SELECT ffu.*, u.userfirst, u.userlast FROM feature_flag_users ffu LEFT JOIN taousers u ON ffu.userid = u.userid WHERE ffu.flag_key = 'import_v3_enabled';

-- ============================================================================
-- SECTION 99: ROLLBACK AND SUMMARY
-- ============================================================================
-- All test data created in Section 3 is rolled back here.
-- No permanent changes to the database.
-- ============================================================================

-- Final count verification before rollback
SELECT 'PRE-ROLLBACK COUNTS' AS section,
    (SELECT COUNT(*) FROM import_v3_jobs WHERE job_id = @test_job_id) AS jobs,
    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = @test_job_id) AS columns_count,
    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = @test_job_id) AS rows_count,
    (SELECT COUNT(*) FROM import_v3_facts WHERE row_id BETWEEN @test_row1_id AND @test_row5_id) AS facts,
    (SELECT COUNT(*) FROM import_v3_events WHERE job_id = @test_job_id) AS events;

ROLLBACK;

-- Post-rollback verification: test data should be gone
SELECT 'POST-ROLLBACK VERIFICATION' AS section,
    (SELECT COUNT(*) FROM import_v3_jobs WHERE userid = 999999) AS test_jobs_remaining,
    (SELECT COUNT(*) FROM import_v3_events WHERE job_id = @test_job_id) AS test_events_remaining;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- If you reached this point without errors, all SQL query patterns used by the
-- Contact Import V3 workflow are syntactically valid and structurally sound.
--
-- Check for:
--   1. Any table_exists = 0 in Section 1 (missing tables)
--   2. Any col_count lower than expected in Section 1 (missing columns)
--   3. Any index_count = 0 in Section 2 (missing indexes)
--   4. Any orphan_count > 0 in Section 25 (referential integrity issues)
--   5. Any invalid_count > 0 in Section 25 (bad status values)
--   6. type=ALL in Section 26 EXPLAIN output (missing index, potential perf issue)
--   7. POST-ROLLBACK test_jobs_remaining should be 0 (rollback worked)
-- ============================================================================
SELECT 'ALL TESTS COMPLETE' AS result;

