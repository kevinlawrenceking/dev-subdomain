-- ============================================================================
-- DIR-LNK-WO-3 -- CLASSIFICATION ENGINE, DEV ROW-LEVEL MODE (P2)
-- ============================================================================
-- Binding : docs/plans/DIR-LNK-WO3-PLANLOCK.md (b8ac4ac2); binding spec MD5 078d926d
-- Mode    : READ-ONLY, **new_development ONLY**. Row-level output is authorized on dev
--           only (Plan Lock P2 / prod-read-class d). NEVER run this file against
--           actorsbusinessoffice.
-- Output  : IDs, buckets, statuses, and flags ONLY -- no phone/email/company values are
--           selected by any statement in this file. Committed evidence may carry this
--           output verbatim. Value-level proof lives in
--           2026-07-14-dir-lnk-wo3-engine-dev-valuelevel.sql whose OUTPUT goes only to
--           C:\Users\kevin\TAO\_dryrun\dir-lnk-wo3\ (outside the repo).
-- Reconciliation statuses (REC statements, PC-2 / PC-3 / spec 6.4):
--   master_snapshot_col_excluded  col_src='master': master-managed snapshot column, NOT a
--                                 V3_10 backfill value. Out of PC-3 retire scope (handled by
--                                 link machinery / WO-7 path). Dev expectation: exactly one,
--                                 contact 132419 Company (R-A2 / D-19).
--   retire_on_match_selected      column matches the engine-selected candidate (bucket one
--                                 or multi_one_primary) under normalization -> the matched
--                                 item is a retire-on-match candidate. RETIREMENT IS NOT
--                                 EXECUTED IN WO-3 (PC-3, timing = Q-4).
--   primary_mismatch              column populated, engine-selected candidate differs ->
--                                 EXCEPTION unless provenance proves authority (PC-2).
--   retire_on_match_exception_bucket  contact is in an exception bucket (multi_zero/multi_multi)
--                                 but the column matches EXACTLY ONE active item -> that item is
--                                 a retire-on-match candidate per PC-3 reconcile wording. Other
--                                 items preserved.
--   retire_ambiguous_dupnorm      column matches MULTIPLE physical items whose values normalize
--                                 identically -> the row to retire is ambiguous. Report, do not
--                                 guess (PC-2 duplicate rule).
--   col_conflict_no_matching_item column populated, contact has usable items, NONE matches ->
--                                 EXCEPTION (spec 6.4 "values differ").
--   col_populated_no_item         column populated but contact has zero usable items ->
--                                 EXCEPTION (no source item to reconcile against).
-- ============================================================================

-- FP-1: fingerprint (dev)
SELECT @@hostname AS hostname, DATABASE() AS db, CURRENT_USER() AS current_user_, NOW() AS now_, VERSION() AS mysql_version;

-- ============================ PHONE =========================================

-- ROW-P1: per-bucket contactID/itemID listing (IDs only)
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
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN = 'Y') AS p,
         COUNT(DISTINCT norm_value) AS dn
  FROM usable GROUP BY contactID
)
SELECT 'Phone' AS field,
       CASE WHEN pc.n = 1 THEN 'one'
            WHEN pc.p = 1 THEN 'multi_one_primary'
            WHEN pc.p = 0 THEN 'multi_zero_primary'
            ELSE 'multi_multi_primary' END AS bucket,
       (pc.n > 1 AND pc.dn = 1) AS dupnorm_all,
       u.contactID, u.itemID, u.primary_YN
FROM usable u JOIN pc ON pc.contactID = u.contactID
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary'), u.contactID, u.itemID;

