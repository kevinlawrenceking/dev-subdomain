-- Ticket 2187 (correction): widen noteDetails so imported/long notes are not truncated.
--
-- The earlier migration V3_5__noteslog_notedetails_to_text.sql ran
--   ALTER TABLE noteslog MODIFY COLUMN noteDetails TEXT;
-- but `noteslog` is a VIEW over the base table `noteslog_tbl` (see rebuild_sharez_view.sql).
-- You cannot widen a column by altering a view, so the base column stayed VARCHAR(2000)
-- and long notes from the contact/relationship importer were still being truncated.
--
-- This migration applies the change to the base table where it actually takes effect.
--
-- Database: new_development (dev), actorsbusinessoffice (prod)
-- Idempotent: re-running MODIFY to the same type is a no-op.

ALTER TABLE noteslog_tbl MODIFY COLUMN noteDetails TEXT NULL;

-- Verify:
-- SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'noteslog_tbl' AND COLUMN_NAME = 'noteDetails';
-- Expected: DATA_TYPE = text
