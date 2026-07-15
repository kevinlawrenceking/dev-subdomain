-- ============================================================================
-- DIR-LNK-WO-4 -- BACKFILL contactPhone (DEV ONLY: new_development)
-- ============================================================================
-- Lock      : docs/plans/DIR-LNK-WO4-PLANLOCK.md. Operator-executed (HeidiSQL).
-- AUTHORIZES: UPDATE contactdetails_tbl.contactPhone (empty -> item value) +
--             paired INSERT into master_audit_tbl. NOTHING ELSE. Zero DDL,
--             zero contactitems writes, _src not written (stays default 'user').
-- RUN_ID    : WO4-DEV-FIXTURE-20260714-PH1  <- executor: set MMDD to the actual
--             apply date BEFORE running; keep the -PH1 suffix (bump -PH2 for the
--             protocol run 2 / a second chunk). WO-12 prod execution references
--             this script by commit SHA and sets its own WO12-class run_id.
-- DESIGN    : audit-driven pairing. Step 1 INSERTs one audit row per planned
--             column write. W-1 (architect errata + supplement): idempotency_key
--             = CONCAT('BACKFILL:', field_name, ':', contactID, ':', run_id) --
--             unique per column, per contact, PER RUN. Same-run retry collides
--             on UQ_master_audit_idem (INSERT IGNORE -> skipped); post-rollback
--             re-application under a NEW run_id inserts cleanly (the W-1
--             deadlock fix); cross-run double-write is prevented by the
--             empty-destination selection + the Step-2 re-assertion (W-2).
--             Step 2 UPDATEs ONLY by join to THIS run_id's audit rows. Both
--             statements share one transaction: a failed chunk rolls back BOTH.
--             Re-run of the whole script verbatim = zero inserts + zero updates.
-- RAW-REPRESENTATIVE RULE (RQ-1, stamped with the lock): written display form =
--             TRIM(raw) of (i) the single primary_YN='Y' row when exactly one
--             exists, else (ii) the LOWEST itemID among the value-identical
--             candidates. (ii) is a deterministic PRESENTATION tiebreak only --
--             value equivalence is proven by normalization first; this is not a
--             value-selection heuristic.
-- GUARDS    : G-LNK linked contacts excluded; G-WIDTH raw > varchar(100) excluded.
--             Both counted in WO4_00 expectation set; excluded rows are reported,
--             never written.
-- CHUNKING  : dev expected volume is far under the 500/transaction lock limit
--             (WO4_00 proves it live). If EX-P ever exceeds 500, uncomment the
--             chunk predicate in step 1 and run successive -PH<n> run_ids.
-- ============================================================================

START TRANSACTION;

-- Step 1: audit rows (the plan of record for this chunk)
INSERT IGNORE INTO master_audit_tbl
  (contactID, actor_userid, actor_type, action_type, field_name,
   old_value, new_value, run_id, idempotency_key, reason)
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
SELECT s.contactID, NULL, 'migration', 'BACKFILL_FROM_CONTACTITEM', 'contactPhone',
       NULL, s.new_value, 'WO4-DEV-FIXTURE-20260714-PH1',
       CONCAT('BACKFILL:contactPhone:', s.contactID, ':WO4-DEV-FIXTURE-20260714-PH1'),
       CONCAT('WO-4 dev backfill, sel_case=', s.sel_case, ', source itemID=', s.rep_itemID)
FROM sel s
JOIN contactdetails_tbl d ON d.contactID = s.contactID
WHERE d.IsDeleted = 0
  AND (d.contactPhone IS NULL OR TRIM(d.contactPhone) = '')
  AND d.master_co_contact_id IS NULL          -- G-LNK
  AND CHAR_LENGTH(s.new_value) <= 100;        -- G-WIDTH
  -- AND s.contactID BETWEEN <lo> AND <hi>    -- chunk predicate (only if EX-P > 500)

-- Step 2: the paired column writes, driven strictly by this run's audit rows
UPDATE contactdetails_tbl d
JOIN master_audit_tbl a
  ON a.contactID = d.contactID
 AND a.run_id = 'WO4-DEV-FIXTURE-20260714-PH1'
 AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
 AND a.field_name = 'contactPhone'
SET d.contactPhone = a.new_value
WHERE d.IsDeleted = 0
  AND (d.contactPhone IS NULL OR TRIM(d.contactPhone) = '');

-- Step 3: in-transaction sanity -- the two counts MUST be equal before COMMIT
SELECT
  (SELECT COUNT(*) FROM master_audit_tbl
    WHERE run_id = 'WO4-DEV-FIXTURE-20260714-PH1'
      AND action_type = 'BACKFILL_FROM_CONTACTITEM' AND field_name = 'contactPhone') AS audit_rows_this_run,
  (SELECT COUNT(*) FROM contactdetails_tbl d
    JOIN master_audit_tbl a ON a.contactID = d.contactID
     AND a.run_id = 'WO4-DEV-FIXTURE-20260714-PH1' AND a.field_name = 'contactPhone'
    WHERE d.contactPhone = a.new_value) AS columns_matching_audit;

-- Operator: COMMIT only if the two numbers above are EQUAL and match EX-P's
-- expected_writes total. Otherwise ROLLBACK and report verbatim.
COMMIT;
