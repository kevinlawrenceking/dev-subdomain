-- =============================================================================
-- WO-0b PANE 2/2 — READY-TO-RUN (HeidiSQL variant) — DSN=abod — schema=new_development
-- Staged 2026-07-07 (CC). Semicolon-only twin of 2026-07-07-wo0b-pane-abod-ready.sql
-- for HeidiSQL / any GUI client (no \G; HeidiSQL does not support it).
-- Binding: TAO / dev-subdomain / branch dev.
--
-- HEIDISQL USAGE:
--   1. Left tree: make sure the active database = new_development (dev / abod).
--   2. File > Load SQL file... this file (or paste into a Query tab).
--   3. Press F9 to run the whole tab. Each SELECT/SHOW opens its own result grid tab.
--   4. CAPTURE: for each result grid, click into it, Ctrl+A (select all rows),
--      Ctrl+C (Heidi copies full multi-line cell values as tab-delimited text),
--      paste into docs/plans/evidence/2026-07-07-wo0b-pane-abod.txt. Label each block
--      with its A-Qn tag so the diff vs the abo pane is unambiguous.
--   5. For the SHOW CREATE VIEW/TABLE rows: the whole DDL sits in one cell — after
--      selecting the row, the full text also shows in Heidi's blue preview pane at the
--      bottom; copy from there if the grid cell truncates on screen.
--   * Run SHOW CREATE VIEW as a QUERY (below). Do NOT read the DDL via Heidi's visual
--     view editor — that regenerates/reformats. The query returns the server's exact DDL.
--
-- READ-ONLY: every statement is SELECT / SHOW / EXPLAIN. No writes, no DDL, no temp tables.
-- Paste output back — I write Addendum B (drift register) and complete the V3_8 reconcile.
-- =============================================================================

-- A-Q1  Engine/version (confirm dev == prod 8.0.41)
SELECT VERSION() AS version;

-- ============================ CRITICAL: V3_8 UNBLOCK ==========================
-- A-Q2  contactdetails view DDL. Capture DEFINER / SQL SECURITY / ALGORITHM and the
--       EXACT column list + order. Reconciles 33-vs-32. Runbook Step 2 STOPs on any delta.
SHOW CREATE VIEW contactdetails;
-- =============================================================================

-- A-Q3  All affected view DDL (drift diff vs prod; confirm sharezz double-z exists on dev)
SHOW CREATE VIEW contactitems;
SHOW CREATE VIEW contacts_ss;
SHOW CREATE VIEW contacts_ss_followup;
SHOW CREATE VIEW contacts_ss_maint;
SHOW CREATE VIEW contacts_ss_target;
SHOW CREATE VIEW sharez;
SHOW CREATE VIEW sharezz;          -- the actually-used (double-z) view; confirm presence on dev

-- A-Q4  contactdetails base table DDL: settle recordname (VIRTUAL GENERATED on prod) +
--       collision-check the 12 WO-1 new columns on DEV (must be zero rows).
SHOW CREATE TABLE contactdetails_tbl;
SELECT COLUMN_NAME, DATA_TYPE, EXTRA, GENERATION_EXPRESSION
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactdetails_tbl'
  AND (COLUMN_NAME = 'recordname'
    OR COLUMN_NAME IN ('contactPhone','contactEmail','contactCompany','company_location_id',
                       'contactPhone_src','contactEmail_src','contactCompany_src','contactphoto_src',
                       'master_co_contact_id','master_coid','master_link_status',
                       'master_linked_date','master_last_sync'));

-- A-Q5  contactitems base DDL + distributions (drift diff vs prod counts)
SHOW CREATE TABLE contactitems_tbl;
SELECT itemstatus, COUNT(*) FROM contactitems_tbl GROUP BY itemstatus;
SELECT valuetype, COUNT(*) FROM contactitems_tbl
 WHERE valuecategory IN ('Phone','Email','Company') GROUP BY valuetype;

-- A-Q8  Master tables on DEV (co_locations DDL, counts, indexes) — drift vs prod (10,740 /
--       25,200 / 12,617). co_locations PK confirmed on prod = `colocid`.
SHOW CREATE TABLE co_locations;
SHOW CREATE TABLE companies;
SHOW CREATE TABLE co_contacts;
SELECT (SELECT COUNT(*) FROM companies)    AS companies,
       (SELECT COUNT(*) FROM co_contacts)  AS co_contacts,
       (SELECT COUNT(*) FROM co_locations) AS co_locations;
SHOW INDEX FROM companies;
SHOW INDEX FROM co_contacts;
SHOW INDEX FROM co_locations;

-- A-Q9  Deployment reality on DEV (which schema(s) hold the master tables) + grants label
SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.TABLES
 WHERE TABLE_NAME IN ('companies','co_contacts','co_locations');
SHOW GRANTS FOR CURRENT_USER();          -- Q9b — prod proved kingk436@% ALL PRIVS; label DEV

-- A-Q13 Grid EXPLAIN on DEV — substitute a real userid before running
EXPLAIN SELECT contactid, col2b, col3, col4, col5, hlink
 FROM contacts_ss WHERE userid = 30 ORDER BY col1 LIMIT 0,25;   -- swap 30 for a real dev userid

-- A-Q18 Collations (drift vs prod utf8mb4_unicode_ci)
SHOW FULL COLUMNS FROM contactitems_tbl;    -- inspect valuecategory/valuetype/itemstatus Collation
SELECT TABLE_NAME, TABLE_COLLATION FROM information_schema.TABLES
 WHERE TABLE_NAME IN ('contactitems_tbl','contactdetails_tbl');

-- -----------------------------------------------------------------------------
-- Optional (already PROVEN on abo / prod authoritative) — dev sanity only:
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
