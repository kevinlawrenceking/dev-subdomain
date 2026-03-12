-- =============================================================================
-- A1_0__import_auditions_tables_ROLLBACK.sql
-- Rollback: Drop all audition import staging tables
-- =============================================================================

DROP TABLE IF EXISTS import_auditions_events;
DROP TABLE IF EXISTS import_auditions_row_results;
DROP TABLE IF EXISTS import_auditions_facts;
DROP TABLE IF EXISTS import_auditions_rows;
DROP TABLE IF EXISTS import_auditions_columns;
DROP TABLE IF EXISTS import_auditions_jobs;
