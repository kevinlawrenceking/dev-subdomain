-- ============================================================================
-- DIR-LNK-WO-4 -- BACKFILL contactCompany (DEV ONLY: new_development)
-- ============================================================================
-- Same design, guards, idempotency, and operator rules as WO4_10 (header there
-- governs, incl. the W-1 key format). RUN_ID: WO4-DEV-FIXTURE-20260714-CO1
-- (executor sets MMDD before running; -CO2 for the protocol run 2).
-- RQ-2 does not apply to Company. G-WIDTH structurally impossible (varchar(255)
-- source -> varchar(255) destination). G-LNK still applies -- and on dev it is
-- the guard that keeps contact 132419's master-managed snapshot untouched
-- (its column is populated anyway, but the guard is belt-and-suspenders).
-- D-5 NOTE: Company rows whose text lives in valuetext (empty valueCompany)
-- are NOT candidates (25 dev contacts, sized in WO-3) -- their columns stay
-- empty and they surface in the exception/data-quality report, per PC-2.
-- ============================================================================

START TRANSACTION;

-- Step 1: audit rows
INSERT IGNORE INTO master_audit_tbl
  (contactID, actor_userid, actor_type, action_type, field_name,
   old_value, new_value, run_id, idempotency_key, reason)
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
SELECT s.contactID, NULL, 'migration', 'BACKFILL_FROM_CONTACTITEM', 'contactCompany',
       NULL, s.new_value, 'WO4-DEV-FIXTURE-20260714-CO1',
       CONCAT('BACKFILL:contactCompany:', s.contactID, ':WO4-DEV-FIXTURE-20260714-CO1'),
       CONCAT('WO-4 dev backfill; sel_case=', s.sel_case, '; source itemID=', s.rep_itemID)
FROM sel s
JOIN contactdetails_tbl d ON d.contactID = s.contactID
WHERE d.IsDeleted = 0
  AND (d.contactCompany IS NULL OR TRIM(d.contactCompany) = '')
  AND d.master_co_contact_id IS NULL;         -- G-LNK
  -- AND s.contactID BETWEEN <lo> AND <hi>    -- chunk predicate (only if EX-C > 500)

-- Step 2: paired column writes
UPDATE contactdetails_tbl d
JOIN master_audit_tbl a
  ON a.contactID = d.contactID
 AND a.run_id = 'WO4-DEV-FIXTURE-20260714-CO1'
 AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
 AND a.field_name = 'contactCompany'
SET d.contactCompany = a.new_value
WHERE d.IsDeleted = 0
  AND (d.contactCompany IS NULL OR TRIM(d.contactCompany) = '');

-- Step 3: in-transaction sanity -- MUST be equal before COMMIT
SELECT
  (SELECT COUNT(*) FROM master_audit_tbl
    WHERE run_id = 'WO4-DEV-FIXTURE-20260714-CO1'
      AND action_type = 'BACKFILL_FROM_CONTACTITEM' AND field_name = 'contactCompany') AS audit_rows_this_run,
  (SELECT COUNT(*) FROM contactdetails_tbl d
    JOIN master_audit_tbl a ON a.contactID = d.contactID
     AND a.run_id = 'WO4-DEV-FIXTURE-20260714-CO1' AND a.field_name = 'contactCompany'
    WHERE d.contactCompany = a.new_value) AS columns_matching_audit;

-- Operator: COMMIT only if equal and matching EX-C. Otherwise ROLLBACK + report.
COMMIT;
