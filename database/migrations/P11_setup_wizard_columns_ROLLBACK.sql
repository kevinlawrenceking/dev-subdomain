-- P11: Onboarding Wizard -- ROLLBACK
-- DATE: 2026-04-07
-- PURPOSE: Remove wizard progress tracking columns and restore view.
--
-- Before running this rollback, capture the current userstatuses.status_url
-- for 'Setup' so it can be restored:
--   SELECT userstatus, status_url FROM userstatuses WHERE userstatus = 'Setup';

-- ----- Step 1: Restore Setup status redirect -----
-- Restore to original value (verify before running):
-- UPDATE userstatuses SET status_url = '/setup/setup-complete.cfm' WHERE userstatus = 'Setup';

-- ----- Step 2: Remove columns from base table -----

ALTER TABLE taousers_tbl
  DROP COLUMN setup_step,
  DROP COLUMN setup_completed_at;

-- ----- Step 3: Rebuild view without new columns -----

DROP VIEW IF EXISTS taousers;

CREATE VIEW taousers AS
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
    tu.isDemo AS isDemo,
    tu.countryid AS countryid,
    tu.def_regionid AS def_regionid,
    tu.access_token AS access_token,
    tu.refresh_token AS refresh_token,
    tu.dateFormatID AS dateFormatID,
    tu.datePrefID AS datePrefID,
    tu.region_id AS region_id,
    tu.shareID AS shareID,
    tu.recover_requested_at AS recover_requested_at
FROM taousers_tbl AS tu
WHERE tu.IsDeleted = 0;
