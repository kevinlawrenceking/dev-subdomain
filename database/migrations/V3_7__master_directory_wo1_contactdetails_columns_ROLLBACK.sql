-- ============================================================================
-- V3_7 ROLLBACK  Master Contact Directory -- WO-1 (part 1 of 3)
--   Reverses V3_7__master_directory_wo1_contactdetails_columns.sql:
--   drops the 3 supporting indexes, drops the 12 added columns, and narrows
--   contactPhoto back to varchar(255).
--
-- PROJECT : TAO / dev-subdomain / branch dev
-- ENGINE  : MySQL 8.0.41. DATABASE()-scoped; run USE <schema>; first.
-- IDEMPOTENT: each drop is guarded; re-running is a no-op.
--
-- ORDER (IMPORTANT):
--   1. Run V3_9__..._fk_ROLLBACK.sql FIRST -- the foreign keys pin the pointer
--      columns/indexes and their DROP will fail otherwise.
--   2. Run V3_8__..._view_ROLLBACK.sql (rebuild the 32-column view) BEFORE this
--      file -- the live 44-column view references columns dropped here.
--   3. Then run this file.
--
-- WARNING (contactPhoto narrow): if any contactPhoto value written after the
--   widen exceeds 255 chars (master IMDb URLs can), narrowing to varchar(255)
--   will TRUNCATE under non-strict mode or ERROR under STRICT mode. The guard
--   below refuses to narrow while any value is longer than 255 and reports the
--   count instead -- clear those rows first if a true narrow is required.
-- ============================================================================

-- --- Step 1: drop supporting indexes (guarded) ---
DROP PROCEDURE IF EXISTS wo1_drop_idx;
DELIMITER //
CREATE PROCEDURE wo1_drop_idx(IN p_idx VARCHAR(64))
BEGIN
    IF (SELECT COUNT(*) FROM information_schema.STATISTICS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME   = 'contactdetails_tbl'
            AND INDEX_NAME   = p_idx) > 0 THEN
        SET @ddl = CONCAT('ALTER TABLE `contactdetails_tbl` DROP INDEX `', p_idx, '`');
        PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;
    END IF;
END //
DELIMITER ;
CALL wo1_drop_idx('idx_cd_master_person');
CALL wo1_drop_idx('idx_cd_master_co');
CALL wo1_drop_idx('idx_cd_company_loc');
DROP PROCEDURE IF EXISTS wo1_drop_idx;

-- --- Step 2: drop added columns (guarded) ---
DROP PROCEDURE IF EXISTS wo1_drop_col;
DELIMITER //
CREATE PROCEDURE wo1_drop_col(IN p_col VARCHAR(64))
BEGIN
    IF (SELECT COUNT(*) FROM information_schema.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME   = 'contactdetails_tbl'
            AND COLUMN_NAME  = p_col) > 0 THEN
        SET @ddl = CONCAT('ALTER TABLE `contactdetails_tbl` DROP COLUMN `', p_col, '`');
        PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;
    END IF;
END //
DELIMITER ;
CALL wo1_drop_col('master_last_sync');
CALL wo1_drop_col('master_linked_date');
CALL wo1_drop_col('master_coid');
CALL wo1_drop_col('master_co_contact_id');
CALL wo1_drop_col('company_location_id');
CALL wo1_drop_col('contactPhoto_src');
CALL wo1_drop_col('contactCompany_src');
CALL wo1_drop_col('contactEmail_src');
CALL wo1_drop_col('contactPhone_src');
CALL wo1_drop_col('contactCompany');
CALL wo1_drop_col('contactEmail');
CALL wo1_drop_col('contactPhone');
DROP PROCEDURE IF EXISTS wo1_drop_col;

-- --- Step 3: narrow contactPhoto back to varchar(255) (guarded + safety check) ---
SET @too_long = (
    SELECT COUNT(*) FROM contactdetails_tbl
    WHERE contactPhoto IS NOT NULL AND CHAR_LENGTH(contactPhoto) > 255
);
SET @is_wide = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'contactdetails_tbl'
      AND COLUMN_NAME  = 'contactPhoto'
      AND CHARACTER_MAXIMUM_LENGTH > 255
);
SET @ddl = IF(@is_wide = 1 AND @too_long = 0,
    'ALTER TABLE `contactdetails_tbl` MODIFY COLUMN `contactPhoto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL',
    CONCAT('SELECT ', @too_long, ' AS rows_over_255_blocking_narrow, ',
           @is_wide, ' AS is_currently_wide'));
PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;

-- --- POST-CHECK: all new columns/indexes gone ---
SELECT COUNT(*) AS residual_new_cols_expect_0
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'contactdetails_tbl'
  AND COLUMN_NAME IN ('contactPhone','contactEmail','contactCompany',
                      'contactPhone_src','contactEmail_src','contactCompany_src','contactPhoto_src',
                      'company_location_id','master_co_contact_id','master_coid',
                      'master_linked_date','master_last_sync');
