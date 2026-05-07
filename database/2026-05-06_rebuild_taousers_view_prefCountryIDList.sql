-- PURPOSE: Rebuild taousers view to expose prefCountryIDList column
-- AUTHOR:  Kevin King
-- DATE:    2026-05-06
-- REASON:  Column was added to taousers_tbl by the audunions per-user
--          country-preference work. The taousers view is a column-list
--          view (not SELECT *), so it must be rebuilt to surface the
--          new column to consumers that read through the view.
--
-- IMPORTANT: Uses SQL SECURITY INVOKER. phpMyAdmin will silently rewrite
--            this to DEFINER on save, which breaks the view with 1146
--            "Table doesn't exist" -- run this script via HeidiSQL or
--            mysql CLI, not via phpMyAdmin's view editor.
--
-- Rollback (restores previous view without prefCountryIDList):
--   DROP VIEW IF EXISTS taousers;
--   CREATE SQL SECURITY INVOKER VIEW taousers AS
--   SELECT tu.userID, tu.userFirstName, tu.userLastName, tu.userEmail, tu.userRole,
--          tu.recordname, tu.contactid, tu.IsDeleted, tu.nletter_yn, tu.nletter_link,
--          tu.calStartTime, tu.calEndTime, tu.calSlotDuration, tu.avatarName,
--          tu.IsBetaTester, tu.defRows, tu.defCountry, tu.defState, tu.tzid,
--          tu.customerid, tu.userstatus, tu.recover, tu.passwordHash, tu.passwordSalt,
--          tu.userPassword, tu.isAudition, tu.viewtypeid, tu.add1, tu.add2, tu.city,
--          tu.regionid, tu.zip, tu.isAuditionModule, tu.imdbid, tu.isSetup,
--          tu.countryid, tu.def_regionid, tu.access_token, tu.refresh_token,
--          tu.dateFormatID, tu.datePrefID, tu.region_id, tu.shareID,
--          tu.recover_requested_at
--   FROM taousers_tbl AS tu WHERE tu.IsDeleted = 0;

-- Step 1: Sanity-check the column actually exists on the base table.
--         If this returns 0, stop and run the prefCountryIDList ALTER first.
SELECT COUNT(*) AS column_present
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name   = 'taousers_tbl'
  AND column_name  = 'prefCountryIDList';
-- expect: 1

-- Step 2: Rebuild the view with prefCountryIDList added at the end of the column list.
DROP VIEW IF EXISTS taousers;

CREATE SQL SECURITY INVOKER VIEW taousers AS
SELECT
    tu.userID AS userID,
    tu.userFirstName AS userFirstName,
    tu.userLastName AS userLastName,
    tu.userEmail AS userEmail,
    tu.userRole AS userRole,
    tu.recordname AS recordname,
    tu.contactid AS contactid,
    tu.IsDeleted AS IsDeleted,
    tu.nletter_yn AS nletter_yn,
    tu.nletter_link AS nletter_link,
    tu.calStartTime AS calStartTime,
    tu.calEndTime AS calEndTime,
    tu.calSlotDuration AS calSlotDuration,
    tu.avatarName AS avatarName,
    tu.IsBetaTester AS IsBetaTester,
    tu.defRows AS defRows,
    tu.defCountry AS defCountry,
    tu.defState AS defState,
    tu.tzid AS tzid,
    tu.customerid AS customerid,
    tu.userstatus AS userstatus,
    tu.recover AS recover,
    tu.passwordHash AS passwordHash,
    tu.passwordSalt AS passwordSalt,
    tu.userPassword AS userPassword,
    tu.isAudition AS isAudition,
    tu.viewtypeid AS viewtypeid,
    tu.add1 AS add1,
    tu.add2 AS add2,
    tu.city AS city,
    tu.regionid AS regionid,
    tu.zip AS zip,
    tu.isAuditionModule AS isAuditionModule,
    tu.imdbid AS imdbid,
    tu.isSetup AS isSetup,
    tu.countryid AS countryid,
    tu.def_regionid AS def_regionid,
    tu.access_token AS access_token,
    tu.refresh_token AS refresh_token,
    tu.dateFormatID AS dateFormatID,
    tu.datePrefID AS datePrefID,
    tu.region_id AS region_id,
    tu.shareID AS shareID,
    tu.recover_requested_at AS recover_requested_at,
    tu.prefCountryIDList AS prefCountryIDList
FROM taousers_tbl AS tu
WHERE tu.IsDeleted = 0;

-- Step 3: Verification
-- 3a. Column appears in view definition
SELECT column_name
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name   = 'taousers'
  AND column_name  = 'prefCountryIDList';
-- expect: 1 row

-- 3b. View returns expected distribution (matches taousers_tbl distribution
--     minus any IsDeleted=1 rows)
SELECT prefCountryIDList, COUNT(*) AS n
FROM taousers
GROUP BY prefCountryIDList
ORDER BY n DESC;
