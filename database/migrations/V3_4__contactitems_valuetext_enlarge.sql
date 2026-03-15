-- ============================================================
-- Contact Items valuetext Column Enlargement
-- Version: V3_4
-- Created: 2026-03-14
-- Purpose: Enlarge contactitems_tbl.valuetext to support long notes
--          and other text content imported through V3 importer
--
-- Context: Ticket 2187 - Notes field truncated to ~250 chars
--          The V3 importer writes notes with cf_sql_longvarchar
--          but the DB column may be VARCHAR(255), silently truncating.
--
-- Note: contactitems_tbl is the BASE TABLE.
--       contactitems is a VIEW (active/non-deleted records).
--       The VIEW inherits column types from the base table.
--
-- This migration is idempotent: safe to run multiple times.
-- ============================================================

-- Enlarge valuetext to TEXT (65,535 bytes) on the base table
ALTER TABLE contactitems_tbl
    MODIFY COLUMN valuetext TEXT DEFAULT NULL;

-- ============================================================
-- Verification query (run after migration):
-- SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
-- FROM information_schema.COLUMNS
-- WHERE TABLE_SCHEMA = DATABASE()
--   AND TABLE_NAME = 'contactitems_tbl'
--   AND COLUMN_NAME = 'valuetext';
-- Expected: DATA_TYPE = 'text', CHARACTER_MAXIMUM_LENGTH = 65535
-- ============================================================
