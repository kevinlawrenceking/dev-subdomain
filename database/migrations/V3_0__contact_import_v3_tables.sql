-- ============================================================
-- Contact Import V3 Schema Migration
-- Version: V3_0
-- Created: 2026-01-17
-- Purpose: Create V3 import tables with EAV pattern for facts
--
-- IMPORTANT: This migration creates NEW tables with import_v3_ prefix.
--            It does NOT modify any V2 tables.
-- ============================================================

-- ============================================================
-- Table 1: import_v3_jobs
-- Purpose: Primary tracking table for V3 import batches
-- ============================================================
CREATE TABLE IF NOT EXISTS import_v3_jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL COMMENT 'Owner FK to taousers.userid',

    -- File metadata
    source_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) NOT NULL COMMENT 'csv, xls, xlsx, vcf',
    file_size BIGINT DEFAULT NULL,
    file_hash VARCHAR(64) DEFAULT NULL COMMENT 'SHA-256 for idempotency',
    stored_file_path VARCHAR(500) DEFAULT NULL,

    -- Job state
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending|parsing|parsed|mapping|validating|reviewing|importing|completed|failed|cancelled',
    error_message TEXT DEFAULT NULL,

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    started_at DATETIME DEFAULT NULL,
    finished_at DATETIME DEFAULT NULL,

    -- Row counts (denormalized for performance)
    total_rows INT DEFAULT 0,
    parsed_rows INT DEFAULT 0,
    valid_rows INT DEFAULT 0,
    problem_rows INT DEFAULT 0,
    dupe_rows INT DEFAULT 0,
    imported_rows INT DEFAULT 0,
    updated_rows INT DEFAULT 0 COMMENT 'New in V3: track updates separately',
    skipped_rows INT DEFAULT 0,

    -- Options
    options_json TEXT DEFAULT NULL COMMENT 'Parsing and import options',

    -- V3 additions
    import_mode VARCHAR(20) DEFAULT 'create_only' COMMENT 'create_only|update_existing|create_and_update',
    allow_blank_overwrite TINYINT(1) DEFAULT 0 COMMENT 'If 1, blanks can clear existing values',
    relationship_system_default VARCHAR(50) DEFAULT NULL COMMENT 'Default system for new contacts',
    folder_assignment_json TEXT DEFAULT NULL COMMENT 'Folder assignment rules',

    -- Indexes
    INDEX IX_import_v3_jobs_userid_status (userid, status),
    INDEX IX_import_v3_jobs_created (created_at DESC),
    INDEX IX_import_v3_jobs_status (status),
    UNIQUE INDEX UX_import_v3_jobs_userid_file_hash (userid, file_hash)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Table 2: import_v3_columns
