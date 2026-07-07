-- =============================================================================
-- WO-0b PANE 2/2 — ONE-GRID variant — DSN=abod — schema=new_development
-- Staged 2026-07-07 (CC). Single UNION ALL query -> ONE HeidiSQL result tab.
-- Binding: TAO / dev-subdomain / branch dev.
--
-- WHY: HeidiSQL opens one grid per statement. This collapses the whole abod pane into a
--      single result set (columns: section | item | detail) so you can Ctrl+A / Ctrl+C
--      once and paste it back. All facts come from information_schema (faithful, read-only)
--      instead of SHOW, which cannot be UNION'd.
--
-- HEIDISQL: set active DB = new_development, select the whole statement, press F9,
--           Ctrl+A in the grid, Ctrl+C, paste into 2026-07-07-wo0b-pane-abod.txt.
--
-- COVERS: Q1 version, Q2 contactdetails view (definer/security + every column in order +
--         full definition = the V3_8 33-vs-32 reconcile), Q3 other-view definer/colcount
--         (F19 drift), Q4 recordname + new-column collision, Q5 contactitems distributions,
--         Q8 master counts/indexes, Q9 master schema presence, Q18 collations, Q19 tz.
-- NOT covered here (run separately only if you want raw DDL verbatim): full SHOW CREATE
--         TABLE index/FK text. The column-level reconcile below is what V3_8 needs.
-- Grants (Q9b) can't come from information_schema in one row -> run SHOW GRANTS FOR
--         CURRENT_USER(); separately (prod already proved kingk436@% ALL PRIVS).
-- =============================================================================
SELECT section, item, detail
FROM (
  -- A-Q1 engine
  SELECT 1 AS grp, 'A-Q1 engine' AS section, 'version' AS item, CAST(VERSION() AS CHAR) AS detail, 0 AS seq

  -- A-Q2 contactdetails view — THE V3_8 UNBLOCK
  UNION ALL SELECT 2,'A-Q2 contactdetails view','definer/security',
    CONCAT('DEFINER=',DEFINER,' | SECURITY=',SECURITY_TYPE,' | updatable=',IS_UPDATABLE),0
    FROM information_schema.VIEWS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='contactdetails'
  UNION ALL SELECT 2,'A-Q2 contactdetails view','colcount',
    CAST(COUNT(*) AS CHAR),1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='contactdetails'
  UNION ALL SELECT 2,'A-Q2 contactdetails view',
    CONCAT('col',LPAD(ORDINAL_POSITION,2,'0')),
    CONCAT(COLUMN_NAME,'  ',COLUMN_TYPE), ORDINAL_POSITION+1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='contactdetails'
  UNION ALL SELECT 2,'A-Q2 contactdetails view','view_definition',
    VIEW_DEFINITION, 9999
    FROM information_schema.VIEWS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='contactdetails'

  -- A-Q3 other affected views — definer/security (F19 DEFINER-drift) + colcount
  UNION ALL SELECT 3,'A-Q3 view definer',TABLE_NAME,
    CONCAT('DEFINER=',DEFINER,' | SECURITY=',SECURITY_TYPE),0
    FROM information_schema.VIEWS
    WHERE TABLE_SCHEMA=DATABASE()
      AND TABLE_NAME IN ('contactitems','contacts_ss','contacts_ss_followup',
                         'contacts_ss_maint','contacts_ss_target','sharez','sharezz')
  UNION ALL SELECT 3,'A-Q3 view colcount',TABLE_NAME,
    CAST(COUNT(*) AS CHAR),1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE()
      AND TABLE_NAME IN ('contactitems','contacts_ss','contacts_ss_followup',
                         'contacts_ss_maint','contacts_ss_target','sharez','sharezz')
    GROUP BY TABLE_NAME
  UNION ALL SELECT 3,'A-Q3 sharezz exists','sharezz',
    IF(EXISTS(SELECT 1 FROM information_schema.VIEWS
              WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sharezz'),'YES','NO'),2

  -- A-Q4 contactdetails_tbl — recordname + new-column collision check
  UNION ALL SELECT 4,'A-Q4 recordname','definition',
    CONCAT(COLUMN_TYPE,' | EXTRA=',EXTRA,' | GEN=',IFNULL(GENERATION_EXPRESSION,'')),0
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='contactdetails_tbl' AND COLUMN_NAME='recordname'
  UNION ALL SELECT 4,'A-Q4 collision','wo1-cols-present',
    CONCAT(COUNT(*),' of 13 already exist: ',IFNULL(GROUP_CONCAT(COLUMN_NAME),'(none)')),1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='contactdetails_tbl'
      AND COLUMN_NAME IN ('contactPhone','contactEmail','contactCompany','company_location_id',
                          'contactPhone_src','contactEmail_src','contactCompany_src','contactphoto_src',
                          'master_co_contact_id','master_coid','master_link_status',
                          'master_linked_date','master_last_sync')
  UNION ALL SELECT 4,'A-Q4 contactPhoto width','contactPhoto',
    COLUMN_TYPE,2
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='contactdetails_tbl' AND COLUMN_NAME='contactPhoto'

  -- A-Q5 contactitems_tbl distributions
  UNION ALL SELECT 5,'A-Q5 itemstatus',IFNULL(itemstatus,'(null)'),CAST(COUNT(*) AS CHAR),0
    FROM contactitems_tbl GROUP BY itemstatus
  UNION ALL SELECT 5,'A-Q5 valuetype (Phone/Email/Company)',IFNULL(valuetype,'(null)'),CAST(COUNT(*) AS CHAR),1
    FROM contactitems_tbl WHERE valuecategory IN ('Phone','Email','Company') GROUP BY valuetype

  -- A-Q8 master tables counts + indexes
  UNION ALL SELECT 8,'A-Q8 master counts','companies',CAST((SELECT COUNT(*) FROM companies) AS CHAR),0
  UNION ALL SELECT 8,'A-Q8 master counts','co_contacts',CAST((SELECT COUNT(*) FROM co_contacts) AS CHAR),1
  UNION ALL SELECT 8,'A-Q8 master counts','co_locations',CAST((SELECT COUNT(*) FROM co_locations) AS CHAR),2
  UNION ALL SELECT 8,'A-Q8 master indexes',TABLE_NAME,GROUP_CONCAT(DISTINCT INDEX_NAME ORDER BY INDEX_NAME),3
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN ('companies','co_contacts','co_locations')
    GROUP BY TABLE_NAME

  -- A-Q9 master-table schema presence (NO schema filter — shows which schemas hold them)
  UNION ALL SELECT 9,'A-Q9 master schema presence',TABLE_NAME,
    GROUP_CONCAT(TABLE_SCHEMA ORDER BY TABLE_SCHEMA),0
    FROM information_schema.TABLES
    WHERE TABLE_NAME IN ('companies','co_contacts','co_locations')
    GROUP BY TABLE_NAME

  -- A-Q18 collations
  UNION ALL SELECT 18,'A-Q18 collation',TABLE_NAME,TABLE_COLLATION,0
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN ('contactitems_tbl','contactdetails_tbl')

  -- A-Q19 time zone
  UNION ALL SELECT 19,'A-Q19 timezone','global / session',
    CONCAT(@@global.time_zone,'  /  ',@@session.time_zone),0
) x
ORDER BY grp, seq, item;

-- Run separately (cannot be UNION'd), only if you also want them:
-- SHOW GRANTS FOR CURRENT_USER();
-- SHOW CREATE TABLE contactdetails_tbl;   -- raw DDL incl indexes/FKs
-- SHOW CREATE TABLE co_locations;
