-- =====================================================================
-- 2026-05-06_audunions_dev_dedupe.sql
--
-- Dev-side cleanup for duplicate (unionName, countryid) rows in
-- audunions. Differs from the 2026-05-05 dedupe by REMAPPING any
-- audprojects.unionID that points at a non-survivor BEFORE deleting,
-- so projects do not become orphans.
--
-- Survivor rule: lowest unionID per (unionName, countryid).
--
-- Idempotent. Safe to run more than once. The unique-key ALTER at the
-- end errors with "Duplicate key name" on a second run -- ignore it.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Pre-flight: list current duplicates
-- ---------------------------------------------------------------------
SELECT unionName, countryid, COUNT(*) AS n, GROUP_CONCAT(unionID ORDER BY unionID) AS ids
FROM audunions
GROUP BY unionName, countryid
HAVING n > 1;

-- ---------------------------------------------------------------------
-- 2. Build remap (non-survivor unionID -> survivor unionID).
--    Uses temporary table so STAGE 3 and 4 are deterministic.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS _audunions_dev_remap_20260506;
CREATE TABLE _audunions_dev_remap_20260506 (
    old_unionID INT NOT NULL PRIMARY KEY,
    new_unionID INT NOT NULL,
    KEY ix_new (new_unionID)
) ENGINE=InnoDB;

INSERT INTO _audunions_dev_remap_20260506 (old_unionID, new_unionID)
SELECT a.unionID, keep.keep_id
FROM audunions a
INNER JOIN (
    SELECT unionName, countryid, MIN(unionID) AS keep_id
    FROM audunions
    GROUP BY unionName, countryid
) keep
    ON keep.unionName = a.unionName
   AND keep.countryid = a.countryid
WHERE a.unionID <> keep.keep_id;

-- Snapshot of audprojects rows that will be touched, for audit
DROP TABLE IF EXISTS _audprojects_unionid_remap_20260506;
CREATE TABLE _audprojects_unionid_remap_20260506 AS
SELECT p.audprojectid, p.unionID AS old_unionID, r.new_unionID
FROM audprojects p
INNER JOIN _audunions_dev_remap_20260506 r ON r.old_unionID = p.unionID;

-- ---------------------------------------------------------------------
-- 3. Remap audprojects.unionID off the non-survivors
-- ---------------------------------------------------------------------
UPDATE audprojects p
INNER JOIN _audunions_dev_remap_20260506 r ON r.old_unionID = p.unionID
SET p.unionID = r.new_unionID;

-- ---------------------------------------------------------------------
-- 4. Hard-delete the non-survivor audunions rows
-- ---------------------------------------------------------------------
DELETE a
FROM audunions a
INNER JOIN _audunions_dev_remap_20260506 r ON r.old_unionID = a.unionID;

-- ---------------------------------------------------------------------
-- 5. Add the unique key so seed re-runs cannot create dupes again.
--    If it already exists, MySQL errors 1061 -- safe to ignore.
-- ---------------------------------------------------------------------
ALTER TABLE audunions
    ADD UNIQUE KEY uk_audunions_name_country (unionName, countryid);

-- ---------------------------------------------------------------------
-- 6. Verification
-- ---------------------------------------------------------------------
-- 6a. Should return 0 rows
SELECT unionName, countryid, COUNT(*) AS n
FROM audunions
GROUP BY unionName, countryid
HAVING n > 1;

-- 6b. Should return 0 orphans
SELECT COUNT(*) AS orphan_audprojects
FROM audprojects p
LEFT JOIN audunions u ON u.unionID = p.unionID
WHERE p.unionID IS NOT NULL AND u.unionID IS NULL;

-- 6c. Active rows per country
SELECT countryid, COUNT(*) AS n
FROM audunions
WHERE isDeleted = b'0'
GROUP BY countryid
ORDER BY countryid;
