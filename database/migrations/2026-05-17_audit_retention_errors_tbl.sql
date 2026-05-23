-- =============================================================================
-- TAO Prod Audit R12: errors_tbl ID-watermark retention
-- Evidence: database/audit/2026-05-17_prod_audit_retention_policy.md
-- Live state (2026-05-17): 5,056 rows / 116 MB; ~17 KB blob per row; no
-- timestamp column (retention must use ID-watermark, AUTO_INCREMENT order).
--
-- *** DESTRUCTIVE. NOT REVERSIBLE BY THIS SCRIPT. ***
-- Data restore = `mysql ... < archive/errors_tbl_pre_id_watermark_*.sql`.
-- PREREQUISITE (DBA): mysqldump archive of rows with ID < (MAX(ID) - p_keep),
-- verified non-zero size, off-box.
--
-- FUTURE FIX (Go redesign or separate migration): add
--   `created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP`
-- so retention can become time-based. ID-watermark is a workaround for the
-- missing timestamp.
--
-- Run on dev first. Idempotent.
-- =============================================================================

DROP PROCEDURE IF EXISTS prune_errors_tbl;

DELIMITER //

-- ---------------------------------------------------------------------------
-- Keep newest p_keep rows by ID. Default 1500 (~3 years at current rate).
-- Safety floor: p_keep >= 500.
-- Call: `CALL prune_errors_tbl(1500);`
-- ---------------------------------------------------------------------------
CREATE PROCEDURE prune_errors_tbl(IN p_keep INT)
BEGIN
    DECLARE v_max_id BIGINT DEFAULT 0;
    DECLARE v_watermark BIGINT DEFAULT 0;
    DECLARE v_plan BIGINT DEFAULT 0;
    DECLARE v_total_deleted BIGINT DEFAULT 0;
    DECLARE v_batch INT DEFAULT 0;

    IF p_keep IS NULL OR p_keep < 500 THEN
        SELECT 'ERROR: p_keep must be >= 500 (safety floor)' AS result;
    ELSE
        SELECT MAX(ID) INTO v_max_id FROM errors_tbl;
        SET v_watermark = v_max_id - p_keep;
        SELECT COUNT(*) INTO v_plan FROM errors_tbl WHERE ID < v_watermark;
        SELECT CONCAT('PLAN: max_id=', v_max_id, ', watermark=', v_watermark,
                      ', will delete ', v_plan, ' rows (keep newest ', p_keep, ')') AS result;

        REPEAT
            DELETE FROM errors_tbl WHERE ID < v_watermark LIMIT 500;
            SET v_batch = ROW_COUNT();
            SET v_total_deleted = v_total_deleted + v_batch;
        UNTIL v_batch = 0 END REPEAT;

        SELECT CONCAT('DONE: deleted ', v_total_deleted, ' rows. Run OPTIMIZE TABLE errors_tbl; off-hours to reclaim disk.') AS result;
    END IF;
END //

DELIMITER ;

SELECT 'Procedure installed. To execute after archive: CALL prune_errors_tbl(1500);' AS next_step;
