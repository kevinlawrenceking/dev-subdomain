-- =============================================================================
-- TAO Relationship System Audit Queries
-- Database: MySQL (new_development for test, actorsbusinessoffice for production)
-- Generated: 2026-01-11
-- =============================================================================
--
-- USAGE: Run these queries against the test database first (new_development)
-- Each query is labeled with its issue category for the health report
--
-- Categories:
--   A. Orphaned notifications
--   B. Missing actionusers rows
--   C. Multiple active pending per suid
--   D. Stuck systems (Active with no pending)
--   E. Duplicate fusystemusers
--   F. Uniqueness violations
--   G. Null notstartdate issues
--   H. Data consistency checks
-- =============================================================================

-- -----------------------------------------------------------------------------
-- CATEGORY A: Orphaned Notifications
-- -----------------------------------------------------------------------------

-- A1. Notifications with missing suid (funotifications.suid not in fusystemusers)
SELECT
    'A1_orphan_suid' AS issue_code,
    COUNT(*) AS issue_count
FROM funotifications n
LEFT JOIN fusystemusers su ON su.suid = n.suid
WHERE su.suid IS NULL
  AND n.isdeleted = 0;

-- A1 Detail: Get sample orphaned notification IDs
SELECT
    n.notid,
    n.suid,
    n.userid,
    n.actionid,
    n.notstatus,
    n.notstartdate,
    'Missing suid in fusystemusers' AS issue
FROM funotifications n
LEFT JOIN fusystemusers su ON su.suid = n.suid
WHERE su.suid IS NULL
  AND n.isdeleted = 0
ORDER BY n.notid DESC
LIMIT 20;

-- A2. Notifications with missing actionid (funotifications.actionid not in fuactions)
SELECT
    'A2_orphan_actionid' AS issue_code,
    COUNT(*) AS issue_count
FROM funotifications n
LEFT JOIN fuactions a ON a.actionid = n.actionid
WHERE a.actionid IS NULL
  AND n.isdeleted = 0;

-- A2 Detail
SELECT
    n.notid,
    n.actionid,
    n.suid,
    n.userid,
    'Missing actionid in fuactions' AS issue
FROM funotifications n
LEFT JOIN fuactions a ON a.actionid = n.actionid
WHERE a.actionid IS NULL
  AND n.isdeleted = 0
LIMIT 20;

-- A3. Notifications where user doesn't exist
SELECT
    'A3_orphan_userid' AS issue_code,
    COUNT(*) AS issue_count
FROM funotifications n
LEFT JOIN taousers u ON u.userid = n.userid
WHERE u.userid IS NULL
  AND n.isdeleted = 0;

-- -----------------------------------------------------------------------------
-- CATEGORY B: Missing ActionUsers Rows
-- -----------------------------------------------------------------------------

-- B1. Count users missing actionusers rows (should have rows for all fuactions)
SELECT
    'B1_missing_actionusers' AS issue_code,
    COUNT(DISTINCT CONCAT(u.userid, '-', a.actionid)) AS issue_count
FROM taousers u
CROSS JOIN fuactions a
LEFT JOIN actionusers au ON au.userid = u.userid AND au.actionid = a.actionid
WHERE au.id IS NULL
  AND u.userstatus = 'Active';

-- B1 Detail: Users and their missing action counts
SELECT
    u.userid,
    u.recordname,
    COUNT(*) AS missing_action_count
FROM taousers u
CROSS JOIN fuactions a
LEFT JOIN actionusers au ON au.userid = u.userid AND au.actionid = a.actionid
WHERE au.id IS NULL
  AND u.userstatus = 'Active'
GROUP BY u.userid, u.recordname
ORDER BY missing_action_count DESC
LIMIT 20;

-- B2. Specific missing actionusers by system
SELECT
    u.userid,
    s.systemid,
    s.systemname,
    COUNT(*) AS missing_count
FROM taousers u
CROSS JOIN fuactions a
INNER JOIN fusystems s ON s.systemid = a.systemid
LEFT JOIN actionusers au ON au.userid = u.userid AND au.actionid = a.actionid
WHERE au.id IS NULL
  AND u.userstatus = 'Active'
GROUP BY u.userid, s.systemid, s.systemname
ORDER BY u.userid, s.systemid
LIMIT 50;

