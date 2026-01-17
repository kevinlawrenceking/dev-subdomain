-- ============================================================
-- Contact Import V3 Schema ROLLBACK
-- Version: V3_0 Rollback
-- Created: 2026-01-17
-- Purpose: Remove all V3 import tables
--
-- USAGE: Run this script to completely remove V3 schema.
--        This is DESTRUCTIVE and will lose all V3 import data.
--
-- Order: Drop dependent tables first (no FKs, but logical order)
-- ============================================================

-- Drop results table (depends on rows)
DROP TABLE IF EXISTS import_v3_row_results;

-- Drop facts table (depends on rows and columns)
DROP TABLE IF EXISTS import_v3_facts;

-- Drop events table (depends on jobs)
DROP TABLE IF EXISTS import_v3_events;

-- Drop rows table (depends on jobs)
DROP TABLE IF EXISTS import_v3_rows;

-- Drop columns table (depends on jobs)
DROP TABLE IF EXISTS import_v3_columns;

-- Drop jobs table (parent)
DROP TABLE IF EXISTS import_v3_jobs;

-- Drop custom fields table (independent)
DROP TABLE IF EXISTS contact_custom_fields;

-- ============================================================
-- Verification query (run after rollback to confirm removal)
-- ============================================================
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = DATABASE()
--   AND table_name LIKE 'import_v3%' OR table_name = 'contact_custom_fields';
-- Expected: Empty result set
-- ============================================================
