-- ============================================================================
-- 2026-06-18_sched_performance_indexes_rollback.sql
-- ----------------------------------------------------------------------------
-- Reverses 2026-06-18_sched_performance_indexes.sql. Drops each index only if
-- present, so it is safe to re-run. Targets DATABASE() -- connect to the schema
-- you applied the indexes to (new_development / actorsbusinessoffice).
--
-- NOTE: indexes live on the BASE tables (events_tbl / funotifications_tbl /
-- fusystemusers_tbl), not the same-named views, so the DROPs target "_tbl".
-- ============================================================================

SET @exists := (
  SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'funotifications_tbl'
    AND index_name   = 'idx_funotif_status_startdate'
);
SET @sql := IF(@exists > 0,
  'ALTER TABLE funotifications_tbl DROP INDEX idx_funotif_status_startdate',
  'SELECT ''idx_funotif_status_startdate not present'' AS note');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exists := (
  SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'events_tbl'
    AND index_name   = 'idx_events_status_stop'
);
SET @sql := IF(@exists > 0,
  'ALTER TABLE events_tbl DROP INDEX idx_events_status_stop',
  'SELECT ''idx_events_status_stop not present'' AS note');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exists := (
  SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'fusystemusers_tbl'
    AND index_name   = 'idx_fusu_user_status'
);
SET @sql := IF(@exists > 0,
  'ALTER TABLE fusystemusers_tbl DROP INDEX idx_fusu_user_status',
  'SELECT ''idx_fusu_user_status not present'' AS note');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
