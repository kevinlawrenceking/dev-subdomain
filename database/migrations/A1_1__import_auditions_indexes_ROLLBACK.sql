-- =============================================================================
-- A1_1__import_auditions_indexes_ROLLBACK.sql
-- Rollback: Drop audition import performance indexes
-- Compatible with MySQL 5.7+ / 8.0.x
-- =============================================================================

DROP PROCEDURE IF EXISTS _drop_index_if_exists;

DELIMITER //
CREATE PROCEDURE _drop_index_if_exists(
    IN p_table VARCHAR(128),
    IN p_index VARCHAR(128)
)
BEGIN
    DECLARE idx_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO idx_exists
      FROM information_schema.statistics
     WHERE table_schema = DATABASE()
       AND table_name   = p_table
       AND index_name   = p_index
     LIMIT 1;

    IF idx_exists > 0 THEN
        SET @ddl = CONCAT('DROP INDEX ', p_index, ' ON ', p_table);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //
DELIMITER ;

CALL _drop_index_if_exists('auditions', 'idx_auditions_userid_status');
CALL _drop_index_if_exists('auditions', 'idx_auditions_userid_date');
CALL _drop_index_if_exists('auditions', 'idx_auditions_userid_project');
CALL _drop_index_if_exists('auditions', 'idx_auditions_dupe_detect');
CALL _drop_index_if_exists('auditions', 'idx_auditions_contactid');

DROP PROCEDURE IF EXISTS _drop_index_if_exists;
