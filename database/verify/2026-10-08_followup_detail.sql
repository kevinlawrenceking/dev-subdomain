-- =====================================================================================
-- 2026-10-08  Repair-queue follow-up  --  READ-ONLY (SELECT / SHOW only)
-- Run as one script in HeidiSQL (F9). Each statement opens its own result tab.
-- Parts:  A = full definitions + column/index/FK diff (plan item 1)
--         B = why prod master_audit_tbl is empty (item 3)
--         C = Targeted enrollments missing from contacts_ss_target, classified (item 4)
--         D = duplicate-contact candidates vs failed-create tickets + related records (item 5)
--         E = error_tickets root-cause coverage (item 6)
-- =====================================================================================

SET SESSION TRANSACTION READ ONLY;

-- -------------------------------------------------------------------------------------
-- A1) Full definitions. Compare each dev/prod pair; ignore AUTO_INCREMENT= counters.
-- -------------------------------------------------------------------------------------
SHOW CREATE TABLE new_development.co_contacts;
SHOW CREATE TABLE actorsbusinessoffice.co_contacts;
SHOW CREATE TABLE new_development.companies;
SHOW CREATE TABLE actorsbusinessoffice.companies;
SHOW CREATE TABLE new_development.co_locations;
SHOW CREATE TABLE actorsbusinessoffice.co_locations;
SHOW CREATE TABLE new_development.master_audit_tbl;
SHOW CREATE TABLE actorsbusinessoffice.master_audit_tbl;
SHOW CREATE TABLE new_development.master_correction_requests_tbl;
SHOW CREATE TABLE actorsbusinessoffice.master_correction_requests_tbl;
SHOW CREATE TABLE new_development.contactdetails_tbl;
SHOW CREATE TABLE actorsbusinessoffice.contactdetails_tbl;
SHOW CREATE TABLE new_development.audcontacts_auditions_xref;
SHOW CREATE TABLE actorsbusinessoffice.audcontacts_auditions_xref;
SHOW CREATE TABLE new_development.error_tickets;
SHOW CREATE TABLE actorsbusinessoffice.error_tickets;
SHOW CREATE VIEW  new_development.contactdetails;
SHOW CREATE VIEW  actorsbusinessoffice.contactdetails;
SHOW CREATE VIEW  new_development.contacts_ss;
SHOW CREATE VIEW  actorsbusinessoffice.contacts_ss;
SHOW CREATE VIEW  new_development.contacts_ss_target;
SHOW CREATE VIEW  actorsbusinessoffice.contacts_ss_target;

-- -------------------------------------------------------------------------------------
-- A2) EVERY column of the Book objects, dev vs prod, unfiltered (includes the 30 rows of
--     parity-check section 2 plus all other columns of these objects). status: OK / DIFF /
--     DEV_ONLY / PROD_ONLY. Compares type, nullability, default, extra (generated/auto_inc),
--     charset, collation and ordinal position.
-- -------------------------------------------------------------------------------------
SELECT k.TABLE_NAME, k.COLUMN_NAME,
       dv.ORDINAL_POSITION AS dev_pos, pr.ORDINAL_POSITION AS prod_pos,
       dv.COLUMN_TYPE AS dev_type, pr.COLUMN_TYPE AS prod_type,
       CONCAT_WS('|', dv.IS_NULLABLE, COALESCE(dv.COLUMN_DEFAULT,'NULL'), dv.EXTRA, dv.CHARACTER_SET_NAME, dv.COLLATION_NAME) AS dev_attrs,
       CONCAT_WS('|', pr.IS_NULLABLE, COALESCE(pr.COLUMN_DEFAULT,'NULL'), pr.EXTRA, pr.CHARACTER_SET_NAME, pr.COLLATION_NAME) AS prod_attrs,
       CASE
         WHEN dv.COLUMN_NAME IS NULL THEN 'PROD_ONLY'
         WHEN pr.COLUMN_NAME IS NULL THEN 'DEV_ONLY'
         WHEN dv.COLUMN_TYPE <> pr.COLUMN_TYPE
           OR dv.IS_NULLABLE <> pr.IS_NULLABLE
           OR NOT (dv.COLUMN_DEFAULT <=> pr.COLUMN_DEFAULT)
           OR dv.EXTRA <> pr.EXTRA
           OR NOT (dv.COLLATION_NAME <=> pr.COLLATION_NAME) THEN 'DIFF'
         WHEN dv.ORDINAL_POSITION <> pr.ORDINAL_POSITION THEN 'OK_ORDER_DIFFERS'
         ELSE 'OK'
       END AS status
