-- =====================================================================
-- 2026-05-05_audunions_finish.sql
--
-- Completes the audunions migration that the prior in-place script
-- left half-done. Current state (verified 2026-05-05):
--
--   * audunions consolidated to 13 rows (one per unionName+countryid)
--   * audunions.audCatIDList already populated
--   * audunions.audCatID column still present (legacy, ready to drop)
--   * audprojects.unionID already remapped (snapshot:
--     audprojects_unionid_remap_20260505, 40 rows)
--   * audunions_pre_consolidation_20260505 snapshot still present
--     for rollback if needed
--   * audunions_new exists but is incomplete (failed parallel-table
--     build attempt) -- needs cleanup
--   * Seeds for new countries (TR/CH/NL/FR/etc.) NOT yet inserted
--
-- This script:
--   1. Drops the abandoned audunions_new
--   2. Drops legacy audCatID column
--   3. Adds the unique key on (unionName, countryid)
--   4. Inserts seed unions for new countries (idempotent)
--
-- Reversible via 2026-05-05_audunions_rollback.sql
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Cleanup the failed parallel-build leftover
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS audunions_new;


-- ---------------------------------------------------------------------
-- 2. Drop the legacy audCatID column from audunions.
--    Must drop the FK constraint first
--    (FK_unions_audcategories: audunions.audCatID -> audcategories.audcatid)
-- ---------------------------------------------------------------------
ALTER TABLE audunions DROP FOREIGN KEY FK_unions_audcategories;
ALTER TABLE audunions DROP COLUMN audCatID;


-- ---------------------------------------------------------------------
-- 3. Add unique key on (unionName, countryid) so seed inserts can use
--    ON DUPLICATE KEY UPDATE for idempotency
-- ---------------------------------------------------------------------
ALTER TABLE audunions
    ADD UNIQUE KEY uk_audunions_name_country (unionName, countryid);


-- ---------------------------------------------------------------------
-- 4. OPTIONAL DATA-QUALITY FIXES
--
-- Inspect, then uncomment the ones you want.
--   AGMA at countryid='GB' -- AGMA = American Guild of Musical Artists
--                              (US union); likely a data entry error.
--   "Equity (UK)" at countryid='US' -- Equity is the UK union, already
--                              represented at countryid='GB'; redundant.
-- ---------------------------------------------------------------------
-- UPDATE audunions SET countryid = 'US'  WHERE unionName = 'AGMA'        AND countryid = 'GB';
-- UPDATE audunions SET isDeleted = b'1'  WHERE unionName = 'Equity (UK)' AND countryid = 'US';


-- ---------------------------------------------------------------------
-- 5. Seed master union data for new countries (and additions to existing).
--    Idempotent on uk_audunions_name_country.
--
--    Categories: 1=Film, 2=TV, 3=Theater, 4=Musical Theater,
--                5=VO, 6=Commercial, 7=New Media
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
-- 6. VERIFICATION
--
--   -- Active unions per country (expect 17 countries: AU, BR, CA, CH,
--   -- DE, ES, FR, GB, IE, IN, IT, MX, NL, NZ, TR, US, ZA)
--   SELECT countryid, COUNT(*) AS n FROM audunions
--   WHERE isDeleted=b'0' GROUP BY countryid ORDER BY countryid;
--
--   -- Full active list
--   SELECT unionID, unionName, countryid, audCatIDList
--   FROM audunions WHERE isDeleted=b'0'
--   ORDER BY countryid, unionName;
--
--   -- Spot-check audprojects integrity
--   SELECT COUNT(*) AS orphan_audprojects
--   FROM audprojects p
--   LEFT JOIN audunions u ON u.unionID = p.unionID
--   WHERE p.unionID IS NOT NULL AND u.unionID IS NULL;
--   -- expect 0
-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------
-- 7. SNAPSHOT CLEANUP (run manually after soak period -- do NOT run now)
--
--   DROP TABLE audunions_pre_consolidation_20260505;
--   DROP TABLE audprojects_unionid_remap_20260505;
-- ---------------------------------------------------------------------
