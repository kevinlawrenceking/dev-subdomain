-- ============================================================================
-- V3_12 ROLLBACK -- STAGE 1 (PRECHECK ONLY). ZERO DDL. Nothing here mutates schema or data.
--   DIR-LNK-WO-2 audit/correction rollback, safety stage.
--
-- PURPOSE: run the row-count prechecks below and REVIEW the returned counts BEFORE any drop.
--   The destructive DROP statements live ONLY in the companion file:
--     V3_12__master_directory_wo2_audit_correction_ROLLBACK_DESTRUCTIVE.sql
--
-- STOP RULE: if EITHER count below is greater than zero:
--     - STOP. Do NOT run the destructive file.
--     - Require explicit NAMED authorization acknowledging PERMANENT destruction of
--       audit and/or correction-request data before the destructive file may be run.
--
-- Do NOT execute the destructive section in the same uninterrupted operation as this precheck.
--   Review the returned row counts first. The rollback is idempotent, but it is LOSS-FREE ONLY
--   while both tables are empty.
-- ============================================================================

SELECT COUNT(*) AS master_audit_rows
FROM master_audit_tbl;

SELECT COUNT(*) AS correction_request_rows
FROM master_correction_requests_tbl;

-- ============================================================================
-- DECISION:
--   both counts = 0  -> loss-free; the destructive file may be run under normal change control.
--   either count > 0 -> STOP; obtain named authorization acknowledging permanent data loss,
--                       exporting both tables first, THEN run the destructive file.
-- ============================================================================
