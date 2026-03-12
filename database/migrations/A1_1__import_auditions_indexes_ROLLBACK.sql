-- =============================================================================
-- A1_1__import_auditions_indexes_ROLLBACK.sql
-- Rollback: Drop audition import performance indexes
-- =============================================================================

DROP INDEX IF EXISTS idx_auditions_userid_status ON auditions;
DROP INDEX IF EXISTS idx_auditions_userid_date ON auditions;
DROP INDEX IF EXISTS idx_auditions_userid_project ON auditions;
DROP INDEX IF EXISTS idx_auditions_dupe_detect ON auditions;
DROP INDEX IF EXISTS idx_auditions_contactid ON auditions;
