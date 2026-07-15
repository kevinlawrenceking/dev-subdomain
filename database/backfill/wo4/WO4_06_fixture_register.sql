-- ============================================================================
-- DIR-LNK-WO-4 -- FIXTURE REGISTER (READ-ONLY; run immediately after WO4_05)
-- ============================================================================
-- Protocol (a): the output of this file IS the fixture register. Commit it to
-- docs/plans/evidence/ BEFORE any backfill script executes. Every subsequent
-- audit row's contactID must appear here (G-REG, WO4_20 V-8).
-- ============================================================================

SELECT @@hostname AS hostname, DATABASE() AS db, CURRENT_USER() AS current_user_, NOW() AS now_;

SELECT d.contactID, d.contactFullName, d.master_co_contact_id,
       ci.itemID, ci.valueCategory, ci.valueType, ci.primary_YN
FROM contactdetails_tbl d
LEFT JOIN contactitems_tbl ci ON ci.contactID = d.contactID AND ci.IsDeleted = 0
WHERE d.userID = 30 AND d.contactFullName LIKE 'ZZWO4FIXTURE%' AND d.IsDeleted = 0
ORDER BY d.contactID, ci.itemID;
