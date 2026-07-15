-- ============================================================================
-- DIR-LNK-WO-4 -- EXPECTATION SET (READ-ONLY; run immediately before backfill)
-- ============================================================================
-- Lock    : docs/plans/DIR-LNK-WO4-PLANLOCK.md. DEV ONLY (new_development).
-- Purpose : fresh live classification counts forming the expected-set table.
--           The dry-run counts (WO-3) are provisional; THESE numbers are the
--           contract the backfill run is verified against (P2/P3).
-- Output  : aggregates only. Zero DML.
-- Selection cases (P1b, precedence order):
--   one                    n=1
--   multi_one_primary      n>1, p=1 (designated primary)
--   rq2_business_over_fax  p=2, exactly one primary 'Business' + one primary 'Work Fax'
--   rq1_carveout           n>1, dn=1, not covered above (value-safe duplicates)
-- Guards (both EXCLUDE from the run and are counted here):
--   G-LNK   : master_co_contact_id IS NOT NULL -> linked contact, master-managed
--             path owns its primaries (WO-7); reported, not backfilled.
--   G-WIDTH : CHAR_LENGTH(TRIM(raw)) > destination width (Phone 100 / Email 150;
--             Company impossible, source and destination both varchar(255)).
-- ============================================================================

SELECT @@hostname AS hostname, DATABASE() AS db, CURRENT_USER() AS current_user_, NOW() AS now_, VERSION() AS mysql_version;

-- EX-0: populated-column baseline (canonical predicate) -- capture BEFORE numbers
SELECT
  SUM(contactPhone   IS NOT NULL AND TRIM(contactPhone)   <> '') AS phone_populated_before,
  SUM(contactEmail   IS NOT NULL AND TRIM(contactEmail)   <> '') AS email_populated_before,
  SUM(contactCompany IS NOT NULL AND TRIM(contactCompany) <> '') AS company_populated_before,
  COUNT(*) AS active_contacts
FROM contactdetails_tbl WHERE IsDeleted = 0;

-- EX-0b: contactitems untouched-proof baseline
SELECT COUNT(*) AS items_total, SUM(IsDeleted = 1) AS items_deleted, MAX(itemID) AS max_itemID
FROM contactitems_tbl;

-- EX-P: Phone expected writes by selection case (+ guard counts)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN, ci.valueType, TRIM(ci.valuetext) AS raw_trimmed,
         IF(REGEXP_REPLACE(ci.valuetext, '[^0-9]', '') REGEXP '^1[0-9]{10}$',
            SUBSTRING(REGEXP_REPLACE(ci.valuetext, '[^0-9]', ''), 2),
            REGEXP_REPLACE(ci.valuetext, '[^0-9]', '')) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Phone' AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
    AND REGEXP_REPLACE(ci.valuetext, '[^0-9]', '') <> ''
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN='Y') AS p, COUNT(DISTINCT norm_value) AS dn,
         SUM(primary_YN='Y' AND valueType='Business') AS p_biz,
         SUM(primary_YN='Y' AND valueType='Work Fax') AS p_fax
  FROM usable GROUP BY contactID
), eligible AS (
  SELECT contactID,
    CASE WHEN n = 1 THEN 'one'
         WHEN p = 1 THEN 'multi_one_primary'
         WHEN p = 2 AND p_biz = 1 AND p_fax = 1 THEN 'rq2_business_over_fax'
         WHEN dn = 1 THEN 'rq1_carveout' END AS sel_case
  FROM pc
  WHERE n = 1 OR p = 1 OR (p = 2 AND p_biz = 1 AND p_fax = 1) OR dn = 1
), rep AS (
  SELECT u.contactID, e.sel_case,
    CASE e.sel_case
      WHEN 'one'                   THEN MIN(u.itemID)
      WHEN 'multi_one_primary'     THEN MIN(CASE WHEN u.primary_YN='Y' THEN u.itemID END)
      WHEN 'rq2_business_over_fax' THEN MIN(CASE WHEN u.primary_YN='Y' AND u.valueType='Business' THEN u.itemID END)
      WHEN 'rq1_carveout'          THEN MIN(u.itemID) END AS rep_itemID
  FROM usable u JOIN eligible e ON e.contactID = u.contactID
  GROUP BY u.contactID, e.sel_case
), sel AS (
  SELECT r.contactID, r.sel_case, r.rep_itemID, u.raw_trimmed AS new_value
  FROM rep r JOIN usable u ON u.itemID = r.rep_itemID
)
SELECT 'Phone' AS field, s.sel_case,
  SUM(d.master_co_contact_id IS NULL AND CHAR_LENGTH(s.new_value) <= 100)     AS expected_writes,
  SUM(d.master_co_contact_id IS NOT NULL)                                     AS excluded_G_LNK,
  SUM(d.master_co_contact_id IS NULL AND CHAR_LENGTH(s.new_value) > 100)      AS excluded_G_WIDTH