-- REC-P1: reconciliation SUMMARY of populated contactPhone columns (PC-3)
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
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN = 'Y') AS p FROM usable GROUP BY contactID
), sel AS (
  SELECT u.contactID, u.itemID, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID,
         IF(REGEXP_REPLACE(d.contactPhone, '[^0-9]', '') REGEXP '^1[0-9]{10}$',
            SUBSTRING(REGEXP_REPLACE(d.contactPhone, '[^0-9]', ''), 2),
            REGEXP_REPLACE(d.contactPhone, '[^0-9]', '')) AS col_norm,
         d.contactPhone_src AS col_src,
         (d.master_co_contact_id IS NOT NULL) AS is_linked
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactPhone IS NOT NULL AND TRIM(d.contactPhone) <> ''
), mm AS (
  SELECT u.contactID, COUNT(*) AS n_match, MIN(u.itemID) AS single_item
  FROM usable u JOIN colnorm c ON c.contactID = u.contactID AND u.norm_value = c.col_norm
  GROUP BY u.contactID
)
SELECT 'Phone' AS field,
  CASE
    WHEN c.col_src = 'master' THEN 'master_snapshot_col_excluded'
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN 'retire_on_match_selected'
    WHEN s.contactID IS NOT NULL THEN 'primary_mismatch'
    WHEN mm.n_match = 1 THEN 'retire_on_match_exception_bucket'
    WHEN mm.n_match > 1 THEN 'retire_ambiguous_dupnorm'
    WHEN pc2.n IS NOT NULL THEN 'col_conflict_no_matching_item'
    ELSE 'col_populated_no_item'
  END AS status,
  c.is_linked, COUNT(*) AS contacts
FROM colnorm c
LEFT JOIN sel s ON s.contactID = c.contactID
LEFT JOIN mm ON mm.contactID = c.contactID
LEFT JOIN pc pc2 ON pc2.contactID = c.contactID
GROUP BY status, c.is_linked ORDER BY status;

-- REC-P2: reconciliation LISTING (contactID, retire itemID, status -- IDs only)
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
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN = 'Y') AS p FROM usable GROUP BY contactID
), sel AS (
  SELECT u.contactID, u.itemID, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID,
         IF(REGEXP_REPLACE(d.contactPhone, '[^0-9]', '') REGEXP '^1[0-9]{10}$',
            SUBSTRING(REGEXP_REPLACE(d.contactPhone, '[^0-9]', ''), 2),
            REGEXP_REPLACE(d.contactPhone, '[^0-9]', '')) AS col_norm,
         d.contactPhone_src AS col_src,
         (d.master_co_contact_id IS NOT NULL) AS is_linked
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactPhone IS NOT NULL AND TRIM(d.contactPhone) <> ''
), mm AS (
  SELECT u.contactID, COUNT(*) AS n_match, MIN(u.itemID) AS single_item
  FROM usable u JOIN colnorm c ON c.contactID = u.contactID AND u.norm_value = c.col_norm
  GROUP BY u.contactID
)
SELECT 'Phone' AS field, c.contactID, c.col_src, c.is_linked,
  CASE
    WHEN c.col_src = 'master' THEN 'master_snapshot_col_excluded'
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN 'retire_on_match_selected'
    WHEN s.contactID IS NOT NULL THEN 'primary_mismatch'
    WHEN mm.n_match = 1 THEN 'retire_on_match_exception_bucket'
    WHEN mm.n_match > 1 THEN 'retire_ambiguous_dupnorm'
    WHEN pc2.n IS NOT NULL THEN 'col_conflict_no_matching_item'
    ELSE 'col_populated_no_item'
  END AS status,
  CASE
    WHEN c.col_src = 'master' THEN NULL
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN s.itemID
    WHEN s.contactID IS NULL AND mm.n_match = 1 THEN mm.single_item
  END AS retire_itemID
FROM colnorm c
LEFT JOIN sel s ON s.contactID = c.contactID
LEFT JOIN mm ON mm.contactID = c.contactID
LEFT JOIN pc pc2 ON pc2.contactID = c.contactID
ORDER BY status, c.contactID;

-- ============================ EMAIL =========================================

-- ROW-E1: per-bucket contactID/itemID listing (IDs only)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
         LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Email'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
    AND LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) <> ''
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN = 'Y') AS p,
         COUNT(DISTINCT norm_value) AS dn
  FROM usable GROUP BY contactID
)
SELECT 'Email' AS field,
       CASE WHEN pc.n = 1 THEN 'one'
            WHEN pc.p = 1 THEN 'multi_one_primary'
            WHEN pc.p = 0 THEN 'multi_zero_primary'
            ELSE 'multi_multi_primary' END AS bucket,
       (pc.n > 1 AND pc.dn = 1) AS dupnorm_all,
       u.contactID, u.itemID, u.primary_YN
FROM usable u JOIN pc ON pc.contactID = u.contactID
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary'), u.contactID, u.itemID;

