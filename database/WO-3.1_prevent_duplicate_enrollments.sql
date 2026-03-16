-- ==========================================================================
-- WO-3.1: Prevent Duplicate Active Enrollments in fusystemusers
-- ==========================================================================
-- PURPOSE: Add a database-level constraint to prevent the same contact
--          from being enrolled in the same system more than once while active.
--
-- STRATEGY:
--   1. Audit: find existing duplicate active enrollments
--   2. Clean: soft-delete all but the earliest enrollment per group
--   3. Constrain: add a generated column + unique index to prevent future dupes
--
-- ROLLBACK: included at bottom
-- ==========================================================================

-- ----- Step 1: Audit — identify duplicate active enrollments -----
SELECT
    userid,
    contactid,
    systemid,
    COUNT(*) AS active_count,
    GROUP_CONCAT(suid ORDER BY sustartdate ASC) AS suid_list
FROM fusystemusers_tbl
WHERE sustatus = 'Active'
  AND isdeleted = 0
GROUP BY userid, contactid, systemid
HAVING COUNT(*) > 1;

-- ----- Step 2: Clean — soft-delete duplicates, keeping the earliest suid -----
-- This UPDATE targets all rows in a duplicate group EXCEPT the one with the
-- lowest suid (earliest enrollment).
UPDATE fusystemusers_tbl dup
INNER JOIN (
    SELECT
        userid, contactid, systemid,
        MIN(suid) AS keep_suid
    FROM fusystemusers_tbl
    WHERE sustatus = 'Active'
      AND isdeleted = 0
    GROUP BY userid, contactid, systemid
    HAVING COUNT(*) > 1
) grp ON dup.userid = grp.userid
     AND dup.contactid = grp.contactid
     AND dup.systemid = grp.systemid
     AND dup.suid <> grp.keep_suid
SET dup.isdeleted = 1,
    dup.sunotes = CONCAT(COALESCE(dup.sunotes, ''), ' [WO-3.1 deduped ', NOW(), ']')
WHERE dup.sustatus = 'Active'
  AND dup.isdeleted = 0;

-- ----- Step 3: Verify cleanup -----
SELECT COUNT(*) AS remaining_dupes
FROM (
    SELECT userid, contactid, systemid
    FROM fusystemusers_tbl
    WHERE sustatus = 'Active'
      AND isdeleted = 0
    GROUP BY userid, contactid, systemid
    HAVING COUNT(*) > 1
) t;
-- Expected: 0

-- ----- Step 4: Add generated column for conditional unique index -----
-- MySQL does not support partial/filtered unique indexes directly.
-- We use a generated column that is non-NULL only for active, non-deleted rows,
-- then add a unique index on (userid, contactid, systemid, active_guard).
-- NULL values in unique indexes are ignored by MySQL, so only active rows are constrained.
ALTER TABLE fusystemusers_tbl
ADD COLUMN active_guard TINYINT
    GENERATED ALWAYS AS (
        CASE WHEN sustatus = 'Active' AND isdeleted = 0 THEN 1 ELSE NULL END
    ) STORED;

ALTER TABLE fusystemusers_tbl
ADD UNIQUE INDEX uq_active_enrollment (userid, contactid, systemid, active_guard);

-- ----- Step 5: Verify constraint -----
-- This should fail with a duplicate key error:
-- INSERT INTO fusystemusers_tbl (systemid, contactid, userid, sustatus)
-- VALUES (1, 1, 1, 'Active');
-- (only if a row with those values already exists and is active/not-deleted)

-- ==========================================================================
-- ROLLBACK
-- ==========================================================================
-- ALTER TABLE fusystemusers_tbl DROP INDEX uq_active_enrollment;
-- ALTER TABLE fusystemusers_tbl DROP COLUMN active_guard;
-- UPDATE fusystemusers_tbl
--   SET isdeleted = 0,
--       sunotes = REPLACE(sunotes, ' [WO-3.1 deduped', '')
--   WHERE sunotes LIKE '%[WO-3.1 deduped%';