FROM (
    SELECT DISTINCT TABLE_NAME, COLUMN_NAME
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA IN ('new_development','actorsbusinessoffice')
      AND TABLE_NAME IN ('co_contacts','companies','co_locations','master_audit_tbl',
                         'master_correction_requests_tbl','contactdetails_tbl','contactdetails',
                         'audcontacts_auditions_xref','contacts_ss','contacts_ss_target')
) k
LEFT JOIN information_schema.COLUMNS dv
       ON dv.TABLE_SCHEMA = 'new_development' AND dv.TABLE_NAME = k.TABLE_NAME AND dv.COLUMN_NAME = k.COLUMN_NAME
LEFT JOIN information_schema.COLUMNS pr
       ON pr.TABLE_SCHEMA = 'actorsbusinessoffice' AND pr.TABLE_NAME = k.TABLE_NAME AND pr.COLUMN_NAME = k.COLUMN_NAME
ORDER BY FIELD(status,'DEV_ONLY','PROD_ONLY','DIFF','OK_ORDER_DIFFERS','OK'), k.TABLE_NAME, COALESCE(dv.ORDINAL_POSITION, pr.ORDINAL_POSITION);

-- -------------------------------------------------------------------------------------
-- A3) Index DEFINITIONS (not just names): uniqueness, type, ordered column list with prefix
--     lengths and expressions. Also matches same-definition indexes that carry different names.
-- -------------------------------------------------------------------------------------
WITH idx AS (
    SELECT TABLE_SCHEMA, TABLE_NAME, INDEX_NAME,
           CONCAT(IF(NON_UNIQUE = 0, 'UNIQUE ', ''), INDEX_TYPE, ' (',
                  GROUP_CONCAT(CONCAT(COALESCE(COLUMN_NAME, CONCAT('expr:', EXPRESSION)),
                                      IF(SUB_PART IS NULL, '', CONCAT('(', SUB_PART, ')')),
                                      IF(COLLATION = 'D', ' DESC', ''))
                               ORDER BY SEQ_IN_INDEX SEPARATOR ', '), ')',
                  IF(MAX(IS_VISIBLE) = 'NO', ' INVISIBLE', '')) AS def
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA IN ('new_development','actorsbusinessoffice')
      AND TABLE_NAME IN ('co_contacts','companies','co_locations','master_audit_tbl',
                         'master_correction_requests_tbl','contactdetails_tbl','audcontacts_auditions_xref')
    GROUP BY TABLE_SCHEMA, TABLE_NAME, INDEX_NAME, NON_UNIQUE, INDEX_TYPE
),
names AS (SELECT DISTINCT TABLE_NAME, INDEX_NAME FROM idx)
SELECT n.TABLE_NAME, n.INDEX_NAME, d.def AS dev_def, p.def AS prod_def,
       CASE
         WHEN d.def IS NULL AND EXISTS (SELECT 1 FROM idx x WHERE x.TABLE_SCHEMA='new_development' AND x.TABLE_NAME=n.TABLE_NAME AND x.def=p.def)
              THEN 'PROD_ONLY_NAME (same def exists on dev under another name)'
         WHEN p.def IS NULL AND EXISTS (SELECT 1 FROM idx x WHERE x.TABLE_SCHEMA='actorsbusinessoffice' AND x.TABLE_NAME=n.TABLE_NAME AND x.def=d.def)
              THEN 'DEV_ONLY_NAME (same def exists on prod under another name)'
         WHEN d.def IS NULL THEN 'PROD_ONLY'
         WHEN p.def IS NULL THEN 'DEV_ONLY'
         WHEN d.def <> p.def THEN 'DIFF'
         ELSE 'OK'
       END AS status
