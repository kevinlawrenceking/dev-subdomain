-- =============================================================================
-- TAO Performance Optimization: Index Creation Migration
-- TAO-PLAN-2026-004, Phase 1.3
--
-- Purpose: Add composite indexes identified by the nine-agent codebase audit
--          to improve query performance on the hottest paths.
--
-- Rollback: 2026-03-20_add_performance_indexes_ROLLBACK.sql
--
-- IMPORTANT: All indexes target _tbl base tables, not views.
-- Uses AddIndexIfNotExists stored procedure for idempotent execution.
--
-- MYSQL: These indexes support the query patterns documented in
--        /database/audit/explain-hot-queries.sql
-- =============================================================================

DELIMITER //

-- Ensure the helper procedure exists
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

-- =============================================================================
-- GROUP 1: funotifications (notification engine - critical path)
-- =============================================================================

-- Supports: notification dashboard queries (WHERE userid + notstatus + isdeleted)
CALL AddIndexIfNotExists('funotifications', 'idx_funot_user_status_deleted', '(userid, notstatus, isdeleted)');

-- Supports: getNotificationsBySystem (WHERE suid + notstatus)
CALL AddIndexIfNotExists('funotifications', 'idx_funot_suid_status', '(suid, notstatus)');

-- Supports: notification lookup by action+user+system (JOIN patterns in complete_not_batch)
CALL AddIndexIfNotExists('funotifications', 'idx_funot_action_user_suid', '(actionid, userid, suid)');

-- =============================================================================
-- GROUP 2: fusystemusers_tbl (relationship system enrollments)
-- =============================================================================

-- Supports: contact_info.cfm sysActive query (WHERE contactid + userid + sustatus)
CALL AddIndexIfNotExists('fusystemusers_tbl', 'idx_fusu_contact_user_status', '(contactid, userid, sustatus)');

-- Supports: system listing/filtering (WHERE systemid + sustatus + isdeleted)
CALL AddIndexIfNotExists('fusystemusers_tbl', 'idx_fusu_system_status_deleted', '(systemid, sustatus, isdeleted)');

-- =============================================================================
-- GROUP 3: contactdetails_tbl (contact listing - high traffic)
-- =============================================================================

-- Supports: main contact listing (WHERE userid + isdeleted)
CALL AddIndexIfNotExists('contactdetails_tbl', 'idx_cd_user_deleted', '(userid, isdeleted)');

-- =============================================================================
-- GROUP 4: contactitems_tbl (contact detail items)
-- =============================================================================

-- Supports: contact detail page item queries (WHERE contactid + valueCategory + itemstatus)
CALL AddIndexIfNotExists('contactitems_tbl', 'idx_ci_contact_category_status', '(contactid, valueCategory, itemstatus)');

-- =============================================================================
-- GROUP 5: audprojects (audition projects)
-- =============================================================================

-- Supports: audition project listing by user/date (WHERE userid + projdate + isdeleted)
CALL AddIndexIfNotExists('audprojects', 'idx_ap_user_date_deleted', '(userid, projdate, isdeleted)');

-- =============================================================================
-- GROUP 6: events_tbl (events/auditions)
-- =============================================================================

-- Supports: event queries by role (WHERE audroleid + isdeleted + eventstatus)
CALL AddIndexIfNotExists('events_tbl', 'idx_ev_role_deleted_status', '(audroleid, isdeleted, eventstatus)');

-- =============================================================================
-- GROUP 7: audroles (audition roles)
-- =============================================================================

-- Supports: role lookup by project (WHERE audprojectid + isdeleted)
CALL AddIndexIfNotExists('audroles', 'idx_ar_project_deleted', '(audprojectid, isdeleted)');

-- =============================================================================
-- GROUP 8: reports_user / reportitems (report refresh - critical N+1 path)
-- =============================================================================

-- Supports: findid query in ReportsRefreshService loop (WHERE userid + reportid)
CALL AddIndexIfNotExists('reports_user', 'idx_ru_user_report', '(userid, reportid)');

-- Supports: reportitems lookup (WHERE userid + ID)
CALL AddIndexIfNotExists('reportitems', 'idx_ri_user_id', '(userid, ID)');

-- =============================================================================
-- GROUP 9: actionusers (per-user action overrides - JOIN target)
-- =============================================================================

-- Supports: LEFT JOIN in notification queries (ON actionid + userid)
CALL AddIndexIfNotExists('actionusers', 'idx_au_action_user', '(actionid, userid)');

-- =============================================================================
-- Cleanup: drop the helper procedure
-- =============================================================================
DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

-- Done
SELECT 'Performance index migration complete' AS status;
