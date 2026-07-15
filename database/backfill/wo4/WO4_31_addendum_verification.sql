-- ============================================================================
-- DIR-LNK-WO-4 ADDENDUM -- VERIFICATION (read-only). new_development.
-- Run BLOCK A before WO4_30 (drift guard); BLOCK B/C after COMMIT (proof).
-- ============================================================================
USE new_development;

-- ---- BLOCK A: PRE-FLIGHT DRIFT GUARD (run BEFORE WO4_30) ----------------------
-- Expected: phone_residue = 4, email_residue = 60 (the enumerated P1 set, still present).
-- If either differs, the data drifted since P1 (2026-07-15). STOP -- do not apply WO4_30.
SELECT
  (SELECT COUNT(*) FROM contactdetails_tbl
     WHERE IsDeleted=0 AND contactPhone IS NOT NULL AND TRIM(contactPhone)<>''
       AND contactID IN (130653,131239,131445,132182)) AS phone_residue,
  (SELECT COUNT(*) FROM contactdetails_tbl
     WHERE IsDeleted=0 AND contactEmail IS NOT NULL AND TRIM(contactEmail)<>''
       AND contactID IN (130647,130648,130650,130661,130934,130954,130955,130963,131047,131052,
                         131089,131221,131249,131250,131252,131300,131445,131664,131665,131666,
                         131667,131668,131669,131670,131671,131672,131673,131674,131675,132163,
                         132166,132168,132173,132176,132177,132178,132179,132182,132194,132196,
                         132197,132239,132243,132245,132248,132249,132251,132253,132254,132255,
                         132256,132258,132259,132263,132264,132267,132269,132270,132271,132313)) AS email_residue;

-- ---- BLOCK B: POST-APPLY STATE (run AFTER COMMIT) ----------------------------
-- Expected: residue_remaining_phone=0, residue_remaining_email=0, addendum_audit_rows=64.
SELECT
  (SELECT COUNT(*) FROM contactdetails_tbl
     WHERE IsDeleted=0 AND contactPhone IS NOT NULL AND TRIM(contactPhone)<>''
       AND contactID IN (130653,131239,131445,132182)) AS residue_remaining_phone,
  (SELECT COUNT(*) FROM contactdetails_tbl
     WHERE IsDeleted=0 AND contactEmail IS NOT NULL AND TRIM(contactEmail)<>''
       AND contactID IN (130647,130648,130650,130661,130934,130954,130955,130963,131047,131052,
                         131089,131221,131249,131250,131252,131300,131445,131664,131665,131666,
                         131667,131668,131669,131670,131671,131672,131673,131674,131675,132163,
                         132166,132168,132173,132176,132177,132178,132179,132182,132194,132196,
                         132197,132239,132243,132245,132248,132249,132251,132253,132254,132255,
                         132256,132258,132259,132263,132264,132267,132269,132270,132271,132313)) AS residue_remaining_email,
  (SELECT COUNT(*) FROM master_audit_tbl
     WHERE run_id='WO4-DEV-ADDENDUM-20260715-01' AND action_type='ADMIN_REPAIR') AS addendum_audit_rows;

-- ---- BLOCK C: POST-CUTOVER DELTA RE-MEASURE (run AFTER COMMIT; proves P4 expectation) --
-- Mirrors the WO-5 P1 delta buckets. Expected post-addendum: changes_val=0 for BOTH fields;
-- goes_blank = 4 (phone) and 60 (email) -- the intended cleanup outcome (value -> blank at cutover).
SELECT 'Phone' AS field,
  SUM((sub IS NOT NULL AND sub<>'')) AS shows_now_subquery,
  SUM((col IS NOT NULL AND TRIM(col)<>'')) AS shows_after_column,
  SUM((col IS NULL OR TRIM(col)='') AND (sub IS NOT NULL AND sub<>'')) AS goes_blank,
  SUM((col IS NOT NULL AND TRIM(col)<>'') AND (sub IS NOT NULL AND sub<>'') AND col<>sub) AS changes_val
FROM (SELECT d.contactPhone AS col,
        (SELECT valueText FROM contactitems WHERE valueCategory='Phone' AND contactID=d.contactID
           AND itemStatus='Active' ORDER BY primary_YN DESC LIMIT 1) AS sub
      FROM contactdetails d WHERE d.contactStatus='Active') t
UNION ALL
SELECT 'Email',
  SUM((sub IS NOT NULL AND sub<>'')),
  SUM((col IS NOT NULL AND TRIM(col)<>'')),
  SUM((col IS NULL OR TRIM(col)='') AND (sub IS NOT NULL AND sub<>'')),
  SUM((col IS NOT NULL AND TRIM(col)<>'') AND (sub IS NOT NULL AND sub<>'') AND col<>sub)
FROM (SELECT d.contactEmail AS col,
        (SELECT valueText FROM contactitems WHERE valueCategory='Email' AND contactID=d.contactID
           AND itemStatus='Active' ORDER BY primary_YN DESC LIMIT 1) AS sub
      FROM contactdetails d WHERE d.contactStatus='Active') t;
