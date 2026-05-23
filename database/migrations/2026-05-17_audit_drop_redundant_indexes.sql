-- =============================================================================
-- TAO Prod Audit R4/R5: drop redundant indexes + 1 duplicate FK
-- Phases 0-2 evidence: database/audit/2026-05-17_prod_audit_phase{0,1,2}.md
--
-- Every index below is a strict leftmost-prefix subset of, or an exact
-- non-unique duplicate of, another index on the same table (Phase 1 §5).
-- Index-pin safety cleared in Phase 2: ZERO `FORCE/USE/IGNORE INDEX` in the
-- CFML codebase. None of these back an FK constraint after the drop (a wider
-- index keeps the FK column leftmost in every case).
--
-- Pure write-overhead reduction; no read-path loss. Fully reversible:
--   ROLLBACK: 2026-05-17_audit_drop_redundant_indexes_ROLLBACK.sql
-- Run on dev (new_development) first, smoke-test, then prod
-- (actorsbusinessoffice). Idempotent.
--
-- PRIOR STATE: this migration's baseline is "post 2026-04-03_drop_redundant
-- _single_column_indexes". If BOTH this ROLLBACK and the 2026-04-03 ROLLBACK
-- are ever run, run the 2026-04-03 ROLLBACK FIRST, then this one, so the
-- composite coverers exist before the single-column indexes are restored.
--
-- EVIDENCE -- exact live prod definitions captured 2026-05-17 from
-- information_schema.STATISTICS (TABLE_NAME, INDEX_NAME, SEQ, COLUMN, SUB_PART,
-- NON_UNIQUE). Every dropped index's ROLLBACK recreation is column-for-column
-- identical to this; no index below has a SUB_PART prefix; all dropped indexes
-- are NON_UNIQUE=1.
--   actionusers_tbl.idx_actionusers_actionID = (actionid)
--       covered by idx_au_action_user(actionid,userid)
--   funotifications_tbl.idx_funotifications_notstatus = (notStatus)
--       covered by idx_funot_status_startdate(notStatus,notStartDate)
--   contactdetails_tbl.idx_cd_user_deleted = (userID,IsDeleted)
--       covered by idx_contactdetails_tbl_dupe_v3(userID,IsDeleted,contactID)
--   contactitems_tbl.idx_ci_contact_category_status = (contactID,valueCategory,itemStatus)
--       covered by idx_contactitems(contactID,valueCategory,itemStatus,primary_YN)
--   contactitems_tbl.valueCategory = (valueCategory)
--       covered by idx_contactitems_tbl_category_status(valueCategory,itemStatus,IsDeleted,contactID)
--   events_tbl.ix_e_event = (eventID)  -- exact dup of PRIMARY(eventID)
--   auditions.idx_auditions_userid_date = (userid,audition_date)
--       covered by idx_auditions_dupe_detect(userid,audition_date,project_name[100])
--   audunions.unionName = (unionName)
--       covered by uk_audunions_name_country(unionName,countryid) [UNIQUE]
--   import_job_rows.IX_import_job_rows_job_rownum = (job_id,row_num)
--       dup of UX_import_job_rows_job_rownum(job_id,row_num) [UNIQUE]
--   import_v3_rows.IX_import_v3_rows_job_rownum = (job_id,row_num)
--       dup of UX_import_v3_rows_job_rownum(job_id,row_num) [UNIQUE]
--   import_auditions_rows.idx_iar_job_rownum = (job_id,row_num)
--       dup of idx_iar_job_row(job_id,row_num) [UNIQUE]
--   sharetokens.IDX_ShareTokens_Token = (token)
--       dup of UC_ShareTokens_Token(token) [UNIQUE]
--
-- FK SAFETY (verified via information_schema.KEY_COLUMN_USAGE 2026-05-17):
--   contactdetails_tbl HAS FK_contactdetails_taousers (userID -> taousers_tbl.
--   userID). Dropping idx_cd_user_deleted is still safe: idx_contactdetails_
--   tbl_dupe_v3 keeps userID as its leftmost column, satisfying InnoDB's FK
--   index requirement. No other dropped index sits on an FK column.
-- =============================================================================