FROM names n
LEFT JOIN idx d ON d.TABLE_SCHEMA='new_development'      AND d.TABLE_NAME=n.TABLE_NAME AND d.INDEX_NAME=n.INDEX_NAME
LEFT JOIN idx p ON p.TABLE_SCHEMA='actorsbusinessoffice' AND p.TABLE_NAME=n.TABLE_NAME AND p.INDEX_NAME=n.INDEX_NAME
ORDER BY (status = 'OK'), n.TABLE_NAME, n.INDEX_NAME;

-- A4) Foreign keys and triggers on the same objects (definition level)
SELECT rc.CONSTRAINT_SCHEMA, rc.TABLE_NAME, rc.CONSTRAINT_NAME, rc.REFERENCED_TABLE_NAME,
       GROUP_CONCAT(CONCAT(k.COLUMN_NAME,'->',k.REFERENCED_COLUMN_NAME) ORDER BY k.ORDINAL_POSITION) AS cols,
       rc.UPDATE_RULE, rc.DELETE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS rc
JOIN information_schema.KEY_COLUMN_USAGE k
  ON k.CONSTRAINT_SCHEMA = rc.CONSTRAINT_SCHEMA AND k.CONSTRAINT_NAME = rc.CONSTRAINT_NAME AND k.TABLE_NAME = rc.TABLE_NAME
WHERE rc.CONSTRAINT_SCHEMA IN ('new_development','actorsbusinessoffice')
  AND rc.TABLE_NAME IN ('co_contacts','companies','co_locations','master_audit_tbl',
                        'master_correction_requests_tbl','contactdetails_tbl','audcontacts_auditions_xref')
GROUP BY rc.CONSTRAINT_SCHEMA, rc.TABLE_NAME, rc.CONSTRAINT_NAME, rc.REFERENCED_TABLE_NAME, rc.UPDATE_RULE, rc.DELETE_RULE
ORDER BY rc.TABLE_NAME, rc.CONSTRAINT_NAME, rc.CONSTRAINT_SCHEMA;

SELECT TRIGGER_SCHEMA, EVENT_OBJECT_TABLE, TRIGGER_NAME, ACTION_TIMING, EVENT_MANIPULATION
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA IN ('new_development','actorsbusinessoffice')
  AND EVENT_OBJECT_TABLE IN ('contactdetails_tbl','master_audit_tbl','audcontacts_auditions_xref','co_contacts');

-- -------------------------------------------------------------------------------------
-- B) Item 3: is an empty prod master_audit_tbl expected? In current code ONLY three paths
--    write it: confirmLink (/ajax/master/link-confirm.cfm, 404 on prod), unlinkMaster
--    (WO-7 version of unlink.cfm) and syncLinkedContact (on-read sync, hard-gated off on prod;
--    resyncall.cfm 404 on prod). updatePrimary never writes audit. If B1 shows linked prod
--    contacts, some writer linked them WITHOUT audit (the pre-WO-7 link.cfm did exactly that).
-- -------------------------------------------------------------------------------------
-- B1) Link state on both sides
SELECT 'dev' AS env,
       SUM(master_co_contact_id IS NOT NULL) AS linked,
       MIN(master_linked_date) AS first_linked, MAX(master_linked_date) AS last_linked,
       MAX(master_last_sync)   AS last_sync,
       SUM(contactCompany_src = 'master') AS company_src_master,
       SUM(contactEmail_src   = 'master') AS email_src_master,
       SUM(contactPhone_src   = 'master') AS phone_src_master,
       SUM(contactPhoto_src   = 'master') AS photo_src_master
