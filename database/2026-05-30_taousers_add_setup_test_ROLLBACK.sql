-- ROLLBACK for 2026-05-30_taousers_add_setup_test.sql
-- TICKET:  TAO-SETUP-TEST-HARNESS-01 (D1)
-- Restores the taousers view to its 2026-05-06 definition (verbatim) and drops
-- the two setup-test columns. Run via HeidiSQL or mysql CLI, NOT phpMyAdmin
-- (DEFINER rewrite trap -- see forward migration header).
--
-- Order matters: drop the view FIRST (it references the columns), then drop
-- the columns, then recreate the prior view.

-- Step 1: Drop the current (setup-test) view.
DROP VIEW IF EXISTS taousers;

-- Step 2: Drop the two columns from the base table.
ALTER TABLE taousers_tbl
    DROP COLUMN test_email_redirect_userid,
    DROP COLUMN is_setup_test;

-- Step 3: Recreate the prior view verbatim (2026-05-06 definition, 45 columns).
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
