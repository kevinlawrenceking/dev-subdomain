-- ============================================================================
-- 2026-06-19_admin_analytics_indexes_ROLLBACK.sql
-- Reverses 2026-06-19_admin_analytics_indexes.sql (drops only indexes it created).
-- Idempotent: drops only if present.
-- ============================================================================

SET @exists := (SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'audprojects'
    AND index_name = 'idx_audproj_deleted_projdate');
SET @sql := IF(@exists = 1,
  'ALTER TABLE audprojects DROP INDEX idx_audproj_deleted_projdate',
  'SELECT ''idx_audproj_deleted_projdate absent'' AS note');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @exists := (SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'audroles'
    AND index_name = 'idx_audrole_proj_deleted');
SET @sql := IF(@exists = 1,
  'ALTER TABLE audroles DROP INDEX idx_audrole_proj_deleted',
  'SELECT ''idx_audrole_proj_deleted absent'' AS note');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @exists := (SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'funotifications_tbl'
    AND index_name = 'idx_funotif_status_enddate');
SET @sql := IF(@exists = 1,
  'ALTER TABLE funotifications_tbl DROP INDEX idx_funotif_status_enddate',
  'SELECT ''idx_funotif_status_enddate absent'' AS note');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @exists := (SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'contactdetails_tbl'
    AND index_name = 'idx_cd_created');
SET @sql := IF(@exists = 1,
  'ALTER TABLE contactdetails_tbl DROP INDEX idx_cd_created',
  'SELECT ''idx_cd_created absent'' AS note');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;