FROM new_development.contactdetails_tbl
UNION ALL
SELECT 'prod',
       SUM(master_co_contact_id IS NOT NULL),
       MIN(master_linked_date), MAX(master_linked_date), MAX(master_last_sync),
       SUM(contactCompany_src = 'master'), SUM(contactEmail_src = 'master'),
       SUM(contactPhone_src = 'master'),   SUM(contactPhoto_src = 'master')
FROM actorsbusinessoffice.contactdetails_tbl;

-- B2) Prod links by month (when did linking happen, and by how many users)
SELECT DATE_FORMAT(master_linked_date, '%Y-%m') AS month, COUNT(*) AS links, COUNT(DISTINCT userid) AS users
FROM actorsbusinessoffice.contactdetails_tbl
WHERE master_co_contact_id IS NOT NULL
GROUP BY DATE_FORMAT(master_linked_date, '%Y-%m')
ORDER BY month;

-- B3) Audit / correction row counts and the latest audit write on each side
SELECT 'dev' AS env, (SELECT COUNT(*) FROM new_development.master_audit_tbl) AS audit_rows,
       (SELECT MAX(auditID) FROM new_development.master_audit_tbl) AS max_audit_id,
       (SELECT COUNT(*) FROM new_development.master_correction_requests_tbl) AS correction_rows
UNION ALL
SELECT 'prod', (SELECT COUNT(*) FROM actorsbusinessoffice.master_audit_tbl),
       (SELECT MAX(auditID) FROM actorsbusinessoffice.master_audit_tbl),
       (SELECT COUNT(*) FROM actorsbusinessoffice.master_correction_requests_tbl);

-- B4) Any recorded failures on the Book endpoints (stored tickets only; handled exceptions
--     were cflog-only before this change)
SELECT DATE(created_at) AS day, script_name, COUNT(*) AS n,
       MIN(LEFT(COALESCE(root_cause_message, error_message), 200)) AS sample_message
FROM actorsbusinessoffice.error_tickets
WHERE script_name LIKE '/ajax/master/%' OR script_name LIKE '/ajax/contact/%'
   OR script_name LIKE '/include/master_link%' OR script_name LIKE '/include/contact_info%'
GROUP BY DATE(created_at), script_name
ORDER BY day DESC
LIMIT 100;

-- -------------------------------------------------------------------------------------
-- C) Item 4: every active Targeted enrollment missing from prod contacts_ss_target, with
--    the reason. Prod contacts_ss = contactdetails WHERE contactStatus = 'Active'
--    (contactdetails is the view over contactdetails_tbl), and contacts_ss_target joins it
--    to fusystemusers + fusystems on contactid AND userid. Reasons starting "INELIGIBLE"
--    are intentional exclusions; "GENUINE" rows are real misses.
-- -------------------------------------------------------------------------------------
SELECT /*+ MAX_EXECUTION_TIME(120000) */
       su.suid, su.userid AS su_userid, su.contactid, su.systemid, su.sustartdate,
       cd.userid AS contact_userid, cd.contactStatus, cd.isdeleted AS contact_deleted,
       (cv.contactid IS NOT NULL) AS in_contactdetails_view,
       CASE
         WHEN cd.contactid IS NULL                  THEN 'GENUINE: orphan enrollment (contact row missing)'
         WHEN cd.isdeleted = 1                      THEN 'INELIGIBLE: contact deleted'
         WHEN cd.userid <> su.userid                THEN 'GENUINE: enrollment userid differs from contact owner'
         WHEN COALESCE(cd.contactStatus,'') <> 'Active' THEN CONCAT('INELIGIBLE: contactStatus=', COALESCE(cd.contactStatus,'NULL'))
         WHEN cv.contactid IS NULL                  THEN 'GENUINE: filtered out by contactdetails view'
         ELSE 'GENUINE: eligible but absent from view (view-body defect)'
       END AS reason
