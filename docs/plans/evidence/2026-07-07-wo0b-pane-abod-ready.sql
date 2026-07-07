-- =============================================================================
-- WO-0b PANE 2/2 — READY-TO-RUN — DSN=abod — schema=new_development
-- Staged 2026-07-07 (CC). Mirror of Appendix A (WO0-PROOF-BUNDLE.md) for the DEV pane.
-- Binding: TAO / dev-subdomain / branch dev.
--
-- PURPOSE: capture the DEV-side DDL that closes the two remaining Master-Directory
--          blockers:
--   (1) *** V3_8 33-vs-32 RECONCILE ***  -> block A-Q2 below (SHOW CREATE VIEW
--       contactdetails). This is the single item holding V3_8 at DRAFT. STOP-on-delta.
--   (2) dev<->prod hot-table DRIFT DIFF (F14-F19) -> the DDL captures (tables + views +
--       master DDL/indexes/counts) diffed against the abo pane
--       (docs/plans/evidence/2026-07-04-wo0b-pane-abo.txt).
--
-- READ-ONLY: every statement is SELECT / SHOW / EXPLAIN. No writes, no DDL, no temp tables.
-- RUN VIA mysql CLI ONLY (never phpMyAdmin — it rewrites SQL SECURITY/DEFINER; NN#12).
--   Example:  mysql -A new_development -t < 2026-07-07-wo0b-pane-abod-ready.sql > pane-abod-out.txt
--   (\G lines render vertically; -t gives boxed grids for the tabular ones.)
-- Then save the output verbatim as docs/plans/evidence/2026-07-07-wo0b-pane-abod.txt
-- and paste back — I write Addendum B (drift register) and complete the V3_8 reconcile.
-- =============================================================================

-- A-Q1  Engine/version (confirm dev == prod 8.0.41)
SELECT VERSION() AS version;

-- ============================ CRITICAL: V3_8 UNBLOCK ==========================
-- A-Q2  contactdetails view DDL. Capture DEFINER / SQL SECURITY / ALGORITHM and the
--       EXACT column list + order. Prod pane said 32 base cols but "33-col" was noted
--       loosely -> reconcile here. Runbook Step 2 STOPs on ANY delta vs V3_8's rebuild.
SHOW CREATE VIEW contactdetails\G
-- =============================================================================

-- A-Q3  All affected view DDL (drift diff vs prod; confirm sharezz double-z exists on dev)
SHOW CREATE VIEW contactitems\G
SHOW CREATE VIEW contacts_ss\G
SHOW CREATE VIEW contacts_ss_followup\G
SHOW CREATE VIEW contacts_ss_maint\G
SHOW CREATE VIEW contacts_ss_target\G
SHOW CREATE VIEW sharez\G
SHOW CREATE VIEW sharezz\G          -- the actually-used (double-z) view; confirm presence on dev

-- A-Q4  contactdetails base table DDL: settle recordname (VIRTUAL GENERATED on prod) +
--       collision-check the 12 WO-1 new columns on DEV (must be zero rows).
SHOW CREATE TABLE contactdetails_tbl\G
SELECT COLUMN_NAME, DATA_TYPE, EXTRA, GENERATION_EXPRESSION
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactdetails_tbl'
  AND (COLUMN_NAME = 'recordname'
    OR COLUMN_NAME IN ('contactPhone','contactEmail','contactCompany','company_location_id',
                       'contactPhone_src','contactEmail_src','contactCompany_src','contactphoto_src',
                       'master_co_contact_id','master_coid','master_link_status',
                       'master_linked_date','master_last_sync'));

-- A-Q5  contactitems base DDL + distributions (drift diff vs prod counts)
SHOW CREATE TABLE contactitems_tbl\G
SELECT itemstatus, COUNT(*) FROM contactitems_tbl GROUP BY itemstatus;
SELECT valuetype, COUNT(*) FROM contactitems_tbl
 WHERE valuecategory IN ('Phone','Email','Company') GROUP BY valuetype;

-- A-Q8  Master tables on DEV (co_locations DDL, counts, indexes) — drift vs prod (10,740 /
--       25,200 / 12,617). co_locations PK confirmed on prod = `colocid`.
SHOW CREATE TABLE co_locations\G
SHOW CREATE TABLE companies\G
SHOW CREATE TABLE co_contacts\G
SELECT (SELECT COUNT(*) FROM companies)    AS companies,
       (SELECT COUNT(*) FROM co_contacts)  AS co_contacts,
       (SELECT COUNT(*) FROM co_locations) AS co_locations;
SHOW INDEX FROM companies;  SHOW INDEX FROM co_contacts;  SHOW INDEX FROM co_locations;

-- A-Q9  Deployment reality on DEV (which schema(s) hold the master tables) + grants label
SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.TABLES
 WHERE TABLE_NAME IN ('companies','co_contacts','co_locations');
SHOW GRANTS FOR CURRENT_USER();          -- Q9b — prod proved kingk436@% ALL PRIVS; label DEV

-- A-Q13 Grid EXPLAIN on DEV — substitute a real :uid before running
EXPLAIN SELECT contactid, col2b, col3, col4, col5, hlink
 FROM contacts_ss WHERE userid = 30 ORDER BY col1 LIMIT 0,25;   -- swap 30 for a real dev userid

-- A-Q18 Collations (drift vs prod utf8mb4_unicode_ci)
SHOW FULL COLUMNS FROM contactitems_tbl;    -- inspect valuecategory/valuetype/itemstatus Collation
SELECT TABLE_NAME, TABLE_COLLATION FROM information_schema.TABLES
 WHERE TABLE_NAME IN ('contactitems_tbl','contactdetails_tbl');

-- -----------------------------------------------------------------------------
-- The following (Q6/Q7/Q14/Q15/Q19) were already PROVEN on abo (prod data authoritative).
-- Re-run on DEV only if you want a dev-side sanity pass; NOT required for the drift diff
-- or the V3_8 reconcile. Left here for completeness / parity with Appendix A.
-- -----------------------------------------------------------------------------
-- A-Q6  Length/junk audit (prod: Company 174 / Email 104 / Phone 57)
SELECT 'Phone' cat, COUNT(*) n, MAX(CHAR_LENGTH(valuetext)) maxtext
 FROM contactitems_tbl WHERE valuecategory='Phone' AND itemstatus='Active' AND IsDeleted=0;
SELECT 'Company' cat, MAX(CHAR_LENGTH(valuecompany)) maxco
 FROM contactitems_tbl WHERE valuecategory='Company' AND itemstatus='Active' AND IsDeleted=0;
-- A-Q19 Time zone
SELECT @@global.time_zone, @@session.time_zone;

-- =============================================================================
-- STOP after capture. No WO-1 apply. Paste output back for Addendum B + V3_8 reconcile.
-- =============================================================================
