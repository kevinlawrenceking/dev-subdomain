-- =============================================================================
-- ROLLBACK for cleanup_myteam_duplicate_contacts.sql
-- Restores (un-archives) every contact the cleanup soft-deleted, using the
-- backup table it created, then drops the backup.
-- =============================================================================

UPDATE contactdetails_tbl
SET    isDeleted = 0
WHERE  contactid IN (SELECT contactid FROM contact_dupe_cleanup_bak);

DROP TABLE IF EXISTS contact_dupe_cleanup_bak;