-- -----------------------------------------------------------------------------
-- CATEGORY C: Multiple Active Pending Per SUID
-- -----------------------------------------------------------------------------

-- C1. Count of suids with multiple pending notifications that have notstartdate set
-- (Violates rule: only ONE notification per suid should have notstartdate set at a time)
SELECT
    'C1_multiple_active_pending' AS issue_code,
    COUNT(*) AS issue_count
FROM (
    SELECT
        n.suid,
        COUNT(*) AS pending_count
    FROM funotifications n
    WHERE n.notstatus = 'Pending'
      AND n.notstartdate IS NOT NULL
      AND n.isdeleted = 0
    GROUP BY n.suid
    HAVING COUNT(*) > 1
) violations;

-- C1 Detail: Show the problematic suids and their multiple pending notifications
SELECT
    n.suid,
    su.contactid,
    su.userid,
    s.systemname,
    n.notid,
    n.actionid,
    a.actionno,
    a.actiontitle,
    n.notstartdate,
    n.notstatus
FROM funotifications n
INNER JOIN fusystemusers su ON su.suid = n.suid
INNER JOIN fusystems s ON s.systemid = su.systemid
INNER JOIN fuactions a ON a.actionid = n.actionid
WHERE n.suid IN (
    SELECT suid
    FROM funotifications
    WHERE notstatus = 'Pending'
      AND notstartdate IS NOT NULL
      AND isdeleted = 0
    GROUP BY suid
    HAVING COUNT(*) > 1
)
AND n.notstatus = 'Pending'
AND n.notstartdate IS NOT NULL
AND n.isdeleted = 0
ORDER BY n.suid, n.notstartdate, a.actionno
LIMIT 50;

-- -----------------------------------------------------------------------------
-- CATEGORY D: Stuck Systems
-- -----------------------------------------------------------------------------

-- D1. Active systems with NO pending notifications at all
SELECT
    'D1_stuck_no_pending' AS issue_code,
    COUNT(*) AS issue_count
FROM fusystemusers su
LEFT JOIN funotifications n ON n.suid = su.suid
    AND n.notstatus = 'Pending'
    AND n.isdeleted = 0
WHERE su.sustatus = 'Active'
  AND su.isdeleted = 0
  AND n.notid IS NULL;

-- D1 Detail
SELECT
    su.suid,
    su.contactid,
    su.userid,
    s.systemname,
    s.systemtype,
    su.sustartdate,
    cd.recordname AS contact_name
FROM fusystemusers su
INNER JOIN fusystems s ON s.systemid = su.systemid
LEFT JOIN contactdetails cd ON cd.contactid = su.contactid AND cd.userid = su.userid
LEFT JOIN funotifications n ON n.suid = su.suid
    AND n.notstatus = 'Pending'
    AND n.isdeleted = 0
WHERE su.sustatus = 'Active'
  AND su.isdeleted = 0
  AND n.notid IS NULL
ORDER BY su.suid
LIMIT 20;

-- D2. Active systems where the only pending notification has NULL notstartdate
-- (Should have been scheduled)
SELECT
    'D2_stuck_null_startdate' AS issue_code,
    COUNT(DISTINCT su.suid) AS issue_count
FROM fusystemusers su
INNER JOIN funotifications n ON n.suid = su.suid
WHERE su.sustatus = 'Active'
  AND su.isdeleted = 0
  AND n.notstatus = 'Pending'
  AND n.notstartdate IS NULL
  AND n.isdeleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM funotifications n2
      WHERE n2.suid = su.suid
        AND n2.notstatus = 'Pending'
        AND n2.notstartdate IS NOT NULL
        AND n2.isdeleted = 0
  );

-- D2 Detail
SELECT
    su.suid,
    su.contactid,
    s.systemname,
    n.notid,
    a.actionno,
    a.actiontitle,
    au.actiondaysno,
    su.sustartdate,
    DATE_ADD(su.sustartdate, INTERVAL au.actiondaysno DAY) AS expected_notstartdate
FROM fusystemusers su
INNER JOIN fusystems s ON s.systemid = su.systemid
INNER JOIN funotifications n ON n.suid = su.suid
INNER JOIN fuactions a ON a.actionid = n.actionid
LEFT JOIN actionusers au ON au.actionid = n.actionid AND au.userid = su.userid
WHERE su.sustatus = 'Active'
  AND su.isdeleted = 0
  AND n.notstatus = 'Pending'
  AND n.notstartdate IS NULL
  AND n.isdeleted = 0