FROM actorsbusinessoffice.fusystemusers su
JOIN actorsbusinessoffice.fusystems s ON s.systemid = su.systemid
LEFT JOIN actorsbusinessoffice.contacts_ss_target t
       ON t.contactid = su.contactid AND t.userid = su.userid
LEFT JOIN actorsbusinessoffice.contactdetails_tbl cd ON cd.contactid = su.contactid
LEFT JOIN actorsbusinessoffice.contactdetails cv     ON cv.contactid = su.contactid
WHERE s.systemtype = 'Targeted List'
  AND su.suStatus = 'Active'
  AND t.contactid IS NULL
ORDER BY reason, su.userid, su.contactid;

-- C2) Same rows summarised by reason
SELECT /*+ MAX_EXECUTION_TIME(120000) */ reason, COUNT(*) AS n, COUNT(DISTINCT su_userid) AS users
FROM (
    SELECT su.userid AS su_userid,
           CASE
             WHEN cd.contactid IS NULL                  THEN 'GENUINE: orphan enrollment (contact row missing)'
             WHEN cd.isdeleted = 1                      THEN 'INELIGIBLE: contact deleted'
             WHEN cd.userid <> su.userid                THEN 'GENUINE: enrollment userid differs from contact owner'
             WHEN COALESCE(cd.contactStatus,'') <> 'Active' THEN CONCAT('INELIGIBLE: contactStatus=', COALESCE(cd.contactStatus,'NULL'))
             WHEN cv.contactid IS NULL                  THEN 'GENUINE: filtered out by contactdetails view'
             ELSE 'GENUINE: eligible but absent from view (view-body defect)'
           END AS reason
    FROM actorsbusinessoffice.fusystemusers su
    JOIN actorsbusinessoffice.fusystems s ON s.systemid = su.systemid
    LEFT JOIN actorsbusinessoffice.contacts_ss_target t ON t.contactid = su.contactid AND t.userid = su.userid
    LEFT JOIN actorsbusinessoffice.contactdetails_tbl cd ON cd.contactid = su.contactid
    LEFT JOIN actorsbusinessoffice.contactdetails cv     ON cv.contactid = su.contactid
    WHERE s.systemtype = 'Targeted List' AND su.suStatus = 'Active' AND t.contactid IS NULL
) x
GROUP BY reason
ORDER BY n DESC;

