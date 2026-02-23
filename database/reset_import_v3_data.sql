-- ============================================================
-- Reset all Import V3 test data
-- Purpose: Wipe all jobs, rows, facts, columns, events, and
--          row_results so CSV test files can be re-imported
--          (clears file_hash uniqueness constraint).
-- Safe: Only touches import_v3_* tables. No schema changes.
-- ============================================================

-- Child tables first, then parent
DELETE FROM import_v3_row_results;
DELETE FROM import_v3_facts;
DELETE FROM import_v3_rows;
DELETE FROM import_v3_columns;
DELETE FROM import_v3_events;
DELETE FROM import_v3_jobs;

-- Verify all empty
SELECT 'import_v3_jobs' AS tbl, COUNT(*) AS remaining FROM import_v3_jobs
UNION ALL
SELECT 'import_v3_columns', COUNT(*) FROM import_v3_columns
UNION ALL
SELECT 'import_v3_rows', COUNT(*) FROM import_v3_rows
UNION ALL
SELECT 'import_v3_facts', COUNT(*) FROM import_v3_facts
UNION ALL
SELECT 'import_v3_events', COUNT(*) FROM import_v3_events
UNION ALL
SELECT 'import_v3_row_results', COUNT(*) FROM import_v3_row_results;
