-- ============================================================
-- Contact Import V3 - Duplicate Detection Performance Indexes
-- Version: V3_2
-- Created: 2026-01-25
-- Phase: 8 (Production Readiness)
--
-- Purpose: Add optimized indexes for duplicate detection queries
-- used by DuplicateMatcherService during contact import.
--
-- Prerequisites:
-- - V3_0 tables must exist (import_v3_*)
-- - Views contactdetails/contactitems must exist (pointing to _tbl base tables)
--
-- IMPORTANT: These indexes are on BASE TABLES (_tbl suffix).
-- The views will use these indexes automatically.
-- ============================================================

-- ============================================================
-- Index 1: contactdetails_tbl - user + deleted + contactid
--
-- Query pattern:
--   SELECT ... FROM contactdetails d
--   WHERE d.userid = ?
--     AND (d.isdeleted IS NULL OR d.isdeleted = 0)
--     ...
--
-- Note: This index may already exist as idx_contactdetails_tbl_user_deleted
--       from previous optimization work. We use IF NOT EXISTS via procedure.
-- ============================================================

DELIMITER //

-- Helper procedure to conditionally create index if not exists
DROP PROCEDURE IF EXISTS AddIndexIfNotExists //

CREATE PROCEDURE AddIndexIfNotExists(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_index_def TEXT
)
BEGIN
    DECLARE v_index_exists INT DEFAULT 0;

    -- Check if index exists
    SELECT COUNT(*) INTO v_index_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_table_name
      AND INDEX_NAME = p_index_name;

    -- Create if not exists
    IF v_index_exists = 0 THEN
        SET @sql = CONCAT('CREATE INDEX ', p_index_name, ' ON ', p_table_name, ' ', p_index_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('CREATED: ', p_index_name, ' on ', p_table_name) AS result;
    ELSE
        SELECT CONCAT('EXISTS: ', p_index_name, ' on ', p_table_name, ' - skipped') AS result;
    END IF;
END //

DELIMITER ;

-- ============================================================
-- Apply indexes
-- ============================================================

-- Index 1: contactdetails - optimized for dupe detection join
-- Covers: userid filter, isdeleted filter, contactid for JOIN
-- Note: Column names use lowercase isdeleted (not IsDeleted) to match actual schema
CALL AddIndexIfNotExists(
    'contactdetails_tbl',
    'idx_contactdetails_tbl_dupe_v3',
    '(userid, isdeleted, contactid)'
);

-- Index 2: contactitems - optimized for dupe detection with valuetext lookup
-- Covers: contactid for JOIN, itemStatus filter, isDeleted filter, valueCategory filter, valuetext for IN clause
-- Note: valuetext(100) is a prefix index for VARCHAR(255) or TEXT columns
CALL AddIndexIfNotExists(
    'contactitems_tbl',
    'idx_contactitems_tbl_dupe_v3',
    '(contactid, itemStatus, isDeleted, valueCategory, valuetext(100))'
);

-- Index 3: contactitems - email/phone category + status for buildUserDupeIndex query
-- Query pattern: WHERE d.userid = ? AND ci.itemStatus = 'Active' AND ci.valueCategory IN ('Email', 'Phone')
-- This is an alternative covering index for the index build query
CALL AddIndexIfNotExists(
    'contactitems_tbl',
    'idx_contactitems_tbl_category_status',
    '(valueCategory, itemStatus, isDeleted, contactid)'
);

-- ============================================================
-- Cleanup helper procedure
-- ============================================================
DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

-- ============================================================
-- Verification queries (run these to confirm indexes)
-- ============================================================
-- SHOW INDEX FROM contactdetails_tbl WHERE Key_name LIKE '%dupe%' OR Key_name LIKE '%user%';
-- SHOW INDEX FROM contactitems_tbl WHERE Key_name LIKE '%dupe%' OR Key_name LIKE '%category%';

-- ============================================================
-- End of V3_2 Migration
-- ============================================================
