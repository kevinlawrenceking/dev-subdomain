-- ============================================================================
-- DIR-LNK-WO-4 -- BACKFILL contactEmail (DEV ONLY: new_development)
-- ============================================================================
-- Same design, guards, idempotency, and operator rules as WO4_10 (header there
-- governs). RUN_ID: WO4-DEV-20260714-EM1 (operator sets MMDD before running).
-- RQ-2 does not apply to Email (Phone-only pattern). G-WIDTH bound = 150.
-- ============================================================================

START TRANSACTION;

-- Step 1: audit rows
INSERT IGNORE INTO master_audit_tbl
  (contactID, actor_userid, actor_type, action_type, field_name,
   old_value, new_value, run_id, idempotency_key, reason)
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
SELECT s.contactID, NULL, 'migration', 'BACKFILL_FROM_CONTACTITEM', 'contactEmail',
       NULL, s.new_value, 'WO4-DEV-20260714-EM1',
       CONCAT('BACKFILL:', s.contactID, ':contactEmail'),
       CONCAT('WO-4 dev backfill; sel_case=', s.sel_case, '; source itemID=', s.rep_itemID)
FROM sel s
JOIN contactdetails_tbl d ON d.contactID = s.contactID
WHERE d.IsDeleted = 0
  AND (d.contactEmail IS NULL OR TRIM(d.contactEmail) = '')
  AND d.master_co_contact_id IS NULL          -- G-LNK
  AND CHAR_LENGTH(s.new_value) <= 150;        -- G-WIDTH
  -- AND s.contactID BETWEEN <lo> AND <hi>    -- chunk predicate (only if EX-E > 500)

-- Step 2: paired column writes
UPDATE contactdetails_tbl d
JOIN master_audit_tbl a
  ON a.contactID = d.contactID
 AND a.run_id = 'WO4-DEV-20260714-EM1'
 AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
 AND a.field_name = 'contactEmail'
SET d.contactEmail = a.new_value
WHERE d.IsDeleted = 0
  AND (d.contactEmail IS NULL OR TRIM(d.contactEmail) = '');

-- Step 3: in-transaction sanity -- MUST be equal before COMMIT
SELECT
  (SELECT COUNT(*) FROM master_audit_tbl
    WHERE run_id = 'WO4-DEV-20260714-EM1'
      AND action_type = 'BACKFILL_FROM_CONTACTITEM' AND field_name = 'contactEmail') AS audit_rows_this_run,
  (SELECT COUNT(*) FROM contactdetails_tbl d
    JOIN master_audit_tbl a ON a.contactID = d.contactID
     AND a.run_id = 'WO4-DEV-20260714-EM1' AND a.field_name = 'contactEmail'
    WHERE d.contactEmail = a.new_value) AS columns_matching_audit;

-- Operator: COMMIT only if equal and matching EX-E. Otherwise ROLLBACK + report.
COMMIT;
