-- PURPOSE: Rebuild taousers view to include recover_requested_at column
-- AUTHOR: Kevin King
-- DATE: 2026-03-19
-- REASON: Column was added to taousers_tbl but the VIEW was not refreshed,
--         causing "Unknown column 'recover_requested_at'" in production.
--
-- Rollback (restores previous view without recover_requested_at):
--   DROP VIEW IF EXISTS taousers;
--   CREATE VIEW taousers AS
--   SELECT tu.userID, tu.userFirstName, tu.userLastName, tu.userEmail, tu.userRole,
--          tu.recordname, tu.contactid, tu.IsDeleted, tu.nletter_yn, tu.nletter_link,
--          tu.calStartTime, tu.calEndTime, tu.calSlotDuration, tu.avatarName,
--          tu.IsBetaTester, tu.defRows, tu.defCountry, tu.defState, tu.tzid,
--          tu.customerid, tu.userstatus, tu.recover, tu.passwordHash, tu.passwordSalt,
--          tu.userPassword, tu.isAudition, tu.viewtypeid, tu.add1, tu.add2, tu.city,
--          tu.regionid, tu.zip, tu.isAuditionModule, tu.imdbid, tu.isSetup,
--          tu.countryid, tu.def_regionid, tu.access_token, tu.refresh_token,
--          tu.dateFormatID, tu.datePrefID, tu.region_id, tu.shareID
--   FROM taousers_tbl AS tu WHERE tu.IsDeleted = 0;

-- Step 1: Ensure the column exists on the base table (idempotent guard)
-- If it already exists this will produce a harmless warning.
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'taousers_tbl'
      AND column_name  = 'recover_requested_at'
);

SET @alter_sql = IF(@col_exists = 0,
    'ALTER TABLE taousers_tbl ADD COLUMN recover_requested_at DATETIME DEFAULT NULL COMMENT ''When recovery token was generated; tokens expire after 1 hour''',
    'SELECT 1'
);

PREPARE stmt FROM @alter_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Rebuild the view with the new column
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
