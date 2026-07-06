-- ============================================================================
-- V3_9  Master Contact Directory -- WO-1 (part 3 of 3): FOREIGN KEYS
--       Add the three master-link foreign keys to contactdetails_tbl.
--
-- PROJECT   : TAO / dev-subdomain / branch dev
-- CLEARANCE : WO-0b Decision Memo CLEARED WITH AMENDMENTS, 2026-07-06 (A2).
-- ENGINE    : MySQL 8.0.41, all tables InnoDB (Q8). DATABASE()-scoped.
--
-- SEPARATE-FILE / DEFERRED APPLY (A2 two-step): this file is NOT applied in the
--   V3_7/V3_8 window. It runs ONLY AFTER the backfill WO has populated and
--   VALIDATED the pointer columns. Adding an FK against unvalidated data will
--   fail on the first orphan row (error 1452) and abort the ALTER.
--
-- FK ACTIONS (A2, LOCKED): ON DELETE SET NULL, ON UPDATE RESTRICT on all three.
--   Deleting a master row degrades a contact to "unlinked" (pointer -> NULL);
--   it never cascades a delete and never breaks the contact. SET NULL requires
--   the FK column to be NULLable -- all three are INT NULL (V3_7). Column type
--   parity confirmed: pointers are signed int; targets are signed int PK
--   (co_locations.colocid, co_contacts.id, companies.coid) -- Addendum-B P1 / Q8.
--
-- !!! MANDATORY PRE-FLIGHT (must all return 0 before running the CALLs) !!!
--   0-sentinel trap (F12): co_contacts.coid uses 0 for "no company". The backfill
--   must map that to NULL for master_coid -- a stored 0 has no companies.coid=0
--   parent and will fail the FK. The orphan checks below catch it.
--
--   SELECT COUNT(*) AS orphan_company_loc FROM contactdetails_tbl d
--     WHERE d.company_location_id IS NOT NULL
--       AND NOT EXISTS (SELECT 1 FROM co_locations l WHERE l.colocid = d.company_location_id);
--   SELECT COUNT(*) AS orphan_master_person FROM contactdetails_tbl d
--     WHERE d.master_co_contact_id IS NOT NULL
--       AND NOT EXISTS (SELECT 1 FROM co_contacts c WHERE c.id = d.master_co_contact_id);
--   SELECT COUNT(*) AS orphan_master_coid FROM contactdetails_tbl d
--     WHERE d.master_coid IS NOT NULL
--       AND NOT EXISTS (SELECT 1 FROM companies co WHERE co.coid = d.master_coid);
--   -- Also confirm no 0-sentinel leaked in:
--   SELECT COUNT(*) AS zero_sentinel_master_coid FROM contactdetails_tbl WHERE master_coid = 0;
--
-- ROLLBACK  : V3_9__master_directory_wo1_contactdetails_fk_ROLLBACK.sql
--             (must run before V3_7 rollback drops the pointer columns).
-- ============================================================================

-- --- Guard: the three master tables must exist in this schema ---
SET @targets_ok = (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name IN ('co_locations','co_contacts','companies')
);
SELECT IF(@targets_ok = 3,
          'OK: co_locations + co_contacts + companies present',
          CONCAT('ABORT: expected 3 master tables in this schema, found ', @targets_ok))
       AS preflight;

DROP PROCEDURE IF EXISTS wo1_add_fk;
DELIMITER //
CREATE PROCEDURE wo1_add_fk(IN p_name VARCHAR(64), IN p_ddl TEXT)
BEGIN
    IF (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
          WHERE CONSTRAINT_SCHEMA = DATABASE()
            AND TABLE_NAME        = 'contactdetails_tbl'
            AND CONSTRAINT_NAME   = p_name
            AND CONSTRAINT_TYPE   = 'FOREIGN KEY') = 0 THEN
        SET @ddl = CONCAT('ALTER TABLE `contactdetails_tbl` ADD CONSTRAINT `', p_name, '` ', p_ddl);
        PREPARE s FROM @ddl; EXECUTE s; DEALLOCATE PREPARE s;
    END IF;
END //
DELIMITER ;

CALL wo1_add_fk('fk_cd_company_location',
    'FOREIGN KEY (`company_location_id`) REFERENCES `co_locations` (`colocid`) ON DELETE SET NULL ON UPDATE RESTRICT');
CALL wo1_add_fk('fk_cd_master_co_contact',
    'FOREIGN KEY (`master_co_contact_id`) REFERENCES `co_contacts` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT');
CALL wo1_add_fk('fk_cd_master_coid',
    'FOREIGN KEY (`master_coid`) REFERENCES `companies` (`coid`) ON DELETE SET NULL ON UPDATE RESTRICT');

DROP PROCEDURE IF EXISTS wo1_add_fk;

-- --- POST-CHECK: three FKs present with the expected referential actions ---
SELECT rc.CONSTRAINT_NAME, kcu.REFERENCED_TABLE_NAME, kcu.REFERENCED_COLUMN_NAME,
       rc.DELETE_RULE, rc.UPDATE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS rc
JOIN information_schema.KEY_COLUMN_USAGE kcu
  ON kcu.CONSTRAINT_SCHEMA = rc.CONSTRAINT_SCHEMA
 AND kcu.CONSTRAINT_NAME   = rc.CONSTRAINT_NAME
WHERE rc.CONSTRAINT_SCHEMA = DATABASE()
  AND rc.TABLE_NAME = 'contactdetails_tbl'
  AND rc.CONSTRAINT_NAME IN ('fk_cd_company_location','fk_cd_master_co_contact','fk_cd_master_coid');
