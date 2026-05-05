-- ============================================================================
-- TAO-DT-SANDBOX rollback
--
-- Reverse FK order: pgpagespluginsxref -> pgpages_tbl -> pgcomps_tbl.
-- Idempotent: re-running after a partial state succeeds with zero rows affected.
-- ============================================================================

START TRANSACTION;

DELETE FROM pgpagespluginsxref
WHERE pgid IN (
    SELECT pgID FROM pgpages_tbl WHERE pgDir = 'admin-datatables-reference'
);

DELETE FROM pgpages_tbl
WHERE pgDir = 'admin-datatables-reference';

DELETE FROM pgcomps_tbl
WHERE compDir = 'admin-datatables-reference';

COMMIT;

-- After running this, also remove from the filesystem:
--   /app/admin-datatables-reference/  (directory)
--   /include/admin-datatables-reference.cfm