DELIMITER //
DROP PROCEDURE IF EXISTS DropIndexIfExists //
CREATE PROCEDURE DropIndexIfExists(IN p_table VARCHAR(64), IN p_index VARCHAR(64))
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=p_table AND INDEX_NAME=p_index;
    IF v > 0 THEN
        SET @s = CONCAT('DROP INDEX `',p_index,'` ON `',p_table,'`');
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
        SELECT CONCAT('DROPPED: ',p_table,'.',p_index) AS result;
    ELSE
        SELECT CONCAT('SKIPPED (absent): ',p_table,'.',p_index) AS result;
    END IF;
END //
DELIMITER ;

-- Subsumed by a wider composite (leftmost-prefix):
CALL DropIndexIfExists('actionusers_tbl','idx_actionusers_actionID');      -- < idx_au_action_user(actionid,userid)
CALL DropIndexIfExists('funotifications_tbl','idx_funotifications_notstatus'); -- < idx_funot_status_startdate(notStatus,notStartDate)
CALL DropIndexIfExists('contactdetails_tbl','idx_cd_user_deleted');        -- < idx_contactdetails_tbl_dupe_v3(userID,IsDeleted,contactID). FK_contactdetails_taousers(userID) STAYS covered: userID is leftmost in idx_contactdetails_tbl_dupe_v3, satisfying InnoDB's FK index requirement.
CALL DropIndexIfExists('contactitems_tbl','idx_ci_contact_category_status'); -- < idx_contactitems(contactID,valueCategory,itemStatus,primary_YN)
CALL DropIndexIfExists('contactitems_tbl','valueCategory');                -- < idx_contactitems_tbl_category_status(valueCategory,...)
CALL DropIndexIfExists('events_tbl','ix_e_event');                         -- exact dup of PRIMARY(eventID)
CALL DropIndexIfExists('auditions','idx_auditions_userid_date');           -- < idx_auditions_dupe_detect(userid,audition_date,project_name)
CALL DropIndexIfExists('audunions','unionName');                           -- < uk_audunions_name_country(unionName,countryid)

-- Non-unique duplicates of a UNIQUE index on identical columns (systemic IX/UX
-- pattern across all three import subsystems + sharetokens):
CALL DropIndexIfExists('import_job_rows','IX_import_job_rows_job_rownum');     -- dup of UX_import_job_rows_job_rownum
CALL DropIndexIfExists('import_v3_rows','IX_import_v3_rows_job_rownum');       -- dup of UX_import_v3_rows_job_rownum
CALL DropIndexIfExists('import_auditions_rows','idx_iar_job_rownum');          -- dup of idx_iar_job_row (unique)
CALL DropIndexIfExists('sharetokens','IDX_ShareTokens_Token');                -- dup of UC_ShareTokens_Token (unique)

DROP PROCEDURE IF EXISTS DropIndexIfExists;

-- ---------------------------------------------------------------------------
-- R5: duplicate FK on auditions_tbl.audStepID (FK_auditions_audsteps_2 is an
-- exact duplicate of FK_auditions_audsteps -> audsteps(audstepid)). Drop the
-- FK constraint, then its now-orphan backing index.
-- ---------------------------------------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS DropDupAuditionsFK //
CREATE PROCEDURE DropDupAuditionsFK()
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.TABLE_CONSTRAINTS
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='auditions_tbl'
        AND CONSTRAINT_NAME='FK_auditions_audsteps_2' AND CONSTRAINT_TYPE='FOREIGN KEY';
    IF v > 0 THEN
        ALTER TABLE auditions_tbl DROP FOREIGN KEY FK_auditions_audsteps_2;
        SELECT 'DROPPED FK: auditions_tbl.FK_auditions_audsteps_2' AS result;
    ELSE
        SELECT 'SKIPPED (absent): FK_auditions_audsteps_2' AS result;
    END IF;
    SELECT COUNT(*) INTO v FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='auditions_tbl'
        AND INDEX_NAME='FK_auditions_audsteps_2';
    IF v > 0 THEN
        DROP INDEX `FK_auditions_audsteps_2` ON `auditions_tbl`;
        SELECT 'DROPPED INDEX: auditions_tbl.FK_auditions_audsteps_2' AS result;
    END IF;
END //
DELIMITER ;
CALL DropDupAuditionsFK();
DROP PROCEDURE IF EXISTS DropDupAuditionsFK;

SELECT 'R4/R5 redundant-index + duplicate-FK migration complete' AS status;
