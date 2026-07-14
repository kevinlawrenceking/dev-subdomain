-- ============================================================================
-- V3_12 ROLLBACK -- STAGE 2 (DESTRUCTIVE). DIR-LNK-WO-2 audit/correction teardown.
--
-- !!! PERMANENT DATA DESTRUCTION !!!
--   Running this file DROPS master_correction_requests_tbl and master_audit_tbl and
--   PERMANENTLY DELETES all master-link audit history and all correction requests.
--
-- NAMED-AUTHORIZATION REQUIREMENT:
--   Do NOT run this file until:
--     1. The Stage-1 precheck (V3_12__..._ROLLBACK.sql) has been run and its row counts reviewed.
--     2. If either table was non-empty, both tables have been EXPORTED.
--     3. Explicit NAMED operator authorization acknowledging permanent audit/correction data
--        destruction has been recorded.
--   Do NOT execute this destructive section in the same uninterrupted operation as the precheck.
--
-- IDEMPOTENT: DROP TABLE IF EXISTS -- re-run is a no-op. No FK between the two tables, so drop
--   order is immaterial; correction dropped first for symmetry with the forward create order.
-- ============================================================================

DROP TABLE IF EXISTS master_correction_requests_tbl;
DROP TABLE IF EXISTS master_audit_tbl;

-- ============================================================================
-- VERIFICATION (read-only)
--   SELECT COUNT(*) FROM information_schema.tables
--     WHERE table_schema=DATABASE() AND table_name IN
--       ('master_audit_tbl','master_correction_requests_tbl');   -- expect 0
-- ============================================================================
