-- ==========================================================================
-- FIX: Missing sustatus on fusystemusers_tbl
-- ==========================================================================
-- PROBLEM: Multiple legacy INSERT paths in SystemUserService.cfc and
--          scheduled tasks did not set sustatus when creating enrollments.
--          If the column has no DEFAULT, these records get sustatus=NULL
--          and are invisible to all views that filter sustatus='Active'.
--
-- FIX:
--   1. Add DEFAULT 'Active' to the sustatus column (safety net)
--   2. Repair any existing NULL sustatus records
-- ==========================================================================

-- ----- Step 1: Add DEFAULT to prevent future NULL inserts -----
ALTER TABLE fusystemusers_tbl
    MODIFY COLUMN sustatus VARCHAR(50) DEFAULT 'Active';

-- ----- Step 2: Repair existing records with NULL sustatus -----
-- These are enrollments that were created without setting sustatus.
-- If isdeleted=0, they were intended to be active.
UPDATE fusystemusers_tbl
SET sustatus = 'Active'
WHERE sustatus IS NULL
  AND isdeleted = 0;

-- ----- Step 3: Verify no NULL sustatus remains for active records -----
SELECT COUNT(*) AS null_sustatus_count
FROM fusystemusers_tbl
WHERE sustatus IS NULL
  AND isdeleted = 0;
-- Expected: 0

-- ==========================================================================
-- ROLLBACK
-- ==========================================================================
-- ALTER TABLE fusystemusers_tbl
--     MODIFY COLUMN sustatus VARCHAR(50) DEFAULT NULL;
-- (No rollback for the UPDATE - those records were broken before)