ORDER BY su.suid, a.actionno
LIMIT 30;

-- -----------------------------------------------------------------------------
-- CATEGORY E: Duplicate System Enrollments
-- -----------------------------------------------------------------------------

-- E1. Duplicate fusystemusers for same (userid, contactid, systemid) - both active
SELECT
    'E1_duplicate_active_enrollments' AS issue_code,
    COUNT(*) AS issue_count
FROM (
    SELECT
        userid,
        contactid,
        systemid,
        COUNT(*) AS enrollment_count
    FROM fusystemusers
    WHERE sustatus = 'Active'
      AND isdeleted = 0
    GROUP BY userid, contactid, systemid
    HAVING COUNT(*) > 1
) dups;

-- E1 Detail
SELECT
    su.suid,
    su.userid,
    su.contactid,
    su.systemid,
    s.systemname,
    su.sustartdate,
    su.sustatus,
    cd.recordname AS contact_name
FROM fusystemusers su
INNER JOIN fusystems s ON s.systemid = su.systemid
LEFT JOIN contactdetails cd ON cd.contactid = su.contactid AND cd.userid = su.userid
WHERE (su.userid, su.contactid, su.systemid) IN (
    SELECT userid, contactid, systemid
    FROM fusystemusers
    WHERE sustatus = 'Active'
      AND isdeleted = 0
    GROUP BY userid, contactid, systemid
    HAVING COUNT(*) > 1
)
AND su.sustatus = 'Active'
AND su.isdeleted = 0
ORDER BY su.userid, su.contactid, su.systemid, su.sustartdate
LIMIT 50;

-- E2. Duplicate maintenance systems created by auto-start
-- (Same contact with multiple active Maintenance List systems)
SELECT
    'E2_duplicate_maintenance' AS issue_code,
    COUNT(*) AS issue_count
FROM (
    SELECT
        su.userid,
        su.contactid,
        COUNT(*) AS maint_count
    FROM fusystemusers su
    INNER JOIN fusystems s ON s.systemid = su.systemid
    WHERE s.systemtype = 'Maintenance List'
      AND su.sustatus = 'Active'
      AND su.isdeleted = 0
    GROUP BY su.userid, su.contactid
    HAVING COUNT(*) > 1
) dups;

-- E2 Detail
SELECT
    su.suid,
    su.userid,
    su.contactid,
    s.systemid,
    s.systemname,
    s.systemscope,
    su.sustartdate,
    cd.recordname AS contact_name
FROM fusystemusers su
INNER JOIN fusystems s ON s.systemid = su.systemid
LEFT JOIN contactdetails cd ON cd.contactid = su.contactid AND cd.userid = su.userid
WHERE s.systemtype = 'Maintenance List'
  AND su.sustatus = 'Active'
  AND su.isdeleted = 0
  AND (su.userid, su.contactid) IN (
      SELECT su2.userid, su2.contactid
      FROM fusystemusers su2
      INNER JOIN fusystems s2 ON s2.systemid = su2.systemid
      WHERE s2.systemtype = 'Maintenance List'
        AND su2.sustatus = 'Active'
        AND su2.isdeleted = 0
      GROUP BY su2.userid, su2.contactid
      HAVING COUNT(*) > 1
  )
ORDER BY su.userid, su.contactid, su.sustartdate
LIMIT 50;

-- -----------------------------------------------------------------------------
-- CATEGORY F: Uniqueness Violations
-- -----------------------------------------------------------------------------

-- F1. Actions marked isUnique that were executed multiple times for same contact
-- (Check funotifications for same actionid + contactid with status Completed)
SELECT
    'F1_uniqueness_violations' AS issue_code,
    COUNT(*) AS issue_count
FROM (
    SELECT
        su.contactid,
        n.actionid,
        COUNT(*) AS completion_count
    FROM funotifications n
    INNER JOIN fusystemusers su ON su.suid = n.suid
    INNER JOIN fuactions a ON a.actionid = n.actionid
    WHERE a.isunique = 1
      AND n.notstatus = 'Completed'
      AND n.isdeleted = 0
    GROUP BY su.contactid, n.actionid
    HAVING COUNT(*) > 1
) violations;

