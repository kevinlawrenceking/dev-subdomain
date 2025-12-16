-- Contact Import V2 Staging Tables Migration
-- Database: MySQL (TAO uses MySQL with ColdFusion)
-- Created: 2024
-- Purpose: Two-phase commit pattern for failsafe contact imports

-- ============================================================
-- Table: import_jobs
-- Primary tracking table for import batches
-- ============================================================
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


-- ============================================================
-- Table: import_job_columns
-- Stores column mapping decisions per job
-- ============================================================
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


-- ============================================================
-- Table: import_job_rows
-- Individual row data with validation and duplicate info
-- ============================================================
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


-- ============================================================
-- Table: import_job_events
-- Audit trail for import operations
-- ============================================================
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


-- ============================================================
-- Table: import_field_mappings
-- Reference table for canonical fields and common aliases
-- ============================================================
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


-- ============================================================
-- Table: import_field_aliases
-- Common header variations for auto-mapping
-- ============================================================
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


-- ============================================================
-- Seed Data: Canonical Fields
-- ============================================================
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


-- ============================================================
-- Seed Data: Field Aliases for Auto-Mapping
-- ============================================================
INSERT INTO import_field_aliases (canonical_field, alias_pattern, confidence) VALUES
-- First Name aliases
('firstName', 'first name', 0.95),
('firstName', 'firstname', 0.95),
('firstName', 'first', 0.85),
('firstName', 'fname', 0.90),
('firstName', 'given name', 0.90),
('firstName', 'givenname', 0.90),
('firstName', 'forename', 0.85),

-- Last Name aliases
('lastName', 'last name', 0.95),
('lastName', 'lastname', 0.95),
('lastName', 'last', 0.85),
('lastName', 'lname', 0.90),
('lastName', 'surname', 0.90),
('lastName', 'family name', 0.90),
('lastName', 'familyname', 0.90),

-- Full Name aliases
('contactFullName', 'full name', 0.95),
('contactFullName', 'fullname', 0.95),
('contactFullName', 'name', 0.80),
('contactFullName', 'contact name', 0.90),
('contactFullName', 'contactname', 0.90),

-- Business Email aliases
('email_business', 'business email', 0.95),
('email_business', 'work email', 0.95),
('email_business', 'workemail', 0.95),
('email_business', 'businessemail', 0.95),
('email_business', 'email', 0.80),
('email_business', 'e-mail', 0.80),
('email_business', 'email address', 0.80),

-- Personal Email aliases
('email_personal', 'personal email', 0.95),
('email_personal', 'home email', 0.90),
('email_personal', 'private email', 0.90),
('email_personal', 'personalemail', 0.95),

-- Work Phone aliases
('phone_work', 'work phone', 0.95),
('phone_work', 'workphone', 0.95),
('phone_work', 'office phone', 0.90),
('phone_work', 'business phone', 0.90),
('phone_work', 'phone', 0.75),
('phone_work', 'telephone', 0.75),
('phone_work', 'tel', 0.70),

-- Mobile Phone aliases
('phone_mobile', 'mobile phone', 0.95),
('phone_mobile', 'mobilephone', 0.95),
('phone_mobile', 'mobile', 0.90),
('phone_mobile', 'cell phone', 0.95),
('phone_mobile', 'cellphone', 0.95),
('phone_mobile', 'cell', 0.85),

-- Home Phone aliases
('phone_home', 'home phone', 0.95),
('phone_home', 'homephone', 0.95),
('phone_home', 'home', 0.60),
('phone_home', 'personal phone', 0.85),

-- Company aliases
('company', 'company', 0.95),
('company', 'company name', 0.95),
('company', 'companyname', 0.95),
('company', 'organization', 0.90),
('company', 'organisation', 0.90),
('company', 'employer', 0.85),
('company', 'business', 0.75),

-- Department aliases
('department', 'department', 0.95),
('department', 'dept', 0.90),
('department', 'division', 0.85),

-- Job Title aliases
('jobTitle', 'job title', 0.95),
('jobTitle', 'jobtitle', 0.95),
('jobTitle', 'title', 0.80),
('jobTitle', 'position', 0.85),
('jobTitle', 'role', 0.75),

-- Address aliases
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

-- Tag aliases
('tag1', 'tag1', 0.95),
('tag1', 'tag 1', 0.95),
('tag1', 'tag', 0.80),
('tag1', 'category', 0.75),
('tag1', 'type', 0.70),

('tag2', 'tag2', 0.95),
('tag2', 'tag 2', 0.95),

('tag3', 'tag3', 0.95),
('tag3', 'tag 3', 0.95),

-- Website aliases
('website', 'website', 0.95),
('website', 'web site', 0.95),
('website', 'url', 0.90),
('website', 'web', 0.80),
('website', 'homepage', 0.85),

-- Birthday aliases
('birthday', 'birthday', 0.95),
('birthday', 'birth date', 0.95),
('birthday', 'birthdate', 0.95),
('birthday', 'dob', 0.90),
('birthday', 'date of birth', 0.95),

-- Meeting Date aliases
('meetingDate', 'meeting date', 0.95),
('meetingDate', 'meetingdate', 0.95),
('meetingDate', 'contact meeting date', 0.95),
('meetingDate', 'first met', 0.85),
('meetingDate', 'date met', 0.85),

-- Meeting Location aliases
('meetingLocation', 'meeting location', 0.95),
('meetingLocation', 'meetinglocation', 0.95),
('meetingLocation', 'contact meeting loc', 0.95),
('meetingLocation', 'where met', 0.85),
('meetingLocation', 'met at', 0.80),

-- Notes aliases
('notes', 'notes', 0.95),
('notes', 'note', 0.90),
('notes', 'comments', 0.85),
('notes', 'comment', 0.85),
('notes', 'description', 0.75),
('notes', 'remarks', 0.85),
('notes', 'memo', 0.80);


-- ============================================================
-- Stored Procedure: Update Job Counts
-- Recalculates row counts by status for a job
-- ============================================================
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS sp_update_import_job_counts(IN p_job_id INT)
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


-- ============================================================
-- View: v_import_jobs_summary
-- Summary view for job listing
-- ============================================================
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
