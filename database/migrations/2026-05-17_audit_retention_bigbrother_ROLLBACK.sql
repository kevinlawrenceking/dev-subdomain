-- =============================================================================
-- ROLLBACK: 2026-05-17_audit_retention_bigbrother.sql
-- Drops the two helper procedures. Idempotent.
--
-- *** THIS DOES NOT RESTORE DELETED ROWS. ***
-- If purges were run, data restore is a DBA operation against the mysqldump
-- archive (off-box). See the retention policy doc, section 4.
-- =============================================================================

DROP PROCEDURE IF EXISTS prune_bigbrother_pre_cliff;
DROP PROCEDURE IF EXISTS prune_bigbrother_rolling;

SELECT 'bigbrother retention procedures dropped' AS result;
