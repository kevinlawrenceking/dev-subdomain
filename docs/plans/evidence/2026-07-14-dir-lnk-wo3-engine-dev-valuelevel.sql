-- ============================================================================
-- DIR-LNK-WO-3 -- CLASSIFICATION ENGINE, DEV VALUE-LEVEL MODE (P2b/P2c proof)
-- ============================================================================
-- Binding : docs/plans/DIR-LNK-WO3-PLANLOCK.md (b8ac4ac2)
-- Mode    : READ-ONLY, **new_development ONLY**.
-- OUTPUT DESTINATION RULE (P2d): the output of this file contains personal contact
--   values (phone digits, emails, company names). It is written ONLY to local working
--   files under C:\Users\kevin\TAO\_dryrun\dir-lnk-wo3\ (outside the repo) and reported
--   in the bundle via MANIFEST (path, bytes, sha256). It is NEVER committed, never
--   pasted into a prompt or report. This .sql file itself carries no data and is safe
--   to commit as evidence.
-- Purpose : per-row retire-on-match PROOF (primary column value == selected item value
--   under normalization, PC-3 / P2b) and duplicate-normalized group detail (P2c).
-- ============================================================================

-- FP-1: fingerprint (dev)
SELECT @@hostname AS hostname, DATABASE() AS db, CURRENT_USER() AS current_user_, NOW() AS now_, VERSION() AS mysql_version;

-- VAL-P1: Phone retire-on-match proof rows (norm + raw, all reconciliation statuses)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN, ci.valuetext AS raw_item,
         IF(REGEXP_REPLACE(ci.valuetext, '[^0-9]', '') REGEXP '^1[0-9]{10}$',
            SUBSTRING(REGEXP_REPLACE(ci.valuetext, '[^0-9]', ''), 2),
            REGEXP_REPLACE(ci.valuetext, '[^0-9]', '')) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Phone'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
    AND REGEXP_REPLACE(ci.valuetext, '[^0-9]', '') <> ''
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN = 'Y') AS p FROM usable GROUP BY contactID
), sel AS (
  SELECT u.contactID, u.itemID, u.raw_item, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID, d.contactPhone AS raw_col, d.contactPhone_src AS col_src,
         IF(REGEXP_REPLACE(d.contactPhone, '[^0-9]', '') REGEXP '^1[0-9]{10}$',
            SUBSTRING(REGEXP_REPLACE(d.contactPhone, '[^0-9]', ''), 2),
            REGEXP_REPLACE(d.contactPhone, '[^0-9]', '')) AS col_norm
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactPhone IS NOT NULL AND TRIM(d.contactPhone) <> ''
)
SELECT 'Phone' AS field, c.contactID, c.col_src, s.itemID,
       c.raw_col, c.col_norm, s.raw_item, s.norm_value AS item_norm,
       (s.norm_value = c.col_norm) AS norm_match
FROM colnorm c LEFT JOIN sel s ON s.contactID = c.contactID
ORDER BY norm_match, c.contactID;

-- VAL-E1: Email retire-on-match proof rows
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN, ci.valuetext AS raw_item,
         LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Email'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
    AND LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) <> ''
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN = 'Y') AS p FROM usable GROUP BY contactID
), sel AS (
  SELECT u.contactID, u.itemID, u.raw_item, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID, d.contactEmail AS raw_col, d.contactEmail_src AS col_src,
         LOWER(REGEXP_REPLACE(d.contactEmail, '^[[:space:]]+|[[:space:]]+$', '')) AS col_norm
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactEmail IS NOT NULL AND TRIM(d.contactEmail) <> ''
)
SELECT 'Email' AS field, c.contactID, c.col_src, s.itemID,
       c.raw_col, c.col_norm, s.raw_item, s.norm_value AS item_norm,
       (s.norm_value = c.col_norm) AS norm_match
FROM colnorm c LEFT JOIN sel s ON s.contactID = c.contactID
ORDER BY norm_match, c.contactID;

-- VAL-C1: Company retire-on-match proof rows
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN, ci.valueCompany AS raw_item,
         LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Company'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valueCompany IS NOT NULL AND TRIM(ci.valueCompany) <> ''
    AND LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) <> ''
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN = 'Y') AS p FROM usable GROUP BY contactID
), sel AS (
  SELECT u.contactID, u.itemID, u.raw_item, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID, d.contactCompany AS raw_col, d.contactCompany_src AS col_src,
         LOWER(TRIM(REGEXP_REPLACE(d.contactCompany, '[[:space:]]+', ' '))) AS col_norm
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactCompany IS NOT NULL AND TRIM(d.contactCompany) <> ''
)
SELECT 'Company' AS field, c.contactID, c.col_src, s.itemID,
       c.raw_col, c.col_norm, s.raw_item, s.norm_value AS item_norm,
       (s.norm_value = c.col_norm) AS norm_match
FROM colnorm c LEFT JOIN sel s ON s.contactID = c.contactID
ORDER BY norm_match, c.contactID;

-- VAL-P2: extension-marker incidence in Phone raw values (limitation L-P1 sizing)
SELECT ci.contactID, ci.itemID, ci.valuetext AS raw_item
FROM contactitems_tbl ci
JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
WHERE ci.valueCategory = 'Phone'
  AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
  AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
  AND LOWER(ci.valuetext) REGEXP '(ext|x[0-9]+|#[0-9]+)'
ORDER BY ci.contactID, ci.itemID;

-- VAL-DUP-P: Phone duplicate-normalized groups within multi buckets (norm value + members)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
         IF(REGEXP_REPLACE(ci.valuetext, '[^0-9]', '') REGEXP '^1[0-9]{10}$',
            SUBSTRING(REGEXP_REPLACE(ci.valuetext, '[^0-9]', ''), 2),
            REGEXP_REPLACE(ci.valuetext, '[^0-9]', '')) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Phone'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
    AND REGEXP_REPLACE(ci.valuetext, '[^0-9]', '') <> ''
)
SELECT u.contactID, u.norm_value, COUNT(*) AS members,
       GROUP_CONCAT(u.itemID ORDER BY u.itemID) AS itemIDs,
       SUM(u.primary_YN = 'Y') AS primaries_in_group
FROM usable u
GROUP BY u.contactID, u.norm_value
HAVING COUNT(*) > 1
ORDER BY u.contactID;

-- VAL-DUP-E: Email duplicate-normalized groups
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
         LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Email'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
    AND LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) <> ''
)
SELECT u.contactID, u.norm_value, COUNT(*) AS members,
       GROUP_CONCAT(u.itemID ORDER BY u.itemID) AS itemIDs,
       SUM(u.primary_YN = 'Y') AS primaries_in_group
FROM usable u
GROUP BY u.contactID, u.norm_value
HAVING COUNT(*) > 1
ORDER BY u.contactID;

-- VAL-DUP-C: Company duplicate-normalized groups
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
         LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Company'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valueCompany IS NOT NULL AND TRIM(ci.valueCompany) <> ''
    AND LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) <> ''
)
SELECT u.contactID, u.norm_value, COUNT(*) AS members,
       GROUP_CONCAT(u.itemID ORDER BY u.itemID) AS itemIDs,
       SUM(u.primary_YN = 'Y') AS primaries_in_group
FROM usable u
GROUP BY u.contactID, u.norm_value
HAVING COUNT(*) > 1
ORDER BY u.contactID;

-- END (dev value-level engine -- output LOCAL ONLY)
