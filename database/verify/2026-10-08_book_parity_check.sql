-- =====================================================================================
-- 2026-10-08  The Book (Master Directory) dev/prod parity check  --  READ-ONLY
--
-- Run from any connection that can read information_schema for BOTH schemas
-- (new_development = dev, actorsbusinessoffice = prod). SELECT only; writes nothing.
-- Every row reports dev vs prod side by side; any row with status <> 'OK' is a gap.
--
-- Inventory is derived from source (not guessed):
--   services/MasterDirectoryService.cfc, services/ContactService.cfc (updatePrimary,
--   writeMasterSync), ajax/master/*.cfm, ajax/contact/updateprimary.cfm,
--   include/contact_info.cfm, include/master_link_preview.cfm
--   + database/migrations/V3_7..V3_9 and 2026-08-29_wo8_prod_promotion_master_audit_correction.sql
-- =====================================================================================

-- Safety: this session cannot write even if a statement below were edited by mistake.
SET SESSION TRANSACTION READ ONLY;

-- 1) Required tables / views
SELECT req.tbl,
       MAX(CASE WHEN t.TABLE_SCHEMA = 'new_development'      THEN t.TABLE_TYPE END) AS dev_type,
       MAX(CASE WHEN t.TABLE_SCHEMA = 'actorsbusinessoffice' THEN t.TABLE_TYPE END) AS prod_type,
       CASE WHEN COUNT(DISTINCT t.TABLE_SCHEMA) = 2 THEN 'OK' ELSE 'GAP' END       AS status
FROM (
          SELECT 'co_contacts' AS tbl
    UNION SELECT 'companies'
    UNION SELECT 'co_locations'
    UNION SELECT 'master_audit_tbl'
    UNION SELECT 'master_correction_requests_tbl'
    UNION SELECT 'contactdetails_tbl'
    UNION SELECT 'contactdetails'
    UNION SELECT 'contactitems_tbl'
    UNION SELECT 'audcontacts_auditions_xref'
    UNION SELECT 'audprojects'
    UNION SELECT 'audmedia'
) req
LEFT JOIN information_schema.TABLES t
       ON t.TABLE_NAME = req.tbl
      AND t.TABLE_SCHEMA IN ('new_development', 'actorsbusinessoffice')
GROUP BY req.tbl
ORDER BY status DESC, req.tbl;

-- 2) Required columns on contactdetails_tbl (V3_7) and the contactdetails view (V3_8)
SELECT req.tbl, req.col,
       MAX(CASE WHEN c.TABLE_SCHEMA = 'new_development'      THEN c.COLUMN_TYPE END) AS dev_type,
       MAX(CASE WHEN c.TABLE_SCHEMA = 'actorsbusinessoffice' THEN c.COLUMN_TYPE END) AS prod_type,
       MAX(CASE WHEN c.TABLE_SCHEMA = 'new_development'      THEN CONCAT(c.IS_NULLABLE, '/', COALESCE(c.COLUMN_DEFAULT, 'NULL')) END) AS dev_null_default,
       MAX(CASE WHEN c.TABLE_SCHEMA = 'actorsbusinessoffice' THEN CONCAT(c.IS_NULLABLE, '/', COALESCE(c.COLUMN_DEFAULT, 'NULL')) END) AS prod_null_default,
       CASE
         WHEN COUNT(DISTINCT c.TABLE_SCHEMA) < 2 THEN 'GAP'
         WHEN COUNT(DISTINCT CONCAT(c.COLUMN_TYPE, c.IS_NULLABLE, COALESCE(c.COLUMN_DEFAULT, 'NULL'))) > 1 THEN 'DIFF'
         ELSE 'OK'
       END AS status
FROM (
          SELECT t.tbl, k.col FROM
          (SELECT 'contactdetails_tbl' AS tbl UNION SELECT 'contactdetails') t
    CROSS JOIN (
              SELECT 'contactPhone' AS col
        UNION SELECT 'contactEmail'
        UNION SELECT 'contactCompany'
        UNION SELECT 'contactPhone_src'
        UNION SELECT 'contactEmail_src'
        UNION SELECT 'contactCompany_src'
        UNION SELECT 'contactPhoto_src'
        UNION SELECT 'company_location_id'
        UNION SELECT 'master_co_contact_id'
        UNION SELECT 'master_coid'
        UNION SELECT 'master_linked_date'
        UNION SELECT 'master_last_sync'
        UNION SELECT 'contactPhoto'
        UNION SELECT 'isdeleted'
        UNION SELECT 'userid'
    ) k
) req
LEFT JOIN information_schema.COLUMNS c
       ON c.TABLE_NAME = req.tbl AND c.COLUMN_NAME = req.col
      AND c.TABLE_SCHEMA IN ('new_development', 'actorsbusinessoffice')
GROUP BY req.tbl, req.col
ORDER BY status DESC, req.tbl, req.col;

-- 3) Columns read from the reference tables and ownership columns used by the fixes
SELECT req.tbl, req.col,
       MAX(CASE WHEN c.TABLE_SCHEMA = 'new_development'      THEN c.COLUMN_TYPE END) AS dev_type,
       MAX(CASE WHEN c.TABLE_SCHEMA = 'actorsbusinessoffice' THEN c.COLUMN_TYPE END) AS prod_type,
       CASE WHEN COUNT(DISTINCT c.TABLE_SCHEMA) = 2 THEN 'OK' ELSE 'GAP' END AS status
FROM (
          SELECT 'co_contacts' AS tbl, 'id' AS col
    UNION SELECT 'co_contacts', 'coid'
    UNION SELECT 'co_contacts', 'fullname'
    UNION SELECT 'co_contacts', 'image_url'
    UNION SELECT 'co_contacts', 'imdbid'
    UNION SELECT 'co_contacts', 'jobtitle_type'
    UNION SELECT 'companies',   'coid'
    UNION SELECT 'companies',   'coName'
    UNION SELECT 'co_locations','colocid'
    UNION SELECT 'co_locations','coid'
    UNION SELECT 'audprojects', 'userid'
    UNION SELECT 'audmedia',    'userid'
    UNION SELECT 'audmedia',    'mediaName'
    UNION SELECT 'audcontacts_auditions_xref', 'audprojectid'
    UNION SELECT 'audcontacts_auditions_xref', 'contactid'
) req
LEFT JOIN information_schema.COLUMNS c
       ON c.TABLE_NAME = req.tbl AND c.COLUMN_NAME = req.col
      AND c.TABLE_SCHEMA IN ('new_development', 'actorsbusinessoffice')
GROUP BY req.tbl, req.col
ORDER BY status DESC, req.tbl, req.col;

-- 4) Indexes the Book relies on (V3_7) + the auditions xref index
SELECT req.tbl, req.idx,
       MAX(CASE WHEN s.TABLE_SCHEMA = 'new_development'      THEN 'Y' END) AS on_dev,
       MAX(CASE WHEN s.TABLE_SCHEMA = 'actorsbusinessoffice' THEN 'Y' END) AS on_prod,
       CASE WHEN COUNT(DISTINCT s.TABLE_SCHEMA) = 2 THEN 'OK' ELSE 'GAP' END AS status
FROM (
          SELECT 'contactdetails_tbl' AS tbl, 'idx_cd_master_person' AS idx
    UNION SELECT 'contactdetails_tbl', 'idx_cd_master_co'
    UNION SELECT 'contactdetails_tbl', 'idx_cd_company_loc'
    UNION SELECT 'audcontacts_auditions_xref', 'idx_aax_project_contact'
) req
LEFT JOIN information_schema.STATISTICS s
       ON s.TABLE_NAME = req.tbl AND s.INDEX_NAME = req.idx
      AND s.TABLE_SCHEMA IN ('new_development', 'actorsbusinessoffice')
GROUP BY req.tbl, req.idx
ORDER BY status DESC, req.tbl, req.idx;

-- 5) Reference data presence (row counts only; no data is compared or copied)
SELECT 'dev'  AS env, 'co_contacts'  AS tbl, COUNT(*) AS n FROM new_development.co_contacts
UNION ALL SELECT 'prod', 'co_contacts',  COUNT(*) FROM actorsbusinessoffice.co_contacts
UNION ALL SELECT 'dev',  'companies',    COUNT(*) FROM new_development.companies
UNION ALL SELECT 'prod', 'companies',    COUNT(*) FROM actorsbusinessoffice.companies
UNION ALL SELECT 'dev',  'co_locations', COUNT(*) FROM new_development.co_locations
UNION ALL SELECT 'prod', 'co_locations', COUNT(*) FROM actorsbusinessoffice.co_locations
UNION ALL SELECT 'dev',  'master_audit_tbl', COUNT(*) FROM new_development.master_audit_tbl
UNION ALL SELECT 'prod', 'master_audit_tbl', COUNT(*) FROM actorsbusinessoffice.master_audit_tbl;

-- 6) Prod data sanity for the Book: linked contacts whose master pointer is dangling
SELECT COUNT(*) AS prod_dangling_master_links
FROM actorsbusinessoffice.contactdetails_tbl d
LEFT JOIN actorsbusinessoffice.co_contacts cc ON cc.id = d.master_co_contact_id
WHERE d.master_co_contact_id IS NOT NULL AND cc.id IS NULL;

-- 7) Evidence for TAO-E001 / E018 / E019 / E037 (cfquery attribute validation): the root-cause
--    text the ErrorService stored for those alerts. Ticket IDs are from the 2026-10-08 queue.
SELECT ticket_id, created_at, error_type, root_cause_type, root_cause_message, root_cause_file, root_cause_line
FROM actorsbusinessoffice.error_tickets
WHERE ticket_id IN ('ERR-85F6B985','ERR-DFFACE1C','ERR-6E75720D','ERR-6E74BC1B','ERR-2FC4B660','ERR-2FC50756',
                    'ERR-1083F87E','ERR-0FE988C0','ERR-0FE987ED','ERR-9CC817A8')
ORDER BY created_at;

-- 8) TAO-E002 / E023 data impact: contacts created in the same minute as a failed create
--    alert can be half-created duplicates. Lists same-name duplicates created within 10 minutes
--    of each other since 2026-04-01 (review only; do NOT merge from this list blindly).
SELECT /*+ MAX_EXECUTION_TIME(60000) */ a.userid, a.contactid AS first_id, b.contactid AS dup_id, a.contactFullName,
       a.contactCreationDate AS first_created, b.contactCreationDate AS dup_created