FROM sel s
JOIN contactdetails_tbl d ON d.contactID = s.contactID
WHERE d.IsDeleted = 0 AND (d.contactPhone IS NULL OR TRIM(d.contactPhone) = '')
GROUP BY s.sel_case ORDER BY s.sel_case;

-- EX-E: Email expected writes by selection case (+ guard counts)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN, TRIM(ci.valuetext) AS raw_trimmed,
         LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Email' AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
    AND LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) <> ''
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN='Y') AS p, COUNT(DISTINCT norm_value) AS dn
  FROM usable GROUP BY contactID
), eligible AS (
  SELECT contactID,
    CASE WHEN n = 1 THEN 'one'
         WHEN p = 1 THEN 'multi_one_primary'
         WHEN dn = 1 THEN 'rq1_carveout' END AS sel_case
  FROM pc
  WHERE n = 1 OR p = 1 OR dn = 1
), rep AS (
  SELECT u.contactID, e.sel_case,
    CASE e.sel_case
      WHEN 'one'               THEN MIN(u.itemID)
      WHEN 'multi_one_primary' THEN MIN(CASE WHEN u.primary_YN='Y' THEN u.itemID END)
      WHEN 'rq1_carveout'      THEN MIN(u.itemID) END AS rep_itemID
  FROM usable u JOIN eligible e ON e.contactID = u.contactID
  GROUP BY u.contactID, e.sel_case
), sel AS (
  SELECT r.contactID, r.sel_case, r.rep_itemID, u.raw_trimmed AS new_value
  FROM rep r JOIN usable u ON u.itemID = r.rep_itemID
)
SELECT 'Email' AS field, s.sel_case,
  SUM(d.master_co_contact_id IS NULL AND CHAR_LENGTH(s.new_value) <= 150)     AS expected_writes,
  SUM(d.master_co_contact_id IS NOT NULL)                                     AS excluded_G_LNK,
  SUM(d.master_co_contact_id IS NULL AND CHAR_LENGTH(s.new_value) > 150)      AS excluded_G_WIDTH
FROM sel s
JOIN contactdetails_tbl d ON d.contactID = s.contactID
WHERE d.IsDeleted = 0 AND (d.contactEmail IS NULL OR TRIM(d.contactEmail) = '')
GROUP BY s.sel_case ORDER BY s.sel_case;

-- EX-C: Company expected writes by selection case (+ G-LNK; G-WIDTH structurally impossible)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN, TRIM(ci.valueCompany) AS raw_trimmed,
         LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Company' AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valueCompany IS NOT NULL AND TRIM(ci.valueCompany) <> ''
    AND LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) <> ''
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN='Y') AS p, COUNT(DISTINCT norm_value) AS dn
  FROM usable GROUP BY contactID
), eligible AS (
  SELECT contactID,
    CASE WHEN n = 1 THEN 'one'
         WHEN p = 1 THEN 'multi_one_primary'
         WHEN dn = 1 THEN 'rq1_carveout' END AS sel_case
  FROM pc
  WHERE n = 1 OR p = 1 OR dn = 1
), rep AS (
  SELECT u.contactID, e.sel_case,
    CASE e.sel_case
      WHEN 'one'               THEN MIN(u.itemID)
      WHEN 'multi_one_primary' THEN MIN(CASE WHEN u.primary_YN='Y' THEN u.itemID END)
      WHEN 'rq1_carveout'      THEN MIN(u.itemID) END AS rep_itemID
  FROM usable u JOIN eligible e ON e.contactID = u.contactID
  GROUP BY u.contactID, e.sel_case
), sel AS (
  SELECT r.contactID, r.sel_case, r.rep_itemID, u.raw_trimmed AS new_value
  FROM rep r JOIN usable u ON u.itemID = r.rep_itemID
)
SELECT 'Company' AS field, s.sel_case,
  SUM(d.master_co_contact_id IS NULL)     AS expected_writes,
  SUM(d.master_co_contact_id IS NOT NULL) AS excluded_G_LNK
FROM sel s
JOIN contactdetails_tbl d ON d.contactID = s.contactID
WHERE d.IsDeleted = 0 AND (d.contactCompany IS NULL OR TRIM(d.contactCompany) = '')
GROUP BY s.sel_case ORDER BY s.sel_case;

-- EX-X: exception-bucket baseline (must be UNCHANGED post-run; P3 proof input)
-- Re-run the three AGG statements from
-- docs/plans/evidence/2026-07-14-dir-lnk-wo3-engine-aggregate.sql (AGG-P1/E1/C1)
-- and capture their output alongside this file's output.
