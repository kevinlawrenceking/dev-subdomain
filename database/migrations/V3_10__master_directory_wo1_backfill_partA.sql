-- ============================================================================
-- V3_10  Master Contact Directory -- WO-1 Backfill, PART A (hot-field denorm)
--        Populate contactPhone / contactEmail / contactCompany on
--        contactdetails_tbl from each contact's own contactitems_tbl rows.
--
-- PROJECT     : TAO / dev-subdomain / branch dev
-- CLEARANCE   : WO-1 Backfill Plan, Part A APPROVED by Kevin 2026-07-07
--               (docs/plans/evidence/2026-07-07-wo1-backfill-plan.md).
-- ENGINE      : MySQL 8.0.41 (ROW_NUMBER). DATABASE()-scoped; runs verbatim on
--               dev + prod. Run USE <schema>; first. DEV FIRST.
-- SCOPE       : PART A ONLY -- the 3 denormalized hot fields. Part B (master
--               linkage: master_co_contact_id / master_coid / company_location_id)
--               is a SEPARATE step, gated on decisions D1-D4. NOT in this file.
-- FK-INDEPENDENT: Part A touches none of the columns V3_9 constrains, so its
--               apply order relative to V3_9 does not matter.
--
-- SELECTION   : mirrors the live contacts_ss "primary" pick
--               (valueCategory + itemStatus='Active', Phone/Email=valuetext,
--               Company=valueCompany) PLUS the locked A5 secondary tie-break
--               itemID ASC for determinism, and explicit IsDeleted=0 (base table).
-- IDEMPOTENT  : recomputes from current items; re-running yields the same result.
--               Wrapped in one transaction. LEFT(...) guards against strict-mode
--               truncation (measured maxes fit: Phone 57/Email 104/Company 174).
-- PROVENANCE  : _src columns are left 'user' (V3_7 default) -- these values are the
--               user's own items. 'master' is stamped only by Part B, later.
--
-- ROLLBACK    : V3_10__master_directory_wo1_backfill_partA_ROLLBACK.sql
-- ============================================================================

-- --- Step 0: preflight -- base table + the 3 target columns must exist (V3_7) ---
SET @ok = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactdetails_tbl'
      AND COLUMN_NAME IN ('contactPhone','contactEmail','contactCompany')
);
SELECT IF(@ok = 3,
          'OK: contactPhone/Email/Company present -- backfilling',
          CONCAT('ABORT: expected 3 target columns, found ', @ok, ' -- run V3_7 first / check USE <schema>'))
       AS preflight;

-- --- Backfill (one transaction) ---------------------------------------------
START TRANSACTION;

-- A1. contactPhone  (varchar(100))
UPDATE contactdetails_tbl cd
JOIN (
  SELECT contactID, valuetext,
         ROW_NUMBER() OVER (PARTITION BY contactID ORDER BY primary_YN DESC, itemID ASC) rn
  FROM   contactitems_tbl
  WHERE  valueCategory = 'Phone' AND itemStatus = 'Active' AND IsDeleted = 0
    AND  TRIM(COALESCE(valuetext,'')) <> ''
) p ON p.contactID = cd.contactID AND p.rn = 1
SET cd.contactPhone = LEFT(p.valuetext, 100)
WHERE cd.IsDeleted = 0;

-- A2. contactEmail  (varchar(150))
UPDATE contactdetails_tbl cd
JOIN (
  SELECT contactID, valuetext,
         ROW_NUMBER() OVER (PARTITION BY contactID ORDER BY primary_YN DESC, itemID ASC) rn
  FROM   contactitems_tbl
  WHERE  valueCategory = 'Email' AND itemStatus = 'Active' AND IsDeleted = 0
    AND  TRIM(COALESCE(valuetext,'')) <> ''
) e ON e.contactID = cd.contactID AND e.rn = 1
SET cd.contactEmail = LEFT(e.valuetext, 150)
WHERE cd.IsDeleted = 0;

-- A3. contactCompany  (varchar(255)) -- uses valueCompany, not valuetext
UPDATE contactdetails_tbl cd
JOIN (
  SELECT contactID, valueCompany,
         ROW_NUMBER() OVER (PARTITION BY contactID ORDER BY primary_YN DESC, itemID ASC) rn
  FROM   contactitems_tbl
  WHERE  valueCategory = 'Company' AND itemStatus = 'Active' AND IsDeleted = 0
    AND  TRIM(COALESCE(valueCompany,'')) <> ''
) c ON c.contactID = cd.contactID AND c.rn = 1
SET cd.contactCompany = LEFT(c.valueCompany, 255)
WHERE cd.IsDeleted = 0;

COMMIT;

-- --- POST-CHECK: filled counts vs. contacts eligible per category ------------
SELECT
  SUM(contactPhone   IS NOT NULL) AS phone_filled,
  SUM(contactEmail   IS NOT NULL) AS email_filled,
  SUM(contactCompany IS NOT NULL) AS company_filled,
  COUNT(*)                        AS total_active
FROM contactdetails_tbl WHERE IsDeleted = 0;

-- Eligibility ceiling: distinct contacts holding >=1 active item per category.
-- Each *_filled above must be <= the matching ceiling here.
SELECT
  (SELECT COUNT(DISTINCT contactID) FROM contactitems_tbl
     WHERE valueCategory='Phone'   AND itemStatus='Active' AND IsDeleted=0 AND TRIM(COALESCE(valuetext,''))    <> '') AS phone_ceiling,
  (SELECT COUNT(DISTINCT contactID) FROM contactitems_tbl
     WHERE valueCategory='Email'   AND itemStatus='Active' AND IsDeleted=0 AND TRIM(COALESCE(valuetext,''))    <> '') AS email_ceiling,
  (SELECT COUNT(DISTINCT contactID) FROM contactitems_tbl
     WHERE valueCategory='Company' AND itemStatus='Active' AND IsDeleted=0 AND TRIM(COALESCE(valueCompany,'')) <> '') AS company_ceiling;

-- Spot-check: 5 sample rows now carrying denormalized values.
SELECT contactID, contactPhone, contactEmail, contactCompany
FROM   contactdetails_tbl
WHERE  IsDeleted = 0 AND (contactPhone IS NOT NULL OR contactEmail IS NOT NULL OR contactCompany IS NOT NULL)
ORDER  BY contactID DESC
LIMIT  5;
