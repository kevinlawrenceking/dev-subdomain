-- ============================================================================
-- 2026-06-19_admin_analytics_pgpages_ROLLBACK.sql
-- Reverses 2026-06-19_admin_analytics_pgpages.sql. Run on the same schema.
-- ============================================================================
START TRANSACTION;
SET @pgID := (SELECT pgID FROM pgpages_tbl WHERE pgDir = 'admin-analytics' LIMIT 1);
DELETE FROM pgpagespluginsxref WHERE pgid = @pgID;
DELETE FROM pgpages_tbl  WHERE pgDir  = 'admin-analytics';
DELETE FROM pgcomps_tbl  WHERE compDir = 'admin-analytics';
COMMIT;
