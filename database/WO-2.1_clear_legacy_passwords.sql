-- WO-2.1: Clear legacy plaintext userPassword column
-- Purpose: Remove any remaining plaintext passwords from taousers_tbl
--          for users who already have SHA-512+salt hashes populated.
-- Safe:    Only clears userPassword where passwordHash IS NOT NULL.
-- Date:    2026-03-15

-- Step 1: Audit — check how many rows still have plaintext passwords
SELECT
    COUNT(*) AS total_users,
    SUM(CASE WHEN userPassword IS NOT NULL AND userPassword != '' THEN 1 ELSE 0 END) AS has_plaintext,
    SUM(CASE WHEN passwordHash IS NOT NULL AND passwordHash != '' THEN 1 ELSE 0 END) AS has_hash,
    SUM(CASE WHEN (userPassword IS NOT NULL AND userPassword != '') AND (passwordHash IS NULL OR passwordHash = '') THEN 1 ELSE 0 END) AS plaintext_only_no_hash
FROM taousers_tbl
WHERE IsDeleted = 0;

-- Step 2: Clear plaintext passwords for users who have hashes
UPDATE taousers_tbl
SET userPassword = NULL
WHERE userPassword IS NOT NULL
  AND userPassword != ''
  AND passwordHash IS NOT NULL
  AND passwordHash != '';

-- Step 3: Verify cleanup
SELECT
    COUNT(*) AS remaining_plaintext
FROM taousers_tbl
WHERE userPassword IS NOT NULL AND userPassword != '';

-- ROLLBACK: Not possible — plaintext passwords cannot be recovered once cleared.
-- This is intentional. If a user has no hash, they must use password recovery.