FROM actorsbusinessoffice.contactdetails_tbl a
JOIN actorsbusinessoffice.contactdetails_tbl b
  ON b.userid = a.userid
 AND b.contactFullName = a.contactFullName
 AND b.contactid > a.contactid
 AND b.contactCreationDate BETWEEN a.contactCreationDate AND a.contactCreationDate + INTERVAL 10 MINUTE
WHERE a.contactCreationDate >= '2026-04-01'
  AND a.isdeleted = 0 AND b.isdeleted = 0
ORDER BY a.contactCreationDate DESC
LIMIT 200;

-- 9) Ticket 1267 (Targeted list misses a new Casting Director relationship): compare the view
--    bodies that drive the Relationships filter buttons. The 2026-04-02 fix (ticket 2191) rebuilt
--    them to filter on fusystems.systemtype = 'Targeted List' / 'Follow Up' / 'Maintenance List'.
SELECT TABLE_SCHEMA, TABLE_NAME, VIEW_DEFINITION
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA IN ('new_development', 'actorsbusinessoffice')
  AND TABLE_NAME IN ('contacts_ss', 'contacts_ss_target', 'contacts_ss_followup', 'contacts_ss_maint')
ORDER BY TABLE_NAME, TABLE_SCHEMA;

-- 10) Ticket 1267 data check: active Targeted enrollments that the prod view does not return.
SELECT /*+ MAX_EXECUTION_TIME(60000) */ su.suid, su.userid, su.contactid, s.systemtype
FROM actorsbusinessoffice.fusystemusers su
JOIN actorsbusinessoffice.fusystems s ON s.systemid = su.systemid
LEFT JOIN actorsbusinessoffice.contacts_ss_target t ON t.contactid = su.contactid AND t.userid = su.userid
WHERE s.systemtype = 'Targeted List'
  AND su.suStatus = 'Active'
  AND t.contactid IS NULL
LIMIT 50;
