CREATE TABLE IF NOT EXISTS import_field_mappings (
    mapping_id INT AUTO_INCREMENT PRIMARY KEY,
    canonical_field VARCHAR(50) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    field_category VARCHAR(30) NOT NULL,
    field_type VARCHAR(20) NOT NULL,
    is_required TINYINT(1) DEFAULT 0,
    max_length INT DEFAULT NULL,
    validation_regex VARCHAR(255) DEFAULT NULL,
    sort_order INT DEFAULT 0,
    UNIQUE INDEX UX_import_field_mappings_field (canonical_field)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_field_aliases (
    alias_id INT AUTO_INCREMENT PRIMARY KEY,
    canonical_field VARCHAR(50) NOT NULL,
    alias_pattern VARCHAR(100) NOT NULL,
    confidence DECIMAL(3,2) DEFAULT 0.90,
    INDEX IX_import_field_aliases_field (canonical_field),
    INDEX IX_import_field_aliases_pattern (alias_pattern),
    CONSTRAINT FK_import_field_aliases_field
        FOREIGN KEY (canonical_field) REFERENCES import_field_mappings(canonical_field)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL,
    source_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) NOT NULL,
    file_size BIGINT DEFAULT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
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
    skipped_rows INT DEFAULT 0,
    options_json TEXT DEFAULT NULL,
    stored_file_path VARCHAR(500) DEFAULT NULL,
    INDEX IX_import_jobs_userid_status (userid, status),
    INDEX IX_import_jobs_created (created_at DESC),
    INDEX IX_import_jobs_status (status),
    CONSTRAINT FK_import_jobs_userid
        FOREIGN KEY (userid) REFERENCES taousers(userid)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_job_columns (
    column_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    source_column_index INT NOT NULL,
    source_column_name VARCHAR(255) DEFAULT NULL,
    normalized_field VARCHAR(50) DEFAULT NULL,
    confidence DECIMAL(3,2) DEFAULT NULL,
    user_confirmed TINYINT(1) DEFAULT 0,
    sample_values TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX IX_import_job_columns_job (job_id),
    UNIQUE INDEX UX_import_job_columns_job_index (job_id, source_column_index),
    CONSTRAINT FK_import_job_columns_job
        FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_job_rows (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    row_num INT NOT NULL,
    raw_json TEXT NOT NULL,
    normalized_json TEXT DEFAULT NULL,
    validation_json TEXT DEFAULT NULL,
    dupe_json TEXT DEFAULT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    error_count INT DEFAULT 0,
    warning_count INT DEFAULT 0,
    matched_contactid INT DEFAULT NULL,
    best_match_score INT DEFAULT NULL,
    created_contactid INT DEFAULT NULL,
    user_action VARCHAR(20) DEFAULT NULL,
    import_error TEXT DEFAULT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX IX_import_job_rows_job_status (job_id, status),
    INDEX IX_import_job_rows_job_rownum (job_id, row_num),
    INDEX IX_import_job_rows_status (status),
    UNIQUE INDEX UX_import_job_rows_job_rownum (job_id, row_num),
    CONSTRAINT FK_import_job_rows_job
        FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_job_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_detail TEXT DEFAULT NULL,
    row_id INT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX IX_import_job_events_job (job_id),
    INDEX IX_import_job_events_type (event_type),
    INDEX IX_import_job_events_created (created_at),
    CONSTRAINT FK_import_job_events_job
        FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

INSERT IGNORE INTO import_field_aliases (canonical_field, alias_pattern, confidence) VALUES
('firstName', 'first name', 0.95),
('firstName', 'firstname', 0.95),
('firstName', 'first', 0.85),
('firstName', 'fname', 0.90),
('firstName', 'given name', 0.90),
('firstName', 'givenname', 0.90),
('firstName', 'forename', 0.85),
('lastName', 'last name', 0.95),
('lastName', 'lastname', 0.95),
('lastName', 'last', 0.85),
('lastName', 'lname', 0.90),
('lastName', 'surname', 0.90),
('lastName', 'family name', 0.90),
('lastName', 'familyname', 0.90),
('contactFullName', 'full name', 0.95),
('contactFullName', 'fullname', 0.95),
('contactFullName', 'name', 0.80),
('contactFullName', 'contact name', 0.90),
('contactFullName', 'contactname', 0.90),
('email_business', 'business email', 0.95),
('email_business', 'work email', 0.95),
('email_business', 'workemail', 0.95),
('email_business', 'businessemail', 0.95),
('email_business', 'email', 0.80),
('email_business', 'e-mail', 0.80),
('email_business', 'email address', 0.80),
('email_personal', 'personal email', 0.95),
('email_personal', 'home email', 0.90),
('email_personal', 'private email', 0.90),
('email_personal', 'personalemail', 0.95),
('phone_work', 'work phone', 0.95),
('phone_work', 'workphone', 0.95),
('phone_work', 'office phone', 0.90),
('phone_work', 'business phone', 0.90),
('phone_work', 'phone', 0.75),
('phone_work', 'telephone', 0.75),
('phone_work', 'tel', 0.70),
('phone_mobile', 'mobile phone', 0.95),
('phone_mobile', 'mobilephone', 0.95),
('phone_mobile', 'mobile', 0.90),
('phone_mobile', 'cell phone', 0.95),
('phone_mobile', 'cellphone', 0.95),
('phone_mobile', 'cell', 0.85),
('phone_home', 'home phone', 0.95),
('phone_home', 'homephone', 0.95),
('phone_home', 'home', 0.60),
('phone_home', 'personal phone', 0.85),
('company', 'company', 0.95),
('company', 'company name', 0.95),
('company', 'companyname', 0.95),
('company', 'organization', 0.90),
('company', 'organisation', 0.90),
('company', 'employer', 0.85),
('company', 'business', 0.75),
('department', 'department', 0.95),
('department', 'dept', 0.90),
('department', 'division', 0.85),
('jobTitle', 'job title', 0.95),
('jobTitle', 'jobtitle', 0.95),
('jobTitle', 'title', 0.80),
('jobTitle', 'position', 0.85),
('jobTitle', 'role', 0.75),
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
('tag1', 'tag1', 0.95),
('tag1', 'tag 1', 0.95),
('tag1', 'tag', 0.80),
('tag1', 'category', 0.75),
('tag1', 'type', 0.70),
('tag2', 'tag2', 0.95),
('tag2', 'tag 2', 0.95),
('tag3', 'tag3', 0.95),
('tag3', 'tag 3', 0.95),
('website', 'website', 0.95),
('website', 'web site', 0.95),
('website', 'url', 0.90),
('website', 'web', 0.80),
('website', 'homepage', 0.85),
('birthday', 'birthday', 0.95),
('birthday', 'birth date', 0.95),
('birthday', 'birthdate', 0.95),
('birthday', 'dob', 0.90),
('birthday', 'date of birth', 0.95),
('meetingDate', 'meeting date', 0.95),
('meetingDate', 'meetingdate', 0.95),
('meetingDate', 'contact meeting date', 0.95),
('meetingDate', 'first met', 0.85),
('meetingDate', 'date met', 0.85),
('meetingLocation', 'meeting location', 0.95),
('meetingLocation', 'meetinglocation', 0.95),
('meetingLocation', 'contact meeting loc', 0.95),
('meetingLocation', 'where met', 0.85),
('meetingLocation', 'met at', 0.80),
('notes', 'notes', 0.95),
('notes', 'note', 0.90),
('notes', 'comments', 0.85),
('notes', 'comment', 0.85),
('notes', 'description', 0.75),
('notes', 'remarks', 0.85),
('notes', 'memo', 0.80);

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

INSERT INTO import_field_mappings
    (canonical_field, display_name, field_category, field_type, is_required, max_length, sort_order)
SELECT 'relationship_system', 'Relationship System', 'contact', 'select', 0, 50, 90
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM import_field_mappings WHERE canonical_field = 'relationship_system'
);

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

CREATE TABLE IF NOT EXISTS import_v3_jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL,
    source_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) NOT NULL,
    file_size BIGINT DEFAULT NULL,
    file_hash VARCHAR(64) DEFAULT NULL,
    stored_file_path VARCHAR(500) DEFAULT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
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
    updated_rows INT DEFAULT 0,
    skipped_rows INT DEFAULT 0,
    options_json TEXT DEFAULT NULL,
    import_mode VARCHAR(20) DEFAULT 'create_only',
    allow_blank_overwrite TINYINT(1) DEFAULT 0,
    relationship_system_default VARCHAR(50) DEFAULT NULL,
    folder_assignment_json TEXT DEFAULT NULL,
    INDEX IX_import_v3_jobs_userid_status (userid, status),
    INDEX IX_import_v3_jobs_created (created_at DESC),
    INDEX IX_import_v3_jobs_status (status),
    UNIQUE INDEX UX_import_v3_jobs_userid_file_hash (userid, file_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_v3_columns (
    column_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    source_column_index INT NOT NULL,
    source_column_name VARCHAR(255) DEFAULT NULL,
    mapped_field VARCHAR(50) DEFAULT NULL,
    is_custom_field TINYINT(1) DEFAULT 0,
    custom_field_id INT DEFAULT NULL,
    confidence DECIMAL(3,2) DEFAULT NULL,
    user_confirmed TINYINT(1) DEFAULT 0,
    sample_values TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX IX_import_v3_columns_job (job_id),
    UNIQUE INDEX UX_import_v3_columns_job_index (job_id, source_column_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_v3_rows (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    row_num INT NOT NULL,
    raw_json TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    error_count INT DEFAULT 0,
    warning_count INT DEFAULT 0,
    validation_summary TEXT DEFAULT NULL,
    dupe_candidates_json TEXT DEFAULT NULL,
    matched_contactid INT DEFAULT NULL,
    best_match_score INT DEFAULT NULL,
    user_action VARCHAR(20) DEFAULT NULL,
    user_action_at DATETIME DEFAULT NULL,
    created_contactid INT DEFAULT NULL,
    updated_contactid INT DEFAULT NULL,
    import_error TEXT DEFAULT NULL,
    imported_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX IX_import_v3_rows_job_status (job_id, status),
    INDEX IX_import_v3_rows_job_rownum (job_id, row_num),
    INDEX IX_import_v3_rows_status (status),
    INDEX IX_import_v3_rows_matched (matched_contactid),
    UNIQUE INDEX UX_import_v3_rows_job_rownum (job_id, row_num)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_v3_facts (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    row_id INT NOT NULL,
    column_id INT NOT NULL,
    field_name VARCHAR(50) NOT NULL,
    raw_value TEXT DEFAULT NULL,
    normalized_value TEXT DEFAULT NULL,
    is_valid TINYINT(1) DEFAULT 1,
    validation_code VARCHAR(30) DEFAULT NULL,
    validation_message VARCHAR(255) DEFAULT NULL,
    existing_value TEXT DEFAULT NULL,
    has_conflict TINYINT(1) DEFAULT 0,
    user_choice VARCHAR(20) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX IX_import_v3_facts_row (row_id),
    INDEX IX_import_v3_facts_field (field_name),
    INDEX IX_import_v3_facts_validation (is_valid, validation_code),
    UNIQUE INDEX UX_import_v3_facts_row_column (row_id, column_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_v3_row_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    row_id INT NOT NULL,
    job_id INT NOT NULL,
    action_taken VARCHAR(20) NOT NULL,
    contactid INT DEFAULT NULL,
    fields_written INT DEFAULT 0,
    fields_skipped INT DEFAULT 0,
    items_created INT DEFAULT 0,
    notes_created INT DEFAULT 0,
    error_code VARCHAR(30) DEFAULT NULL,
    error_message TEXT DEFAULT NULL,
    undo_available TINYINT(1) DEFAULT 1,
    undo_json TEXT DEFAULT NULL,
    undone_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX IX_import_v3_row_results_job (job_id),
    INDEX IX_import_v3_row_results_action (action_taken),
    INDEX IX_import_v3_row_results_contact (contactid),
    UNIQUE INDEX UX_import_v3_row_results_row (row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_v3_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_detail TEXT DEFAULT NULL,
    row_id INT DEFAULT NULL,
    userid INT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX IX_import_v3_events_job (job_id),
    INDEX IX_import_v3_events_type (event_type),
    INDEX IX_import_v3_events_created (created_at DESC),
    INDEX IX_import_v3_events_row (row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contact_custom_fields (
    field_id INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL,
    field_key VARCHAR(50) NOT NULL,
    field_label VARCHAR(100) NOT NULL,
    field_type VARCHAR(20) NOT NULL DEFAULT 'text',
    options_json TEXT DEFAULT NULL,
    is_required TINYINT(1) DEFAULT 0,
    max_length INT DEFAULT NULL,
    validation_regex VARCHAR(255) DEFAULT NULL,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    show_in_list TINYINT(1) DEFAULT 0,
    show_in_card TINYINT(1) DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX IX_contact_custom_fields_userid (userid),
    INDEX IX_contact_custom_fields_active (userid, is_active),
    UNIQUE INDEX UX_contact_custom_fields_userid_key (userid, field_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS feature_flags (
    flag_key VARCHAR(50) NOT NULL PRIMARY KEY,
    is_enabled TINYINT(1) NOT NULL DEFAULT 0,
    description VARCHAR(255) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX IX_feature_flags_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

INSERT INTO feature_flags (flag_key, is_enabled, description)
VALUES ('import_v3_enabled', 0, 'Contact Import V3 - new multi-format importer with staging and review')
ON DUPLICATE KEY UPDATE updated_at = NOW();

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
    END IF;
END //

DELIMITER ;

CALL AddIndexIfNotExists(
    'contactdetails_tbl',
    'idx_contactdetails_tbl_dupe_v3',
    '(userid, isdeleted, contactid)'
);

CALL AddIndexIfNotExists(
    'contactitems_tbl',
    'idx_contactitems_tbl_dupe_v3',
    '(contactid, itemStatus, isDeleted, valueCategory, valuetext(100))'
);

CALL AddIndexIfNotExists(
    'contactitems_tbl',
    'idx_contactitems_tbl_category_status',
    '(valueCategory, itemStatus, isDeleted, contactid)'
);

DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

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

UPDATE taousers_tbl
SET    shareID = UUID()
WHERE  shareID IS NULL
    OR shareID = '';

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

SET @admin_compid = (SELECT compid FROM pgpages WHERE pgDir = 'admin-support' LIMIT 1);

INSERT INTO pgpages (pgDir, pgname, pgTitle, pgHeading, pgFilename, compid, isdef, pk, update_type, datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN)
SELECT 'admin-users', 'Admin Users', 'User Management', 'User Management', 'admin-users.cfm', @admin_compid, 1, 'userid', 'custom', 'N', 'N', 'N', 'N'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgpages WHERE pgDir = 'admin-users');

INSERT INTO pgpages (pgDir, pgname, pgTitle, pgHeading, pgFilename, compid, isdef, pk, update_type, datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN)
SELECT 'admin-users-detail', 'Admin User Detail', 'User Detail', 'User Detail', 'admin-users-detail.cfm', @admin_compid, 1, 'userid', 'custom', 'N', 'N', 'N', 'N'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgpages WHERE pgDir = 'admin-users-detail');

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
