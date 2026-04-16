-- Rollback: Revert noteDetails to VARCHAR(2000)
-- WARNING: Data longer than 2000 chars will be truncated

ALTER TABLE noteslog MODIFY COLUMN noteDetails VARCHAR(2000);
