-- =============================================================================
-- ROLLBACK: 2026-05-16_events_completed_perf_indexes.sql
--
-- Drops the three indexes added for sched/events_completed.cfm.
-- Idempotent: safe to run if an index is already absent.
-- =============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS DropIndexIfExists //

CREATE PROCEDURE DropIndexIfExists(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64)
)
BEGIN
    DECLARE v_index_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO v_index_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_table_name
      AND INDEX_NAME = p_index_name;

    IF v_index_exists > 0 THEN
        SET @sql = CONCAT('DROP INDEX `', p_index_name, '` ON `', p_table_name, '`');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('DROPPED: ', p_index_name, ' on ', p_table_name) AS result;
    ELSE
        SELECT CONCAT('NOT FOUND: ', p_index_name, ' on ', p_table_name, ' - skipped') AS result;
    END IF;
END //

DELIMITER ;

CALL DropIndexIfExists('funotifications_tbl', 'idx_funot_status_startdate');
CALL DropIndexIfExists('events_tbl', 'idx_ev_status_stop');
-- CORRECTION (2026-05-17): base table is eventcontactsxref_tbl, not the view.
CALL DropIndexIfExists('eventcontactsxref_tbl', 'idx_ecx_contact_event');

DROP PROCEDURE IF EXISTS DropIndexIfExists;

SELECT 'events_completed perf index rollback complete' AS status;
