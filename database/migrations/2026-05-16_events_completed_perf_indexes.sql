-- =============================================================================
-- TAO Performance: events_completed.cfm supporting indexes
--
-- Purpose: ensure the indexes that support sched/events_completed.cfm's hot
--          queries exist. IMPORTANT CORRECTION (2026-05-17): a live check of
--          dev (new_development) found ALL THREE indexes below ALREADY PRESENT
--          (idx_funot_status_startdate, idx_ev_status_stop,
--          idx_ecx_contact_event). The earlier "missing indexes" claim came
--          from trusting database/audit/verify-indexes.sql, which is a
--          RECOMMENDATIONS doc, not a live snapshot -- it was wrong for dev.
--
--          This migration is therefore an IDEMPOTENT ENSURE-EXISTS, kept only
--          to close a possible dev->prod schema-drift gap (prod index state
--          was NOT verifiable from the read-only dev MCP connection). On any
--          environment where the indexes already exist it is a safe no-op
--          (AddIndexIfNotExists prints "EXISTS: ... skipped").
--
--          It is NOT the root fix for the timeout. The code changes in
--          sched/events_completed.cfm (kill JOB A SELECT *, per-event
--          isolation, bounded JOB D, backlog cap) stand on their own.
--          Confirm prod's actual index state before assuming this does
--          anything there -- see verification note at end of file.
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
-- Composite serves both the GROUP BY contactid and the eventid join probe.
-- CORRECTION (2026-05-17): `eventcontactsxref` is a VIEW; the base table is
-- `eventcontactsxref_tbl`. Targeting the view name would error
-- ("not BASE TABLE"). Fixed to the base table. On dev this index, and an
-- exact duplicate `idx_eventcontactsxref_contact`, already exist.
CALL AddIndexIfNotExists('eventcontactsxref_tbl', 'idx_ecx_contact_event', '(contactid, eventid)');

DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

SELECT 'events_completed perf index migration complete' AS status;

-- =============================================================================
-- VERIFY PROD INDEX STATE BEFORE ASSUMING THIS MIGRATION DOES ANYTHING.
-- Run this read-only check against actorsbusinessoffice; if all three rows
-- come back, prod already has them and this migration is a no-op there too:
--
--   SELECT TABLE_NAME, INDEX_NAME,
--          GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS cols
--   FROM information_schema.STATISTICS
--   WHERE TABLE_SCHEMA = DATABASE()
--     AND ( (TABLE_NAME='funotifications_tbl' AND INDEX_NAME='idx_funot_status_startdate')
--        OR (TABLE_NAME='events_tbl'          AND INDEX_NAME='idx_ev_status_stop')
--        OR (TABLE_NAME='eventcontactsxref_tbl' AND INDEX_NAME='idx_ecx_contact_event') )
--   GROUP BY TABLE_NAME, INDEX_NAME;
-- =============================================================================
