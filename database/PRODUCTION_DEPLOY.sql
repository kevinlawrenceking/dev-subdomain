-- ============================================================================
-- TAO PRODUCTION DEPLOYMENT SCRIPT
-- ============================================================================
-- Target schema: actorsbusinessoffice
-- Date generated: 2026-02-26
-- Covers:
--   1. Contact Import V2 staging tables + seed data (V2_0, V2_1)
--   2. Contact Import V3 tables (V3_0)
--   3. Feature flags (V3_1)
--   4. Duplicate detection indexes (V3_2)
--   5. V3 column mapping enhancements (V3_3)
--   6. taousers_tbl.shareID column + view refresh
--   7. Admin Users page registration (pgpages + plugins)
--
-- RUN ORDER: Execute sections in order. Each section is idempotent.
-- PRE-REQ: Back up the database before running.
-- ============================================================================


-- ============================================================================
-- SECTION 1: CONTACT IMPORT V2 STAGING TABLES (V2_0)
-- ============================================================================
-- Tables: import_field_mappings, import_field_aliases, import_jobs,
--         import_job_columns, import_job_rows, import_job_events
-- These are shared reference tables used by both V2 and V3 importers.
-- ============================================================================

-- 1a. import_field_mappings (canonical field reference - must exist before aliases)
CREATE TABLE IF NOT EXISTS import_field_mappings (
    mapping_id INT AUTO_INCREMENT PRIMARY KEY,
    canonical_field VARCHAR(50) NOT NULL COMMENT 'Internal field name',
    display_name VARCHAR(100) NOT NULL COMMENT 'User-friendly display name',
    field_category VARCHAR(30) NOT NULL COMMENT 'contact, email, phone, company, address, tag, url, note',
    field_type VARCHAR(20) NOT NULL COMMENT 'string, email, phone, date, text, url',
    is_required TINYINT(1) DEFAULT 0,
    max_length INT DEFAULT NULL,
    validation_regex VARCHAR(255) DEFAULT NULL,
    sort_order INT DEFAULT 0,

    UNIQUE INDEX UX_import_field_mappings_field (canonical_field)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1b. import_field_aliases (header auto-mapping patterns)
CREATE TABLE IF NOT EXISTS import_field_aliases (
    alias_id INT AUTO_INCREMENT PRIMARY KEY,
    canonical_field VARCHAR(50) NOT NULL,
    alias_pattern VARCHAR(100) NOT NULL COMMENT 'Header text pattern (case-insensitive)',
    confidence DECIMAL(3,2) DEFAULT 0.90 COMMENT 'Confidence score for this alias',

    INDEX IX_import_field_aliases_field (canonical_field),
    INDEX IX_import_field_aliases_pattern (alias_pattern),

    CONSTRAINT FK_import_field_aliases_field
        FOREIGN KEY (canonical_field) REFERENCES import_field_mappings(canonical_field)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1c. import_jobs (V2 job tracking - still used as FK target by V2 tables)
CREATE TABLE IF NOT EXISTS import_jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL,
    source_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) NOT NULL COMMENT 'csv, xls, xlsx',
    file_size BIGINT DEFAULT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        COMMENT 'pending, parsing, parsed, mapping, reviewing, importing, completed, failed, cancelled',
    error_message TEXT DEFAULT NULL COMMENT 'Error details if status is failed',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    started_at DATETIME DEFAULT NULL,
    finished_at DATETIME DEFAULT NULL,
    total_rows INT DEFAULT 0,
    parsed_rows INT DEFAULT 0,
    valid_rows INT DEFAULT 0,
    problem_rows INT DEFAULT 0,
    dupe_rows INT DEFAULT 0,
    imported_rows INT DEFAULT 0,
    skipped_rows INT DEFAULT 0,
    options_json TEXT DEFAULT NULL COMMENT 'JSON: delimiter, encoding, sheet name, has_header, etc.',
    stored_file_path VARCHAR(500) DEFAULT NULL COMMENT 'Server path to uploaded file',

    INDEX IX_import_jobs_userid_status (userid, status),
    INDEX IX_import_jobs_created (created_at DESC),
    INDEX IX_import_jobs_status (status),

    CONSTRAINT FK_import_jobs_userid
        FOREIGN KEY (userid) REFERENCES taousers(userid)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1d. import_job_columns
CREATE TABLE IF NOT EXISTS import_job_columns (
    column_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    source_column_index INT NOT NULL COMMENT '0-based column index from source file',
    source_column_name VARCHAR(255) DEFAULT NULL COMMENT 'Header text from source file',
    normalized_field VARCHAR(50) DEFAULT NULL COMMENT 'Mapped TAO field name',
    confidence DECIMAL(3,2) DEFAULT NULL COMMENT 'Auto-map confidence 0.00-1.00',
    user_confirmed TINYINT(1) DEFAULT 0,
    sample_values TEXT DEFAULT NULL COMMENT 'JSON array of first 5 values for preview',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX IX_import_job_columns_job (job_id),
    UNIQUE INDEX UX_import_job_columns_job_index (job_id, source_column_index),

    CONSTRAINT FK_import_job_columns_job
        FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1e. import_job_rows
CREATE TABLE IF NOT EXISTS import_job_rows (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    row_num INT NOT NULL COMMENT '1-based row number from source file (excluding header)',
    raw_json TEXT NOT NULL COMMENT 'Original cell values as JSON object keyed by column index',
    normalized_json TEXT DEFAULT NULL COMMENT 'Mapped fields with normalized types as JSON object',
    validation_json TEXT DEFAULT NULL COMMENT 'Per-field validation errors/warnings as JSON object',
    dupe_json TEXT DEFAULT NULL COMMENT 'Duplicate candidates with scores/reasons as JSON array',
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        COMMENT 'pending, ready, problem, dupe, ignored, importing, imported, failed',
    error_count INT DEFAULT 0 COMMENT 'Number of validation errors',
    warning_count INT DEFAULT 0 COMMENT 'Number of validation warnings',
    matched_contactid INT DEFAULT NULL COMMENT 'If dupe, the best matched existing contact ID',
    best_match_score INT DEFAULT NULL COMMENT 'Duplicate match score 0-100',
    created_contactid INT DEFAULT NULL COMMENT 'After import, the created/updated contactid',
    user_action VARCHAR(20) DEFAULT NULL
        COMMENT 'User decision: import_new, skip, update_existing, merge',
    import_error TEXT DEFAULT NULL COMMENT 'Error message if import failed for this row',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX IX_import_job_rows_job_status (job_id, status),
    INDEX IX_import_job_rows_job_rownum (job_id, row_num),
    INDEX IX_import_job_rows_status (status),
    UNIQUE INDEX UX_import_job_rows_job_rownum (job_id, row_num),

    CONSTRAINT FK_import_job_rows_job
        FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1f. import_job_events
CREATE TABLE IF NOT EXISTS import_job_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL
        COMMENT 'created, parsing_started, parsing_completed, parsing_failed, columns_mapped, row_updated, row_action_set, import_started, import_completed, row_imported, row_skipped, row_failed',
    event_detail TEXT DEFAULT NULL COMMENT 'JSON with event specifics',
    row_id INT DEFAULT NULL COMMENT 'Related row if applicable',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX IX_import_job_events_job (job_id),
    INDEX IX_import_job_events_type (event_type),
    INDEX IX_import_job_events_created (created_at),

    CONSTRAINT FK_import_job_events_job
        FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- SECTION 2: V2 SEED DATA (canonical fields + aliases)
-- ============================================================================

INSERT INTO import_field_mappings
    (canonical_field, display_name, field_category, field_type, is_required, max_length, sort_order)
VALUES
    ('firstName', 'First Name', 'contact', 'string', 1, 100, 1),
    ('lastName', 'Last Name', 'contact', 'string', 0, 100, 2),
    ('contactFullName', 'Full Name', 'contact', 'string', 0, 255, 3),
    ('email_business', 'Business Email', 'email', 'email', 0, 254, 10),
    ('email_personal', 'Personal Email', 'email', 'email', 0, 254, 11),
    ('phone_work', 'Work Phone', 'phone', 'phone', 0, 50, 20),
    ('phone_mobile', 'Mobile Phone', 'phone', 'phone', 0, 50, 21),
    ('phone_home', 'Home Phone', 'phone', 'phone', 0, 50, 22),
    ('company', 'Company', 'company', 'string', 0, 255, 30),
    ('department', 'Department', 'company', 'string', 0, 255, 31),
    ('jobTitle', 'Job Title', 'company', 'string', 0, 255, 32),
    ('address_street', 'Street Address', 'address', 'string', 0, 255, 40),
    ('address_extended', 'Address Line 2', 'address', 'string', 0, 255, 41),
    ('address_city', 'City', 'address', 'string', 0, 100, 42),
    ('address_state', 'State/Province', 'address', 'string', 0, 100, 43),
    ('address_zip', 'Postal Code', 'address', 'string', 0, 20, 44),
    ('address_country', 'Country', 'address', 'string', 0, 100, 45),
    ('tag1', 'Tag 1', 'tag', 'string', 0, 40, 50),
    ('tag2', 'Tag 2', 'tag', 'string', 0, 40, 51),
    ('tag3', 'Tag 3', 'tag', 'string', 0, 40, 52),
    ('website', 'Website', 'url', 'url', 0, 500, 60),
    ('birthday', 'Birthday', 'contact', 'date', 0, NULL, 70),
    ('meetingDate', 'Meeting Date', 'contact', 'date', 0, NULL, 71),
    ('meetingLocation', 'Meeting Location', 'contact', 'string', 0, 255, 72),
    ('notes', 'Notes', 'note', 'text', 0, 65535, 80)
ON DUPLICATE KEY UPDATE display_name = VALUES(display_name);

-- Standard field aliases
INSERT IGNORE INTO import_field_aliases (canonical_field, alias_pattern, confidence) VALUES
-- First Name
('firstName', 'first name', 0.95),
('firstName', 'firstname', 0.95),
('firstName', 'first', 0.85),
('firstName', 'fname', 0.90),
('firstName', 'given name', 0.90),
('firstName', 'givenname', 0.90),
('firstName', 'forename', 0.85),
-- Last Name
('lastName', 'last name', 0.95),
('lastName', 'lastname', 0.95),
('lastName', 'last', 0.85),
('lastName', 'lname', 0.90),
('lastName', 'surname', 0.90),
('lastName', 'family name', 0.90),
('lastName', 'familyname', 0.90),
-- Full Name
('contactFullName', 'full name', 0.95),
('contactFullName', 'fullname', 0.95),
('contactFullName', 'name', 0.80),
('contactFullName', 'contact name', 0.90),
('contactFullName', 'contactname', 0.90),
-- Business Email
('email_business', 'business email', 0.95),
('email_business', 'work email', 0.95),
('email_business', 'workemail', 0.95),
('email_business', 'businessemail', 0.95),
('email_business', 'email', 0.80),
('email_business', 'e-mail', 0.80),
('email_business', 'email address', 0.80),
-- Personal Email
('email_personal', 'personal email', 0.95),
('email_personal', 'home email', 0.90),
('email_personal', 'private email', 0.90),
('email_personal', 'personalemail', 0.95),
-- Work Phone
('phone_work', 'work phone', 0.95),
('phone_work', 'workphone', 0.95),
('phone_work', 'office phone', 0.90),
('phone_work', 'business phone', 0.90),
('phone_work', 'phone', 0.75),
('phone_work', 'telephone', 0.75),
('phone_work', 'tel', 0.70),
-- Mobile Phone
('phone_mobile', 'mobile phone', 0.95),
('phone_mobile', 'mobilephone', 0.95),
('phone_mobile', 'mobile', 0.90),
('phone_mobile', 'cell phone', 0.95),
('phone_mobile', 'cellphone', 0.95),
('phone_mobile', 'cell', 0.85),
-- Home Phone
('phone_home', 'home phone', 0.95),
('phone_home', 'homephone', 0.95),
('phone_home', 'home', 0.60),
('phone_home', 'personal phone', 0.85),
-- Company
('company', 'company', 0.95),
('company', 'company name', 0.95),
('company', 'companyname', 0.95),
('company', 'organization', 0.90),
('company', 'organisation', 0.90),
('company', 'employer', 0.85),
('company', 'business', 0.75),
-- Department
('department', 'department', 0.95),
('department', 'dept', 0.90),
('department', 'division', 0.85),
-- Job Title
('jobTitle', 'job title', 0.95),
('jobTitle', 'jobtitle', 0.95),
('jobTitle', 'title', 0.80),
('jobTitle', 'position', 0.85),
('jobTitle', 'role', 0.75),
-- Address
('address_street', 'street address', 0.95),
('address_street', 'address', 0.85),
('address_street', 'address1', 0.90),
('address_street', 'address 1', 0.90),
('address_street', 'street', 0.80),
('address_extended', 'address line 2', 0.95),
('address_extended', 'address2', 0.90),
('address_extended', 'address 2', 0.90),
('address_extended', 'apt', 0.80),
('address_extended', 'suite', 0.80),
('address_extended', 'unit', 0.80),
('address_city', 'city', 0.95),
('address_city', 'town', 0.85),
('address_city', 'locality', 0.80),
('address_state', 'state', 0.95),
('address_state', 'province', 0.90),
('address_state', 'region', 0.85),
('address_state', 'state/province', 0.95),
('address_zip', 'zip', 0.95),
('address_zip', 'zip code', 0.95),
('address_zip', 'zipcode', 0.95),
('address_zip', 'postal code', 0.95),
('address_zip', 'postalcode', 0.95),
('address_zip', 'postcode', 0.90),
('address_country', 'country', 0.95),
('address_country', 'nation', 0.80),
-- Tags
('tag1', 'tag1', 0.95),
('tag1', 'tag 1', 0.95),
('tag1', 'tag', 0.80),
('tag1', 'category', 0.75),
('tag1', 'type', 0.70),
('tag2', 'tag2', 0.95),
('tag2', 'tag 2', 0.95),
('tag3', 'tag3', 0.95),
('tag3', 'tag 3', 0.95),
-- Website
('website', 'website', 0.95),
('website', 'web site', 0.95),
('website', 'url', 0.90),
('website', 'web', 0.80),
('website', 'homepage', 0.85),
-- Birthday
('birthday', 'birthday', 0.95),
('birthday', 'birth date', 0.95),
('birthday', 'birthdate', 0.95),
('birthday', 'dob', 0.90),
('birthday', 'date of birth', 0.95),
-- Meeting Date
('meetingDate', 'meeting date', 0.95),
('meetingDate', 'meetingdate', 0.95),
('meetingDate', 'contact meeting date', 0.95),
('meetingDate', 'first met', 0.85),
('meetingDate', 'date met', 0.85),
-- Meeting Location
('meetingLocation', 'meeting location', 0.95),
('meetingLocation', 'meetinglocation', 0.95),
('meetingLocation', 'contact meeting loc', 0.95),
('meetingLocation', 'where met', 0.85),
('meetingLocation', 'met at', 0.80),
-- Notes
('notes', 'notes', 0.95),
('notes', 'note', 0.90),
('notes', 'comments', 0.85),
('notes', 'comment', 0.85),
('notes', 'description', 0.75),
('notes', 'remarks', 0.85),
('notes', 'memo', 0.80);


-- ============================================================================
-- SECTION 3: V2 STORED PROCEDURE + VIEW
-- ============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS sp_update_import_job_counts //

CREATE PROCEDURE sp_update_import_job_counts(IN p_job_id INT)
BEGIN
    UPDATE import_jobs j
    SET
        valid_rows = (SELECT COUNT(*) FROM import_job_rows WHERE job_id = p_job_id AND status = 'ready'),
        problem_rows = (SELECT COUNT(*) FROM import_job_rows WHERE job_id = p_job_id AND status = 'problem'),
        dupe_rows = (SELECT COUNT(*) FROM import_job_rows WHERE job_id = p_job_id AND status = 'dupe'),
        imported_rows = (SELECT COUNT(*) FROM import_job_rows WHERE job_id = p_job_id AND status = 'imported'),
        skipped_rows = (SELECT COUNT(*) FROM import_job_rows WHERE job_id = p_job_id AND status = 'ignored'),
        updated_at = CURRENT_TIMESTAMP
    WHERE j.job_id = p_job_id;
END //

DELIMITER ;

CREATE OR REPLACE VIEW v_import_jobs_summary AS
SELECT
    j.job_id,
    j.userid,
    j.source_filename,
    j.file_type,
    j.status,
    j.created_at,
    j.finished_at,
    j.total_rows,
    j.parsed_rows,
    j.valid_rows,
    j.problem_rows,
    j.dupe_rows,
    j.imported_rows,
    j.skipped_rows,
    CASE
        WHEN j.status = 'completed' THEN 100
        WHEN j.status = 'importing' THEN 90
        WHEN j.status = 'reviewing' THEN 70
        WHEN j.status = 'mapping' THEN 50
        WHEN j.status = 'parsed' THEN 40
        WHEN j.status = 'parsing' THEN ROUND((j.parsed_rows / GREATEST(j.total_rows, 1)) * 30)
        ELSE 0
    END AS progress_percent
FROM import_jobs j;


-- ============================================================================
-- SECTION 4: V2.1 ENHANCEMENTS (file hash, relationship_system, Google/Apple aliases)
-- ============================================================================

-- 4a. Add file_hash column to import_jobs for idempotency
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

-- 4b. Create unique index on (userid, file_hash) for race-safe idempotency
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

-- 4c. Add relationship_system field mapping
INSERT INTO import_field_mappings
    (canonical_field, display_name, field_category, field_type, is_required, max_length, sort_order)
SELECT 'relationship_system', 'Relationship System', 'contact', 'select', 0, 50, 90
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM import_field_mappings WHERE canonical_field = 'relationship_system'
);

-- 4d. Relationship system aliases
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

-- 4e. Google Contacts CSV field aliases
INSERT IGNORE INTO import_field_aliases (canonical_field, alias_pattern, confidence)
VALUES
    ('firstName', 'given name', 0.98),
    ('lastName', 'family name', 0.98),
    ('contactFullName', 'name', 0.85),
    ('email_business', 'e-mail 1 - value', 0.95),
    ('email_personal', 'e-mail 2 - value', 0.90),
    ('phone_work', 'phone 1 - value', 0.90),
    ('phone_mobile', 'phone 2 - value', 0.85),
    ('phone_home', 'phone 3 - value', 0.80),
    ('company', 'organization 1 - name', 0.98),
    ('jobTitle', 'organization 1 - title', 0.98),
    ('department', 'organization 1 - department', 0.98),
    ('address_street', 'address 1 - street', 0.98),
    ('address_city', 'address 1 - city', 0.98),
    ('address_state', 'address 1 - region', 0.98),
    ('address_zip', 'address 1 - postal code', 0.98),
    ('address_country', 'address 1 - country', 0.98),
    ('birthday', 'birthday', 0.98),
    ('notes', 'notes', 0.98),
    ('website', 'website 1 - value', 0.95);

-- 4f. Apple/iCloud vCard field aliases
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


-- ============================================================================
-- SECTION 5: CONTACT IMPORT V3 TABLES (V3_0)
-- ============================================================================
-- 7 new tables with import_v3_ prefix + contact_custom_fields
-- ============================================================================

-- 5a. import_v3_jobs
CREATE TABLE IF NOT EXISTS import_v3_jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL COMMENT 'Owner FK to taousers.userid',
    source_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) NOT NULL COMMENT 'csv, xls, xlsx, vcf',
    file_size BIGINT DEFAULT NULL,
    file_hash VARCHAR(64) DEFAULT NULL COMMENT 'SHA-256 for idempotency',
    stored_file_path VARCHAR(500) DEFAULT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending|parsing|parsed|mapping|validating|reviewing|importing|completed|failed|cancelled',
    error_message TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    started_at DATETIME DEFAULT NULL,
    finished_at DATETIME DEFAULT NULL,
    total_rows INT DEFAULT 0,
    parsed_rows INT DEFAULT 0,
    valid_rows INT DEFAULT 0,
    problem_rows INT DEFAULT 0,
    dupe_rows INT DEFAULT 0,
    imported_rows INT DEFAULT 0,
    updated_rows INT DEFAULT 0 COMMENT 'New in V3: track updates separately',
    skipped_rows INT DEFAULT 0,
    options_json TEXT DEFAULT NULL COMMENT 'Parsing and import options',
    import_mode VARCHAR(20) DEFAULT 'create_only' COMMENT 'create_only|update_existing|create_and_update',
    allow_blank_overwrite TINYINT(1) DEFAULT 0 COMMENT 'If 1, blanks can clear existing values',
    relationship_system_default VARCHAR(50) DEFAULT NULL COMMENT 'Default system for new contacts',
    folder_assignment_json TEXT DEFAULT NULL COMMENT 'Folder assignment rules',

    INDEX IX_import_v3_jobs_userid_status (userid, status),
    INDEX IX_import_v3_jobs_created (created_at DESC),
    INDEX IX_import_v3_jobs_status (status),
    UNIQUE INDEX UX_import_v3_jobs_userid_file_hash (userid, file_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5b. import_v3_columns
CREATE TABLE IF NOT EXISTS import_v3_columns (
    column_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',
    source_column_index INT NOT NULL COMMENT '0-based index from file',
    source_column_name VARCHAR(255) DEFAULT NULL COMMENT 'Header text from file',
    mapped_field VARCHAR(50) DEFAULT NULL COMMENT 'TAO canonical field name or custom_field key',
    is_custom_field TINYINT(1) DEFAULT 0 COMMENT '1 if maps to contact_custom_fields',
    custom_field_id INT DEFAULT NULL COMMENT 'FK to contact_custom_fields.field_id if custom',
    confidence DECIMAL(3,2) DEFAULT NULL COMMENT 'Auto-map confidence 0.00-1.00',
    user_confirmed TINYINT(1) DEFAULT 0 COMMENT '1 if user approved mapping',
    sample_values TEXT DEFAULT NULL COMMENT 'JSON array of sample values',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX IX_import_v3_columns_job (job_id),
    UNIQUE INDEX UX_import_v3_columns_job_index (job_id, source_column_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5c. import_v3_rows
CREATE TABLE IF NOT EXISTS import_v3_rows (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',
    row_num INT NOT NULL COMMENT '1-based row number from file',
    raw_json TEXT NOT NULL COMMENT 'Original cell values by column index',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending|validating|ready|problem|dupe|ignored|importing|imported|updated|failed',
    error_count INT DEFAULT 0,
    warning_count INT DEFAULT 0,
    validation_summary TEXT DEFAULT NULL COMMENT 'JSON summary of validation issues',
    dupe_candidates_json TEXT DEFAULT NULL COMMENT 'JSON array of candidate contacts',
    matched_contactid INT DEFAULT NULL COMMENT 'Best match contact ID',
    best_match_score INT DEFAULT NULL COMMENT 'Match confidence 0-100',
    user_action VARCHAR(20) DEFAULT NULL COMMENT 'import_new|skip|update_existing|merge',
    user_action_at DATETIME DEFAULT NULL,
    created_contactid INT DEFAULT NULL COMMENT 'New contact ID if created',
    updated_contactid INT DEFAULT NULL COMMENT 'Existing contact ID if updated',
    import_error TEXT DEFAULT NULL COMMENT 'Error message if failed',
    imported_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX IX_import_v3_rows_job_status (job_id, status),
    INDEX IX_import_v3_rows_job_rownum (job_id, row_num),
    INDEX IX_import_v3_rows_status (status),
    INDEX IX_import_v3_rows_matched (matched_contactid),
    UNIQUE INDEX UX_import_v3_rows_job_rownum (job_id, row_num)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5d. import_v3_facts (EAV pattern)
CREATE TABLE IF NOT EXISTS import_v3_facts (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    row_id INT NOT NULL COMMENT 'FK to import_v3_rows.row_id',
    column_id INT NOT NULL COMMENT 'FK to import_v3_columns.column_id',
    field_name VARCHAR(50) NOT NULL COMMENT 'Canonical field name (e.g., email_business)',
    raw_value TEXT DEFAULT NULL COMMENT 'Original value from file',
    normalized_value TEXT DEFAULT NULL COMMENT 'Cleaned/normalized value',
    is_valid TINYINT(1) DEFAULT 1,
    validation_code VARCHAR(30) DEFAULT NULL COMMENT 'error code if invalid',
    validation_message VARCHAR(255) DEFAULT NULL COMMENT 'human-readable error',
    existing_value TEXT DEFAULT NULL COMMENT 'Current value in contact (for updates)',
    has_conflict TINYINT(1) DEFAULT 0 COMMENT '1 if normalized != existing and both non-empty',
    user_choice VARCHAR(20) DEFAULT NULL COMMENT 'keep_existing|use_import|clear',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX IX_import_v3_facts_row (row_id),
    INDEX IX_import_v3_facts_field (field_name),
    INDEX IX_import_v3_facts_validation (is_valid, validation_code),
    UNIQUE INDEX UX_import_v3_facts_row_column (row_id, column_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5e. import_v3_row_results
CREATE TABLE IF NOT EXISTS import_v3_row_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    row_id INT NOT NULL COMMENT 'FK to import_v3_rows.row_id',
    job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id (denormalized for queries)',
    action_taken VARCHAR(20) NOT NULL COMMENT 'created|updated|skipped|failed',
    contactid INT DEFAULT NULL COMMENT 'Affected contact ID',
    fields_written INT DEFAULT 0 COMMENT 'Count of fields written',
    fields_skipped INT DEFAULT 0 COMMENT 'Count of fields skipped (blank/conflict)',
    items_created INT DEFAULT 0 COMMENT 'Count of contactitems created',
    notes_created INT DEFAULT 0 COMMENT 'Count of notes created',
    error_code VARCHAR(30) DEFAULT NULL,
    error_message TEXT DEFAULT NULL,
    undo_available TINYINT(1) DEFAULT 1,
    undo_json TEXT DEFAULT NULL COMMENT 'Data needed to reverse this import row',
    undone_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX IX_import_v3_row_results_job (job_id),
    INDEX IX_import_v3_row_results_action (action_taken),
    INDEX IX_import_v3_row_results_contact (contactid),
    UNIQUE INDEX UX_import_v3_row_results_row (row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5f. import_v3_events
CREATE TABLE IF NOT EXISTS import_v3_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',
    event_type VARCHAR(50) NOT NULL COMMENT 'created|parsing_started|parsing_completed|...',
    event_detail TEXT DEFAULT NULL COMMENT 'JSON details',
    row_id INT DEFAULT NULL COMMENT 'FK to import_v3_rows if row-specific',
    userid INT DEFAULT NULL COMMENT 'User who triggered event (for future multi-user)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX IX_import_v3_events_job (job_id),
    INDEX IX_import_v3_events_type (event_type),
    INDEX IX_import_v3_events_created (created_at DESC),
    INDEX IX_import_v3_events_row (row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5g. contact_custom_fields
CREATE TABLE IF NOT EXISTS contact_custom_fields (
    field_id INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL COMMENT 'Owner FK to taousers.userid',
    field_key VARCHAR(50) NOT NULL COMMENT 'Internal key (e.g., custom_assistant_name)',
    field_label VARCHAR(100) NOT NULL COMMENT 'Display label',
    field_type VARCHAR(20) NOT NULL DEFAULT 'text' COMMENT 'text|email|phone|date|url|select',
    options_json TEXT DEFAULT NULL COMMENT 'JSON array of options for select type',
    is_required TINYINT(1) DEFAULT 0,
    max_length INT DEFAULT NULL,
    validation_regex VARCHAR(255) DEFAULT NULL,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    show_in_list TINYINT(1) DEFAULT 0 COMMENT 'Show in contact list view',
    show_in_card TINYINT(1) DEFAULT 1 COMMENT 'Show in contact card view',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX IX_contact_custom_fields_userid (userid),
    INDEX IX_contact_custom_fields_active (userid, is_active),
    UNIQUE INDEX UX_contact_custom_fields_userid_key (userid, field_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- SECTION 6: FEATURE FLAGS (V3_1)
-- ============================================================================

-- 6a. feature_flags
CREATE TABLE IF NOT EXISTS feature_flags (
    flag_key VARCHAR(50) NOT NULL PRIMARY KEY,
    is_enabled TINYINT(1) NOT NULL DEFAULT 0,
    description VARCHAR(255) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX IX_feature_flags_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6b. feature_flag_users
CREATE TABLE IF NOT EXISTS feature_flag_users (
    flag_key VARCHAR(50) NOT NULL,
    userid INT NOT NULL,
    is_enabled TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    notes VARCHAR(255) DEFAULT NULL,

    PRIMARY KEY (flag_key, userid),
    INDEX IX_feature_flag_users_userid (userid),
    INDEX IX_feature_flag_users_flag (flag_key),

    CONSTRAINT FK_feature_flag_users_flag
        FOREIGN KEY (flag_key) REFERENCES feature_flags(flag_key)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6c. Seed default flag (import V3 OFF by default for safe rollout)
INSERT INTO feature_flags (flag_key, is_enabled, description)
VALUES ('import_v3_enabled', 0, 'Contact Import V3 - new multi-format importer with staging and review')
ON DUPLICATE KEY UPDATE updated_at = NOW();


-- ============================================================================
-- SECTION 7: DUPLICATE DETECTION PERFORMANCE INDEXES (V3_2)
-- ============================================================================
-- Adds indexes to existing contactdetails_tbl and contactitems_tbl
-- for fast dupe matching during import.
-- ============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS AddIndexIfNotExists //

CREATE PROCEDURE AddIndexIfNotExists(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_index_def TEXT
)
BEGIN
    DECLARE v_index_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO v_index_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_table_name
      AND INDEX_NAME = p_index_name;

    IF v_index_exists = 0 THEN
        SET @sql = CONCAT('CREATE INDEX ', p_index_name, ' ON ', p_table_name, ' ', p_index_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('CREATED: ', p_index_name, ' on ', p_table_name) AS result;
    ELSE
        SELECT CONCAT('EXISTS: ', p_index_name, ' on ', p_table_name, ' - skipped') AS result;
    END IF;
END //

DELIMITER ;

-- Index on contactdetails_tbl for user + deleted + contactid
CALL AddIndexIfNotExists(
    'contactdetails_tbl',
    'idx_contactdetails_tbl_dupe_v3',
    '(userid, isdeleted, contactid)'
);

-- Index on contactitems_tbl for dupe detection with valuetext lookup
CALL AddIndexIfNotExists(
    'contactitems_tbl',
    'idx_contactitems_tbl_dupe_v3',
    '(contactid, itemStatus, isDeleted, valueCategory, valuetext(100))'
);

-- Index on contactitems_tbl for category + status for dupe index build
CALL AddIndexIfNotExists(
    'contactitems_tbl',
    'idx_contactitems_tbl_category_status',
    '(valueCategory, itemStatus, isDeleted, contactid)'
);

-- Cleanup helper procedure
DROP PROCEDURE IF EXISTS AddIndexIfNotExists;


-- ============================================================================
-- SECTION 8: V3 COLUMN MAPPING ENHANCEMENTS (V3_3)
-- ============================================================================
-- Adds intent, target_key, transform_json to import_v3_columns
-- ============================================================================

-- Safe column additions (will fail harmlessly if columns already exist)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'import_v3_columns'
      AND column_name = 'intent');

SET @add_intent = IF(@col_exists = 0,
    'ALTER TABLE import_v3_columns ADD COLUMN intent VARCHAR(20) DEFAULT NULL AFTER sample_values',
    'SELECT 1');
PREPARE stmt FROM @add_intent;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'import_v3_columns'
      AND column_name = 'target_key');

SET @add_target_key = IF(@col_exists = 0,
    'ALTER TABLE import_v3_columns ADD COLUMN target_key VARCHAR(100) DEFAULT NULL AFTER intent',
    'SELECT 1');
PREPARE stmt FROM @add_target_key;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'import_v3_columns'
      AND column_name = 'transform_json');

SET @add_transform = IF(@col_exists = 0,
    'ALTER TABLE import_v3_columns ADD COLUMN transform_json TEXT DEFAULT NULL AFTER target_key',
    'SELECT 1');
PREPARE stmt FROM @add_transform;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- ============================================================================
-- SECTION 9: taousers_tbl.shareID COLUMN + VIEW REFRESH
-- ============================================================================
-- Adds persistent shareID (UUID) for public share links.
-- ============================================================================

-- 9a. Add shareID column if it does not exist
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'taousers_tbl'
      AND column_name = 'shareID');

SET @add_shareid = IF(@col_exists = 0,
    'ALTER TABLE taousers_tbl ADD COLUMN shareID CHAR(36) NULL',
    'SELECT 1');
PREPARE stmt FROM @add_shareid;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 9b. Populate any NULL shareID values with UUID
UPDATE taousers_tbl
SET    shareID = UUID()
WHERE  shareID IS NULL
    OR shareID = '';

-- 9c. Make NOT NULL (safe if already NOT NULL)
SET @is_nullable = (SELECT IS_NULLABLE FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'taousers_tbl'
      AND column_name = 'shareID');

SET @modify_stmt = IF(@is_nullable = 'YES',
    'ALTER TABLE taousers_tbl MODIFY COLUMN shareID CHAR(36) NOT NULL',
    'SELECT 1');
PREPARE stmt FROM @modify_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 9d. Add unique index if not exists
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'taousers_tbl'
      AND index_name = 'UQ_taousers_tbl_shareID');

SET @create_idx = IF(@idx_exists = 0,
    'CREATE UNIQUE INDEX UQ_taousers_tbl_shareID ON taousers_tbl(shareID)',
    'SELECT 1');
PREPARE stmt FROM @create_idx;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 9e. Refresh the taousers view to expose shareID
DROP VIEW IF EXISTS taousers;

CREATE VIEW taousers AS
SELECT
    tu.userID AS userID,
    tu.userFirstName AS userFirstName,
    tu.userLastName AS userLastName,
    tu.userEmail AS userEmail,
    tu.userRole AS userRole,
    tu.recordname AS recordname,
    tu.contactid AS contactid,
    tu.IsDeleted AS IsDeleted,
    tu.nletter_yn AS nletter_yn,
    tu.nletter_link AS nletter_link,
    tu.calStartTime AS calStartTime,
    tu.calEndTime AS calEndTime,
    tu.calSlotDuration AS calSlotDuration,
    tu.avatarName AS avatarName,
    tu.IsBetaTester AS IsBetaTester,
    tu.defRows AS defRows,
    tu.defCountry AS defCountry,
    tu.defState AS defState,
    tu.tzid AS tzid,
    tu.customerid AS customerid,
    tu.userstatus AS userstatus,
    tu.recover AS recover,
    tu.passwordHash AS passwordHash,
    tu.passwordSalt AS passwordSalt,
    tu.userPassword AS userPassword,
    tu.isAudition AS isAudition,
    tu.viewtypeid AS viewtypeid,
    tu.add1 AS add1,
    tu.add2 AS add2,
    tu.city AS city,
    tu.regionid AS regionid,
    tu.zip AS zip,
    tu.isAuditionModule AS isAuditionModule,
    tu.imdbid AS imdbid,
    tu.isSetup AS isSetup,
    tu.countryid AS countryid,
    tu.def_regionid AS def_regionid,
    tu.access_token AS access_token,
    tu.refresh_token AS refresh_token,
    tu.dateFormatID AS dateFormatID,
    tu.datePrefID AS datePrefID,
    tu.region_id AS region_id,
    tu.shareID AS shareID
FROM taousers_tbl AS tu
WHERE tu.IsDeleted = 0;


-- ============================================================================
-- SECTION 10: ADMIN USERS PAGE REGISTRATION (pgpages + plugins)
-- ============================================================================
-- Registers the admin-users and admin-users-detail pages in the page system.
-- ============================================================================

-- 10a. Get compid from admin-support (the parent admin page)
SET @admin_compid = (SELECT compid FROM pgpages WHERE pgDir = 'admin-support' LIMIT 1);

-- 10b. Insert admin-users page if not exists
INSERT INTO pgpages (pgDir, pgname, pgTitle, pgHeading, pgFilename, compid, isdef, pk, update_type, datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN)
SELECT 'admin-users', 'Admin Users', 'User Management', 'User Management', 'admin-users.cfm', @admin_compid, 1, 'userid', 'custom', 'N', 'N', 'N', 'N'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgpages WHERE pgDir = 'admin-users');

-- 10c. Insert admin-users-detail page if not exists
INSERT INTO pgpages (pgDir, pgname, pgTitle, pgHeading, pgFilename, compid, isdef, pk, update_type, datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN)
SELECT 'admin-users-detail', 'Admin User Detail', 'User Detail', 'User Detail', 'admin-users-detail.cfm', @admin_compid, 1, 'userid', 'custom', 'N', 'N', 'N', 'N'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgpages WHERE pgDir = 'admin-users-detail');

-- 10d. Update page metadata (idempotent)
UPDATE pgpages
SET pgFilename = 'admin-users.cfm',
    pgTitle = 'User Management',
    pgHeading = 'User Management',
    isdef = 1
WHERE pgDir = 'admin-users';

UPDATE pgpages
SET pgFilename = 'admin-users-detail.cfm',
    pgTitle = 'User Detail',
    pgHeading = 'User Detail',
    isdef = 1
WHERE pgDir = 'admin-users-detail';

-- 10e. Propagate plugins from admin-support to admin-users pages
SET @source_pgid = (SELECT pgid FROM pgpages WHERE pgDir = 'admin-support' LIMIT 1);
SET @users_pgid = (SELECT pgid FROM pgpages WHERE pgDir = 'admin-users' LIMIT 1);
SET @detail_pgid = (SELECT pgid FROM pgpages WHERE pgDir = 'admin-users-detail' LIMIT 1);

INSERT IGNORE INTO pgpagespluginsxref (pgid, pluginid)
SELECT @users_pgid, pluginid
FROM pgpagespluginsxref
WHERE pgid = @source_pgid;

INSERT IGNORE INTO pgpagespluginsxref (pgid, pluginid)
SELECT @detail_pgid, pluginid
FROM pgpagespluginsxref
WHERE pgid = @source_pgid;


-- ============================================================================
-- SECTION 11: VERIFICATION QUERIES
-- ============================================================================
-- Run these after deployment to confirm everything applied correctly.
-- ============================================================================

-- 11a. Verify all new tables exist
SELECT table_name, engine, table_collation
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name IN (
    'import_field_mappings', 'import_field_aliases',
    'import_jobs', 'import_job_columns', 'import_job_rows', 'import_job_events',
    'import_v3_jobs', 'import_v3_columns', 'import_v3_rows', 'import_v3_facts',
    'import_v3_row_results', 'import_v3_events', 'contact_custom_fields',
    'feature_flags', 'feature_flag_users'
  )
ORDER BY table_name;
-- Expected: 15 rows

-- 11b. Verify V3.3 columns on import_v3_columns
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'import_v3_columns'
  AND column_name IN ('intent', 'target_key', 'transform_json');
-- Expected: 3 rows

-- 11c. Verify dupe detection indexes
SHOW INDEX FROM contactdetails_tbl WHERE Key_name LIKE '%dupe_v3%';
SHOW INDEX FROM contactitems_tbl WHERE Key_name LIKE '%dupe_v3%' OR Key_name LIKE '%category_status%';
-- Expected: 1 index on contactdetails_tbl, 2 on contactitems_tbl

-- 11d. Verify shareID on taousers_tbl
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'taousers_tbl'
  AND column_name = 'shareID';
-- Expected: 1 row, CHAR(36), NOT NULL

-- 11e. Verify feature flag
SELECT * FROM feature_flags WHERE flag_key = 'import_v3_enabled';
-- Expected: 1 row, is_enabled = 0

-- 11f. Verify pgpages
SELECT pgDir, pgTitle, pgFilename FROM pgpages WHERE pgDir IN ('admin-users', 'admin-users-detail');
-- Expected: 2 rows

-- 11g. Verify seed data counts
SELECT 'import_field_mappings' AS tbl, COUNT(*) AS cnt FROM import_field_mappings
UNION ALL
SELECT 'import_field_aliases', COUNT(*) FROM import_field_aliases;
-- Expected: ~26 mappings, ~120+ aliases

-- 11h. Verify taousers view includes shareID
SELECT column_name FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'taousers'
  AND column_name = 'shareID';
-- Expected: 1 row

-- 11i. Verify V2 stored procedure
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = DATABASE()
  AND routine_name = 'sp_update_import_job_counts';
-- Expected: 1 row

-- 11j. Verify V2 summary view
SELECT table_name FROM information_schema.views
WHERE table_schema = DATABASE()
  AND table_name = 'v_import_jobs_summary';
-- Expected: 1 row


-- ============================================================================
-- END OF PRODUCTION DEPLOYMENT SCRIPT
-- ============================================================================


-- ============================================================================
-- ROLLBACK SCRIPT (save separately - only run if deployment must be reversed)
-- ============================================================================
-- WARNING: This is DESTRUCTIVE. It will drop all new tables and lose data.
-- Run sections in REVERSE order of deployment.
--
-- -- Rollback Section 10 (pgpages):
-- DELETE FROM pgpagespluginsxref WHERE pgid IN (
--     SELECT pgid FROM pgpages WHERE pgDir IN ('admin-users', 'admin-users-detail')
-- );
-- DELETE FROM pgpages WHERE pgDir IN ('admin-users', 'admin-users-detail');
--
-- -- Rollback Section 9 (shareID):
-- DROP VIEW IF EXISTS taousers;
-- ALTER TABLE taousers_tbl DROP INDEX UQ_taousers_tbl_shareID;
-- ALTER TABLE taousers_tbl DROP COLUMN shareID;
-- -- NOTE: You must recreate the taousers view WITHOUT shareID after this.
--
-- -- Rollback Section 8 (V3_3):
-- ALTER TABLE import_v3_columns
--     DROP COLUMN IF EXISTS transform_json,
--     DROP COLUMN IF EXISTS target_key,
--     DROP COLUMN IF EXISTS intent;
--
-- -- Rollback Section 7 (V3_2):
-- DROP INDEX IF EXISTS idx_contactdetails_tbl_dupe_v3 ON contactdetails_tbl;
-- DROP INDEX IF EXISTS idx_contactitems_tbl_dupe_v3 ON contactitems_tbl;
-- DROP INDEX IF EXISTS idx_contactitems_tbl_category_status ON contactitems_tbl;
--
-- -- Rollback Section 6 (V3_1):
-- DROP TABLE IF EXISTS feature_flag_users;
-- DROP TABLE IF EXISTS feature_flags;
--
-- -- Rollback Section 5 (V3_0):
-- DROP TABLE IF EXISTS import_v3_row_results;
-- DROP TABLE IF EXISTS import_v3_facts;
-- DROP TABLE IF EXISTS import_v3_events;
-- DROP TABLE IF EXISTS import_v3_rows;
-- DROP TABLE IF EXISTS import_v3_columns;
-- DROP TABLE IF EXISTS import_v3_jobs;
-- DROP TABLE IF EXISTS contact_custom_fields;
--
-- -- Rollback Section 4 (V2_1):
-- DROP INDEX UX_import_jobs_userid_file_hash ON import_jobs;
-- ALTER TABLE import_jobs DROP COLUMN file_hash;
-- DELETE FROM import_field_mappings WHERE canonical_field = 'relationship_system';
-- DELETE FROM import_field_aliases WHERE canonical_field = 'relationship_system';
-- DELETE FROM import_field_aliases WHERE alias_pattern LIKE 'e-mail%'
--     OR alias_pattern LIKE 'phone%value'
--     OR alias_pattern LIKE 'organization%'
--     OR alias_pattern LIKE 'address%-%';
-- DELETE FROM import_field_aliases WHERE alias_pattern LIKE 'n_%'
--     OR alias_pattern LIKE 'email_%'
--     OR alias_pattern LIKE 'tel_%'
--     OR alias_pattern LIKE 'adr_%'
--     OR alias_pattern IN ('fn', 'org', 'bday', 'note', 'url');
--
-- -- Rollback Sections 1-3 (V2_0):
-- DROP VIEW IF EXISTS v_import_jobs_summary;
-- DROP PROCEDURE IF EXISTS sp_update_import_job_counts;
-- DROP TABLE IF EXISTS import_job_events;
-- DROP TABLE IF EXISTS import_job_rows;
-- DROP TABLE IF EXISTS import_job_columns;
-- DROP TABLE IF EXISTS import_jobs;
-- DROP TABLE IF EXISTS import_field_aliases;
-- DROP TABLE IF EXISTS import_field_mappings;
-- ============================================================================
