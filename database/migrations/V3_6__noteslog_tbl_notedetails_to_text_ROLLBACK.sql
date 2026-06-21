-- Rollback for V3_6__noteslog_tbl_notedetails_to_text.sql
-- WARNING: reverting to VARCHAR(2000) will truncate any existing notes longer than 2000 chars.
-- Take a backup of noteslog_tbl before running this rollback.

ALTER TABLE noteslog_tbl MODIFY COLUMN noteDetails VARCHAR(2000) NULL;
