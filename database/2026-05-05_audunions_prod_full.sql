-- =====================================================================
-- 2026-05-05_audunions_prod_full.sql
--
-- End-to-end prod migration of audunions:
--   * Consolidates per-category rows -> one row per (unionName,
--     countryid) with audCatIDList CSV
--   * Remaps audprojects.unionID to surviving unionIDs
--   * Drops the FK_unions_audcategories + legacy audCatID column
--   * Adds unique key uk_audunions_name_country
--   * Seeds master union data for new countries
--
-- ASSUMES PROD IS IN PRISTINE PRE-MIGRATION STATE:
--   * audunions has 67 rows
--   * audCatID column present, audCatIDList NOT present
--   * FK_unions_audcategories present
--   * No audunions_pre_consolidation_20260505 / audprojects_unionid_remap_20260505
--
-- HEIDI SQL: enable Tools -> Preferences -> SQL -> "Stop on errors".
-- Run the entire file as ONE batch. Do not paste in pieces.
--
-- Reversible via 2026-05-05_audunions_rollback.sql
-- =====================================================================
--
-- PRE-FLIGHT DIAGNOSTIC (run these manually first; abort if any fail)
-- =====================================================================
-- -- A. Pristine columns (expect: audCatID present, audCatIDList absent)
-- SHOW COLUMNS FROM audunions;
--
-- -- B. Pristine row count (expect: 67)
-- SELECT COUNT(*) AS total FROM audunions;
--
-- -- C. FK present and named as expected
-- SELECT CONSTRAINT_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
-- FROM information_schema.KEY_COLUMN_USAGE
-- WHERE TABLE_SCHEMA = DATABASE()
--   AND TABLE_NAME = 'audunions'
--   AND COLUMN_NAME = 'audCatID';
-- -- expect: FK_unions_audcategories -> audcategories(audcatid)
-- -- if different name, edit STAGE 6 below to match.
--
-- -- D. No leftover snapshots from prior attempts
-- SHOW TABLES LIKE 'audunions_pre_consolidation%';
-- SHOW TABLES LIKE 'audprojects_unionid_remap%';
-- -- expect: empty
-- =====================================================================


-- ---------------------------------------------------------------------
-- STAGE 0: Snapshots (required for rollback)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS audunions_pre_consolidation_20260505;
CREATE TABLE audunions_pre_consolidation_20260505 AS
SELECT unionID, unionName, countryid, audCatID, isDeleted
FROM audunions;

