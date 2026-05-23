-- =============================================================================
-- ROLLBACK: 2026-05-17_audit_drop_redundant_indexes.sql
-- Recreates the 12 dropped indexes with their original definitions and
-- re-adds the duplicate FK. Idempotent.
--
-- Each CREATE INDEX below is column-for-column identical to the live prod
-- definition captured 2026-05-17 (information_schema.STATISTICS) and embedded
-- as the EVIDENCE block in the forward migration. All 12 are NON_UNIQUE=1
-- (hence CREATE INDEX, not UNIQUE) with no SUB_PART prefix. Verified, not
-- inferred.
--
-- ROLLBACK ORDER: if the 2026-04-03_drop_redundant_single_column_indexes
-- ROLLBACK is also being run, run THAT one first, then this one.
-- =============================================================================

DELIMITER //
DROP PROCEDURE IF EXISTS AddIndexIfNotExists //
CREATE PROCEDURE AddIndexIfNotExists(IN p_table VARCHAR(64), IN p_index VARCHAR(64), IN p_def TEXT)
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=p_table AND INDEX_NAME=p_index;
    IF v = 0 THEN
        SET @s = CONCAT('CREATE INDEX `',p_index,'` ON `',p_table,'` ',p_def);
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
        SELECT CONCAT('RECREATED: ',p_table,'.',p_index) AS result;
    ELSE
        SELECT CONCAT('SKIPPED (exists): ',p_table,'.',p_index) AS result;
    END IF;
END //
DELIMITER ;

CALL AddIndexIfNotExists('actionusers_tbl','idx_actionusers_actionID','(actionid)');
CALL AddIndexIfNotExists('funotifications_tbl','idx_funotifications_notstatus','(notStatus)');
CALL AddIndexIfNotExists('contactdetails_tbl','idx_cd_user_deleted','(userID,IsDeleted)');
CALL AddIndexIfNotExists('contactitems_tbl','idx_ci_contact_category_status','(contactID,valueCategory,itemStatus)');
CALL AddIndexIfNotExists('contactitems_tbl','valueCategory','(valueCategory)');
CALL AddIndexIfNotExists('events_tbl','ix_e_event','(eventID)');
CALL AddIndexIfNotExists('auditions','idx_auditions_userid_date','(userid,audition_date)');
CALL AddIndexIfNotExists('audunions','unionName','(unionName)');
CALL AddIndexIfNotExists('import_job_rows','IX_import_job_rows_job_rownum','(job_id,row_num)');
CALL AddIndexIfNotExists('import_v3_rows','IX_import_v3_rows_job_rownum','(job_id,row_num)');
CALL AddIndexIfNotExists('import_auditions_rows','idx_iar_job_rownum','(job_id,row_num)');
CALL AddIndexIfNotExists('sharetokens','IDX_ShareTokens_Token','(token)');

DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

-- Re-add the duplicate FK (and its auto index) on auditions_tbl.audStepID.
DELIMITER //
DROP PROCEDURE IF EXISTS ReAddDupAuditionsFK //
CREATE PROCEDURE ReAddDupAuditionsFK()
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.TABLE_CONSTRAINTS
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='auditions_tbl'
        AND CONSTRAINT_NAME='FK_auditions_audsteps_2' AND CONSTRAINT_TYPE='FOREIGN KEY';
    IF v = 0 THEN
        ALTER TABLE auditions_tbl
          ADD CONSTRAINT FK_auditions_audsteps_2
          FOREIGN KEY (audStepID) REFERENCES audsteps(audstepid);
        SELECT 'RE-ADDED FK: auditions_tbl.FK_auditions_audsteps_2' AS result;
    ELSE
        SELECT 'SKIPPED (exists): FK_auditions_audsteps_2' AS result;
    END IF;
END //
DELIMITER ;
CALL ReAddDupAuditionsFK();
DROP PROCEDURE IF EXISTS ReAddDupAuditionsFK;

SELECT 'R4/R5 rollback complete' AS status;
