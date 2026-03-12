-- =============================================================================
-- A1_0__import_auditions_tables.sql
-- Audition Import staging tables (mirrors Contact Import V3 architecture)
-- =============================================================================

-- 1. import_auditions_jobs (Master job tracker)
CREATE TABLE IF NOT EXISTS import_auditions_jobs (
  job_id           INT AUTO_INCREMENT PRIMARY KEY,
  userid           INT NOT NULL,
  source_filename  VARCHAR(500),
  file_type        VARCHAR(10),               -- csv, xls, xlsx
  file_size        BIGINT,
  file_hash        VARCHAR(64),               -- SHA-256
  stored_file_path VARCHAR(1000),
  status           ENUM('created','uploaded','parsing','parsed','mapping',
                        'reviewing','finalizing','completed','failed','cancelled'),
  error_message    TEXT,
  total_rows       INT DEFAULT 0,
  parsed_rows      INT DEFAULT 0,
  valid_rows       INT DEFAULT 0,
  problem_rows     INT DEFAULT 0,
  dupe_rows        INT DEFAULT 0,
  imported_rows    INT DEFAULT 0,
  skipped_rows     INT DEFAULT 0,
  options_json     TEXT,
  import_mode      VARCHAR(30) DEFAULT 'create_only',
  created_at       DATETIME DEFAULT NOW(),
  updated_at       DATETIME DEFAULT NOW() ON UPDATE NOW(),
  started_at       DATETIME,
  finished_at      DATETIME,

  INDEX idx_iaj_userid_status (userid, status),
  INDEX idx_iaj_created_at (created_at DESC),
  INDEX idx_iaj_status (status),
  UNIQUE idx_iaj_userid_filehash (userid, file_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. import_auditions_columns (Column mapping)
CREATE TABLE IF NOT EXISTS import_auditions_columns (
  column_id           INT AUTO_INCREMENT PRIMARY KEY,
  job_id              INT NOT NULL,
  source_column_index INT,
  source_column_name  VARCHAR(500),
  mapped_field        VARCHAR(100),
  confidence          DECIMAL(3,2) DEFAULT 0.00,
  user_confirmed      TINYINT DEFAULT 0,
  sample_values       TEXT,
  intent              VARCHAR(50),            -- ignore|audition_field|note
  target_key          VARCHAR(100),
  transform_json      TEXT,

  INDEX idx_iac_job_id (job_id),
  UNIQUE idx_iac_job_col (job_id, source_column_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. import_auditions_rows (Individual rows)
CREATE TABLE IF NOT EXISTS import_auditions_rows (
  row_id               INT AUTO_INCREMENT PRIMARY KEY,
  job_id               INT NOT NULL,
  row_num              INT,
  raw_json             TEXT,
  status               ENUM('pending','validating','ready','problem','dupe',
                            'ignored','finalizing','imported','failed'),
  error_count          INT DEFAULT 0,
  warning_count        INT DEFAULT 0,
  validation_summary   TEXT,
  dupe_candidates_json TEXT,
  matched_audition_id  INT,
  best_match_score     DECIMAL(5,2) DEFAULT 0,
  user_action          VARCHAR(30),           -- import_new|skip|update_existing
  user_action_at       DATETIME,
  created_audition_id  INT,
  import_error         TEXT,
  imported_at          DATETIME,
  created_at           DATETIME DEFAULT NOW(),
  updated_at           DATETIME DEFAULT NOW() ON UPDATE NOW(),

  INDEX idx_iar_job_status (job_id, status),
  INDEX idx_iar_job_rownum (job_id, row_num),
  INDEX idx_iar_status (status),
  UNIQUE idx_iar_job_row (job_id, row_num)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. import_auditions_facts (EAV field storage)
CREATE TABLE IF NOT EXISTS import_auditions_facts (
  fact_id            INT AUTO_INCREMENT PRIMARY KEY,
  row_id             INT NOT NULL,
  column_id          INT,
  field_name         VARCHAR(100),
  raw_value          TEXT,
  normalized_value   TEXT,
  is_valid           TINYINT DEFAULT 1,
  validation_code    VARCHAR(50),
  validation_message VARCHAR(500),
  existing_value     TEXT,
  has_conflict       TINYINT DEFAULT 0,
  user_choice        VARCHAR(30),
  created_at         DATETIME DEFAULT NOW(),
  updated_at         DATETIME DEFAULT NOW() ON UPDATE NOW(),

  INDEX idx_iaf_row_id (row_id),
  INDEX idx_iaf_field_name (field_name),
  INDEX idx_iaf_valid (is_valid, validation_code),
  UNIQUE idx_iaf_row_col (row_id, column_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. import_auditions_row_results (Finalization audit trail)
CREATE TABLE IF NOT EXISTS import_auditions_row_results (
  result_id      INT AUTO_INCREMENT PRIMARY KEY,
  row_id         INT NOT NULL,
  job_id         INT,
  action_taken   VARCHAR(20),                 -- created|updated|skipped|failed
  audition_id    INT,
  fields_written INT DEFAULT 0,
  fields_skipped INT DEFAULT 0,
  error_code     VARCHAR(50),
  error_message  TEXT,
  undo_available TINYINT DEFAULT 0,
  undo_json      TEXT,
  undone_at      DATETIME,
  created_at     DATETIME DEFAULT NOW(),

  INDEX idx_iarr_job_id (job_id),
  INDEX idx_iarr_action (action_taken),
  INDEX idx_iarr_audition (audition_id),
  UNIQUE idx_iarr_row (row_id)               -- Idempotency guarantee
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. import_auditions_events (Audit log)
CREATE TABLE IF NOT EXISTS import_auditions_events (
  event_id     INT AUTO_INCREMENT PRIMARY KEY,
  job_id       INT NOT NULL,
  event_type   VARCHAR(50),
  event_detail TEXT,
  row_id       INT,
  userid       INT,
  created_at   DATETIME DEFAULT NOW(),

  INDEX idx_iae_job_id (job_id),
  INDEX idx_iae_event_type (event_type),
  INDEX idx_iae_created_at (created_at DESC),
  INDEX idx_iae_row_id (row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
