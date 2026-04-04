-- =============================================================================
-- TAO Performance Optimization: Drop Redundant Single-Column Indexes
-- TAO-PLAN-2026-004, Phase 1.4
--
-- Purpose: Remove single-column indexes that are fully covered by composite
--          indexes added in 2026-03-20_add_performance_indexes.sql.
--
--          A composite index on (A, B, C) serves any lookup on just A via its
--          leftmost prefix, making a standalone index on A redundant.
--          Redundant indexes waste storage and add write overhead on every
--          INSERT/UPDATE/DELETE with zero query benefit.
--
-- Rollback: 2026-04-03_drop_redundant_single_column_indexes_ROLLBACK.sql
--
-- Run on dev first:  new_development
-- Then production:   actorsbusinessoffice
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

-- ---------------------------------------------------------------------------
-- funotifications_tbl  (4 indexes to drop)
-- ---------------------------------------------------------------------------

-- actionID covered by idx_funot_action_user_suid (actionID, userID, suID)
CALL DropIndexIfExists('funotifications_tbl', 'actionID');

-- userID covered by idx_funot_user_status_deleted (userID, notStatus, IsDeleted)
CALL DropIndexIfExists('funotifications_tbl', 'userID');

-- suID covered by idx_funot_suid_status (suID, notStatus)
CALL DropIndexIfExists('funotifications_tbl', 'suID');

-- idx_funotifications_suID is a duplicate of suID above, also covered by idx_funot_suid_status
CALL DropIndexIfExists('funotifications_tbl', 'idx_funotifications_suID');

-- ---------------------------------------------------------------------------
-- fusystemusers_tbl  (3 indexes to drop)
-- ---------------------------------------------------------------------------

-- contactID covered by idx_fusu_contact_user_status (contactID, userid, sustatus)
CALL DropIndexIfExists('fusystemusers_tbl', 'contactID');

-- systemID covered by idx_fusu_system_status_deleted (systemID, sustatus, IsDeleted)
CALL DropIndexIfExists('fusystemusers_tbl', 'systemID');

-- userid covered by idx_fusystemusers_user_contact (userid, contactID, sustatus, systemID)
CALL DropIndexIfExists('fusystemusers_tbl', 'userid');

-- ---------------------------------------------------------------------------
-- contactdetails_tbl  (2 indexes to drop)
-- ---------------------------------------------------------------------------

-- userID covered by idx_cd_user_deleted (userID, IsDeleted)
CALL DropIndexIfExists('contactdetails_tbl', 'userID');

-- idx_contactdetails_userid is a duplicate of userID above, also covered by idx_cd_user_deleted
CALL DropIndexIfExists('contactdetails_tbl', 'idx_contactdetails_userid');

-- ---------------------------------------------------------------------------
-- contactitems_tbl  (1 index to drop)
-- ---------------------------------------------------------------------------

-- contactID covered by idx_ci_contact_category_status (contactID, valueCategory, itemStatus)
CALL DropIndexIfExists('contactitems_tbl', 'contactID');

-- =============================================================================
-- Cleanup
-- =============================================================================
DROP PROCEDURE IF EXISTS DropIndexIfExists;

SELECT '10 redundant single-column indexes dropped' AS status;
