-- =============================================================================
-- TAO Prod Audit R12: bigbrother retention (one-time + rolling)
-- Evidence: database/audit/2026-05-17_prod_audit_retention_policy.md
-- Live state (2026-05-17): 2,302,214 rows / 363 MB (43% of the DB).
-- Volume cliff in April 2025: pre-2025-04 = ~99% of corpus; post-cliff = ~80/mo.
--
-- *** DESTRUCTIVE. NOT REVERSIBLE BY THIS SCRIPT. ***
-- Data restore = `mysql ... < archive/bigbrother_pre_*.sql` (DBA, off-box).
-- The ROLLBACK file only drops the helper procedures; it cannot resurrect rows.
-- PREREQUISITE (DBA, before running on prod):
--   1. CLIFF INVESTIGATION must be closed (intentional throttle vs. broken logger).
--   2. mysqldump archive of the to-be-deleted range, verified non-zero size, off-box.
--
-- Run on dev first. Idempotent (proc CREATE OR REPLACE; CALLs re-run safely).
-- =============================================================================

DROP PROCEDURE IF EXISTS prune_bigbrother_pre_cliff;
DROP PROCEDURE IF EXISTS prune_bigbrother_rolling;

DELIMITER //

-- ---------------------------------------------------------------------------
-- ONE-TIME: purge everything before a cutoff date (default 2025-04-01).
-- Batched to avoid long table locks. SELECTs the would-delete count first.
-- Call: `CALL prune_bigbrother_pre_cliff('2025-04-01');`
-- ---------------------------------------------------------------------------
CREATE PROCEDURE prune_bigbrother_pre_cliff(IN p_cutoff DATE)
BEGIN
    DECLARE v_plan BIGINT DEFAULT 0;
    DECLARE v_total_deleted BIGINT DEFAULT 0;
    DECLARE v_batch INT DEFAULT 0;

    IF p_cutoff IS NULL OR p_cutoff > CURDATE() THEN
        SELECT 'ERROR: p_cutoff must be a past date' AS result;
    ELSE
        SELECT COUNT(*) INTO v_plan FROM bigbrother WHERE `timestamp` < p_cutoff;
        SELECT CONCAT('PLAN: will delete ', v_plan, ' rows older than ', p_cutoff) AS result;

        REPEAT
            DELETE FROM bigbrother WHERE `timestamp` < p_cutoff LIMIT 10000;
            SET v_batch = ROW_COUNT();
            SET v_total_deleted = v_total_deleted + v_batch;
        UNTIL v_batch = 0 END REPEAT;

        SELECT CONCAT('DONE: deleted ', v_total_deleted, ' rows. Run OPTIMIZE TABLE bigbrother; off-hours to reclaim disk.') AS result;
    END IF;
END //

-- ---------------------------------------------------------------------------
-- ROLLING: keep last N days (default 365). Wire to a monthly CF cron.
-- Call: `CALL prune_bigbrother_rolling(365);`
-- ---------------------------------------------------------------------------
CREATE PROCEDURE prune_bigbrother_rolling(IN p_keep_days INT)
BEGIN
    DECLARE v_cutoff DATE;
    DECLARE v_plan BIGINT DEFAULT 0;
    DECLARE v_total_deleted BIGINT DEFAULT 0;
    DECLARE v_batch INT DEFAULT 0;

    IF p_keep_days IS NULL OR p_keep_days < 30 THEN
        SELECT 'ERROR: p_keep_days must be >= 30 (safety floor)' AS result;
    ELSE
        SET v_cutoff = DATE_SUB(CURDATE(), INTERVAL p_keep_days DAY);
        SELECT COUNT(*) INTO v_plan FROM bigbrother WHERE `timestamp` < v_cutoff;
        SELECT CONCAT('PLAN: will delete ', v_plan, ' rows older than ', v_cutoff, ' (keep ', p_keep_days, ' days)') AS result;

        REPEAT
            DELETE FROM bigbrother WHERE `timestamp` < v_cutoff LIMIT 10000;
            SET v_batch = ROW_COUNT();
            SET v_total_deleted = v_total_deleted + v_batch;
        UNTIL v_batch = 0 END REPEAT;

        SELECT CONCAT('DONE: deleted ', v_total_deleted, ' rows.') AS result;
    END IF;
END //

DELIMITER ;

SELECT 'Procedures installed. To execute, call manually after archive: CALL prune_bigbrother_pre_cliff(''2025-04-01''); CALL prune_bigbrother_rolling(365);' AS next_step;
