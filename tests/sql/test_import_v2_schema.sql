-- ============================================================
-- Contact Import V2 - Schema Verification Tests
-- Run against: abod (test) or abo (production)
--
-- Usage: Execute this script after running the migration.
--        Each test outputs PASS or FAIL with details.
-- ============================================================

SET @test_count = 0;
SET @pass_count = 0;
SET @fail_count = 0;

SELECT '========================================' AS '';
SELECT 'Contact Import V2 Schema Tests' AS '';
SELECT '========================================' AS '';
SELECT NOW() AS 'Test Run Time';
SELECT '' AS '';

-- ============================================================
-- TEST 1: Verify import_jobs table exists with correct columns
-- ============================================================
SET @test_count = @test_count + 1;
SELECT 'TEST 1: import_jobs table structure' AS '';

SELECT
    CASE
        WHEN COUNT(*) = 16 THEN 'PASS'
        ELSE CONCAT('FAIL - Expected 16 columns, found ', COUNT(*))
    END AS result,
    @pass_count := @pass_count + (COUNT(*) = 16),
    @fail_count := @fail_count + (COUNT(*) != 16)
FROM information_schema.columns
WHERE table_schema = DATABASE()
AND table_name = 'import_jobs';

-- Verify critical columns exist
SELECT
    CASE
        WHEN COUNT(*) = 6 THEN 'PASS - All critical columns exist'
        ELSE CONCAT('FAIL - Missing critical columns. Found ', COUNT(*), ' of 6')
    END AS critical_columns_check
FROM information_schema.columns
WHERE table_schema = DATABASE()
AND table_name = 'import_jobs'
AND column_name IN ('job_id', 'userid', 'status', 'total_rows', 'valid_rows', 'imported_rows');


-- ============================================================
-- TEST 2: Verify import_job_columns table exists
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 2: import_job_columns table structure' AS '';

SELECT
    CASE
        WHEN COUNT(*) >= 7 THEN 'PASS'
        ELSE CONCAT('FAIL - Expected at least 7 columns, found ', COUNT(*))
    END AS result
FROM information_schema.columns
WHERE table_schema = DATABASE()
AND table_name = 'import_job_columns';


-- ============================================================
-- TEST 3: Verify import_job_rows table exists
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 3: import_job_rows table structure' AS '';

SELECT
    CASE
        WHEN COUNT(*) >= 14 THEN 'PASS'
        ELSE CONCAT('FAIL - Expected at least 14 columns, found ', COUNT(*))
    END AS result
FROM information_schema.columns
WHERE table_schema = DATABASE()
AND table_name = 'import_job_rows';

-- Verify JSON columns exist
SELECT
    CASE
        WHEN COUNT(*) = 4 THEN 'PASS - All JSON columns exist'
        ELSE CONCAT('FAIL - Missing JSON columns. Found ', COUNT(*), ' of 4')
    END AS json_columns_check
FROM information_schema.columns
WHERE table_schema = DATABASE()
AND table_name = 'import_job_rows'
AND column_name IN ('raw_json', 'normalized_json', 'validation_json', 'dupe_json');


-- ============================================================
-- TEST 4: Verify import_job_events table exists
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 4: import_job_events table structure' AS '';

SELECT
    CASE
        WHEN COUNT(*) >= 5 THEN 'PASS'
        ELSE CONCAT('FAIL - Expected at least 5 columns, found ', COUNT(*))
    END AS result
FROM information_schema.columns
WHERE table_schema = DATABASE()
AND table_name = 'import_job_events';


-- ============================================================
-- TEST 5: Verify import_field_mappings table exists and has seed data
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 5: import_field_mappings table and seed data' AS '';

SELECT
    CASE
        WHEN COUNT(*) >= 20 THEN CONCAT('PASS - ', COUNT(*), ' field mappings found')
        ELSE CONCAT('FAIL - Expected at least 20 mappings, found ', COUNT(*))
    END AS result
FROM import_field_mappings;

