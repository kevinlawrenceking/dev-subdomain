-- =============================================================================
-- TAO Performance Audit: EXPLAIN for Hot Queries
-- TAO-PLAN-2026-004, Phase 1.2
--
-- Purpose: Run EXPLAIN on the top 5 suspected slow queries to analyze
--          query plans and identify missing index opportunities.
--
-- Usage:   Run each EXPLAIN block against the target schema.
--          Placeholder values (userid=1, etc.) are used - the goal is
--          to see the query plan, not real data.
--
-- MYSQL: All queries here need optimization before Go migration.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. ReportsRefreshService - findid query (runs inside per-row loop)
--    Pattern: Executes once per report row. With 50-500 rows per report,
--    this query fires 50-500 times per refresh. Loop-invariant (same
--    userid + reportid every iteration).
--
--    Target index: reports_user(userid, reportid)
-- -----------------------------------------------------------------------------
EXPLAIN
SELECT r.ID AS new_id
FROM reports_user r
WHERE r.userid = 1
  AND r.reportid = 1;

-- -----------------------------------------------------------------------------
-- 2. contact_info.cfm - System status for a contact (sysActive)
--    Pattern: Runs per active system for a contact (typically 2-5 systems).
--    JOINs fusystemusers to fusystems.
--
--    Target indexes: fusystemusers_tbl(contactid, userid, sustatus)
-- -----------------------------------------------------------------------------
EXPLAIN
SELECT
    fc.suID,
    fc.contactid,
    fc.userid,
    fc.suStartDate,
    fc.suenddate,
    fc.suStatus,
    s.systemName,
    s.systemdescript,
    s.systemtype,
    s.systemscope,
    s.systemid,
    s.recordname
FROM
    fusystemusers fc
INNER JOIN
    fusystems s ON s.systemID = fc.systemID
WHERE
    fc.contactID = 1
    AND fc.userID = 1
    AND fc.suStatus <> 'Completed'
ORDER BY
    fc.suStatus;

-- -----------------------------------------------------------------------------
-- 2b. contact_info.cfm - Available systems (NOT IN subquery)
--     Pattern: Runs per contact view to show enrollable systems.
--
--     Target indexes: fusystemusers_tbl(contactid, userid, sustatus)
-- -----------------------------------------------------------------------------
EXPLAIN
SELECT *
FROM fusystems
WHERE systemscope = 'Contact'
  AND systemid NOT IN (
      SELECT systemid
      FROM fusystemusers
      WHERE contactID = 1
        AND userID = 1
        AND suStatus = 'Active'
  )
ORDER BY FIELD(systemtype, 'Targeted List', 'Follow Up', 'Maintenance List');

-- -----------------------------------------------------------------------------
-- 3. complete_not_batch.cfm - getNotificationsBySystem
--    Pattern: Runs per notification being completed to find next pending
--    notification in the same system enrollment.
--
--    Target indexes: funotifications(suid, notstatus, isdeleted)
-- -----------------------------------------------------------------------------
EXPLAIN
SELECT
    n.notID,
    n.actionID,
    n.userID,
    n.suID,
    n.notTimeStamp,
    n.notStartDate,
    n.notEndDate,
    n.notStatus,
    n.notNotes,
    f.systemID,
    f.contactID,
    f.suTimeStamp,
    f.suStartDate,
    f.suEndDate,
    f.suStatus,
    f.suNotes,
    a.actionID,
    a.actionNo,
    a.actionDetails,
    a.actionTitle,
    a.navToURL,
    COALESCE(au.actionDaysNo, 0) AS actionDaysNo,
    COALESCE(au.actionDaysRecurring, 0) AS actionDaysRecurring,
    a.actionNotes,
    a.actionInfo,
    n.ispastdue,
    ns.checktype,
    ns.delstart,
    ns.delend,
    ns.status_color
FROM
    funotifications n
INNER JOIN
    fusystemusers f ON f.suID = n.suID
INNER JOIN
    fuactions a ON a.actionID = n.actionID
LEFT JOIN
    actionusers au ON a.actionID = au.actionID AND au.userID = f.userID
INNER JOIN
    notstatuses ns ON ns.notstatus = n.notStatus
WHERE
    n.suID = 1
    AND n.notStatus = 'Pending'
    AND n.isdeleted = 0
    AND n.notStartDate IS NULL
ORDER BY
    a.actionNo, a.actionID
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 4. core.cfm - Nav link queries (FindLinksT / FindLinksB)
--    Pattern: Runs on EVERY authenticated page load via core.cfm.
--    3-table JOIN through pgapplinks -> pgplugins -> pgpagespluginsxref -> pgpages.
--
--    These are candidates for cachedwithin (Phase 2) rather than index changes,
--    but EXPLAIN helps confirm current plan efficiency.
-- -----------------------------------------------------------------------------

-- FindLinksT (header links)
EXPLAIN
SELECT
    l.linkid,
    l.linkurl,
    l.linkname,
    l.linktype,
    l.link_no,
    l.linkloc_tb,
    l.pluginname,
    l.rel,
    l.hrefid
FROM
    pgapplinks l
    INNER JOIN pgplugins p ON p.pluginName = l.pluginname
    INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
    INNER JOIN pgpages g ON g.pgid = x.pgid
WHERE
    g.pgid = 1
    AND l.linkloc_tb IN ('t','i')
ORDER BY
    l.link_no;

-- FindLinksB (bottom links)
EXPLAIN
SELECT
    l.linkid,
    l.linkurl,
    l.linkname,
    l.linktype,
    l.link_no,
    l.linkloc_tb,
    l.pluginname,
    l.rel,
    l.hrefid
FROM
    pgapplinks l
    INNER JOIN pgplugins p ON p.pluginName = l.pluginname
    INNER JOIN pgpagespluginsxref x ON x.pluginid = p.pluginid
    INNER JOIN pgpages g ON g.pgid = x.pgid
WHERE
    g.pgid = 1
    AND l.linkloc_tb = 'b'
    AND l.linkname NOT LIKE '%calendar - custom%'
    AND l.linktype <> 'css'
ORDER BY
    l.link_no;

-- -----------------------------------------------------------------------------
-- 5. contactdetails lookup (most contact pages)
--    Pattern: Runs on most contact-facing pages with WHERE userid = ? AND isdeleted = 0.
--    contactdetails is a VIEW on contactdetails_tbl.
--
--    Target index: contactdetails_tbl(userid, isdeleted)
-- -----------------------------------------------------------------------------
EXPLAIN
SELECT
    contactid, userid, contactFullName, contactStatus, recordname,
    contactCreationDate, contactLastUpdated
FROM contactdetails
WHERE userid = 1
  AND (isdeleted IS NULL OR isdeleted = 0)
ORDER BY contactFullName;

-- =============================================================================
-- BONUS: Additional high-value EXPLAIN targets identified during audit
-- =============================================================================

-- 6. funotifications - notification dashboard query (most common filter)
--    Target index: funotifications(userid, notstatus, isdeleted)
EXPLAIN
SELECT n.notID, n.actionID, n.notStartDate, n.notStatus
FROM funotifications n
WHERE n.userid = 1
  AND n.notstatus = 'Active'
  AND n.isdeleted = 0
ORDER BY n.notStartDate;

-- 7. contactitems lookup (per-contact detail page)
--    Target index: contactitems_tbl(contactid, valueCategory, itemstatus)
EXPLAIN
SELECT *
FROM contactitems
WHERE contactid = 1
  AND valueCategory = 'email'
  AND itemstatus = 'active';
