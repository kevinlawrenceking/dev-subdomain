-- ============================================================================
-- DIR-LNK-WO-3 -- CLASSIFICATION ENGINE, AGGREGATE MODE (P1b / P3)
-- ============================================================================
-- Binding : docs/plans/DIR-LNK-WO3-PLANLOCK.md (b8ac4ac2); binding spec MD5 078d926d
-- Rules   : PC-2 decision table (Plan Lock SECTION 3a); canonical count predicate (3e);
--           reference normalization N-P/N-E/N-C
--           (docs/plans/evidence/2026-07-14-dir-lnk-wo3-normalization-rules.md).
-- Mode    : READ-ONLY. Zero DDL, zero DML, zero temp tables, zero server-side objects.
--           Every statement is SELECT-only (CTEs materialize client-side per statement).
-- Schemas : runs unmodified on new_development (dev) AND actorsbusinessoffice (prod).
--           On prod this file is the ONLY authorized mode (aggregate GROUP BY output;
--           no row-level data leaves the server). Fingerprint statement runs first.
-- Buckets : one / multi_one_primary / multi_zero_primary / multi_multi_primary per PC-2.
--           duplicate_normalized is a FLAG (dupnorm_all_contacts) within multi buckets:
--           all usable candidates normalize to ONE identical value.
--           primary_mismatch is a RECONCILIATION status (dev row-level file) -- on prod it
--           is STRUCTURALLY ZERO because DG-1 proved all prod primary columns are empty.
-- Candidate predicate (normalization-rules doc, "Candidate predicate"):
--           ci.IsDeleted=0 AND ci.itemStatus='Active' AND ci.valueCategory=<F>
--           AND d.IsDeleted=0 AND raw value IS NOT NULL AND TRIM(raw)<>'' AND norm<>''
-- R-A1 PARITY MODE: statements suffixed "parity" reproduce the R-A1 SQL exactly
--           (no value-emptiness conditions) to reconcile drift vs the WO-1 numbers (P3a).
-- Field substitution table (identifiers cannot be bound as parameters; each field is
-- instantiated literally below from this one template):
--   Phone   : value column ci.valuetext    norm = N-P (digits, leading-1 strip)
--   Email   : value column ci.valuetext    norm = N-E (trim, lower)
--   Company : value column ci.valueCompany norm = N-C (ws-collapse, trim, lower)
-- ============================================================================

-- FP-1: fingerprint (run first against each schema; capture in evidence block)
SELECT @@hostname AS hostname, DATABASE() AS db, CURRENT_USER() AS current_user_, NOW() AS now_, VERSION() AS mysql_version;

-- DEN-1: denominators
SELECT COUNT(*) AS active_contacts FROM contactdetails_tbl WHERE IsDeleted = 0;

-- ============================ PHONE =========================================

-- AGG-P1: PC-2 bucket counts + duplicate-normalized flag (canonical mode)
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
       CASE WHEN n = 1 THEN 'one'
            WHEN p = 1 THEN 'multi_one_primary'
            WHEN p = 0 THEN 'multi_zero_primary'
            ELSE 'multi_multi_primary' END AS bucket,
       COUNT(*) AS contacts,
       SUM(n > 1 AND dn = 1) AS dupnorm_all_contacts
FROM pc
GROUP BY bucket
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary');

-- AGG-P2: normalized-empty visibility (contacts whose raw-non-empty Phone items ALL normalize empty)
SELECT 'Phone' AS field, COUNT(*) AS none_usable_contacts FROM (
  SELECT ci.contactID
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Phone'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
  GROUP BY ci.contactID
  HAVING SUM(REGEXP_REPLACE(ci.valuetext, '[^0-9]', '') <> '') = 0
) t;

-- AGG-P3 (R-A1 parity): buckets with NO value-emptiness conditions -- reconciles WO-1 numbers
SELECT 'Phone' AS field, bucket, COUNT(*) AS contacts FROM (
  SELECT ci.contactID,
    CASE WHEN COUNT(*) = 1 THEN 'one'
         WHEN COUNT(*) > 1 AND SUM(ci.primary_YN = 'Y') = 1 THEN 'multi_one_primary'
         WHEN COUNT(*) > 1 AND SUM(ci.primary_YN = 'Y') = 0 THEN 'multi_zero_primary'
         ELSE 'multi_multi_primary' END AS bucket
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Phone' AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
  GROUP BY ci.contactID
) t GROUP BY bucket
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary');

-- ============================ EMAIL =========================================

-- AGG-E1: PC-2 bucket counts + duplicate-normalized flag (canonical mode)
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
       CASE WHEN n = 1 THEN 'one'
            WHEN p = 1 THEN 'multi_one_primary'
            WHEN p = 0 THEN 'multi_zero_primary'
            ELSE 'multi_multi_primary' END AS bucket,
       COUNT(*) AS contacts,
       SUM(n > 1 AND dn = 1) AS dupnorm_all_contacts
FROM pc
GROUP BY bucket
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary');

