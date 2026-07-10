-- =============================================================================
-- TAO Performance: auditions list + contact list supporting indexes
-- Date: 2026-07-09
--
-- ROOT CAUSE (proven via EXPLAIN on prod actorsbusinessoffice, userid=629/375 projects):
--   AuditionProjectService.getAuditions (services/AuditionProjectService.cfc:1484)
--   LEFT JOINs audcontacts_auditions_xref on x.audprojectid = p.audprojectid.
--   The table's ONLY secondary index is (contactid, audprojectid) -- audprojectid
--   is the SECOND column, so the join cannot seek. EXPLAIN showed:
--       x | type=index | rows=11289 | Using where; Using index; Using join buffer
--   i.e. a FULL index scan of all 11,289 xref rows, block-nested-loop joined,
--   on every auditions page load. GROUP_CONCAT(c3.recordname) forces it to
--   materialize. This is the auditions slowness.
--
-- FIX A (primary): add (audprojectid, contactid) so the join becomes a ref
--   seek (~1 row/group) and stays covering ("Using index"). Keeps the existing
--   (contactid, audprojectid) index -- that one still serves contact-side lookups,
--   so this is ADDITIVE, not a replacement.
--
-- FIX B (secondary): contactdetails list (WHERE userid=? ORDER BY contactFullName)
--   showed rows=1801 + Using filesort; the existing (userID,IsDeleted,contactID)
--   index ends in contactID, so the name sort cannot use it. Adding
--   (userID, contactFullName) lets MySQL read in name order and drop the filesort.
--   VERIFY on dev EXPLAIN -- the WHERE also has (IsDeleted IS NULL OR =0), applied
--   as a residual filter here.
--
-- Targets BASE TABLES only (confirmed 2026-07-09: both are TABLE_TYPE='BASE TABLE';
--   contactdetails is a VIEW -> its base table contactdetails_tbl is targeted).
-- Idempotent (skips if index already exists). Online DDL (ALGORITHM=INPLACE,
--   LOCK=NONE) so it does not block reads/writes during business hours.
--
-- Rollback: 2026-07-09_auditions_perf_indexes_ROLLBACK.sql
-- Run on dev first (new_development), verify EXPLAIN, then prod (actorsbusinessoffice).
-- =============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS AddIndexIfNotExists //

CREATE PROCEDURE AddIndexIfNotExists(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_index_def  TEXT
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

-- FIX A: auditions xref join seek (audprojectid leading). THE auditions fix.
CALL AddIndexIfNotExists('audcontacts_auditions_xref', 'idx_aax_project_contact',
    '(audprojectid, contactid) ALGORITHM=INPLACE LOCK=NONE');

-- FIX B: contactdetails name-sorted read for the contact list ORDER BY contactFullName.
CALL AddIndexIfNotExists('contactdetails_tbl', 'idx_cd_user_fullname',
    '(userID, contactFullName) ALGORITHM=INPLACE LOCK=NONE');

DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

SELECT 'auditions perf index migration complete' AS status;

-- =============================================================================
-- VERIFY (read-only) after apply, per environment:
--
--   SELECT TABLE_NAME, INDEX_NAME,
--          GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS cols
--   FROM information_schema.STATISTICS
--   WHERE TABLE_SCHEMA = DATABASE()
--     AND ( (TABLE_NAME='audcontacts_auditions_xref' AND INDEX_NAME='idx_aax_project_contact')
--        OR (TABLE_NAME='contactdetails_tbl'         AND INDEX_NAME='idx_cd_user_fullname') )
--   GROUP BY TABLE_NAME, INDEX_NAME;
--
-- Then re-run the getAuditions EXPLAIN (see
-- database/audit/proof_auditions_perf_indexes.sql). Expected: the xref line
-- flips from  type=index rows=11289 Using join buffer  ->  type=ref rows~1 Using index.
-- =============================================================================