DROP TABLE IF EXISTS audprojects_unionid_remap_20260505;
CREATE TABLE audprojects_unionid_remap_20260505 (
    audprojectid INT NOT NULL PRIMARY KEY,
    old_unionID  INT NOT NULL,
    new_unionID  INT NOT NULL,
    remapped_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- ---------------------------------------------------------------------
-- STAGE 1: Normalize casing -- "Non-union" -> "Non-Union"
-- (otherwise lowercase rows would consolidate as a separate union)
-- ---------------------------------------------------------------------
UPDATE audunions
SET unionName = 'Non-Union'
WHERE unionName = 'Non-union';


-- ---------------------------------------------------------------------
-- STAGE 2: Add audCatIDList column
-- ---------------------------------------------------------------------
ALTER TABLE audunions
    ADD COLUMN audCatIDList VARCHAR(50) NOT NULL DEFAULT '' AFTER audCatID;


-- ---------------------------------------------------------------------
-- STAGE 3: Build survivor list (lowest unionID per name+country) and
-- populate audCatIDList on the survivor row of each group
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS _audunions_survivors_20260505;
CREATE TABLE _audunions_survivors_20260505 (
    survivor_unionID INT NOT NULL PRIMARY KEY,
    unionName        VARCHAR(100) NOT NULL,
    countryid        CHAR(2)      NOT NULL,
    catList          VARCHAR(50)  NOT NULL
) ENGINE=InnoDB;

INSERT INTO _audunions_survivors_20260505 (survivor_unionID, unionName, countryid, catList)
SELECT
    MIN(unionID),
    unionName,
    countryid,
    GROUP_CONCAT(DISTINCT audCatID ORDER BY audCatID SEPARATOR ',')
FROM audunions
GROUP BY unionName, countryid;

UPDATE audunions u
INNER JOIN _audunions_survivors_20260505 s ON s.survivor_unionID = u.unionID
SET u.audCatIDList = s.catList;


-- ---------------------------------------------------------------------
-- STAGE 4: Build remap (old non-survivor unionID -> survivor),
-- snapshot the audprojects rows that will change, then update them
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS _audunions_remap_20260505;
CREATE TABLE _audunions_remap_20260505 (
    old_unionID INT NOT NULL PRIMARY KEY,
    new_unionID INT NOT NULL
) ENGINE=InnoDB;

INSERT INTO _audunions_remap_20260505 (old_unionID, new_unionID)
SELECT a.unionID, s.survivor_unionID
FROM audunions a
INNER JOIN _audunions_survivors_20260505 s
    ON s.unionName = a.unionName
   AND s.countryid = a.countryid
WHERE a.unionID <> s.survivor_unionID;

INSERT INTO audprojects_unionid_remap_20260505 (audprojectid, old_unionID, new_unionID)
SELECT p.audprojectid, p.unionID, r.new_unionID
FROM audprojects p
INNER JOIN _audunions_remap_20260505 r ON r.old_unionID = p.unionID;

UPDATE audprojects p
INNER JOIN _audunions_remap_20260505 r ON r.old_unionID = p.unionID
SET p.unionID = r.new_unionID;


-- ---------------------------------------------------------------------
-- STAGE 5: Hard-delete non-survivors
-- ---------------------------------------------------------------------
DELETE a
FROM audunions a
INNER JOIN _audunions_remap_20260505 r ON r.old_unionID = a.unionID;


-- ---------------------------------------------------------------------
-- STAGE 6: Drop FK_unions_audcategories and legacy audCatID column
-- (FK must drop first; column drop fails otherwise with #1828)
-- ---------------------------------------------------------------------
ALTER TABLE audunions DROP FOREIGN KEY FK_unions_audcategories;
ALTER TABLE audunions DROP COLUMN audCatID;


-- ---------------------------------------------------------------------
-- STAGE 7: Add unique key (BEFORE seeds, so seeds are idempotent)
-- ---------------------------------------------------------------------
ALTER TABLE audunions
    ADD UNIQUE KEY uk_audunions_name_country (unionName, countryid);


-- ---------------------------------------------------------------------
-- STAGE 8: OPTIONAL DATA-QUALITY FIXES
-- (left commented; uncomment if you want them applied)
--   AGMA at countryid='GB' -- AGMA = American Guild of Musical Artists
--                              (US union); likely a data entry error.
--   "Equity (UK)" at countryid='US' -- Equity is the UK union, already
--                              represented at countryid='GB'; redundant.
-- ---------------------------------------------------------------------
-- UPDATE audunions SET countryid = 'US'  WHERE unionName = 'AGMA'        AND countryid = 'GB';
-- UPDATE audunions SET isDeleted = b'1'  WHERE unionName = 'Equity (UK)' AND countryid = 'US';


-- ---------------------------------------------------------------------
-- STAGE 9: Seed master union data
-- Categories: 1=Film, 2=TV, 3=Theater, 4=Musical Theater,
--             5=VO, 6=Commercial, 7=New Media
-- Idempotent via ON DUPLICATE KEY UPDATE on uk_audunions_name_country.
-- ---------------------------------------------------------------------
INSERT INTO audunions (unionName, countryid, audCatIDList, isDeleted) VALUES
    -- US additions
    ('AGMA', 'US', '3,4', b'0'),
    -- CA additions (BC branch + Quebec union)
    ('UBCP/ACTRA',               'CA', '1,2,5,6,7',     b'0'),
    ('UDA - Union des Artistes', 'CA', '1,2,3,4,5,6,7', b'0'),
    -- TR (Turkey)
    ('Oyuncular Sendikasi', 'TR', '1,2,3,6,7',     b'0'),
    ('Non-Union',           'TR', '1,2,3,4,5,6,7', b'0'),
    -- CH (Switzerland)
    ('SBKV',      'CH', '3,4',           b'0'),
    ('SSRS',      'CH', '1,2,3,4',       b'0'),
    ('SSFV',      'CH', '1,2,5,6,7',     b'0'),
    ('Non-Union', 'CH', '1,2,3,4,5,6,7', b'0'),
    -- NL (Netherlands)
    ('Kunstenbond', 'NL', '1,2,3,4,5,6,7', b'0'),
    ('NTB',         'NL', '4,5',           b'0'),
    ('Non-Union',   'NL', '1,2,3,4,5,6,7', b'0'),
    -- FR (France)
    ('SFA-CGT',   'FR', '1,2,3,4,5,6,7', b'0'),
    ('SNAM-CGT',  'FR', '4,5',           b'0'),
    ('Non-Union', 'FR', '1,2,3,4,5,6,7', b'0'),
    -- DE (Germany)
    ('BFFS',      'DE', '1,2,5,6,7',     b'0'),
    ('GDBA',      'DE', '3,4',           b'0'),
    ('Non-Union', 'DE', '1,2,3,4,5,6,7', b'0'),
    -- IE (Ireland)
    ('Irish Equity (SIPTU)', 'IE', '1,2,3,4,5,6,7', b'0'),
    ('Non-Union',            'IE', '1,2,3,4,5,6,7', b'0'),
    -- ES (Spain)
    ('Union de Actores y Actrices', 'ES', '1,2,3,4,5,6,7', b'0'),
    ('Non-Union',                   'ES', '1,2,3,4,5,6,7', b'0'),
    -- IT (Italy)
    ('SAI Slc-CGIL', 'IT', '1,2,3,4,5,6,7', b'0'),
    ('Non-Union',    'IT', '1,2,3,4,5,6,7', b'0'),
    -- NZ (New Zealand)
    ('Equity NZ', 'NZ', '1,2,3,4,5,6,7', b'0'),
    ('Non-Union', 'NZ', '1,2,3,4,5,6,7', b'0'),
    -- ZA (South Africa)
    ('SAGA',      'ZA', '1,2,3,4,5,6,7', b'0'),
    ('Non-Union', 'ZA', '1,2,3,4,5,6,7', b'0'),
    -- IN (India)
    ('CINTAA',    'IN', '1,2,7',         b'0'),
    ('FWICE',     'IN', '1,2,5,6,7',     b'0'),
    ('Non-Union', 'IN', '1,2,3,4,5,6,7', b'0'),
    -- MX (Mexico)
    ('ANDA',      'MX', '1,2,3,4,5,6,7', b'0'),
    ('Non-Union', 'MX', '1,2,3,4,5,6,7', b'0'),
    -- BR (Brazil)
    ('SATED-SP',  'BR', '1,2,3,4,5,6,7', b'0'),
    ('Non-Union', 'BR', '1,2,3,4,5,6,7', b'0')
ON DUPLICATE KEY UPDATE
    audCatIDList = VALUES(audCatIDList),
    isDeleted    = VALUES(isDeleted);


-- ---------------------------------------------------------------------
-- STAGE 10: Cleanup work tables (snapshots stay -- needed for rollback)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS _audunions_survivors_20260505;
DROP TABLE IF EXISTS _audunions_remap_20260505;


-- ---------------------------------------------------------------------
-- STAGE 11: Verification (read these results before considering done)
-- ---------------------------------------------------------------------
-- Total rows -- expect 48
SELECT COUNT(*) AS total FROM audunions;

-- Per-country -- expect 17 countries: AU, BR, CA, CH, DE, ES, FR, GB,
--   IE, IN, IT, MX, NL, NZ, TR, US, ZA
SELECT countryid, COUNT(*) AS n
FROM audunions
WHERE isDeleted = b'0'
GROUP BY countryid
ORDER BY countryid;

-- Orphan check -- expect 0
SELECT COUNT(*) AS orphans
FROM audprojects p
LEFT JOIN audunions u ON u.unionID = p.unionID
WHERE p.unionID IS NOT NULL AND u.unionID IS NULL;

-- Duplicate check -- expect 0 rows
SELECT unionName, countryid, COUNT(*) AS n
FROM audunions
GROUP BY unionName, countryid
HAVING n > 1;


-- ---------------------------------------------------------------------
-- POST-MIGRATION
--   * Snapshots audunions_pre_consolidation_20260505 and
--     audprojects_unionid_remap_20260505 are kept for rollback.
--     Drop them only after a soak period (e.g. one week of stable use):
--
--       DROP TABLE audunions_pre_consolidation_20260505;
--       DROP TABLE audprojects_unionid_remap_20260505;
--
--   * Code already deployed expects audCatIDList -- the form, service,
--     and ins/upd query files were updated together with the dev migration.
-- ---------------------------------------------------------------------
