-- =============================================================================
-- TAO Performance Optimization: Index Creation ROLLBACK
-- TAO-PLAN-2026-004, Phase 1.3
--
-- Purpose: Remove all indexes added by 2026-03-20_add_performance_indexes.sql
--
-- Usage: Run if indexes cause unexpected issues (lock contention, storage, etc.)
--        Each DROP INDEX uses IF EXISTS for idempotent execution.
-- =============================================================================

-- GROUP 1: funotifications_tbl
DROP INDEX IF EXISTS idx_funot_user_status_deleted ON funotifications_tbl;
DROP INDEX IF EXISTS idx_funot_suid_status ON funotifications_tbl;
DROP INDEX IF EXISTS idx_funot_action_user_suid ON funotifications_tbl;

-- GROUP 2: fusystemusers_tbl
DROP INDEX IF EXISTS idx_fusu_contact_user_status ON fusystemusers_tbl;
DROP INDEX IF EXISTS idx_fusu_system_status_deleted ON fusystemusers_tbl;

-- GROUP 3: contactdetails_tbl
DROP INDEX IF EXISTS idx_cd_user_deleted ON contactdetails_tbl;

-- GROUP 4: contactitems_tbl
DROP INDEX IF EXISTS idx_ci_contact_category_status ON contactitems_tbl;

-- GROUP 5: audprojects
DROP INDEX IF EXISTS idx_ap_user_date_deleted ON audprojects;

-- GROUP 6: events_tbl
DROP INDEX IF EXISTS idx_ev_role_deleted_status ON events_tbl;

-- GROUP 7: audroles
DROP INDEX IF EXISTS idx_ar_project_deleted ON audroles;

-- GROUP 8: reports_user_tbl / reportitems
DROP INDEX IF EXISTS idx_ru_user_report ON reports_user_tbl;
DROP INDEX IF EXISTS idx_ri_user_id ON reportitems;

-- GROUP 9: actionusers_tbl
DROP INDEX IF EXISTS idx_au_action_user ON actionusers_tbl;

-- Cleanup helper procedure if it was left behind
DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

SELECT 'Performance index rollback complete' AS status;
