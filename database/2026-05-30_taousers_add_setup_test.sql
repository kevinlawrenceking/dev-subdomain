-- PURPOSE: Add setup-test harness columns to taousers_tbl and rebuild the
--          taousers view to expose them.
-- AUTHOR:  Kevin King
-- DATE:    2026-05-30
-- TICKET:  TAO-SETUP-TEST-HARNESS-01 (D1)
-- REASON:  is_setup_test flags a setup-test user (redirected setup mail,
--          excluded from real-user reporting); test_email_redirect_userid
--          names the admin tester whose inbox receives that user's setup mail.
--
-- IMPORTANT: The taousers view is a COLUMN-LIST view (not SELECT *) and uses
--            SQL SECURITY INVOKER. phpMyAdmin silently rewrites this to DEFINER
--            on save, which breaks the view with 1146 "Table doesn't exist".
--            Run via HeidiSQL or the mysql CLI, NOT phpMyAdmin's view editor.
--
-- View column list below = the verbatim list from
-- 2026-05-06_rebuild_taousers_view_prefCountryIDList.sql (45 columns, unchanged
-- order) + the two new columns appended at the end. Do not reorder.
--
-- NOTE: `isSetup` (existing, camelCase boolean) and `is_setup_test` (new,
--       snake_case test-harness flag) are DISTINCT columns with different
--       meanings. They are not duplicates -- do not merge or "deduplicate" them.

-- Step 1: Additive columns on the base table.
ALTER TABLE taousers_tbl
    ADD COLUMN is_setup_test TINYINT(1) NOT NULL DEFAULT 0
        COMMENT 'Setup-test harness flag; excluded from real-user reporting',
    ADD COLUMN test_email_redirect_userid INT NULL
        COMMENT 'Admin tester userid whose inbox receives this user''s setup mail';

-- Step 2: Sanity-check both columns landed before rebuilding the view.
SELECT COUNT(*) AS columns_present
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name   = 'taousers_tbl'
  AND column_name IN ('is_setup_test', 'test_email_redirect_userid');
-- expect: 2

-- Step 3: Rebuild the view = verbatim 2026-05-06 column list + two new columns.
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
    tu.prefCountryIDList AS prefCountryIDList,
    tu.is_setup_test AS is_setup_test,
    tu.test_email_redirect_userid AS test_email_redirect_userid
FROM taousers_tbl AS tu
WHERE tu.IsDeleted = 0;

-- Step 4: Verification
-- 4a. Both new columns appear in the view definition.
SELECT column_name
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name   = 'taousers'
  AND column_name IN ('is_setup_test', 'test_email_redirect_userid')
ORDER BY column_name;
-- expect: 2 rows

-- 4b. View still returns the full active-user set (no column-count regression).
SELECT COUNT(*) AS active_users FROM taousers;

-- 4c. Defaults applied on existing rows.
SELECT is_setup_test, COUNT(*) AS n FROM taousers GROUP BY is_setup_test;
-- expect: all existing rows is_setup_test = 0
