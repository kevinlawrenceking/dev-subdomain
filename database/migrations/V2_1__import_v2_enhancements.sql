-- Contact Import V2 Enhancements Migration
-- Database: MySQL (TAO uses MySQL with ColdFusion)
-- Created: 2026-01-07
-- Purpose: Add file hash idempotency, VCF support, relationship system field, Google Contacts aliases

-- ============================================================
-- Add file_hash column for idempotency
-- ============================================================
-- Check if column exists before adding (MySQL approach)
SET @dbname = DATABASE();
SET @tablename = 'import_jobs';
SET @columnname = 'file_hash';
SET @preparedStatement = (SELECT IF(
    (SELECT COUNT(*) FROM information_schema.columns
     WHERE table_schema = @dbname
       AND table_name = @tablename
       AND column_name = @columnname) > 0,
    'SELECT 1',
    'ALTER TABLE import_jobs ADD COLUMN file_hash VARCHAR(64) NULL'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- ============================================================
-- Create unique index on (userid, file_hash) for race-safe idempotency
-- ============================================================
-- Drop simple index if exists, create unique composite index
SET @indexExists = (SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'import_jobs'
      AND index_name = 'IX_import_jobs_file_hash');

SET @dropStatement = IF(@indexExists > 0,
    'DROP INDEX IX_import_jobs_file_hash ON import_jobs',
    'SELECT 1');
PREPARE dropIfExists FROM @dropStatement;
EXECUTE dropIfExists;
DEALLOCATE PREPARE dropIfExists;

-- Create unique composite index for (userid, file_hash) to prevent concurrent duplicates
-- Note: NULL values are allowed (unique constraint ignores NULLs in MySQL)
SET @uniqueIndexExists = (SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'import_jobs'
      AND index_name = 'UX_import_jobs_userid_file_hash');

SET @createUniqueIndex = IF(@uniqueIndexExists = 0,
    'CREATE UNIQUE INDEX UX_import_jobs_userid_file_hash ON import_jobs(userid, file_hash)',
    'SELECT 1');
PREPARE createIfNotExists FROM @createUniqueIndex;
EXECUTE createIfNotExists;
DEALLOCATE PREPARE createIfNotExists;

-- ============================================================
-- Add relationship_system field mapping
-- ============================================================
INSERT INTO import_field_mappings
    (canonical_field, display_name, field_category, field_type, is_required, max_length, sort_order)
SELECT 'relationship_system', 'Relationship System', 'contact', 'select', 0, 50, 90
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM import_field_mappings WHERE canonical_field = 'relationship_system'
);

-- ============================================================
-- Add aliases for relationship_system (using INSERT IGNORE for upsert behavior)
-- ============================================================
INSERT IGNORE INTO import_field_aliases (canonical_field, alias_pattern, confidence)
VALUES
    ('relationship_system', 'relationship_system', 0.95),
    ('relationship_system', 'relationship system', 0.95),
    ('relationship_system', 'maintenance_or_target', 0.95),
    ('relationship_system', 'maintenance or target', 0.95),
    ('relationship_system', 'system', 0.70),
    ('relationship_system', 'fu system', 0.85),
    ('relationship_system', 'follow up system', 0.85),
    ('relationship_system', 'followup system', 0.85);

-- Update confidence for existing aliases
UPDATE import_field_aliases SET confidence = 0.95
WHERE canonical_field = 'relationship_system'
  AND alias_pattern IN ('relationship_system', 'relationship system', 'maintenance_or_target', 'maintenance or target');

UPDATE import_field_aliases SET confidence = 0.85
WHERE canonical_field = 'relationship_system'
  AND alias_pattern IN ('fu system', 'follow up system', 'followup system');

UPDATE import_field_aliases SET confidence = 0.70
WHERE canonical_field = 'relationship_system'
  AND alias_pattern = 'system';

-- ============================================================
-- Google Contacts CSV Field Aliases
-- ============================================================
INSERT IGNORE INTO import_field_aliases (canonical_field, alias_pattern, confidence)
VALUES
    -- Google Contacts name fields
    ('firstName', 'given name', 0.98),
    ('lastName', 'family name', 0.98),
    ('contactFullName', 'name', 0.85),

    -- Google Contacts email fields
    ('email_business', 'e-mail 1 - value', 0.95),
    ('email_personal', 'e-mail 2 - value', 0.90),

    -- Google Contacts phone fields
    ('phone_work', 'phone 1 - value', 0.90),
    ('phone_mobile', 'phone 2 - value', 0.85),
    ('phone_home', 'phone 3 - value', 0.80),

    -- Google Contacts organization fields
    ('company', 'organization 1 - name', 0.98),
    ('jobTitle', 'organization 1 - title', 0.98),
    ('department', 'organization 1 - department', 0.98),

    -- Google Contacts address fields
    ('address_street', 'address 1 - street', 0.98),
    ('address_city', 'address 1 - city', 0.98),
    ('address_state', 'address 1 - region', 0.98),
    ('address_zip', 'address 1 - postal code', 0.98),
    ('address_country', 'address 1 - country', 0.98),

    -- Google Contacts other fields
    ('birthday', 'birthday', 0.98),
    ('notes', 'notes', 0.98),
    ('website', 'website 1 - value', 0.95);

-- ============================================================
-- Apple/iCloud vCard field aliases
-- ============================================================
INSERT IGNORE INTO import_field_aliases (canonical_field, alias_pattern, confidence)
VALUES
    ('contactFullName', 'fn', 0.98),
    ('firstName', 'n_given', 0.98),
    ('lastName', 'n_family', 0.98),
    ('email_business', 'email_work', 0.98),
    ('email_personal', 'email_home', 0.98),
    ('phone_work', 'tel_work', 0.98),
    ('phone_mobile', 'tel_cell', 0.98),
    ('phone_home', 'tel_home', 0.98),
    ('company', 'org', 0.98),
    ('jobTitle', 'title', 0.85),
    ('address_street', 'adr_street', 0.98),
    ('address_city', 'adr_city', 0.98),
    ('address_state', 'adr_region', 0.98),
    ('address_zip', 'adr_postal', 0.98),
    ('address_country', 'adr_country', 0.98),
    ('birthday', 'bday', 0.98),
    ('notes', 'note', 0.95),
    ('website', 'url', 0.95);

-- ============================================================
-- Rollback Script (save separately if needed)
-- ============================================================
-- DROP INDEX UX_import_jobs_userid_file_hash ON import_jobs;
-- ALTER TABLE import_jobs DROP COLUMN file_hash;
-- DELETE FROM import_field_mappings WHERE canonical_field = 'relationship_system';
-- DELETE FROM import_field_aliases WHERE canonical_field = 'relationship_system';
-- DELETE FROM import_field_aliases WHERE alias_pattern LIKE 'e-mail%' OR alias_pattern LIKE 'phone%value' OR alias_pattern LIKE 'organization%' OR alias_pattern LIKE 'address%-%';
-- DELETE FROM import_field_aliases WHERE alias_pattern LIKE 'n_%' OR alias_pattern LIKE 'email_%' OR alias_pattern LIKE 'tel_%' OR alias_pattern LIKE 'adr_%' OR alias_pattern IN ('fn', 'org', 'bday', 'note', 'url');
