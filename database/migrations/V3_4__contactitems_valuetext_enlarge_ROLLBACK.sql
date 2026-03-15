-- ============================================================
-- ROLLBACK: Contact Items valuetext Column Enlargement
-- Version: V3_4
-- Purpose: Revert valuetext back to VARCHAR(255) on base table
--
-- WARNING: This will truncate any data longer than 255 characters!
-- Only run if you are certain no long values exist.
-- ============================================================

-- Check for long values before reverting
-- SELECT COUNT(*) as long_values FROM contactitems_tbl WHERE LENGTH(valuetext) > 255;

-- Revert to VARCHAR(255) - DATA LOSS if values exceed 255 chars
-- ALTER TABLE contactitems_tbl MODIFY COLUMN valuetext VARCHAR(255) DEFAULT NULL;
