-- =============================================================================
-- A1_1__import_auditions_indexes.sql
-- Performance indexes for audition duplicate detection and common queries
--
-- REQUIRES: `auditions` production table must already exist.
-- Compatible with MySQL 5.7+ / 8.0.x (avoids CREATE INDEX IF NOT EXISTS
-- which requires 8.0.29+).
-- =============================================================================

-- Safe index creation: skips if index already exists, proceeds if it does not.
-- Uses information_schema lookup wrapped in a stored procedure.

DROP PROCEDURE IF EXISTS _add_index_if_missing;

DELIMITER //
CREATE PROCEDURE _add_index_if_missing(
    IN p_table    VARCHAR(128),
    IN p_index    VARCHAR(128),
    IN p_sql      TEXT
)
BEGIN
    DECLARE idx_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO idx_exists
      FROM information_schema.statistics
     WHERE table_schema = DATABASE()
       AND table_name   = p_table
       AND index_name   = p_index
     LIMIT 1;

    IF idx_exists = 0 THEN
        SET @ddl = p_sql;
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //
DELIMITER ;

-- Index on auditions table for duplicate detection queries
CALL _add_index_if_missing('auditions', 'idx_auditions_userid_status',
    'CREATE INDEX idx_auditions_userid_status ON auditions (userid, status)');

CALL _add_index_if_missing('auditions', 'idx_auditions_userid_date',
    'CREATE INDEX idx_auditions_userid_date ON auditions (userid, audition_date)');

CALL _add_index_if_missing('auditions', 'idx_auditions_userid_project',
    'CREATE INDEX idx_auditions_userid_project ON auditions (userid, project_name(100))');

-- Composite index for the most common dupe detection pattern
CALL _add_index_if_missing('auditions', 'idx_auditions_dupe_detect',
    'CREATE INDEX idx_auditions_dupe_detect ON auditions (userid, audition_date, project_name(100))');

-- Index for contact resolution during finalize
CALL _add_index_if_missing('auditions', 'idx_auditions_contactid',
    'CREATE INDEX idx_auditions_contactid ON auditions (contactid)');

-- Clean up helper procedure
DROP PROCEDURE IF EXISTS _add_index_if_missing;