-- -------------------------------------------------------------------------------------
-- D) Item 5: duplicate candidates (same owner + same name, created <= 10 min apart since
--    2026-04-01) with (a) any failed-create error ticket in the window and (b) the related
--    records hanging off each side. REVIEW ONLY - nothing here merges or deletes.
--    Failed creates after a session expiry have user_id NULL in error_tickets, so tickets are
--    matched on time window + the posted name appearing in the redacted form_data JSON.
-- -------------------------------------------------------------------------------------
SELECT /*+ MAX_EXECUTION_TIME(120000) */
       a.userid, a.contactFullName,
       a.contactid AS first_id, a.contactCreationDate AS first_created,
       b.contactid AS dup_id,   b.contactCreationDate AS dup_created,
       TIMESTAMPDIFF(SECOND, a.contactCreationDate, b.contactCreationDate) AS secs_apart,
       (SELECT GROUP_CONCAT(CONCAT(et.ticket_id, '@', DATE_FORMAT(et.created_at, '%H:%i:%s'), ' ', et.script_name) SEPARATOR '; ')
          FROM actorsbusinessoffice.error_tickets et
         WHERE et.created_at BETWEEN a.contactCreationDate - INTERVAL 2 MINUTE AND b.contactCreationDate + INTERVAL 2 MINUTE
           AND et.script_name IN ('/include/remoteAddNameAdd.cfm','/include/remoteAddContactAdd.cfm','/include/remoteAddContactAddaud.cfm')
           AND (et.user_id = a.userid OR et.user_id IS NULL)
           AND (et.form_data LIKE CONCAT('%', REPLACE(a.contactFullName, '%', ''), '%') OR et.user_id = a.userid)
       ) AS failed_create_tickets,
       (SELECT COUNT(*) FROM actorsbusinessoffice.contactitems_tbl ci WHERE ci.contactID = a.contactid AND ci.IsDeleted = 0) AS first_items,
       (SELECT COUNT(*) FROM actorsbusinessoffice.contactitems_tbl ci WHERE ci.contactID = b.contactid AND ci.IsDeleted = 0) AS dup_items,
       (SELECT COUNT(*) FROM actorsbusinessoffice.fusystemusers_tbl f WHERE f.contactID = a.contactid AND f.IsDeleted = 0) AS first_systems,
       (SELECT COUNT(*) FROM actorsbusinessoffice.fusystemusers_tbl f WHERE f.contactID = b.contactid AND f.IsDeleted = 0) AS dup_systems,
       (SELECT COUNT(*) FROM actorsbusinessoffice.audcontacts_auditions_xref x WHERE x.contactid = a.contactid) AS first_auditions,
       (SELECT COUNT(*) FROM actorsbusinessoffice.audcontacts_auditions_xref x WHERE x.contactid = b.contactid) AS dup_auditions,
       (SELECT COUNT(*) FROM actorsbusinessoffice.eventcontactsxref_tbl e WHERE e.contactID = a.contactid AND e.IsDeleted = 0) AS first_events,
       (SELECT COUNT(*) FROM actorsbusinessoffice.eventcontactsxref_tbl e WHERE e.contactID = b.contactid AND e.IsDeleted = 0) AS dup_events,
       (a.master_co_contact_id IS NOT NULL) AS first_linked, (b.master_co_contact_id IS NOT NULL) AS dup_linked
FROM actorsbusinessoffice.contactdetails_tbl a
JOIN actorsbusinessoffice.contactdetails_tbl b
  ON b.userid = a.userid
 AND b.contactFullName = a.contactFullName
 AND b.contactid > a.contactid
 AND b.contactCreationDate BETWEEN a.contactCreationDate AND a.contactCreationDate + INTERVAL 10 MINUTE
WHERE a.contactCreationDate >= '2026-04-01'
  AND a.isdeleted = 0 AND b.isdeleted = 0
ORDER BY (failed_create_tickets IS NULL), a.contactCreationDate DESC
LIMIT 200;

-- D2) All failed contact-create tickets since 2026-04-01 (to line up against D)
SELECT ticket_id, created_at, user_id, script_name, LEFT(COALESCE(root_cause_message, error_message), 160) AS msg,
       LEFT(form_data, 300) AS form_data_head
FROM actorsbusinessoffice.error_tickets
WHERE script_name IN ('/include/remoteAddNameAdd.cfm','/include/remoteAddContactAdd.cfm','/include/remoteAddContactAddaud.cfm')
  AND created_at >= '2026-04-01'
ORDER BY created_at DESC;

-- -------------------------------------------------------------------------------------
-- E) Item 6: root-cause coverage of stored tickets since 2026-04-17 (root_cause_* added).
--    has_root = 0 rows are what the ErrorService fallback fix targets.
-- -------------------------------------------------------------------------------------
SELECT DATE_FORMAT(created_at, '%Y-%m') AS month,
       COUNT(*) AS tickets,
       SUM(root_cause_message IS NOT NULL) AS has_root,
       SUM(root_cause_message IS NULL)     AS no_root,
       SUM(root_cause_message IS NULL AND (error_detail IS NOT NULL AND error_detail <> '')) AS no_root_but_outer_detail,
       SUM(cf_context = 'handled') AS handled
FROM actorsbusinessoffice.error_tickets
WHERE created_at >= '2026-04-17'
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;