-- REC-E1: reconciliation SUMMARY of populated contactEmail columns
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
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
  SELECT u.contactID, u.itemID, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID,
         LOWER(REGEXP_REPLACE(d.contactEmail, '^[[:space:]]+|[[:space:]]+$', '')) AS col_norm,
         d.contactEmail_src AS col_src,
         (d.master_co_contact_id IS NOT NULL) AS is_linked
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactEmail IS NOT NULL AND TRIM(d.contactEmail) <> ''
), mm AS (
  SELECT u.contactID, COUNT(*) AS n_match, MIN(u.itemID) AS single_item
  FROM usable u JOIN colnorm c ON c.contactID = u.contactID AND u.norm_value = c.col_norm
  GROUP BY u.contactID
)
SELECT 'Email' AS field,
  CASE
    WHEN c.col_src = 'master' THEN 'master_snapshot_col_excluded'
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN 'retire_on_match_selected'
    WHEN s.contactID IS NOT NULL THEN 'primary_mismatch'
    WHEN mm.n_match = 1 THEN 'retire_on_match_exception_bucket'
    WHEN mm.n_match > 1 THEN 'retire_ambiguous_dupnorm'
    WHEN pc2.n IS NOT NULL THEN 'col_conflict_no_matching_item'
    ELSE 'col_populated_no_item'
  END AS status,
  c.is_linked, COUNT(*) AS contacts
FROM colnorm c
LEFT JOIN sel s ON s.contactID = c.contactID
LEFT JOIN mm ON mm.contactID = c.contactID
LEFT JOIN pc pc2 ON pc2.contactID = c.contactID
GROUP BY status, c.is_linked ORDER BY status;

-- REC-E2: reconciliation LISTING (IDs only)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
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
  SELECT u.contactID, u.itemID, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID,
         LOWER(REGEXP_REPLACE(d.contactEmail, '^[[:space:]]+|[[:space:]]+$', '')) AS col_norm,
         d.contactEmail_src AS col_src,
         (d.master_co_contact_id IS NOT NULL) AS is_linked
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactEmail IS NOT NULL AND TRIM(d.contactEmail) <> ''
), mm AS (
  SELECT u.contactID, COUNT(*) AS n_match, MIN(u.itemID) AS single_item
  FROM usable u JOIN colnorm c ON c.contactID = u.contactID AND u.norm_value = c.col_norm
  GROUP BY u.contactID
)
SELECT 'Email' AS field, c.contactID, c.col_src, c.is_linked,
  CASE
    WHEN c.col_src = 'master' THEN 'master_snapshot_col_excluded'
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN 'retire_on_match_selected'
    WHEN s.contactID IS NOT NULL THEN 'primary_mismatch'
    WHEN mm.n_match = 1 THEN 'retire_on_match_exception_bucket'
    WHEN mm.n_match > 1 THEN 'retire_ambiguous_dupnorm'
    WHEN pc2.n IS NOT NULL THEN 'col_conflict_no_matching_item'
    ELSE 'col_populated_no_item'
  END AS status,
  CASE
    WHEN c.col_src = 'master' THEN NULL
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN s.itemID
    WHEN s.contactID IS NULL AND mm.n_match = 1 THEN mm.single_item
  END AS retire_itemID
FROM colnorm c
LEFT JOIN sel s ON s.contactID = c.contactID
LEFT JOIN mm ON mm.contactID = c.contactID
LEFT JOIN pc pc2 ON pc2.contactID = c.contactID
ORDER BY status, c.contactID;

-- ============================ COMPANY =======================================

-- ROW-C1: per-bucket contactID/itemID listing (IDs only)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
         LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) AS norm_value
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Company'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valueCompany IS NOT NULL AND TRIM(ci.valueCompany) <> ''
    AND LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) <> ''
), pc AS (
  SELECT contactID, COUNT(*) AS n, SUM(primary_YN = 'Y') AS p,
         COUNT(DISTINCT norm_value) AS dn
  FROM usable GROUP BY contactID
)
SELECT 'Company' AS field,
       CASE WHEN pc.n = 1 THEN 'one'
            WHEN pc.p = 1 THEN 'multi_one_primary'
            WHEN pc.p = 0 THEN 'multi_zero_primary'
            ELSE 'multi_multi_primary' END AS bucket,
       (pc.n > 1 AND pc.dn = 1) AS dupnorm_all,
       u.contactID, u.itemID, u.primary_YN
