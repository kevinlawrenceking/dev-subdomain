-- =============================================================================
-- TAO Performance Audit: Index Verification Script
-- TAO-PLAN-2026-004, Phase 1.1
--
-- Purpose: Document existing indexes on the 12 target tables so we can
--          identify which recommended composite indexes are missing.
--
-- Usage:   Run against the target schema (new_development or actorsbusinessoffice).
--          Returns a single result set for easy export/review.
--          Compare output against the recommended indexes listed below.
--
-- MIGRATE: In Go/AWS, these become part of the schema migration tooling (goose/atlas).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Recommended indexes (from audit):
--
-- funotifications_tbl:   (userid, notstatus, isdeleted)
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
-- reports_user_tbl:      (userid, reportid)
--
-- reportitems:           (userid, ID)
--
-- actionusers_tbl:       (actionid, userid)
-- -----------------------------------------------------------------------------

SELECT
    TABLE_NAME   AS table_name,
    INDEX_NAME   AS index_name,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns,
    INDEX_TYPE   AS index_type,
    CASE NON_UNIQUE WHEN 0 THEN 'UNIQUE' ELSE 'NON-UNIQUE' END AS uniqueness
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN (
    'funotifications_tbl',
    'fusystemusers_tbl',
    'contactdetails_tbl',
    'contactitems_tbl',
    'audprojects',
    'events_tbl',
    'audroles',
    'reports_user_tbl',
    'reportitems',
    'fuactions',
    'actionusers_tbl',
    'fusystems'
  )
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY TABLE_NAME, INDEX_NAME;
