-- ============================================================================
-- DIR-LNK-WO-4 -- AUDIT-DRIVEN ROLLBACK BY RUN_ID (DEV ONLY: new_development)
-- ============================================================================
-- Lock   : docs/plans/DIR-LNK-WO4-PLANLOCK.md P1d. Operator-executed, named-auth
--          gated like every WO-4 apply step.
-- Usage  : replace every occurrence of the token  @@RUN_ID@@  with ONE forward
--          run_id (e.g. WO4-DEV-20260714-PH1), then run Stage 1; run Stage 2
--          only after reviewing Stage 1 output. One run_id per execution.
-- Design : reverses ONLY columns still holding the audited new_value
--          (match-guard). Columns edited since backfill are SKIPPED and
--          reported -- rollback never overwrites later user data.
--          The reversal itself INSERTS audit rows (action_type='ADMIN_REPAIR',
--          run_id='@@RUN_ID@@-RB'). AUDIT ROWS ARE NEVER DELETED OR EDITED --
--          append-only holds even in rollback. Re-running the rollback is
--          idempotent: the ROLLBACK:* idempotency keys collide (INSERT IGNORE)
--          and the match-guard finds no still-matching columns.
-- All three field pairs are included; the pairs not matching the run_id's
-- field_name simply affect zero rows.
-- ============================================================================

-- ---------------- STAGE 1 -- PRECHECK (ZERO DML) ----------------------------
SELECT @@hostname AS hostname, DATABASE() AS db, CURRENT_USER() AS current_user_, NOW() AS now_;

SELECT a.field_name,
       COUNT(*) AS audit_rows_for_run,
       SUM(CASE a.field_name
             WHEN 'contactPhone'   THEN (d.contactPhone   = a.new_value)
             WHEN 'contactEmail'   THEN (d.contactEmail   = a.new_value)
             WHEN 'contactCompany' THEN (d.contactCompany = a.new_value)
           END) AS reversible_still_matching,
       SUM(CASE a.field_name
             WHEN 'contactPhone'   THEN (d.contactPhone   <> a.new_value)
             WHEN 'contactEmail'   THEN (d.contactEmail   <> a.new_value)
             WHEN 'contactCompany' THEN (d.contactCompany <> a.new_value)
           END) AS diverged_will_skip
FROM master_audit_tbl a
JOIN contactdetails_tbl d ON d.contactID = a.contactID
WHERE a.run_id = '@@RUN_ID@@' AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
GROUP BY a.field_name;

-- STOP. Review: diverged_will_skip rows are reported unresolved, never touched.
-- Proceed to Stage 2 only under the rollback decision.

-- ---------------- STAGE 2 -- REVERSAL (transactional) -----------------------
START TRANSACTION;

-- 2a: reversal audit rows (append-only record of the repair)
INSERT IGNORE INTO master_audit_tbl
  (contactID, actor_userid, actor_type, action_type, field_name,
   old_value, new_value, run_id, idempotency_key, reason)
SELECT a.contactID, NULL, 'migration', 'ADMIN_REPAIR', a.field_name,
       a.new_value, NULL, CONCAT('@@RUN_ID@@', '-RB'),
       CONCAT('ROLLBACK:', a.run_id, ':', a.contactID, ':', a.field_name),
       CONCAT('WO-4 rollback run_id=', a.run_id)
FROM master_audit_tbl a
JOIN contactdetails_tbl d ON d.contactID = a.contactID
WHERE a.run_id = '@@RUN_ID@@' AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
  AND CASE a.field_name
        WHEN 'contactPhone'   THEN (d.contactPhone   = a.new_value)
        WHEN 'contactEmail'   THEN (d.contactEmail   = a.new_value)
        WHEN 'contactCompany' THEN (d.contactCompany = a.new_value)
      END;                                          -- match-guard

-- 2b: column reversal, per field pair (non-matching field pairs affect 0 rows)
UPDATE contactdetails_tbl d
JOIN master_audit_tbl a ON a.contactID = d.contactID
 AND a.run_id = '@@RUN_ID@@' AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
 AND a.field_name = 'contactPhone'
SET d.contactPhone = a.old_value
WHERE d.contactPhone = a.new_value;                 -- match-guard

UPDATE contactdetails_tbl d
JOIN master_audit_tbl a ON a.contactID = d.contactID
 AND a.run_id = '@@RUN_ID@@' AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
 AND a.field_name = 'contactEmail'
SET d.contactEmail = a.old_value
WHERE d.contactEmail = a.new_value;

UPDATE contactdetails_tbl d
JOIN master_audit_tbl a ON a.contactID = d.contactID
 AND a.run_id = '@@RUN_ID@@' AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
 AND a.field_name = 'contactCompany'
SET d.contactCompany = a.old_value
WHERE d.contactCompany = a.new_value;

-- NOTE: old_value is NULL for every WO-4 forward row (DG-1-style empty
-- destinations; forward scripts write old_value NULL by design). Columns that
-- were '' (empty string) before backfill are restored to NULL -- equivalent
-- under the canonical predicate; documented, accepted.

-- 2c: in-transaction sanity -- reversal audit rows == columns reverted
SELECT
  (SELECT COUNT(*) FROM master_audit_tbl
    WHERE run_id = CONCAT('@@RUN_ID@@', '-RB') AND action_type = 'ADMIN_REPAIR') AS reversal_audit_rows,
  (SELECT COUNT(*) FROM master_audit_tbl a
    JOIN contactdetails_tbl d ON d.contactID = a.contactID
    WHERE a.run_id = '@@RUN_ID@@' AND a.action_type = 'BACKFILL_FROM_CONTACTITEM'
      AND CASE a.field_name
            WHEN 'contactPhone'   THEN (d.contactPhone   IS NULL OR TRIM(d.contactPhone)   = '')
            WHEN 'contactEmail'   THEN (d.contactEmail   IS NULL OR TRIM(d.contactEmail)   = '')
            WHEN 'contactCompany' THEN (d.contactCompany IS NULL OR TRIM(d.contactCompany) = '')
          END) AS columns_now_empty;

-- Operator: COMMIT only if reversal_audit_rows equals Stage 1's
-- reversible_still_matching total (columns_now_empty may exceed it only by
-- rows that were already empty for other reasons -- investigate any delta).
COMMIT;