FROM usable u JOIN pc ON pc.contactID = u.contactID
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary'), u.contactID, u.itemID;

-- REC-C1: reconciliation SUMMARY of populated contactCompany columns
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
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
  SELECT u.contactID, u.itemID, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID,
         LOWER(TRIM(REGEXP_REPLACE(d.contactCompany, '[[:space:]]+', ' '))) AS col_norm,
         d.contactCompany_src AS col_src,
         (d.master_co_contact_id IS NOT NULL) AS is_linked
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactCompany IS NOT NULL AND TRIM(d.contactCompany) <> ''
), mm AS (
  SELECT u.contactID, COUNT(*) AS n_match, MIN(u.itemID) AS single_item
  FROM usable u JOIN colnorm c ON c.contactID = u.contactID AND u.norm_value = c.col_norm
  GROUP BY u.contactID
)
SELECT 'Company' AS field,
  CASE
    WHEN c.col_src = 'master' THEN 'master_snapshot_col_excluded'
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN 'retire_on_match_selected'
    WHEN s.contactID IS NOT NULL THEN 'primary_mismatch'
    WHEN mm.n_match = 1 THEN 'retire_on_match_exception_bucket'
    WHEN mm.n_match > 1 THEN 'retire_ambiguous_dupnorm'
    WHEN pc2.n IS NOT NULL THEN 'col_conflict_no_matching_item'
    ELSE 'col_populated_no_item'
  END AS status,
  c.is_linked, COUNT(*) AS contacts
FROM colnorm c
LEFT JOIN sel s ON s.contactID = c.contactID
LEFT JOIN mm ON mm.contactID = c.contactID
LEFT JOIN pc pc2 ON pc2.contactID = c.contactID
GROUP BY status, c.is_linked ORDER BY status;

-- REC-C2: reconciliation LISTING (IDs only)
WITH usable AS (
  SELECT ci.contactID, ci.itemID, ci.primary_YN,
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
  SELECT u.contactID, u.itemID, u.norm_value
  FROM usable u JOIN pc ON pc.contactID = u.contactID
  WHERE pc.n = 1 OR (pc.p = 1 AND u.primary_YN = 'Y')
), colnorm AS (
  SELECT d.contactID,
         LOWER(TRIM(REGEXP_REPLACE(d.contactCompany, '[[:space:]]+', ' '))) AS col_norm,
         d.contactCompany_src AS col_src,
         (d.master_co_contact_id IS NOT NULL) AS is_linked
  FROM contactdetails_tbl d
  WHERE d.IsDeleted = 0 AND d.contactCompany IS NOT NULL AND TRIM(d.contactCompany) <> ''
), mm AS (
  SELECT u.contactID, COUNT(*) AS n_match, MIN(u.itemID) AS single_item
  FROM usable u JOIN colnorm c ON c.contactID = u.contactID AND u.norm_value = c.col_norm
  GROUP BY u.contactID
)
SELECT 'Company' AS field, c.contactID, c.col_src, c.is_linked,
  CASE
    WHEN c.col_src = 'master' THEN 'master_snapshot_col_excluded'
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN 'retire_on_match_selected'
    WHEN s.contactID IS NOT NULL THEN 'primary_mismatch'
    WHEN mm.n_match = 1 THEN 'retire_on_match_exception_bucket'
    WHEN mm.n_match > 1 THEN 'retire_ambiguous_dupnorm'
    WHEN pc2.n IS NOT NULL THEN 'col_conflict_no_matching_item'
    ELSE 'col_populated_no_item'
  END AS status,
  CASE
    WHEN c.col_src = 'master' THEN NULL
    WHEN s.contactID IS NOT NULL AND s.norm_value = c.col_norm THEN s.itemID
    WHEN s.contactID IS NULL AND mm.n_match = 1 THEN mm.single_item
  END AS retire_itemID
FROM colnorm c
LEFT JOIN sel s ON s.contactID = c.contactID
LEFT JOIN mm ON mm.contactID = c.contactID
LEFT JOIN pc pc2 ON pc2.contactID = c.contactID
ORDER BY status, c.contactID;

-- END (dev row-level engine)
