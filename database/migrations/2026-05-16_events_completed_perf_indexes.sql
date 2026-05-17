-- =============================================================================
-- TAO Performance: events_completed.cfm supporting indexes
--
-- Purpose: sched/events_completed.cfm kept exceeding requesttimeout=600.
--          Its hot queries had NO supporting indexes and scanned tables that
--          grow unbounded. Verified against database/audit/verify-indexes.sql:
--          funotifications_tbl had no notstartdate index; events_tbl had no
--          (eventstatus, eventstop) index; eventcontactsxref was unindexed
--          beyond its PK.
--
-- Queries fixed:
--   JOB A  UPDATE funotifications WHERE notstatus='Future'
--                                   AND notstartdate < <today>
--   JOB C  SELECT events WHERE eventstatus='Active' AND eventstop < CURDATE()
--   JOB D  events JOIN eventcontactsxref WHERE eventstatus='Completed'
--                                          AND eventstop < CURDATE()
--                 GROUP BY contactid
--
-- Index column order: equality predicate first, range/order column second.
-- Targets _tbl base tables (indexes never go on views). Idempotent.
--
-- Rollback: 2026-05-16_events_completed_perf_indexes_ROLLBACK.sql
-- Run on dev first (new_development), then production (actorsbusinessoffice).
-- =============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS AddIndexIfNotExists //

CREATE PROCEDURE AddIndexIfNotExists(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_index_def TEXT
)
BEGIN
    DECLARE v_index_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO v_index_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_table_name
      AND INDEX_NAME = p_index_name;

    IF v_index_exists = 0 THEN
        SET @sql = CONCAT('CREATE INDEX ', p_index_name, ' ON ', p_table_name, ' ', p_index_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('CREATED: ', p_index_name, ' on ', p_table_name) AS result;
    ELSE
        SELECT CONCAT('EXISTS: ', p_index_name, ' on ', p_table_name, ' - skipped') AS result;
    END IF;
END //

DELIMITER ;

-- JOB A: funotifications Future->Active flip.
-- WHERE notstatus = 'Future' (equality) AND notstartdate < today (range).
CALL AddIndexIfNotExists('funotifications_tbl', 'idx_funot_status_startdate', '(notstatus, notstartdate)');

-- JOB C driver + JOB D backfill scan over events.
-- WHERE eventstatus = ? (equality) AND eventstop < CURDATE() (range);
-- also covers the JOB C "ORDER BY eventstop" within a status.
CALL AddIndexIfNotExists('events_tbl', 'idx_ev_status_stop', '(eventstatus, eventstop)');

-- JOB D: eventcontactsxref joined to events on eventid, grouped by contactid.
-- Composite serves both the GROUP BY contactid and the eventid join probe,
-- and leftmost (contactid) serves contactid-only lookups elsewhere.
-- NOTE: eventcontactsxref is a plain xref table (no view/_tbl split).
CALL AddIndexIfNotExists('eventcontactsxref', 'idx_ecx_contact_event', '(contactid, eventid)');

DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

SELECT 'events_completed perf index migration complete' AS status;
