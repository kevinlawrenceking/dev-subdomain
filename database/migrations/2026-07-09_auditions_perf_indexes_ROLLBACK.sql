-- =============================================================================
-- ROLLBACK: 2026-07-09_auditions_perf_indexes.sql
-- Drops the two additive performance indexes. Safe: they are secondary indexes
-- only; no data is affected. Idempotent (skips if already absent).
-- Note: does NOT touch the pre-existing idx (contactid, audprojectid) on the
-- xref table or idx_contactdetails_tbl_dupe_v3 -- those predate this migration.
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
        SET @sql = CONCAT('DROP INDEX ', p_index_name, ' ON ', p_table_name,
                          ' ALGORITHM=INPLACE LOCK=NONE');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('DROPPED: ', p_index_name, ' on ', p_table_name) AS result;
    ELSE
        SELECT CONCAT('ABSENT: ', p_index_name, ' on ', p_table_name, ' - skipped') AS result;
    END IF;
END //

DELIMITER ;

CALL DropIndexIfExists('audcontacts_auditions_xref', 'idx_aax_project_contact');
CALL DropIndexIfExists('contactdetails_tbl', 'idx_cd_user_fullname');

DROP PROCEDURE IF EXISTS DropIndexIfExists;

SELECT 'auditions perf index rollback complete' AS status;
