-- ============================================================================
-- 2026-06-18_sched_performance_indexes.sql
-- ----------------------------------------------------------------------------
-- Supporting indexes for the nightly sched/events_completed.cfm job and the
-- notification engine. MySQL / InnoDB.
--
-- Context: events_completed.cfm timed out in prod (37 cfoutput + 33 cfhttp
-- timeouts). The dominant cost is a latency-bound backlog of JOB C events, now
-- bounded by ?batchSize and an anti-overlap lock in the .cfm. These indexes
-- remove the residual table scans on the hot predicates so each bounded batch
-- finishes well inside the request timeout.
--
-- IMPORTANT: events / funotifications / fusystemusers are VIEWS. You cannot
-- index a view -- the indexes go on the underlying BASE tables, which follow
-- the TAO "_tbl" convention: events_tbl, funotifications_tbl, fusystemusers_tbl.
-- The views inherit the indexes automatically since they read straight through.
--
-- SAFETY:
--   * Idempotent: each index is created only if missing (checked via
--     information_schema), so this script can be re-run without error.
--   * Targets DATABASE() -- run it while connected to the schema you want
--     (new_development for dev / abod, actorsbusinessoffice for prod / abo).
--   * ADD INDEX on InnoDB is online (no full table rebuild / no long lock) on
--     MySQL 5.6+. Tables here are small (events_tbl ~5.3k, funotifications_tbl
--     ~34k), so impact is negligible -- but still run off-peak per house rule.
--   * DO NOT auto-run as part of a deploy. Apply deliberately and verify with
--     SHOW INDEX afterward.
-- Rollback: 2026-06-18_sched_performance_indexes_rollback.sql
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) funotifications_tbl (notstatus, notstartdate)
--    JOB A flips 'Future' -> 'Active' WHERE notstartdate < today AND
--    notstatus = 'Future'. The notification engine also reads on
--    (notstatus, notstartdate <= NOW()). Composite covers both.
--    (Base table behind the funotifications view.)
-- ---------------------------------------------------------------------------
SET @exists := (
  SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'funotifications_tbl'
    AND index_name   = 'idx_funotif_status_startdate'
);
SET @sql := IF(@exists = 0,
  'ALTER TABLE funotifications_tbl ADD INDEX idx_funotif_status_startdate (notstatus, notstartdate)',
  'SELECT ''idx_funotif_status_startdate already exists'' AS note');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
-- 2) events_tbl (eventstatus, eventstop)
--    JOB C driver: WHERE e.eventstatus = 'Active' AND e.eventstop < CURDATE()
--    ORDER BY e.eventstop. Composite serves both the filter and the sort.
--    (Base table behind the events view.)
-- ---------------------------------------------------------------------------
SET @exists := (
  SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'events_tbl'
    AND index_name   = 'idx_events_status_stop'
);
SET @sql := IF(@exists = 0,
  'ALTER TABLE events_tbl ADD INDEX idx_events_status_stop (eventstatus, eventstop)',
  'SELECT ''idx_events_status_stop already exists'' AS note');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
-- 3) fusystemusers_tbl (userid, suStatus)
--    allEnrollments preload: WHERE su.suStatus = 'Active'
--    AND su.userid IN (<batch userids>). userid is the selective leading col.
--    (Base table behind the fusystemusers view.)
-- ---------------------------------------------------------------------------
SET @exists := (
  SELECT COUNT(1) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 'fusystemusers_tbl'
    AND index_name   = 'idx_fusu_user_status'
);
SET @sql := IF(@exists = 0,
  'ALTER TABLE fusystemusers_tbl ADD INDEX idx_fusu_user_status (userid, suStatus)',
  'SELECT ''idx_fusu_user_status already exists'' AS note');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Verify:
--   SHOW INDEX FROM funotifications_tbl WHERE Key_name = 'idx_funotif_status_startdate';
--   SHOW INDEX FROM events_tbl          WHERE Key_name = 'idx_events_status_stop';
--   SHOW INDEX FROM fusystemusers_tbl   WHERE Key_name = 'idx_fusu_user_status';
--
-- Optional (evaluate with EXPLAIN if JOB C is still latency-bound after a run):
--   eventcontactsxref_tbl (contactid), contactdetails_tbl (contactmeetingdate),
--   actionusers_tbl (userid, actionid). Most are already covered by PK/FK keys;
--   add only if EXPLAIN shows a scan.
