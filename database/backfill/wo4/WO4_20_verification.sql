-- ============================================================================
-- DIR-LNK-WO-4 -- POST-RUN VERIFICATION (READ-ONLY; run after all three fields)
-- ============================================================================
-- Zero DML. Compare every number against the WO4_00 expectation-set capture.
-- Operator: replace the three run_id literals if the apply date changed them.
-- ============================================================================

SELECT @@hostname AS hostname, DATABASE() AS db, CURRENT_USER() AS current_user_, NOW() AS now_, VERSION() AS mysql_version;

-- V-1: populated-column AFTER counts (delta vs EX-0 must equal audit rows per field)
SELECT
  SUM(contactPhone   IS NOT NULL AND TRIM(contactPhone)   <> '') AS phone_populated_after,
  SUM(contactEmail   IS NOT NULL AND TRIM(contactEmail)   <> '') AS email_populated_after,
  SUM(contactCompany IS NOT NULL AND TRIM(contactCompany) <> '') AS company_populated_after,
  COUNT(*) AS active_contacts
FROM contactdetails_tbl WHERE IsDeleted = 0;

-- V-2: audit-row count == populated-column count, EXACTLY, per run
SELECT a.run_id, a.field_name, COUNT(*) AS audit_rows,
       SUM(CASE a.field_name
             WHEN 'contactPhone'   THEN (d.contactPhone   = a.new_value)
             WHEN 'contactEmail'   THEN (d.contactEmail   = a.new_value)
             WHEN 'contactCompany' THEN (d.contactCompany = a.new_value)
           END) AS columns_holding_audited_value
FROM master_audit_tbl a
JOIN contactdetails_tbl d ON d.contactID = a.contactID
WHERE a.action_type = 'BACKFILL_FROM_CONTACTITEM'
  AND a.run_id IN ('WO4-DEV-20260714-PH1','WO4-DEV-20260714-EM1','WO4-DEV-20260714-CO1')
GROUP BY a.run_id, a.field_name;

-- V-3: _src untouched proof -- every backfilled contact still has _src='user'
SELECT a.field_name,
       SUM(CASE a.field_name
             WHEN 'contactPhone'   THEN (d.contactPhone_src   = 'user')
             WHEN 'contactEmail'   THEN (d.contactEmail_src   = 'user')
             WHEN 'contactCompany' THEN (d.contactCompany_src = 'user')
           END) AS src_user_count,
       COUNT(*) AS audit_rows
FROM master_audit_tbl a
JOIN contactdetails_tbl d ON d.contactID = a.contactID
WHERE a.action_type = 'BACKFILL_FROM_CONTACTITEM'
  AND a.run_id IN ('WO4-DEV-20260714-PH1','WO4-DEV-20260714-EM1','WO4-DEV-20260714-CO1')
GROUP BY a.field_name;

-- V-4: contactitems untouched proof (compare to EX-0b baseline; all three equal)
SELECT COUNT(*) AS items_total, SUM(IsDeleted = 1) AS items_deleted, MAX(itemID) AS max_itemID
FROM contactitems_tbl;

-- V-5: exception-queue untouched proof
-- Re-run AGG-P1/E1/C1 from 2026-07-14-dir-lnk-wo3-engine-aggregate.sql:
-- multi_zero_primary and multi_multi_primary counts must equal the EX-X capture.
-- (one/multi_one_primary counts DROP by design -- their columns are now populated,
-- but bucket classification is item-based so they in fact stay constant too:
-- record both and explain any delta.)

-- V-6: idempotent re-run proof (operator step, not a query):
-- re-execute WO4_10/11/12 verbatim. Expected: Step 1 -> 0 rows inserted
-- (idempotency_key collisions, INSERT IGNORE), Step 2 -> 0 rows updated
-- (no empty destination remains for this selection), Step 3 counts unchanged.
-- Capture the statement outputs verbatim for the P3 bundle.

-- V-7: G-LNK proof -- no linked contact received a backfill audit row
SELECT COUNT(*) AS linked_contacts_backfilled_must_be_zero
FROM master_audit_tbl a
JOIN contactdetails_tbl d ON d.contactID = a.contactID
WHERE a.action_type = 'BACKFILL_FROM_CONTACTITEM'
  AND a.run_id IN ('WO4-DEV-20260714-PH1','WO4-DEV-20260714-EM1','WO4-DEV-20260714-CO1')
  AND d.master_co_contact_id IS NOT NULL;
