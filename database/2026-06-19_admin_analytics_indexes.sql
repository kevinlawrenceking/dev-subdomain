-- ============================================================================
-- 2026-06-19_admin_analytics_indexes.sql
-- TAO-ADMIN-ANALYTICS-01 -- CONDITIONAL indexes for the analytics series queries.
-- Apply ONLY where 2026-06-19_admin_analytics_explain.sql shows a costly type=ALL.
-- Tables are small (events_tbl ~5.3k, funotifications_tbl ~34k); scans may be fine.
-- Indexes go on BASE tables; audprojects/audroles are base tables (no _tbl).
-- Idempotent: each created only if missing. InnoDB online add (run off-peak).
-- Rollback: 2026-06-19_admin_analytics_indexes_ROLLBACK.sql
-- ============================================================================

-- audprojects (isDeleted, projdate) -- range on projdate after equality isDeleted
SET @exists := (SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'audprojects'
    AND index_name = 'idx_audproj_deleted_projdate');
SET @sql := IF(@exists = 0,
  'ALTER TABLE audprojects ADD INDEX idx_audproj_deleted_projdate (isDeleted, projdate)',
  'SELECT ''idx_audproj_deleted_projdate already exists'' AS note');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

-- audroles (audprojectID, isdeleted, isbooked) -- join + soft-delete + bookings flag
SET @exists := (SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'audroles'
    AND index_name = 'idx_audrole_proj_deleted');
SET @sql := IF(@exists = 0,
  'ALTER TABLE audroles ADD INDEX idx_audrole_proj_deleted (audprojectID, isdeleted, isbooked)',
  'SELECT ''idx_audrole_proj_deleted already exists'' AS note');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

-- funotifications_tbl (notstatus, notenddate, isdeleted) -- equality then range
SET @exists := (SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'funotifications_tbl'
    AND index_name = 'idx_funotif_status_enddate');
SET @sql := IF(@exists = 0,
  'ALTER TABLE funotifications_tbl ADD INDEX idx_funotif_status_enddate (notstatus, notenddate, isdeleted)',
  'SELECT ''idx_funotif_status_enddate already exists'' AS note');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

-- contactdetails_tbl (IsDeleted, contactCreationDate) -- creation-date range
SET @exists := (SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'contactdetails_tbl'
    AND index_name = 'idx_cd_created');
SET @sql := IF(@exists = 0,
  'ALTER TABLE contactdetails_tbl ADD INDEX idx_cd_created (IsDeleted, contactCreationDate)',
  'SELECT ''idx_cd_created already exists'' AS note');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;
