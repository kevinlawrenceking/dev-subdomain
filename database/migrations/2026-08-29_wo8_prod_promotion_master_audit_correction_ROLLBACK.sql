-- =============================================================================
-- WO-8 PROD PROMOTION -- ROLLBACK
-- Reverse of 2026-08-29_wo8_prod_promotion_master_audit_correction.sql
--
-- TARGET   : actorsbusinessoffice (PROD).  Run `USE actorsbusinessoffice;` first.
-- ENGINE   : MySQL 8.0.41.
-- AUTHORED : 2026-08-29.  DO NOT RUN until reviewed + named-authorized.
--
-- WHAT IS REVERSIBLE, WHAT IS NOT -- READ BEFORE RUNNING
--
--   SECTION 1 (the two new tables) -- reverse = DROP, but see the reversibility flag:
--     * CLEANLY REVERSIBLE only while the tables are EMPTY, i.e. rolled back BEFORE any WO-8 code has
--       written audit or correction rows on prod.
--     * Once rows exist, DROP PERMANENTLY DESTROYS master-link audit history and correction requests.
--       master_audit_tbl is APPEND-ONLY history -- there is no other copy. Treat a post-write drop as a
--       destructive, two-stage, named-authorization operation (see STAGE 2 below), exactly as V3_12 does.
--
--   SECTION 2 (the _src columns + Tier-1 indexes) -- *** NOT REVERSED HERE. DO NOT DROP. ***
--     Those objects PREDATE this migration (WO-1 / 2026-07-09 perf), already existed on prod before it
--     ran, and are in ACTIVE USE by deployed prod code. Dropping them would break prod reads/writes and
--     the auditions/contacts performance path. They are OUT OF SCOPE of this rollback by design.
--
--   SECTION 3 (optional perf indexes) -- reverse only the ones actually applied (guarded DROP below,
--     commented out to match the forward file's commented-out adds).
-- =============================================================================


-- =============================================================================
-- STAGE 1 -- PRECHECK (read-only; ALWAYS run first, review counts before STAGE 2)
-- =============================================================================
SELECT 'master_audit_tbl' AS tbl,
       (SELECT COUNT(*) FROM information_schema.tables
          WHERE table_schema = DATABASE() AND table_name = 'master_audit_tbl') AS exists_flag;
SELECT 'master_correction_requests_tbl' AS tbl,
       (SELECT COUNT(*) FROM information_schema.tables
          WHERE table_schema = DATABASE() AND table_name = 'master_correction_requests_tbl') AS exists_flag;

-- Row counts -- if EITHER is > 0, STAGE 2 destroys real audit/correction data. EXPORT both first and
-- record explicit named authorization acknowledging permanent destruction before proceeding.
-- (These SELECTs fail harmlessly if the table does not exist; run them only when exists_flag = 1.)
-- SELECT COUNT(*) AS audit_rows      FROM master_audit_tbl;
-- SELECT COUNT(*) AS correction_rows FROM master_correction_requests_tbl;


-- =============================================================================
-- STAGE 2 -- DESTRUCTIVE DROP  (Section 1 reverse)
--   !!! PERMANENT DATA DESTRUCTION once the tables are non-empty !!!
--   Do NOT run in the same uninterrupted operation as the precheck. Requires:
--     1. STAGE 1 counts reviewed.
--     2. If non-empty, both tables EXPORTED.
--     3. Explicit NAMED operator authorization acknowledging permanent audit/correction destruction.
--   IDEMPOTENT: DROP TABLE IF EXISTS. No FK between them, so drop order is immaterial; correction
--   dropped first for symmetry with the forward create order.
-- =============================================================================
DROP TABLE IF EXISTS master_correction_requests_tbl;
DROP TABLE IF EXISTS master_audit_tbl;


-- =============================================================================
-- SECTION 2 REVERSE -- INTENTIONALLY OMITTED.
--   DO NOT drop contactPhone_src / contactEmail_src / contactCompany_src / contactPhoto_src, nor
--   idx_aax_project_contact / idx_cd_user_fullname. They predate this migration and are load-bearing.
-- =============================================================================


-- =============================================================================
-- SECTION 3 REVERSE -- optional perf indexes (only if they were applied from the forward file).
--   Commented out by default, mirroring the forward file. Uses a guarded DROP so a re-run is safe.
-- =============================================================================
-- DELIMITER //
-- DROP PROCEDURE IF EXISTS _wo8_DropIndexIfExists //
-- CREATE PROCEDURE _wo8_DropIndexIfExists(IN p_table VARCHAR(64), IN p_index VARCHAR(64))
-- BEGIN
--     DECLARE v INT DEFAULT 0;
--     SELECT COUNT(*) INTO v FROM information_schema.STATISTICS
--       WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND INDEX_NAME = p_index;
--     IF v > 0 THEN
--         SET @s = CONCAT('DROP INDEX ', p_index, ' ON ', p_table);
--         PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
--     END IF;
-- END //
-- DELIMITER ;
-- CALL _wo8_DropIndexIfExists('audprojects', 'idx_audprojects_deleted_date');
-- CALL _wo8_DropIndexIfExists('events_tbl', 'idx_events_id_start');
-- CALL _wo8_DropIndexIfExists('contactitems_tbl', 'idx_contactitems_lookup');
-- CALL _wo8_DropIndexIfExists('eventcontactsxref_tbl', 'idx_eventcontactsxref_contact');
-- DROP PROCEDURE IF EXISTS _wo8_DropIndexIfExists;

SELECT 'WO-8 prod promotion rollback complete' AS status;

-- =============================================================================
-- VERIFICATION (read-only)
--   SELECT COUNT(*) FROM information_schema.tables
--     WHERE table_schema = DATABASE()
--       AND table_name IN ('master_audit_tbl','master_correction_requests_tbl');   -- expect 0 after STAGE 2
--   -- _src columns + Tier-1 indexes MUST still be present (Section 2 not reversed):
--   SELECT COUNT(*) FROM information_schema.columns
--     WHERE table_schema = DATABASE() AND table_name = 'contactdetails_tbl'
--       AND column_name LIKE '%\_src';                                             -- expect 4
-- =============================================================================
