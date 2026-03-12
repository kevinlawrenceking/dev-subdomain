-- =============================================================================
-- A1_1__import_auditions_indexes.sql
-- Performance indexes for audition duplicate detection and common queries
-- =============================================================================

-- Index on auditions table for duplicate detection queries
-- (same date + project, same date + actor)
CREATE INDEX IF NOT EXISTS idx_auditions_userid_status
  ON auditions (userid, status);

CREATE INDEX IF NOT EXISTS idx_auditions_userid_date
  ON auditions (userid, audition_date);

CREATE INDEX IF NOT EXISTS idx_auditions_userid_project
  ON auditions (userid, project_name(100));

-- Composite index for the most common dupe detection pattern
CREATE INDEX IF NOT EXISTS idx_auditions_dupe_detect
  ON auditions (userid, audition_date, project_name(100));

-- Index for contact resolution during finalize
CREATE INDEX IF NOT EXISTS idx_auditions_contactid
  ON auditions (contactid);