-- AGG-E2: normalized-empty visibility (Email; N-E never empties a raw-non-empty value,
-- so this is expected 0 -- included for engine symmetry / proof-of-absence)
SELECT 'Email' AS field, COUNT(*) AS none_usable_contacts FROM (
  SELECT ci.contactID
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Email'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valuetext IS NOT NULL AND TRIM(ci.valuetext) <> ''
  GROUP BY ci.contactID
  HAVING SUM(LOWER(REGEXP_REPLACE(ci.valuetext, '^[[:space:]]+|[[:space:]]+$', '')) <> '') = 0
) t;

-- AGG-E3 (R-A1 parity)
SELECT 'Email' AS field, bucket, COUNT(*) AS contacts FROM (
  SELECT ci.contactID,
    CASE WHEN COUNT(*) = 1 THEN 'one'
         WHEN COUNT(*) > 1 AND SUM(ci.primary_YN = 'Y') = 1 THEN 'multi_one_primary'
         WHEN COUNT(*) > 1 AND SUM(ci.primary_YN = 'Y') = 0 THEN 'multi_zero_primary'
         ELSE 'multi_multi_primary' END AS bucket
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Email' AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
  GROUP BY ci.contactID
) t GROUP BY bucket
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary');

-- ============================ COMPANY =======================================

-- AGG-C1: PC-2 bucket counts + duplicate-normalized flag (canonical mode)
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
       CASE WHEN n = 1 THEN 'one'
            WHEN p = 1 THEN 'multi_one_primary'
            WHEN p = 0 THEN 'multi_zero_primary'
            ELSE 'multi_multi_primary' END AS bucket,
       COUNT(*) AS contacts,
       SUM(n > 1 AND dn = 1) AS dupnorm_all_contacts
FROM pc
GROUP BY bucket
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary');

-- AGG-C2: normalized-empty visibility (Company)
SELECT 'Company' AS field, COUNT(*) AS none_usable_contacts FROM (
  SELECT ci.contactID
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Company'
    AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
    AND ci.valueCompany IS NOT NULL AND TRIM(ci.valueCompany) <> ''
  GROUP BY ci.contactID
  HAVING SUM(LOWER(TRIM(REGEXP_REPLACE(ci.valueCompany, '[[:space:]]+', ' '))) <> '') = 0
) t;

-- AGG-C3 (R-A1 parity -- note R-A1 ran with valueCategory='Company' on valueCompany-holding rows;
-- the WO-1 published Company counts came from this shape)
SELECT 'Company' AS field, bucket, COUNT(*) AS contacts FROM (
  SELECT ci.contactID,
    CASE WHEN COUNT(*) = 1 THEN 'one'
         WHEN COUNT(*) > 1 AND SUM(ci.primary_YN = 'Y') = 1 THEN 'multi_one_primary'
         WHEN COUNT(*) > 1 AND SUM(ci.primary_YN = 'Y') = 0 THEN 'multi_zero_primary'
         ELSE 'multi_multi_primary' END AS bucket
  FROM contactitems_tbl ci
  JOIN contactdetails_tbl d ON d.contactID = ci.contactID AND d.IsDeleted = 0
  WHERE ci.valueCategory = 'Company' AND ci.IsDeleted = 0 AND ci.itemStatus = 'Active'
  GROUP BY ci.contactID
) t GROUP BY bucket
ORDER BY FIELD(bucket, 'one', 'multi_one_primary', 'multi_zero_primary', 'multi_multi_primary');

-- ================== OFFICE POPULATION (P3c, spec 7.5 exposure) ==============
-- Prod-relevant; runs on either schema (master tables are a dev seed of prod).

-- OFF-1: office-level population rates
SELECT COUNT(*) AS total_offices,
       SUM(phone IS NOT NULL AND TRIM(phone) <> '') AS offices_with_phone,
       SUM(email IS NOT NULL AND TRIM(email) <> '') AS offices_with_email
FROM co_locations;

-- OFF-2: per-company office coverage, split single-office vs multi-office
SELECT grp, COUNT(*) AS companies,
       SUM(all_phone_blank) AS companies_all_offices_no_phone,
       SUM(all_email_blank) AS companies_all_offices_no_email
FROM (
  SELECT coid,
         CASE WHEN COUNT(*) = 1 THEN 'one_office' ELSE 'multi_office' END AS grp,
         (SUM(phone IS NOT NULL AND TRIM(phone) <> '') = 0) AS all_phone_blank,
         (SUM(email IS NOT NULL AND TRIM(email) <> '') = 0) AS all_email_blank
  FROM co_locations
  GROUP BY coid
) offs
GROUP BY grp;

-- OFF-3: companies with ZERO office rows (blank-master exposure by definition; expect 785)
SELECT COUNT(*) AS companies_zero_offices
FROM companies c
LEFT JOIN co_locations l ON l.coid = c.coid
WHERE l.colocid IS NULL;

-- OFF-4: company-level fallback fields population (companies.coPhone/coEmail exist per WO-1 1.4)
SELECT COUNT(*) AS total_companies,
       SUM(coPhone IS NOT NULL AND TRIM(coPhone) <> '') AS companies_with_coPhone,
       SUM(coEmail IS NOT NULL AND TRIM(coEmail) <> '') AS companies_with_coEmail
FROM companies;

-- END (aggregate engine)
