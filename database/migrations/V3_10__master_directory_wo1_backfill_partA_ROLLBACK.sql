-- ============================================================================
-- V3_10 ROLLBACK -- WO-1 Backfill Part A
--   Clears the 3 denormalized hot fields back to NULL. Safe/idempotent.
--   Does NOT touch _src (stays 'user') or any master-linkage column (Part B).
--   Does NOT drop the columns themselves -- that is V3_7's rollback.
--
-- ENGINE : MySQL 8.0.41. DATABASE()-scoped. Run USE <schema>; first.
-- ============================================================================

START TRANSACTION;

UPDATE contactdetails_tbl
SET contactPhone   = NULL,
    contactEmail   = NULL,
    contactCompany = NULL
WHERE IsDeleted = 0;

COMMIT;

-- Verify all three are cleared (expect 0 / 0 / 0):
SELECT
  SUM(contactPhone   IS NOT NULL) AS phone_left,
  SUM(contactEmail   IS NOT NULL) AS email_left,
  SUM(contactCompany IS NOT NULL) AS company_left
FROM contactdetails_tbl WHERE IsDeleted = 0;
