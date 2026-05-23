-- =============================================================================
-- TAO Prod Audit R6/R7: QUARANTINE (rename, NOT drop) dead tables/views
-- Evidence: database/audit/2026-05-17_prod_audit_phase{0,1,2}.md
-- Every object below has: 0 rows or frozen-backup data, ZERO CFML code refs,
-- ZERO sched/ refs (Phase 2 4-part evidence).
--
-- This script ONLY RENAMES objects to `_zzq_20260517_<name>`. Nothing is
-- dropped. Fully reversible via the ROLLBACK. A separate DROP script is a
-- LATER phase, only after >=2 weeks of observation with no missing-table
-- errors in the app logs.
--
-- PREREQUISITE (DBA, before running on prod): mysqldump-archive the non-empty
-- ones: events_tbl_backup, audprojects_unionid_remap_20260505,
-- audunions_pre_consolidation_20260505, useradministrator_tbl.
--
-- Run dev (new_development) first, smoke-test, then prod. Idempotent.
-- ROLLBACK: 2026-05-17_audit_quarantine_dead_tables_ROLLBACK.sql
-- =============================================================================

DELIMITER //
DROP PROCEDURE IF EXISTS QuarantineIfExists //
CREATE PROCEDURE QuarantineIfExists(IN p_name VARCHAR(64))
BEGIN
    DECLARE v_src INT DEFAULT 0;
    DECLARE v_dst INT DEFAULT 0;
    DECLARE v_q VARCHAR(80);
    SET v_q = CONCAT('_zzq_20260517_', p_name);
    SELECT COUNT(*) INTO v_src FROM information_schema.TABLES
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=p_name;
    SELECT COUNT(*) INTO v_dst FROM information_schema.TABLES
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=v_q;
    IF v_src > 0 AND v_dst = 0 THEN
        SET @s = CONCAT('RENAME TABLE `',p_name,'` TO `',v_q,'`');
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
        SELECT CONCAT('QUARANTINED: ',p_name,' -> ',v_q) AS result;
    ELSEIF v_dst > 0 THEN
        SELECT CONCAT('SKIPPED (already quarantined): ',p_name) AS result;
    ELSE
        SELECT CONCAT('SKIPPED (absent): ',p_name) AS result;
    END IF;
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- AUTO BLOCK: EMPTY (0-row) dead objects only. Reversible rename; nothing to
-- archive because there is no data. Safe to run unattended.
-- ---------------------------------------------------------------------------
CALL QuarantineIfExists('_audprojects_crosslist_snapshot_20260506'); -- 0 rows
CALL QuarantineIfExists('clubs');                 -- 0 rows
CALL QuarantineIfExists('clubmembers');           -- 0 rows
CALL QuarantineIfExists('clubgrades');            -- 0 rows
CALL QuarantineIfExists('projconxref_tbl');       -- 0 rows
CALL QuarantineIfExists('useradmin_tbl');         -- 0 rows
CALL QuarantineIfExists('userlinks_tbl');         -- 0 rows
CALL QuarantineIfExists('ipn_log');               -- 0 rows
CALL QuarantineIfExists('importtest');            -- 0 rows
CALL QuarantineIfExists('import-contacts');       -- 0 rows

-- ===========================================================================
-- GATED BLOCK: NON-EMPTY objects. DO NOT run these CALLs until the DBA has
-- mysqldump-archived each one (rename is reversible, but a later DROP phase
-- assumes an archive exists). Uncomment ONLY after archiving:
--   events_tbl_backup                 (13,710 rows, frozen 2026-01-11)
--   audprojects_unionid_remap_20260505 (1,483 rows)
--   audunions_pre_consolidation_20260505 (59 rows)
--   useradministrator_tbl             (2 rows)
-- Archive command per table, e.g.:
--   mysqldump actorsbusinessoffice events_tbl_backup > archive/events_tbl_backup_20260517.sql
--
-- CALL QuarantineIfExists('events_tbl_backup');
-- CALL QuarantineIfExists('audprojects_unionid_remap_20260505');
-- CALL QuarantineIfExists('audunions_pre_consolidation_20260505');
-- CALL QuarantineIfExists('useradministrator_tbl');
-- ===========================================================================

-- pgpanels_user_xref_delete: name literally says "delete"; 0 rows; no refs.
CALL QuarantineIfExists('pgpanels_user_xref_delete'); -- 0 rows
-- Superseded legacy views (RENAME TABLE works on views in MySQL 8;
-- dev already runs without these):
CALL QuarantineIfExists('shares_old');
CALL QuarantineIfExists('sharez_old');

DROP PROCEDURE IF EXISTS QuarantineIfExists;

SELECT 'R6 quarantine complete' AS status;

-- =============================================================================
-- R7 -- tao_regions / tao_countries: NOT auto-quarantined. Gated on a manual
-- pre-check. The DBA must run the verification below and confirm BOTH:
--   (a) regions/countries are populated canonical sets, and
--   (b) NO view definition references tao_regions/tao_countries,
-- THEN uncomment and run the two CALLs.
--
--   SELECT 'regions' t, COUNT(*) n FROM regions
--   UNION ALL SELECT 'tao_regions', COUNT(*) FROM tao_regions
--   UNION ALL SELECT 'countries', COUNT(*) FROM countries
--   UNION ALL SELECT 'tao_countries', COUNT(*) FROM tao_countries;
--
--   SELECT TABLE_NAME FROM information_schema.VIEWS
--   WHERE TABLE_SCHEMA=DATABASE()
--     AND (VIEW_DEFINITION LIKE '%tao_regions%' OR VIEW_DEFINITION LIKE '%tao_countries%');
--   -- expected: empty result set
--
-- If both pass, run:
--   RENAME TABLE `tao_regions`  TO `_zzq_20260517_tao_regions`;
--   RENAME TABLE `tao_countries` TO `_zzq_20260517_tao_countries`;
-- =============================================================================
