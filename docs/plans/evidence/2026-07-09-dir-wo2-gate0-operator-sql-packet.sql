-- ============================================================================
-- DIR-WO-2 GATE 0 -- OPERATOR SQL PACKET (READ-ONLY, live verification)
-- Binding: TAO-MCD-P1 / dev-subdomain / branch dev . Staged 2026-07-09 (CC).
--
-- WHY THIS FILE EXISTS: CC has no DB channel (no mysql CLI on the workstation,
--   no credentials in the agent environment -- same constraint recorded in
--   2026-07-08-prod-promotion-runbook.md: "CC cannot execute any of this").
--   Every query below is READ-ONLY (information_schema / SHOW / SELECT COUNT /
--   LIMIT samples). Run each block on BOTH schemas where marked, paste raw
--   output back to CC for the GATE-0 addendum.
-- Tooling: mysql CLI or HeidiSQL query tab. NOT phpMyAdmin (F19).
-- ============================================================================

-- ############ BLOCK 1 (G0-2a) -- 12-column presence, BOTH schemas ############
-- Run once with USE new_development; then once with USE actorsbusinessoffice;
SELECT DATABASE() AS schema_under_test;
SELECT column_name, column_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = DATABASE() AND table_name = 'contactdetails_tbl'
  AND column_name IN ('master_co_contact_id','master_coid','company_location_id',
                      'contactCompany','contactPhone','contactEmail',
                      'contactCompany_src','contactPhone_src','contactEmail_src',
                      'master_linked_date','master_last_sync',
                      'contactPhoto_src')            -- 12th: out of scope, report-only
ORDER BY column_name;
-- Expect 12 rows in each schema (11 in-scope + contactPhoto_src).

-- ############ BLOCK 2 (G0-2b) -- view security + shape, BOTH schemas #########
SHOW CREATE VIEW contactdetails\G
SELECT table_schema, security_type, is_updatable
FROM information_schema.views
WHERE table_schema = DATABASE() AND table_name = 'contactdetails';
SELECT COUNT(*) AS view_col_count_expect_44
FROM information_schema.columns
WHERE table_schema = DATABASE() AND table_name = 'contactdetails';

-- ############ BLOCK 3 (G0-2c/d) -- backfill + FK state, BOTH schemas #########
SELECT COUNT(*)                                    AS rows_total,
       SUM(contactCompany IS NOT NULL)             AS company_nonnull,
       SUM(contactPhone   IS NOT NULL)             AS phone_nonnull,
       SUM(contactEmail   IS NOT NULL)             AS email_nonnull,
       SUM(master_co_contact_id IS NOT NULL)       AS person_ptr_set,
       SUM(master_coid          IS NOT NULL)       AS coid_ptr_set,
       SUM(company_location_id  IS NOT NULL)       AS office_ptr_set
FROM contactdetails_tbl;
-- Expected: dev company_nonnull=435 phone=276 email=292 (V3_10 Part A);
--           prod all 0 (V3_10 NOT applied); pointers 0 everywhere.

SELECT rc.CONSTRAINT_NAME, kcu.REFERENCED_TABLE_NAME, kcu.REFERENCED_COLUMN_NAME,
       rc.DELETE_RULE, rc.UPDATE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS rc
JOIN information_schema.KEY_COLUMN_USAGE kcu
  ON kcu.CONSTRAINT_SCHEMA = rc.CONSTRAINT_SCHEMA AND kcu.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
WHERE rc.CONSTRAINT_SCHEMA = DATABASE() AND rc.TABLE_NAME = 'contactdetails_tbl'
  AND rc.CONSTRAINT_NAME IN ('fk_cd_company_location','fk_cd_master_co_contact','fk_cd_master_coid');
-- Expect 3 rows / SET NULL / RESTRICT in BOTH schemas (V3_9 applied 07-07 dev, 07-08 prod).

-- ############ BLOCK 4 (G0-4) -- seed verification, dev only ##################
-- USE new_development;
SELECT 'co_contacts' t, COUNT(*) n FROM co_contacts
UNION ALL SELECT 'co_locations', COUNT(*) FROM co_locations
UNION ALL SELECT 'companies',    COUNT(*) FROM companies;
-- Expected (at 2026-07-07 seed): 25200 / 12617 / 10740.
SELECT id, fullname            FROM co_contacts  ORDER BY id      LIMIT 3;
SELECT colocid, location, coid FROM co_locations ORDER BY colocid LIMIT 3;
SELECT coid, coName            FROM companies    ORDER BY coid    LIMIT 3;

-- ############ BLOCK 5 (G0-5) -- co_locations key + cardinality, dev ##########
SHOW CREATE TABLE co_locations\G
SELECT SUM(cnt = 0) AS companies_zero_loc,
       SUM(cnt = 1) AS companies_one_loc,
       SUM(cnt > 1) AS companies_multi_loc
FROM (SELECT c.coid, COUNT(l.colocid) cnt
        FROM companies c LEFT JOIN co_locations l ON l.coid = c.coid
       GROUP BY c.coid) t;

-- ############ BLOCK 6 (G0-6b) -- live view DDL, BOTH schemas #################
SHOW CREATE VIEW contacts_ss\G
SHOW CREATE VIEW contacts_ss_target\G
SHOW CREATE VIEW contacts_ss_followup\G
SHOW CREATE VIEW contacts_ss_maint\G
SHOW CREATE VIEW sharez\G
SHOW CREATE VIEW sharezz\G
-- contacts_ss base-view DDL exists NOWHERE in-repo; this capture is the only source.

-- ############ BLOCK 7 (G0-6d) -- contactitems provenance check, dev ##########
SELECT column_name FROM information_schema.columns
WHERE table_schema = DATABASE() AND table_name = 'contactitems_tbl'
ORDER BY ordinal_position;
-- Expect NO src/source/origin/provenance column.

-- ############ BLOCK 8 (G0-11) -- co_contacts search fields, dev ##############
SELECT COUNT(*) AS co_contacts_total FROM co_contacts;
SHOW INDEX FROM co_contacts;
SELECT column_name FROM information_schema.columns
WHERE table_schema = DATABASE() AND table_name = 'co_contacts'
  AND (column_name LIKE '%phone%' OR column_name LIKE '%email%' OR column_name LIKE '%mail%');
-- Expect empty set (no person-level phone/email) + fullname MUL index.
-- ============================================================================
