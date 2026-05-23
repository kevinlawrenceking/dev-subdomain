-- =============================================================================
-- ROLLBACK: 2026-05-17_audit_quarantine_dead_tables.sql
-- Renames every `_zzq_20260517_<name>` object back to `<name>`. Idempotent.
-- (Also handles the manually-run tao_regions/tao_countries case if applied.)
-- =============================================================================

DELIMITER //
DROP PROCEDURE IF EXISTS UnquarantineIfExists //
CREATE PROCEDURE UnquarantineIfExists(IN p_name VARCHAR(64))
BEGIN
    DECLARE v_src INT DEFAULT 0;
    DECLARE v_dst INT DEFAULT 0;
    DECLARE v_q VARCHAR(80);
    SET v_q = CONCAT('_zzq_20260517_', p_name);
    SELECT COUNT(*) INTO v_src FROM information_schema.TABLES
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=v_q;
    SELECT COUNT(*) INTO v_dst FROM information_schema.TABLES
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=p_name;
    IF v_src > 0 AND v_dst = 0 THEN
        SET @s = CONCAT('RENAME TABLE `',v_q,'` TO `',p_name,'`');
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
        SELECT CONCAT('RESTORED: ',v_q,' -> ',p_name) AS result;
    ELSEIF v_dst > 0 THEN
        SELECT CONCAT('SKIPPED (already present): ',p_name) AS result;
    ELSE
        SELECT CONCAT('SKIPPED (no quarantined copy): ',p_name) AS result;
    END IF;
END //
DELIMITER ;

CALL UnquarantineIfExists('_audprojects_crosslist_snapshot_20260506');
CALL UnquarantineIfExists('audprojects_unionid_remap_20260505');
CALL UnquarantineIfExists('audunions_pre_consolidation_20260505');
CALL UnquarantineIfExists('events_tbl_backup');
CALL UnquarantineIfExists('clubs');
CALL UnquarantineIfExists('clubmembers');
CALL UnquarantineIfExists('clubgrades');
CALL UnquarantineIfExists('projconxref_tbl');
CALL UnquarantineIfExists('useradmin_tbl');
CALL UnquarantineIfExists('useradministrator_tbl');
CALL UnquarantineIfExists('userlinks_tbl');
CALL UnquarantineIfExists('ipn_log');
CALL UnquarantineIfExists('importtest');
CALL UnquarantineIfExists('import-contacts');
CALL UnquarantineIfExists('pgpanels_user_xref_delete');
CALL UnquarantineIfExists('shares_old');
CALL UnquarantineIfExists('sharez_old');
-- tao_* (only if the gated section was manually applied):
CALL UnquarantineIfExists('tao_regions');
CALL UnquarantineIfExists('tao_countries');

DROP PROCEDURE IF EXISTS UnquarantineIfExists;

SELECT 'R6/R7 quarantine rollback complete' AS status;
