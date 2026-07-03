-- =============================================================================
-- ROLLBACK for 2026-07-02_contact_not_duplicate.sql
-- Drops the "not a match" dismissal table. User dismissals are lost; the
-- Possible-duplicates list will show every previously dismissed pair again.
-- =============================================================================

DROP TABLE IF EXISTS contact_not_duplicate;
