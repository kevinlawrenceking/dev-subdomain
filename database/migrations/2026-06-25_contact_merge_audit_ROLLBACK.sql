-- =============================================================================
-- ROLLBACK for 2026-06-25_contact_merge_audit.sql
-- Drops the merge audit tables. Any merge history they hold is lost.
-- =============================================================================

DROP TABLE IF EXISTS contact_merge_map;
DROP TABLE IF EXISTS contact_merge_log;
