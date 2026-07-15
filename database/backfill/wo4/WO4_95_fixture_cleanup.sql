-- ============================================================================
-- DIR-LNK-WO-4 -- FIXTURE CLEANUP (DEV ONLY) -- HELD; run LAST (protocol e/g)
-- ============================================================================
-- Cleanup = SOFT-DELETE (IsDeleted=1) on fixture contacts + their items.
-- Fixture IDs remain registered permanently; fixture BACKFILL/ADMIN_REPAIR
-- audit rows are permanent test history (protocol f) -- NEVER deleted.
-- This script writes ZERO audit rows (protocol f).
-- Predicate = userID 30 + the ZZWO4FIXTURE name prefix; the affected-row counts
-- MUST match the committed register (8 contacts / 13 items) -- mismatch =
-- ROLLBACK + STOP.
-- ============================================================================

START TRANSACTION;

-- Precheck: what will be touched (compare against the committed register)
SELECT
  (SELECT COUNT(*) FROM contactdetails_tbl WHERE userID = 30 AND contactFullName LIKE 'ZZWO4FIXTURE%' AND IsDeleted = 0) AS contacts_to_softdelete,
  (SELECT COUNT(*) FROM contactitems_tbl ci JOIN contactdetails_tbl d ON d.contactID = ci.contactID
    WHERE d.userID = 30 AND d.contactFullName LIKE 'ZZWO4FIXTURE%' AND ci.IsDeleted = 0) AS items_to_softdelete;

UPDATE contactitems_tbl ci
JOIN contactdetails_tbl d ON d.contactID = ci.contactID
SET ci.IsDeleted = 1
WHERE d.userID = 30 AND d.contactFullName LIKE 'ZZWO4FIXTURE%' AND ci.IsDeleted = 0;

UPDATE contactdetails_tbl
SET IsDeleted = 1
WHERE userID = 30 AND contactFullName LIKE 'ZZWO4FIXTURE%' AND IsDeleted = 0;

-- Sanity: zero live fixture rows remain
SELECT
  (SELECT COUNT(*) FROM contactdetails_tbl WHERE userID = 30 AND contactFullName LIKE 'ZZWO4FIXTURE%' AND IsDeleted = 0) AS live_fixture_contacts_expect_0,
  (SELECT COUNT(*) FROM contactitems_tbl ci JOIN contactdetails_tbl d ON d.contactID = ci.contactID
    WHERE d.userID = 30 AND d.contactFullName LIKE 'ZZWO4FIXTURE%' AND ci.IsDeleted = 0) AS live_fixture_items_expect_0;

-- Operator: COMMIT only if precheck matched the register and sanity shows 0/0.
COMMIT;
