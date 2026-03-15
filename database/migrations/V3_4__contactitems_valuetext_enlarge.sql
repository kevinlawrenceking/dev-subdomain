-- ============================================================
-- Contact Items valuetext Column Enlargement
-- Version: V3_4
-- Created: 2026-03-14
-- Purpose: Enlarge contactitems.valuetext to support long notes
--          and other text content imported through V3 importer
--
-- Context: Ticket 2187 - Notes field truncated to ~250 chars
--          The V3 importer writes notes with cf_sql_longvarchar
--          but the DB column may be VARCHAR(255), silently truncating.
--
-- This migration is idempotent: safe to run multiple times.
-- ============================================================

-- Check current column type and alter if needed
-- Only runs the ALTER if valuetext is currently VARCHAR (any length)
SET @current_type = (
    SELECT DATA_TYPE FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'contactitems'
      AND COLUMN_NAME = 'valuetext'
);

-- Enlarge valuetext to TEXT (65,535 bytes) if currently VARCHAR
-- TEXT supports long notes, descriptions, and other free-form content
ALTER TABLE contactitems
    MODIFY COLUMN valuetext TEXT DEFAULT NULL;

-- Also check contactitems_tbl (filtered view table) if it exists
SET @tbl_exists = (
    SELECT COUNT(*) FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'contactitems_tbl'
);

-- Note: contactitems_tbl is a VIEW, not a base table.
-- The VIEW inherits column types from the underlying table.
-- No ALTER needed on the view.

-- ============================================================
-- Verification query (run after migration):
-- SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
-- FROM information_schema.COLUMNS
-- WHERE TABLE_SCHEMA = DATABASE()
--   AND TABLE_NAME = 'contactitems'
--   AND COLUMN_NAME = 'valuetext';
-- Expected: DATA_TYPE = 'text', CHARACTER_MAXIMUM_LENGTH = 65535
-- ============================================================
