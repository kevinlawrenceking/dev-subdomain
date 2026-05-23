-- =============================================================================
-- ROLLBACK: 2026-05-17_audit_retention_errors_tbl.sql
-- Drops the helper procedure. Idempotent.
--
-- *** THIS DOES NOT RESTORE DELETED ROWS. ***
-- Data restore = `mysql ... < archive/errors_tbl_pre_id_watermark_*.sql`.
-- =============================================================================

DROP PROCEDURE IF EXISTS prune_errors_tbl;

SELECT 'errors_tbl retention procedure dropped' AS result;
