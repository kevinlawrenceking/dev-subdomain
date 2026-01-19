-- ============================================================
-- V3_1 Feature Flags Tables - ROLLBACK
-- Removes feature flag infrastructure
--
-- WARNING: This will delete all feature flag data including
-- user allowlist entries. Make sure to export before running.
-- ============================================================

-- Drop child table first (FK dependency)
DROP TABLE IF EXISTS feature_flag_users;

-- Drop parent table
DROP TABLE IF EXISTS feature_flags;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- SHOW TABLES LIKE 'feature_flag%';
-- Expected: Empty result
