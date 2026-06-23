-- ROLLBACK for 2026-06-22_auditionsimport_note_to_text.sql
-- Reverts auditionsimport.note from TEXT back to VARCHAR(500).
-- AUTHOR: Claude Code
-- DATE:   2026-06-22
--
-- WARNING: LOSSY. Any note longer than 500 characters stored after the forward
-- migration WILL be truncated to 500 by this rollback. Only run if you are sure no
-- note exceeds 500 chars (check first with the SELECT below).
--
-- SAFE TO RE-RUN: guarded by a DATA_TYPE check.

-- Pre-check (run manually before rolling back): rows that would be truncated.
-- SELECT COUNT(*) AS would_truncate FROM auditionsimport WHERE LENGTH(note) > 500;

SET @is_text = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'auditionsimport'
      AND column_name  = 'note'
      AND data_type    = 'text'
);
SET @sql = IF(@is_text = 1,
    'ALTER TABLE auditionsimport MODIFY COLUMN note VARCHAR(500) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT table_name, column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'auditionsimport'
  AND column_name = 'note';
