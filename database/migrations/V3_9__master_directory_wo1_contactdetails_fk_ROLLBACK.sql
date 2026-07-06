-- ============================================================================
-- V3_9 ROLLBACK  Master Contact Directory -- WO-1 (part 3 of 3)
--   Drop the three master-link foreign keys. Run this BEFORE the V3_7 rollback
--   (the FKs pin the pointer columns and their indexes).
--
-- PROJECT : TAO / dev-subdomain / branch dev
-- ENGINE  : MySQL 8.0.41. DATABASE()-scoped; run USE <schema>; first.
-- IDEMPOTENT: each drop is guarded on information_schema.
-- ============================================================================

DROP PROCEDURE IF EXISTS wo1_drop_fk;
DELIMITER //
CREATE PROCEDURE wo1_drop_fk(IN p_name VARCHAR(64))
BEGIN
    IF (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
          WHERE CONSTRAINT_SCHEMA = DATABASE()
            AND TABLE_NAME        = 'contactdetails_tbl'
            AND CONSTRAINT_NAME   = p_name
            AND CONSTRAINT_TYPE   = 'FOREIGN KEY') > 0 THEN
        SET @ddl = CONCAT('ALTER TABLE `contactdetails_tbl` DROP FOREIGN KEY `', p_name, '`');
        PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;
    END IF;
END //
DELIMITER ;

CALL wo1_drop_fk('fk_cd_company_location');
CALL wo1_drop_fk('fk_cd_master_co_contact');
CALL wo1_drop_fk('fk_cd_master_coid');

DROP PROCEDURE IF EXISTS wo1_drop_fk;

-- --- POST-CHECK: no WO-1 FKs remain ---
SELECT COUNT(*) AS residual_wo1_fks_expect_0
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = DATABASE()
  AND TABLE_NAME = 'contactdetails_tbl'
  AND CONSTRAINT_TYPE = 'FOREIGN KEY'
  AND CONSTRAINT_NAME IN ('fk_cd_company_location','fk_cd_master_co_contact','fk_cd_master_coid');
