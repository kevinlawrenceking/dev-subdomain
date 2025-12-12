-- =====================================================
-- FIX: charDescription Column Length Issue
-- =====================================================
-- Issue: Users getting errors with long character descriptions
-- Solution:
--   1. Change audroles.charDescription from VARCHAR to TEXT
--   2. Change auditionsimport.charDescription from VARCHAR to TEXT
--   3. Update code to remove 500 char maxlength in import files
--
-- Date: 2025-11-30
-- Database: new_development (dev), actorsbusinessoffice (prod)
-- =====================================================

-- Check current column definitions
-- Run this first to see current types:
-- SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE COLUMN_NAME = 'charDescription'
-- AND TABLE_NAME IN ('audroles', 'auditionsimport');

-- =====================================================
-- For MySQL/MariaDB:
-- =====================================================

-- 1. Fix audroles table
ALTER TABLE audroles
MODIFY COLUMN charDescription TEXT NULL;

-- 2. Fix auditionsimport table
ALTER TABLE auditionsimport
MODIFY COLUMN charDescription TEXT NULL;

-- =====================================================
-- For MSSQL Server:
-- =====================================================
-- Uncomment these if using MSSQL:

-- 1. Fix audroles table
-- ALTER TABLE audroles
-- ALTER COLUMN charDescription VARCHAR(MAX) NULL;

-- 2. Fix auditionsimport table
-- ALTER TABLE auditionsimport
-- ALTER COLUMN charDescription VARCHAR(MAX) NULL;

-- =====================================================
-- Verify the changes:
-- =====================================================
-- SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE COLUMN_NAME = 'charDescription'
-- AND TABLE_NAME IN ('audroles', 'auditionsimport');

-- =====================================================
-- NOTES:
-- =====================================================
-- - TEXT in MySQL allows up to 65,535 characters (~65KB)
-- - If need more, use MEDIUMTEXT (16MB) or LONGTEXT (4GB)
-- - VARCHAR(MAX) in MSSQL allows up to 2GB
-- - After running this SQL, also deploy the code fixes in:
--   * include/upload_audition.cfm (line 190-191)
--   * include/upload_audition_back.cfm (line 188-189)
-- =====================================================
