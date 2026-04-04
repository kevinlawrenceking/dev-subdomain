-- =============================================================================
-- TAO Performance Optimization: ROLLBACK — Recreate Dropped Single-Column Indexes
-- TAO-PLAN-2026-004, Phase 1.4
--
-- Purpose: Restore the 10 single-column indexes removed by
--          2026-04-03_drop_redundant_single_column_indexes.sql
--
-- Uses AddIndexIfNotExists for idempotent execution.
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
        SET @sql = CONCAT('CREATE INDEX `', p_index_name, '` ON `', p_table_name, '` ', p_index_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('CREATED: ', p_index_name, ' on ', p_table_name) AS result;
    ELSE
        SELECT CONCAT('EXISTS: ', p_index_name, ' on ', p_table_name, ' - skipped') AS result;
    END IF;
END //

DELIMITER ;

-- funotifications_tbl
CALL AddIndexIfNotExists('funotifications_tbl', 'actionID', '(actionID)');
CALL AddIndexIfNotExists('funotifications_tbl', 'userID', '(userID)');
CALL AddIndexIfNotExists('funotifications_tbl', 'suID', '(suID)');
CALL AddIndexIfNotExists('funotifications_tbl', 'idx_funotifications_suID', '(suID)');

-- fusystemusers_tbl
CALL AddIndexIfNotExists('fusystemusers_tbl', 'contactID', '(contactID)');
CALL AddIndexIfNotExists('fusystemusers_tbl', 'systemID', '(systemID)');
CALL AddIndexIfNotExists('fusystemusers_tbl', 'userid', '(userid)');

-- contactdetails_tbl
CALL AddIndexIfNotExists('contactdetails_tbl', 'userID', '(userID)');
CALL AddIndexIfNotExists('contactdetails_tbl', 'idx_contactdetails_userid', '(userID)');

-- contactitems_tbl
CALL AddIndexIfNotExists('contactitems_tbl', 'contactID', '(contactID)');

-- Cleanup
DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

SELECT '10 single-column indexes restored' AS status;