-- Verify required fields exist
SELECT
    CASE
        WHEN COUNT(*) = 5 THEN 'PASS - All required core fields exist'
        ELSE CONCAT('FAIL - Missing core fields. Found ', COUNT(*), ' of 5')
    END AS core_fields_check
FROM import_field_mappings
WHERE canonical_field IN ('firstName', 'lastName', 'email_business', 'phone_work', 'company');


-- ============================================================
-- TEST 6: Verify import_field_aliases table exists and has seed data
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 6: import_field_aliases table and seed data' AS '';

SELECT
    CASE
        WHEN COUNT(*) >= 50 THEN CONCAT('PASS - ', COUNT(*), ' aliases found')
        ELSE CONCAT('FAIL - Expected at least 50 aliases, found ', COUNT(*))
    END AS result
FROM import_field_aliases;


-- ============================================================
-- TEST 7: Verify foreign key constraints
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 7: Foreign key constraints' AS '';

SELECT
    CASE
        WHEN COUNT(*) >= 4 THEN CONCAT('PASS - ', COUNT(*), ' foreign keys found')
        ELSE CONCAT('FAIL - Expected at least 4 foreign keys, found ', COUNT(*))
    END AS result
FROM information_schema.table_constraints
WHERE table_schema = DATABASE()
AND constraint_type = 'FOREIGN KEY'
AND table_name LIKE 'import_%';


-- ============================================================
-- TEST 8: Verify indexes exist
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 8: Index verification' AS '';

SELECT
    CASE
        WHEN COUNT(*) >= 10 THEN CONCAT('PASS - ', COUNT(*), ' indexes found')
        ELSE CONCAT('FAIL - Expected at least 10 indexes, found ', COUNT(*))
    END AS result
FROM information_schema.statistics
WHERE table_schema = DATABASE()
AND table_name LIKE 'import_%'
AND index_name != 'PRIMARY';


-- ============================================================
-- TEST 9: Verify stored procedure exists
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 9: Stored procedure sp_update_import_job_counts' AS '';

SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS - Stored procedure exists'
        ELSE 'FAIL - Stored procedure not found'
    END AS result
FROM information_schema.routines
WHERE routine_schema = DATABASE()
AND routine_name = 'sp_update_import_job_counts'
AND routine_type = 'PROCEDURE';


-- ============================================================
-- TEST 10: Verify view exists
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 10: View v_import_jobs_summary' AS '';

SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS - View exists'
        ELSE 'FAIL - View not found'
    END AS result
FROM information_schema.views
WHERE table_schema = DATABASE()
AND table_name = 'v_import_jobs_summary';


-- ============================================================
-- TEST 11: Verify table engines are InnoDB
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 11: Table engines (should be InnoDB)' AS '';

SELECT
    CASE
        WHEN SUM(CASE WHEN engine != 'InnoDB' THEN 1 ELSE 0 END) = 0 THEN 'PASS - All tables use InnoDB'
        ELSE CONCAT('FAIL - ', SUM(CASE WHEN engine != 'InnoDB' THEN 1 ELSE 0 END), ' tables not using InnoDB')
    END AS result
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name LIKE 'import_%'
AND table_type = 'BASE TABLE';


-- ============================================================
-- TEST 12: Verify charset/collation
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 12: Charset and collation (should be utf8mb4)' AS '';

SELECT
    CASE
        WHEN SUM(CASE WHEN table_collation NOT LIKE 'utf8mb4%' THEN 1 ELSE 0 END) = 0 THEN 'PASS - All tables use utf8mb4'
        ELSE CONCAT('FAIL - ', SUM(CASE WHEN table_collation NOT LIKE 'utf8mb4%' THEN 1 ELSE 0 END), ' tables not using utf8mb4')
    END AS result
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name LIKE 'import_%'
AND table_type = 'BASE TABLE';


-- ============================================================
-- TEST 13: Verify unique constraints
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 13: Unique constraints' AS '';