-- Purpose: Column mapping configuration per job
-- ============================================================
CREATE TABLE IF NOT EXISTS import_v3_columns (
    column_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',

    -- Source column info
    source_column_index INT NOT NULL COMMENT '0-based index from file',
    source_column_name VARCHAR(255) DEFAULT NULL COMMENT 'Header text from file',

    -- Mapping info
    mapped_field VARCHAR(50) DEFAULT NULL COMMENT 'TAO canonical field name or custom_field key',
    is_custom_field TINYINT(1) DEFAULT 0 COMMENT '1 if maps to contact_custom_fields',
    custom_field_id INT DEFAULT NULL COMMENT 'FK to contact_custom_fields.field_id if custom',

    -- Auto-mapping metadata
    confidence DECIMAL(3,2) DEFAULT NULL COMMENT 'Auto-map confidence 0.00-1.00',
    user_confirmed TINYINT(1) DEFAULT 0 COMMENT '1 if user approved mapping',

    -- Sample data for UI
    sample_values TEXT DEFAULT NULL COMMENT 'JSON array of sample values',

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX IX_import_v3_columns_job (job_id),
    UNIQUE INDEX UX_import_v3_columns_job_index (job_id, source_column_index)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Table 3: import_v3_rows
-- Purpose: Individual row storage (minimal - facts hold field data)
-- ============================================================
CREATE TABLE IF NOT EXISTS import_v3_rows (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',
    row_num INT NOT NULL COMMENT '1-based row number from file',

    -- Raw data (preserved for debugging/reparse)
    raw_json TEXT NOT NULL COMMENT 'Original cell values by column index',

    -- Row state
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending|validating|ready|problem|dupe|ignored|importing|imported|updated|failed',

    -- Validation summary
    error_count INT DEFAULT 0,
    warning_count INT DEFAULT 0,
    validation_summary TEXT DEFAULT NULL COMMENT 'JSON summary of validation issues',

    -- Duplicate detection
    dupe_candidates_json TEXT DEFAULT NULL COMMENT 'JSON array of candidate contacts',
    matched_contactid INT DEFAULT NULL COMMENT 'Best match contact ID',
    best_match_score INT DEFAULT NULL COMMENT 'Match confidence 0-100',

    -- User decision
    user_action VARCHAR(20) DEFAULT NULL COMMENT 'import_new|skip|update_existing|merge',
    user_action_at DATETIME DEFAULT NULL,

    -- Result tracking
    created_contactid INT DEFAULT NULL COMMENT 'New contact ID if created',
    updated_contactid INT DEFAULT NULL COMMENT 'Existing contact ID if updated',
    import_error TEXT DEFAULT NULL COMMENT 'Error message if failed',
    imported_at DATETIME DEFAULT NULL,

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX IX_import_v3_rows_job_status (job_id, status),
    INDEX IX_import_v3_rows_job_rownum (job_id, row_num),
    INDEX IX_import_v3_rows_status (status),
    INDEX IX_import_v3_rows_matched (matched_contactid),
    UNIQUE INDEX UX_import_v3_rows_job_rownum (job_id, row_num)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Table 4: import_v3_facts
-- Purpose: EAV pattern - one row per field per imported row
-- Enables field-level validation, conflict detection, and granular edits
-- ============================================================
CREATE TABLE IF NOT EXISTS import_v3_facts (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    row_id INT NOT NULL COMMENT 'FK to import_v3_rows.row_id',
    column_id INT NOT NULL COMMENT 'FK to import_v3_columns.column_id',

    -- Field identification
    field_name VARCHAR(50) NOT NULL COMMENT 'Canonical field name (e.g., email_business)',

    -- Values
    raw_value TEXT DEFAULT NULL COMMENT 'Original value from file',
    normalized_value TEXT DEFAULT NULL COMMENT 'Cleaned/normalized value',

    -- Validation state
    is_valid TINYINT(1) DEFAULT 1,
    validation_code VARCHAR(30) DEFAULT NULL COMMENT 'error code if invalid',
    validation_message VARCHAR(255) DEFAULT NULL COMMENT 'human-readable error',

    -- For duplicate/update scenarios
    existing_value TEXT DEFAULT NULL COMMENT 'Current value in contact (for updates)',
    has_conflict TINYINT(1) DEFAULT 0 COMMENT '1 if normalized != existing and both non-empty',
    user_choice VARCHAR(20) DEFAULT NULL COMMENT 'keep_existing|use_import|clear',

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX IX_import_v3_facts_row (row_id),
    INDEX IX_import_v3_facts_field (field_name),
    INDEX IX_import_v3_facts_validation (is_valid, validation_code),
    UNIQUE INDEX UX_import_v3_facts_row_column (row_id, column_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Table 5: import_v3_row_results
-- Purpose: Track finalize results separately from row state
-- Enables batch undo and detailed result reporting
-- ============================================================
CREATE TABLE IF NOT EXISTS import_v3_row_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    row_id INT NOT NULL COMMENT 'FK to import_v3_rows.row_id',
    job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id (denormalized for queries)',

    -- Result
    action_taken VARCHAR(20) NOT NULL COMMENT 'created|updated|skipped|failed',
    contactid INT DEFAULT NULL COMMENT 'Affected contact ID',

    -- Details
    fields_written INT DEFAULT 0 COMMENT 'Count of fields written',
    fields_skipped INT DEFAULT 0 COMMENT 'Count of fields skipped (blank/conflict)',
    items_created INT DEFAULT 0 COMMENT 'Count of contactitems created',
    notes_created INT DEFAULT 0 COMMENT 'Count of notes created',

    -- Error tracking
    error_code VARCHAR(30) DEFAULT NULL,
    error_message TEXT DEFAULT NULL,

    -- For undo capability
    undo_available TINYINT(1) DEFAULT 1,
    undo_json TEXT DEFAULT NULL COMMENT 'Data needed to reverse this import row',
    undone_at DATETIME DEFAULT NULL,

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX IX_import_v3_row_results_job (job_id),
    INDEX IX_import_v3_row_results_action (action_taken),
    INDEX IX_import_v3_row_results_contact (contactid),
    UNIQUE INDEX UX_import_v3_row_results_row (row_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Table 6: import_v3_events
-- Purpose: Audit trail for import operations
-- ============================================================
CREATE TABLE IF NOT EXISTS import_v3_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',

    -- Event info
    event_type VARCHAR(50) NOT NULL COMMENT 'created|parsing_started|parsing_completed|...',
    event_detail TEXT DEFAULT NULL COMMENT 'JSON details',

    -- Optional row reference
    row_id INT DEFAULT NULL COMMENT 'FK to import_v3_rows if row-specific',

    -- Actor
    userid INT DEFAULT NULL COMMENT 'User who triggered event (for future multi-user)',

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX IX_import_v3_events_job (job_id),
    INDEX IX_import_v3_events_type (event_type),
    INDEX IX_import_v3_events_created (created_at DESC),
    INDEX IX_import_v3_events_row (row_id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Table 7: contact_custom_fields
-- Purpose: User-defined field schema for extensibility
-- Allows users to create custom fields mapped during import
-- ============================================================
CREATE TABLE IF NOT EXISTS contact_custom_fields (
    field_id INT AUTO_INCREMENT PRIMARY KEY,
    userid INT NOT NULL COMMENT 'Owner FK to taousers.userid',

    -- Field definition
    field_key VARCHAR(50) NOT NULL COMMENT 'Internal key (e.g., custom_assistant_name)',
    field_label VARCHAR(100) NOT NULL COMMENT 'Display label',
    field_type VARCHAR(20) NOT NULL DEFAULT 'text' COMMENT 'text|email|phone|date|url|select',

    -- Options for select type
    options_json TEXT DEFAULT NULL COMMENT 'JSON array of options for select type',

    -- Validation
    is_required TINYINT(1) DEFAULT 0,
    max_length INT DEFAULT NULL,
    validation_regex VARCHAR(255) DEFAULT NULL,

    -- Display
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    show_in_list TINYINT(1) DEFAULT 0 COMMENT 'Show in contact list view',
    show_in_card TINYINT(1) DEFAULT 1 COMMENT 'Show in contact card view',

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX IX_contact_custom_fields_userid (userid),
    INDEX IX_contact_custom_fields_active (userid, is_active),
    UNIQUE INDEX UX_contact_custom_fields_userid_key (userid, field_key)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- End of V3_0 Migration
-- ============================================================
