-- PURPOSE: Introduce a persistent shareID for public share links
-- AUTHOR: GitHub Copilot
-- DATE: 2025-10-19
-- NOTES:
--   * Adds a new shareID column to taousers_tbl.
--   * Populates existing rows with UUID() values.
--   * Enforces uniqueness on shareID.
--   * Updates the taousers view to expose the new column.
--

-- NOTE: Run the ALTER below only once; it will error if the column already exists.
ALTER TABLE taousers_tbl
    ADD COLUMN shareID CHAR(36) NULL;

-- 2. Populate any NULL shareID values with a generated identifier.
UPDATE taousers_tbl
SET    shareID = UUID()
WHERE  shareID IS NULL
    OR  shareID = '';

-- 3. Enforce NOT NULL and uniqueness once every row has a value.
ALTER TABLE taousers_tbl
    MODIFY COLUMN shareID CHAR(36) NOT NULL;

ALTER TABLE taousers_tbl
    ADD UNIQUE INDEX UQ_taousers_tbl_shareID (shareID);

-- 4. Refresh the taousers view so downstream code can select shareID.
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
    tu.shareID AS shareID
FROM taousers_tbl AS tu
WHERE tu.IsDeleted = 0;