SELECT
    CASE
        WHEN COUNT(*) >= 3 THEN CONCAT('PASS - ', COUNT(*), ' unique constraints found')
        ELSE CONCAT('FAIL - Expected at least 3 unique constraints, found ', COUNT(*))
    END AS result
FROM information_schema.table_constraints
WHERE table_schema = DATABASE()
AND constraint_type = 'UNIQUE'
AND table_name LIKE 'import_%';


-- ============================================================
-- TEST 14: Functional test - Can insert and delete a test job
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 14: Functional test - Insert/Delete job' AS '';

-- Get a valid userid for testing
SET @test_userid = (SELECT userid FROM taousers LIMIT 1);

-- Only run if we have a test user
SET @functional_result = 'SKIP - No test user found';

-- Insert test job
INSERT INTO import_jobs (userid, source_filename, file_type, status)
SELECT @test_userid, '__test_migration__.csv', 'csv', 'pending'
WHERE @test_userid IS NOT NULL;

SET @test_job_id = LAST_INSERT_ID();

-- Verify insert
SET @functional_result = (
    SELECT CASE
        WHEN COUNT(*) = 1 THEN 'INSERT OK'
        ELSE 'INSERT FAIL'
    END
    FROM import_jobs
    WHERE job_id = @test_job_id
);

-- Insert test column
INSERT INTO import_job_columns (job_id, source_column_index, source_column_name)
VALUES (@test_job_id, 0, 'Test Column');

-- Insert test row
INSERT INTO import_job_rows (job_id, row_num, raw_json, status)
VALUES (@test_job_id, 1, '{"test": "data"}', 'pending');

-- Insert test event
INSERT INTO import_job_events (job_id, event_type)
VALUES (@test_job_id, 'test');

-- Verify cascade delete
DELETE FROM import_jobs WHERE job_id = @test_job_id;

SET @cascade_check = (
    SELECT CASE
        WHEN COUNT(*) = 0 THEN 'CASCADE OK'
        ELSE 'CASCADE FAIL'
    END
    FROM import_job_rows
    WHERE job_id = @test_job_id
);

SELECT CONCAT(
    CASE
        WHEN @functional_result = 'INSERT OK' AND @cascade_check = 'CASCADE OK'
        THEN 'PASS - Insert and cascade delete working'
        ELSE CONCAT('FAIL - ', @functional_result, ', ', @cascade_check)
    END
) AS result;


-- ============================================================
-- TEST 15: Verify status enum values work
-- ============================================================
SET @test_count = @test_count + 1;
SELECT '' AS '';
SELECT 'TEST 15: Status column accepts expected values' AS '';

SELECT
    CASE
        WHEN column_type LIKE '%varchar%'
        THEN 'PASS - Status column is VARCHAR (flexible enum)'
        ELSE CONCAT('INFO - Status column type: ', column_type)
    END AS result
FROM information_schema.columns
WHERE table_schema = DATABASE()
AND table_name = 'import_jobs'
AND column_name = 'status';


-- ============================================================
-- SUMMARY
-- ============================================================
SELECT '' AS '';
SELECT '========================================' AS '';
SELECT 'TEST SUMMARY' AS '';
SELECT '========================================' AS '';
SELECT CONCAT('Total Tests: ', @test_count) AS '';
SELECT CONCAT('Tests executed successfully') AS '';
SELECT '' AS '';

-- List all tables created
SELECT 'Tables created:' AS '';
SELECT table_name, engine, table_collation, table_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_name LIKE 'import_%'
ORDER BY table_name;

SELECT '' AS '';
SELECT 'Views created:' AS '';
SELECT table_name
FROM information_schema.views
WHERE table_schema = DATABASE()
AND table_name LIKE '%import%';

SELECT '' AS '';
SELECT 'Stored procedures created:' AS '';
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = DATABASE()
AND routine_name LIKE '%import%';

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT 'Schema verification complete' AS '';
SELECT '========================================' AS '';
