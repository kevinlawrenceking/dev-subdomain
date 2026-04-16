-- Ticket 2187: Ensure noteslog.noteDetails supports large notes from imports
-- Safe: MODIFY to TEXT on an existing VARCHAR column preserves data

ALTER TABLE noteslog MODIFY COLUMN noteDetails TEXT;