-- F1 Detail
SELECT
    su.contactid,
    cd.recordname AS contact_name,
    n.actionid,
    a.actiontitle,
    a.uniquename,
    COUNT(*) AS times_completed
FROM funotifications n
INNER JOIN fusystemusers su ON su.suid = n.suid
INNER JOIN fuactions a ON a.actionid = n.actionid
LEFT JOIN contactdetails cd ON cd.contactid = su.contactid
WHERE a.isunique = 1
  AND n.notstatus = 'Completed'
  AND n.isdeleted = 0
GROUP BY su.contactid, cd.recordname, n.actionid, a.actiontitle, a.uniquename
HAVING COUNT(*) > 1
ORDER BY times_completed DESC
LIMIT 20;

-- F2. Contacts with unique action completed but flag not set in contactdetails
-- (Requires knowing which columns map to which uniquename values)
-- This is a sample query - adjust based on actual uniquename column names
/*
SELECT
    'F2_missing_unique_flag' AS issue_code,
    COUNT(*) AS issue_count
FROM funotifications n
INNER JOIN fusystemusers su ON su.suid = n.suid
INNER JOIN fuactions a ON a.actionid = n.actionid
INNER JOIN contactdetails cd ON cd.contactid = su.contactid AND cd.userid = su.userid
WHERE a.isunique = 1
  AND a.uniquename IS NOT NULL
  AND n.notstatus = 'Completed'
  AND n.isdeleted = 0
  -- Would need dynamic SQL or CASE statement to check cd.[uniquename] = 'Y'
;
*/

-- -----------------------------------------------------------------------------
-- CATEGORY G: Scheduling Issues
-- -----------------------------------------------------------------------------

-- G1. Notifications that should be due but have future status
SELECT
    'G1_overdue_future_status' AS issue_code,
    COUNT(*) AS issue_count
FROM funotifications n
WHERE n.notstatus = 'Future'
  AND n.notstartdate <= CURDATE()
  AND n.isdeleted = 0;

-- G2. Pending notifications with notstartdate in distant past (> 1 year)
SELECT
    'G2_ancient_pending' AS issue_code,
    COUNT(*) AS issue_count
FROM funotifications n
WHERE n.notstatus = 'Pending'
  AND n.notstartdate < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  AND n.isdeleted = 0;

-- G2 Detail
SELECT
    n.notid,
    n.suid,
    su.contactid,
    cd.recordname,
    n.notstartdate,
    DATEDIFF(CURDATE(), n.notstartdate) AS days_overdue,
    a.actiontitle
FROM funotifications n
INNER JOIN fusystemusers su ON su.suid = n.suid
INNER JOIN fuactions a ON a.actionid = n.actionid
LEFT JOIN contactdetails cd ON cd.contactid = su.contactid
WHERE n.notstatus = 'Pending'
  AND n.notstartdate < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  AND n.isdeleted = 0
ORDER BY n.notstartdate
LIMIT 20;

-- -----------------------------------------------------------------------------
-- CATEGORY H: Data Consistency Checks
-- -----------------------------------------------------------------------------

-- H1. fusystemusers marked as Completed but still have pending notifications
SELECT
    'H1_completed_with_pending' AS issue_code,
    COUNT(*) AS issue_count
FROM fusystemusers su
INNER JOIN funotifications n ON n.suid = su.suid
WHERE su.sustatus = 'Completed'
  AND n.notstatus = 'Pending'
  AND n.isdeleted = 0
  AND su.isdeleted = 0;

-- H1 Detail
SELECT
    su.suid,
    su.contactid,
    s.systemname,
    su.sustatus,
    COUNT(n.notid) AS pending_notification_count
FROM fusystemusers su
INNER JOIN fusystems s ON s.systemid = su.systemid
INNER JOIN funotifications n ON n.suid = su.suid
WHERE su.sustatus = 'Completed'
  AND n.notstatus = 'Pending'
  AND n.isdeleted = 0
  AND su.isdeleted = 0
GROUP BY su.suid, su.contactid, s.systemname, su.sustatus
LIMIT 20;

-- H2. Notifications with enddate but status still Pending
SELECT
    'H2_pending_with_enddate' AS issue_code,
    COUNT(*) AS issue_count
