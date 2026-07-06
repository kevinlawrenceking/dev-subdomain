-- ============================================================================
-- V3_7  Master Contact Directory -- WO-1 (part 1 of 3)
--       contactdetails_tbl: denormalized hot fields, master-link pointers,
--       provenance flags, supporting indexes, and the contactPhoto widen.
--
-- PROJECT     : TAO / dev-subdomain / branch dev
-- WORK ORDER  : Master Contact Directory Phase 1, WO-1 (schema authoring)
-- CLEARANCE   : WO-0b Decision Memo CLEARED WITH AMENDMENTS (A1-A6), 2026-07-06.
-- ENGINE      : MySQL 8.0.41 (Q1). Runs verbatim on BOTH new_development (dev)
--               and actorsbusinessoffice (prod) via DATABASE(). Run USE <schema>; first.
-- TARGET      : contactdetails_tbl (BASE TABLE). The `contactdetails` VIEW is
--               rebuilt separately in V3_8, applied in the SAME migration window (A4).
-- APPLY ORDER : V3_7 (this file) -> V3_8 (view) in one window; V3_9 (FKs) later,
--               only AFTER backfill validation (A2). See the execution runbook:
--               docs/plans/evidence/2026-07-06-wo1-execution-runbook.md
--
-- IDEMPOTENT / REPLAY-SAFE (NN#5): every ADD/MODIFY/INDEX is guarded against
--   information_schema; re-running is a no-op. MySQL 8 has no `ADD COLUMN IF NOT
--   EXISTS`, so temporary helper procedures gate each change. Both procedures are
--   dropped at the end -- the script leaves no residue.
--
-- DECISIONS FOLDED IN (evidence: docs/plans/evidence/2026-07-04-wo0b-pane-abo.txt
--   and 2026-07-04-wo0b-prod-Q8-Q15-master.txt):
--   * contactCompany varchar(255) -- match source valueCompany(255); active max 174 (F3/D-5, A-amend).
--   * contactPhone varchar(100) (active max 57), contactEmail varchar(150) (active max 104) (Q6).
--   * master_linked_date / master_last_sync = DATETIME, NOT TIMESTAMP (Q19, cross-cut fact #2).
--   * contactPhoto widen varchar(255) -> varchar(500) -- source co_contacts.image_url is
--     varchar(500); width-match is deterministic (A1). Collation preserved (utf8mb4_unicode_ci).
--   * pointer cols INT NULL (signed) -> FK targets are all signed int PK
--     (co_locations.colocid, co_contacts.id, companies.coid). FKs are a SEPARATE
--     follow-up file (V3_9) applied post-backfill (A2). This file only adds the
--     columns + supporting indexes.
--   * _src ENUM('user','master') NOT NULL DEFAULT 'user' -- user-authored data wins;
--     existing rows backfill as 'user' from their own contactitems (A1: 'user' beats 'master').
--   * NO master_link_status column -- link state is DERIVED (master_co_contact_id IS NOT NULL),
--     per the WO-1 ruling column list. This intentionally diverges from plan-v1 §7 prose;
--     flagged for the WO-4/WO-5 authors.
--   * recordname is VIRTUAL GENERATED (= contactFullName) -- untouched here; never written (F1).
--   * Columns are appended at table end (no AFTER clause) -- physical order is immaterial;
--     the V3_8 view defines presentation order. Keeps each guarded ADD independent.
--
-- ROLLBACK    : V3_7__master_directory_wo1_contactdetails_columns_ROLLBACK.sql
--               (drop it AFTER V3_9 FK rollback -- FKs pin the indexed columns).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Step 0: Environment guard. Abort cleanly if the base table is missing.
-- ----------------------------------------------------------------------------
SET @tbl_ok = (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name   = 'contactdetails_tbl'
      AND table_type   = 'BASE TABLE'
);
-- If @tbl_ok <> 1 the CALLs below still no-op (guarded), but surface it loudly:
SELECT IF(@tbl_ok = 1,
          'OK: contactdetails_tbl present in this schema',
          'ABORT: contactdetails_tbl NOT a base table in this schema -- check USE <schema>')
       AS preflight;

-- ----------------------------------------------------------------------------
-- Step 1: Guarded column adds (idempotent).
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS wo1_add_col;
DELIMITER //
CREATE PROCEDURE wo1_add_col(IN p_col VARCHAR(64), IN p_def TEXT)
BEGIN
    IF (SELECT COUNT(*) FROM information_schema.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME   = 'contactdetails_tbl'
            AND COLUMN_NAME  = p_col) = 0 THEN
        SET @ddl = CONCAT('ALTER TABLE `contactdetails_tbl` ADD COLUMN ', p_def);
        PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;
    END IF;
END //
DELIMITER ;

-- Denormalized hot fields (read-path acceleration; backfilled by a later WO)
CALL wo1_add_col('contactPhone',        '`contactPhone` varchar(100) NULL DEFAULT NULL');
CALL wo1_add_col('contactEmail',        '`contactEmail` varchar(150) NULL DEFAULT NULL');
CALL wo1_add_col('contactCompany',      '`contactCompany` varchar(255) NULL DEFAULT NULL');

-- Provenance flags: which side owns the current value ('user' upload/edit wins)
CALL wo1_add_col('contactPhone_src',    '`contactPhone_src` ENUM(''user'',''master'') NOT NULL DEFAULT ''user''');
CALL wo1_add_col('contactEmail_src',    '`contactEmail_src` ENUM(''user'',''master'') NOT NULL DEFAULT ''user''');
CALL wo1_add_col('contactCompany_src',  '`contactCompany_src` ENUM(''user'',''master'') NOT NULL DEFAULT ''user''');
CALL wo1_add_col('contactPhoto_src',    '`contactPhoto_src` ENUM(''user'',''master'') NOT NULL DEFAULT ''user''');

-- Master-link pointers (signed INT; FKs added in V3_9 after backfill validation)
CALL wo1_add_col('company_location_id', '`company_location_id` int NULL DEFAULT NULL');   -- -> co_locations.colocid
CALL wo1_add_col('master_co_contact_id','`master_co_contact_id` int NULL DEFAULT NULL');  -- -> co_contacts.id (the person)
CALL wo1_add_col('master_coid',         '`master_coid` int NULL DEFAULT NULL');           -- -> companies.coid

-- Master sync bookkeeping (DATETIME, not TIMESTAMP -- Q19)
CALL wo1_add_col('master_linked_date',  '`master_linked_date` datetime NULL DEFAULT NULL');
CALL wo1_add_col('master_last_sync',    '`master_last_sync` datetime NULL DEFAULT NULL');

DROP PROCEDURE IF EXISTS wo1_add_col;

-- ----------------------------------------------------------------------------
-- Step 2: Guarded supporting indexes for the three pointer columns.
--         (Support the FK adds in V3_9 and the master-filter queries in WO-5/6.)
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS wo1_add_idx;
DELIMITER //
CREATE PROCEDURE wo1_add_idx(IN p_idx VARCHAR(64), IN p_cols VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM information_schema.STATISTICS
          WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME   = 'contactdetails_tbl'
            AND INDEX_NAME   = p_idx) = 0 THEN
        SET @ddl = CONCAT('ALTER TABLE `contactdetails_tbl` ADD INDEX `', p_idx, '` (', p_cols, ')');
        PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;
    END IF;
END //
DELIMITER ;

CALL wo1_add_idx('idx_cd_master_person', '`master_co_contact_id`');
CALL wo1_add_idx('idx_cd_master_co',     '`master_coid`');
CALL wo1_add_idx('idx_cd_company_loc',   '`company_location_id`');

DROP PROCEDURE IF EXISTS wo1_add_idx;

-- ----------------------------------------------------------------------------
-- Step 3: Widen contactPhoto varchar(255) -> varchar(500) (A1). Guarded so a
--         replay is a no-op; collation preserved to avoid an implicit convert.
-- ----------------------------------------------------------------------------
SET @need_widen = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'contactdetails_tbl'
      AND COLUMN_NAME  = 'contactPhoto'
      AND CHARACTER_MAXIMUM_LENGTH < 500
);
SET @ddl = IF(@need_widen = 1,
    'ALTER TABLE `contactdetails_tbl` MODIFY COLUMN `contactPhoto` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL',
    'SELECT ''contactPhoto already >= varchar(500) -- widen skipped'' AS note');
PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;

-- ----------------------------------------------------------------------------
-- POST-CHECK: all 12 new columns present, 3 indexes present, contactPhoto=500.
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS new_cols_present_expect_12
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'contactdetails_tbl'
  AND COLUMN_NAME IN ('contactPhone','contactEmail','contactCompany',
                      'contactPhone_src','contactEmail_src','contactCompany_src','contactPhoto_src',
                      'company_location_id','master_co_contact_id','master_coid',
                      'master_linked_date','master_last_sync');

SELECT COUNT(DISTINCT INDEX_NAME) AS new_idx_present_expect_3
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'contactdetails_tbl'
  AND INDEX_NAME IN ('idx_cd_master_person','idx_cd_master_co','idx_cd_company_loc');

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'contactdetails_tbl'
  AND COLUMN_NAME = 'contactPhoto';
