-- ============================================================
-- Contact Import V3 - Duplicate Detection Performance Indexes - ROLLBACK
-- Version: V3_2 ROLLBACK
-- Created: 2026-01-25
--
-- Purpose: Remove V3.2 indexes if needed
--
-- WARNING: Only run this if you need to undo V3_2 changes.
-- These indexes are for performance - removing them will slow duplicate detection.
-- ============================================================

-- Drop the V3.2 indexes (existing indexes from prior optimization remain)
DROP INDEX IF EXISTS idx_contactdetails_tbl_dupe_v3 ON contactdetails_tbl;
DROP INDEX IF EXISTS idx_contactitems_tbl_dupe_v3 ON contactitems_tbl;
DROP INDEX IF EXISTS idx_contactitems_tbl_category_status ON contactitems_tbl;

-- ============================================================
-- End of V3_2 Rollback
-- ============================================================
