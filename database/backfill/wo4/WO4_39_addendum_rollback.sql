-- ============================================================================
-- DIR-LNK-WO-4 ADDENDUM -- ROLLBACK (audit-driven restore). new_development.
-- Restores the 64 nulled columns to their captured residue (old_value) from the
-- addendum's own audit rows, and APPENDS reversal audit rows (append-only: audit
-- rows are NEVER deleted or edited, even in rollback -- WO-4 discipline).
-- Operator-executed (HeidiSQL). Set FWD_RUN_ID to the applied forward run_id.
-- ============================================================================
USE new_development;

-- forward run to reverse:
SET @fwd := 'WO4-DEV-ADDENDUM-20260715-01';
-- reversal family (distinct run_id so its own idempotency keys never collide with the forward):
SET @rev := 'WO4-DEV-ADDENDUM-ROLLBACK-20260715-01';

START TRANSACTION;

-- Step 1: restore columns from the forward audit rows' old_value.
UPDATE contactdetails_tbl d
JOIN master_audit_tbl a
  ON a.contactID = d.contactID AND a.run_id = @fwd
 AND a.action_type = 'ADMIN_REPAIR' AND a.field_name = 'contactPhone'
SET d.contactPhone = a.old_value
WHERE d.IsDeleted = 0 AND d.contactPhone IS NULL;

UPDATE contactdetails_tbl d
JOIN master_audit_tbl a
  ON a.contactID = d.contactID AND a.run_id = @fwd
 AND a.action_type = 'ADMIN_REPAIR' AND a.field_name = 'contactEmail'
SET d.contactEmail = a.old_value
WHERE d.IsDeleted = 0 AND d.contactEmail IS NULL;

-- Step 2: append reversal audit rows (old_value=NULL -> new_value=restored residue).
INSERT IGNORE INTO master_audit_tbl
  (contactID, actor_userid, actor_type, action_type, field_name,
   old_value, new_value, run_id, idempotency_key, reason)
SELECT a.contactID, NULL, 'migration', 'ADMIN_REPAIR', a.field_name,
       NULL, a.old_value, @rev,
       CONCAT('ADMIN_REPAIR:', a.field_name, ':', a.contactID, ':', @rev),
       CONCAT('WO-4 addendum ROLLBACK of run_id=', @fwd)
FROM master_audit_tbl a
WHERE a.run_id = @fwd AND a.action_type = 'ADMIN_REPAIR'
  AND a.field_name IN ('contactPhone','contactEmail');

-- Step 3: sanity -- restored columns == forward audit rows. COMMIT only if equal, else ROLLBACK.
SELECT
  (SELECT COUNT(*) FROM master_audit_tbl WHERE run_id=@fwd AND field_name IN ('contactPhone','contactEmail')) AS fwd_rows,
  (SELECT COUNT(*) FROM contactdetails_tbl d JOIN master_audit_tbl a
     ON a.contactID=d.contactID AND a.run_id=@fwd AND a.field_name='contactPhone'
     WHERE d.contactPhone = a.old_value) +
  (SELECT COUNT(*) FROM contactdetails_tbl d JOIN master_audit_tbl a
     ON a.contactID=d.contactID AND a.run_id=@fwd AND a.field_name='contactEmail'
     WHERE d.contactEmail = a.old_value) AS restored_cols;
-- Expected: fwd_rows = restored_cols = 64.
COMMIT;