FROM funotifications n
WHERE n.notstatus = 'Pending'
  AND n.notenddate IS NOT NULL
  AND n.isdeleted = 0;

-- H3. Total counts for reference
SELECT 'TOTAL_fusystemusers_active' AS metric, COUNT(*) AS value
FROM fusystemusers WHERE sustatus = 'Active' AND isdeleted = 0
UNION ALL
SELECT 'TOTAL_fusystemusers_completed' AS metric, COUNT(*) AS value
FROM fusystemusers WHERE sustatus = 'Completed' AND isdeleted = 0
UNION ALL
SELECT 'TOTAL_funotifications_pending' AS metric, COUNT(*) AS value
FROM funotifications WHERE notstatus = 'Pending' AND isdeleted = 0
UNION ALL
SELECT 'TOTAL_funotifications_completed' AS metric, COUNT(*) AS value
FROM funotifications WHERE notstatus = 'Completed' AND isdeleted = 0
UNION ALL
SELECT 'TOTAL_funotifications_skipped' AS metric, COUNT(*) AS value
FROM funotifications WHERE notstatus = 'Skipped' AND isdeleted = 0
UNION ALL
SELECT 'TOTAL_fuactions' AS metric, COUNT(*) AS value
FROM fuactions
UNION ALL
SELECT 'TOTAL_actionusers' AS metric, COUNT(*) AS value
FROM actionusers WHERE isdeleted = 0
UNION ALL
SELECT 'TOTAL_active_users' AS metric, COUNT(*) AS value
FROM taousers WHERE userstatus = 'Active';

-- -----------------------------------------------------------------------------
-- SUMMARY QUERY: All Issue Counts in One Result
-- -----------------------------------------------------------------------------

SELECT 'A1_orphan_suid' AS issue_code, COUNT(*) AS issue_count
FROM funotifications n
LEFT JOIN fusystemusers su ON su.suid = n.suid
WHERE su.suid IS NULL AND n.isdeleted = 0

UNION ALL

SELECT 'A2_orphan_actionid', COUNT(*)
FROM funotifications n
LEFT JOIN fuactions a ON a.actionid = n.actionid
WHERE a.actionid IS NULL AND n.isdeleted = 0

UNION ALL

SELECT 'A3_orphan_userid', COUNT(*)
FROM funotifications n
LEFT JOIN taousers u ON u.userid = n.userid
WHERE u.userid IS NULL AND n.isdeleted = 0

UNION ALL

SELECT 'C1_multiple_active_pending', COUNT(*)
FROM (
    SELECT suid FROM funotifications
    WHERE notstatus = 'Pending' AND notstartdate IS NOT NULL AND isdeleted = 0
    GROUP BY suid HAVING COUNT(*) > 1
) t

UNION ALL

SELECT 'D1_stuck_no_pending', COUNT(*)
FROM fusystemusers su
LEFT JOIN funotifications n ON n.suid = su.suid AND n.notstatus = 'Pending' AND n.isdeleted = 0
WHERE su.sustatus = 'Active' AND su.isdeleted = 0 AND n.notid IS NULL

UNION ALL

SELECT 'E1_duplicate_active_enrollments', COUNT(*)
FROM (
    SELECT userid, contactid, systemid FROM fusystemusers
    WHERE sustatus = 'Active' AND isdeleted = 0
    GROUP BY userid, contactid, systemid HAVING COUNT(*) > 1
) t

UNION ALL

SELECT 'E2_duplicate_maintenance', COUNT(*)
FROM (
    SELECT su.userid, su.contactid FROM fusystemusers su
    INNER JOIN fusystems s ON s.systemid = su.systemid
    WHERE s.systemtype = 'Maintenance List' AND su.sustatus = 'Active' AND su.isdeleted = 0
    GROUP BY su.userid, su.contactid HAVING COUNT(*) > 1
) t

UNION ALL

SELECT 'G1_overdue_future_status', COUNT(*)
FROM funotifications WHERE notstatus = 'Future' AND notstartdate <= CURDATE() AND isdeleted = 0

UNION ALL

SELECT 'H1_completed_with_pending', COUNT(*)
FROM fusystemusers su
INNER JOIN funotifications n ON n.suid = su.suid
WHERE su.sustatus = 'Completed' AND n.notstatus = 'Pending' AND n.isdeleted = 0 AND su.isdeleted = 0;
