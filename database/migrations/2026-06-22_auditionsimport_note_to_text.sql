-- PURPOSE: Widen auditionsimport.note from VARCHAR(500) to TEXT so long audition
--          import notes are no longer truncated at 500 characters during staging.
--          (auditionsimport.charDescription was already TEXT; only `note` was missed.)
-- AUTHOR:  Claude Code
-- DATE:    2026-06-22
--
-- SAFE TO RE-RUN: guarded by an information_schema DATA_TYPE check; once the column
--                 is already TEXT the ALTER is skipped.
-- NON-LOSSY: VARCHAR(500) -> TEXT only widens; existing values are preserved.

SET @is_varchar = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'auditionsimport'
      AND column_name  = 'note'
      AND data_type    = 'varchar'
);
SET @sql = IF(@is_varchar = 1,
    'ALTER TABLE auditionsimport MODIFY COLUMN note TEXT NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Post-check: expect data_type = 'text'.
SELECT table_name, column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'auditionsimport'
  AND column_name = 'note';
