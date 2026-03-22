-- =============================================================================
-- TAO Performance Audit: Index Verification Script
-- TAO-PLAN-2026-004, Phase 1.1
--
-- Purpose: Document existing indexes on the 12 target tables so we can
--          identify which recommended composite indexes are missing.
--
-- Usage:   Run against the target schema (new_development or actorsbusinessoffice).
--          Compare output against the recommended indexes listed below.
--
-- MIGRATE: In Go/AWS, these become part of the schema migration tooling (goose/atlas).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Recommended indexes (from audit):
--
-- funotifications:       (userid, notstatus, isdeleted)
--                        (suid, notstatus)
--                        (actionid, userid, suid)
--
-- fusystemusers_tbl:     (contactid, userid, sustatus)
--                        (systemid, sustatus, isdeleted)
--
-- contactdetails_tbl:    (userid, isdeleted)
--
-- contactitems_tbl:      (contactid, valueCategory, itemstatus)
--
-- audprojects:           (userid, projdate, isdeleted)
--
-- events_tbl:            (audroleid, isdeleted, eventstatus)
--
-- audroles:              (audprojectid, isdeleted)
--
-- reports_user:          (userid, reportid)
--
-- reportitems:           (userid, ID)
-- -----------------------------------------------------------------------------

-- 1. funotifications
SELECT 'funotifications' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'funotifications'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 2. fusystemusers_tbl
SELECT 'fusystemusers_tbl' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fusystemusers_tbl'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 3. contactdetails_tbl
SELECT 'contactdetails_tbl' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactdetails_tbl'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 4. contactitems_tbl
SELECT 'contactitems_tbl' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactitems_tbl'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 5. audprojects
SELECT 'audprojects' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'audprojects'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 6. events_tbl
SELECT 'events_tbl' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'events_tbl'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 7. audroles
SELECT 'audroles' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'audroles'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 8. reports_user
SELECT 'reports_user' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'reports_user'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 9. reportitems
SELECT 'reportitems' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'reportitems'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 10. fuactions
SELECT 'fuactions' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fuactions'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 11. actionusers
SELECT 'actionusers' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'actionusers'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- 12. fusystems
SELECT 'fusystems' AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fusystems'
GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY INDEX_NAME;

-- =============================================================================
-- Summary: Union all tables into one comparison view
-- =============================================================================
SELECT TABLE_NAME AS table_name, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns, INDEX_TYPE, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN (
    'funotifications', 'fusystemusers_tbl', 'contactdetails_tbl', 'contactitems_tbl',
    'audprojects', 'events_tbl', 'audroles', 'reports_user', 'reportitems',
    'fuactions', 'actionusers', 'fusystems'
  )
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY TABLE_NAME, INDEX_NAME;
