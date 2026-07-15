-- ============================================================================
-- DIR-LNK-WO-4 ADDENDUM -- V3_10 EXCEPTION-CLASS RESIDUE CLEANUP (DEV: new_development)
-- ============================================================================
-- Authority : WO-5 P1 bucket-(b) finding + Kevin's §4 ruling OPTION 2 (2026-07-15).
--             Ratification relay committed with DIR-LNK-WO5-PLANLOCK v-final.
-- AUTHORIZES: UPDATE contactdetails_tbl.contactPhone/contactEmail (residue -> NULL)
--             + paired INSERT into master_audit_tbl. NOTHING ELSE. Zero DDL, zero
--             contactitems writes, _src NOT touched (stays 'user'; a NULL value has
--             no source to mark).
-- WHY       : These 64 columns hold V3_10 Part A residue (2026-07-07, pre-ratified-
--             engine) for exception-class contacts (multi_zero / multi_multi primary,
--             values genuinely differ). The ratified WO-4 engine EXCLUDES this class
--             (leaves blank); prod WO-12 will therefore show blank. Nulling dev makes
--             dev a faithful WO-12 preview and removes the 64 display-divergences that
--             the WO-5 read cutover would otherwise surface. Proven: 0/64 carry a WO-4
--             BACKFILL audit row (WO-4 was conformant; the residue predates it).
-- SCOPE     : EXACTLY the 64 enumerated contacts -- 4 phone + 60 email (contacts
--             131445 and 132182 appear in BOTH -> two field-clears each). 64 audit
--             rows, 64 column-nulls, 62 distinct contacts.
-- RUN_ID    : WO4-DEV-ADDENDUM-20260715-01  <- executor: set MMDD to the actual apply
--             date BEFORE running; bump -02 for a re-apply under a fresh idempotency
--             family. contactitems is NEVER touched here (RQ-5i retirement is separate).
-- DESIGN    : audit-driven pairing, same shape as WO4_10..12 (reverse direction).
--             Step 1 INSERT IGNOREs one audit row per planned NULL, capturing the live
--             residue as old_value (value-level detail lives in the audit TABLE, not in
--             this script -- WO-4 P1e). W-1 key = CONCAT(action,':',field,':',contactID,
--             ':',run_id): same-run retry collides (skipped); re-apply under a NEW run_id
--             inserts cleanly. Step 2 nulls ONLY by join to THIS run's audit rows. Both
--             steps share one transaction. Re-run verbatim after COMMIT = 0 inserts +
--             0 updates (columns already NULL). Run WO4_31 pre-flight FIRST.
-- CHANNEL   : Operator-executed (HeidiSQL). CC does NOT execute -- the D-3 DML exception
--             EXPIRED with F-11 and does not renew for this addendum.
-- ORDER     : run this BEFORE WO5_01_views_dev.sql (cleanup precedes read cutover).
-- ============================================================================
USE new_development;

START TRANSACTION;

-- Step 1a: PHONE audit rows (4). old_value = live residue; new_value = NULL.
INSERT IGNORE INTO master_audit_tbl
  (contactID, actor_userid, actor_type, action_type, field_name,
   old_value, new_value, run_id, idempotency_key, reason)
SELECT d.contactID, NULL, 'migration', 'ADMIN_REPAIR', 'contactPhone',
       d.contactPhone, NULL, 'WO4-DEV-ADDENDUM-20260715-01',
       CONCAT('ADMIN_REPAIR:contactPhone:', d.contactID, ':WO4-DEV-ADDENDUM-20260715-01'),
       'WO-4 addendum: V3_10 exception-class residue cleanup per WO-5 P1 bucket-(b)'
FROM contactdetails_tbl d
WHERE d.IsDeleted = 0
  AND d.contactID IN (130653,131239,131445,132182)
  AND d.contactPhone IS NOT NULL AND TRIM(d.contactPhone) <> '';

-- Step 1b: EMAIL audit rows (60).
INSERT IGNORE INTO master_audit_tbl
  (contactID, actor_userid, actor_type, action_type, field_name,
   old_value, new_value, run_id, idempotency_key, reason)
SELECT d.contactID, NULL, 'migration', 'ADMIN_REPAIR', 'contactEmail',
       d.contactEmail, NULL, 'WO4-DEV-ADDENDUM-20260715-01',
       CONCAT('ADMIN_REPAIR:contactEmail:', d.contactID, ':WO4-DEV-ADDENDUM-20260715-01'),
       'WO-4 addendum: V3_10 exception-class residue cleanup per WO-5 P1 bucket-(b)'
FROM contactdetails_tbl d
WHERE d.IsDeleted = 0
  AND d.contactID IN (130647,130648,130650,130661,130934,130954,130955,130963,131047,131052,
                      131089,131221,131249,131250,131252,131300,131445,131664,131665,131666,
                      131667,131668,131669,131670,131671,131672,131673,131674,131675,132163,
                      132166,132168,132173,132176,132177,132178,132179,132182,132194,132196,
                      132197,132239,132243,132245,132248,132249,132251,132253,132254,132255,
                      132256,132258,132259,132263,132264,132267,132269,132270,132271,132313)
  AND d.contactEmail IS NOT NULL AND TRIM(d.contactEmail) <> '';

-- Step 2a: PHONE null writes, driven strictly by THIS run's audit rows.
UPDATE contactdetails_tbl d
JOIN master_audit_tbl a
  ON a.contactID = d.contactID
 AND a.run_id = 'WO4-DEV-ADDENDUM-20260715-01'
 AND a.action_type = 'ADMIN_REPAIR'
 AND a.field_name = 'contactPhone'
SET d.contactPhone = NULL
WHERE d.IsDeleted = 0 AND d.contactPhone IS NOT NULL;

-- Step 2b: EMAIL null writes.
UPDATE contactdetails_tbl d
JOIN master_audit_tbl a
  ON a.contactID = d.contactID
 AND a.run_id = 'WO4-DEV-ADDENDUM-20260715-01'
 AND a.action_type = 'ADMIN_REPAIR'
 AND a.field_name = 'contactEmail'
SET d.contactEmail = NULL
WHERE d.IsDeleted = 0 AND d.contactEmail IS NOT NULL;

-- Step 3: in-transaction sanity gate -- audit rows == columns nulled, per field.
-- COMMIT ONLY if audit_phone=nulled_phone=4 AND audit_email=nulled_email=60. Else ROLLBACK.
SELECT
  (SELECT COUNT(*) FROM master_audit_tbl
     WHERE run_id='WO4-DEV-ADDENDUM-20260715-01' AND field_name='contactPhone') AS audit_phone,
  (SELECT COUNT(*) FROM contactdetails_tbl d
     JOIN master_audit_tbl a ON a.contactID=d.contactID
      AND a.run_id='WO4-DEV-ADDENDUM-20260715-01' AND a.field_name='contactPhone'
     WHERE d.contactPhone IS NULL) AS nulled_phone,
  (SELECT COUNT(*) FROM master_audit_tbl
     WHERE run_id='WO4-DEV-ADDENDUM-20260715-01' AND field_name='contactEmail') AS audit_email,
  (SELECT COUNT(*) FROM contactdetails_tbl d
     JOIN master_audit_tbl a ON a.contactID=d.contactID
      AND a.run_id='WO4-DEV-ADDENDUM-20260715-01' AND a.field_name='contactEmail'
     WHERE d.contactEmail IS NULL) AS nulled_email;

-- Operator: COMMIT only if the four counts are 4 / 4 / 60 / 60. Otherwise ROLLBACK and report verbatim.
COMMIT;
