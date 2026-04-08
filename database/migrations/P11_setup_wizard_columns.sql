-- P11: Onboarding Wizard -- Schema Migration
-- DATE: 2026-04-07
-- PURPOSE: Add wizard progress tracking columns to taousers_tbl
--          and rebuild the taousers view to expose them.
--
-- IMPORTANT: ALTER and backfill run as a single migration.
-- If backfill runs separately and fails, Active users would have
-- setup_step=0 and the setup guard would trap them in the wizard.
--
-- Rollback: database/migrations/P11_setup_wizard_columns_ROLLBACK.sql

-- ----- Step 1: Add columns to base table -----

ALTER TABLE taousers_tbl
  ADD COLUMN setup_step TINYINT NOT NULL DEFAULT 0
    COMMENT 'Wizard progress: 0=not started, 1-6=last completed step, 7=wizard done',
  ADD COLUMN setup_completed_at DATETIME NULL DEFAULT NULL
    COMMENT 'Timestamp when wizard completed and user activated';

-- ----- Step 2: Backfill existing users (MUST follow ALTER immediately) -----
-- Note: userstatus column may store values with trailing spaces (CHAR-padded).
-- Use TRIM() in WHERE clauses to match regardless of padding.

-- All existing Active users: mark wizard-complete so they never see it
UPDATE taousers_tbl
SET setup_step = 7,
    setup_completed_at = NOW()
WHERE TRIM(userstatus) = 'Active';

-- Users in Setup status who already completed bootstrap (isSetup = 1):
-- These finished the old setup flow before the wizard existed.
UPDATE taousers_tbl
SET setup_step = 7,
    userstatus = 'Active',
    setup_completed_at = NOW()
WHERE TRIM(userstatus) = 'Setup'
  AND isSetup = 1;

-- Catch-all: soft-deleted users and users with NULL/unknown status
-- should never enter the wizard. Set them to 7 to prevent edge cases.
UPDATE taousers_tbl
SET setup_step = 7
WHERE setup_step = 0
  AND (IsDeleted = 1
       OR userstatus IS NULL
       OR TRIM(userstatus) NOT IN ('Setup', 'Active'));

-- ----- Step 3: Rebuild the taousers view with new columns -----

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
    tu.recover_requested_at AS recover_requested_at,
    tu.setup_step AS setup_step,
    tu.setup_completed_at AS setup_completed_at
FROM taousers_tbl AS tu
WHERE tu.IsDeleted = 0;

-- ----- Step 4: Update login redirect for Setup-status users -----
-- Login flow (login/login2.cfm) redirects via userstatuses.status_url.
-- Setup users must route through /app/ so the Application.cfc guard
-- can redirect them to /app/setup-wizard/.

UPDATE userstatuses
SET status_url = '/app/'
WHERE userstatus = 'Setup';
