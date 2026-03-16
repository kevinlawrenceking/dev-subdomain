-- ==========================================================================
-- WO-3.2: Relationship System Diagnostic Queries
-- ==========================================================================
-- PURPOSE: Discover data integrity issues in the relationship system.
-- Run these against the production database to assess health.
-- These are SELECT-only — no data modifications.
-- ==========================================================================

-- ----- 1. Orphaned notifications: funotifications referencing non-existent suid -----
SELECT
    n.notid,
    n.suid,
    n.actionid,
    n.userid,
    n.notstatus,
    n.notstartdate
FROM funotifications n
LEFT JOIN fusystemusers_tbl su ON su.suid = n.suid
WHERE su.suid IS NULL
  AND n.isdeleted = 0;

-- ----- 2. Orphaned notifications: funotifications referencing deleted suid -----
SELECT
    n.notid,
    n.suid,
    n.actionid,
    n.userid,
    n.notstatus,
    su.sustatus,
    su.isdeleted AS su_isdeleted
FROM funotifications n
INNER JOIN fusystemusers_tbl su ON su.suid = n.suid
WHERE su.isdeleted = 1
  AND n.isdeleted = 0
  AND n.notstatus = 'Pending';

-- ----- 3. Stuck systems: Active systems with ZERO pending notifications -----
SELECT
    su.suid,
    su.systemid,
    su.contactid,
    su.userid,
    su.sustartdate,
    su.sustatus,
    s.systemname,
    s.systemtype
FROM fusystemusers_tbl su
INNER JOIN fusystems s ON s.systemid = su.systemid
LEFT JOIN funotifications n
    ON n.suid = su.suid
    AND n.notstatus = 'Pending'
    AND n.isdeleted = 0
WHERE su.sustatus = 'Active'
  AND su.isdeleted = 0
  AND n.notid IS NULL;

-- ----- 4. Multiple pending notifications with notstartdate set for same suid -----
-- Rule: only ONE notification per suid should have notstartdate set at a time
SELECT
    n.suid,
    COUNT(*) AS scheduled_count,
    GROUP_CONCAT(n.notid ORDER BY n.notstartdate) AS notid_list,
    GROUP_CONCAT(n.notstartdate ORDER BY n.notstartdate) AS dates
FROM funotifications n
WHERE n.notstatus = 'Pending'
  AND n.notstartdate IS NOT NULL
  AND n.isdeleted = 0
GROUP BY n.suid
HAVING COUNT(*) > 1;

-- ----- 5. Duplicate active enrollments (same user+contact+system) -----
SELECT
    su.userid,
    su.contactid,
    su.systemid,
    s.systemname,
    s.systemtype,
    COUNT(*) AS active_count,
    GROUP_CONCAT(su.suid ORDER BY su.sustartdate) AS suid_list
FROM fusystemusers_tbl su
INNER JOIN fusystems s ON s.systemid = su.systemid
WHERE su.sustatus = 'Active'
  AND su.isdeleted = 0
GROUP BY su.userid, su.contactid, su.systemid
HAVING COUNT(*) > 1;

-- ----- 6. Notifications referencing non-existent actions -----
SELECT
    n.notid,
    n.actionid,
    n.suid,
    n.notstatus
FROM funotifications n
LEFT JOIN fuactions a ON a.actionid = n.actionid
WHERE a.actionid IS NULL
  AND n.isdeleted = 0;

-- ----- 7. Summary counts -----
SELECT 'Active systems' AS metric, COUNT(*) AS cnt
FROM fusystemusers_tbl WHERE sustatus = 'Active' AND isdeleted = 0
UNION ALL
SELECT 'Pending notifications', COUNT(*)
FROM funotifications WHERE notstatus = 'Pending' AND isdeleted = 0 AND notstartdate IS NOT NULL
UNION ALL
SELECT 'Unscheduled pending', COUNT(*)
FROM funotifications WHERE notstatus = 'Pending' AND isdeleted = 0 AND notstartdate IS NULL
UNION ALL
SELECT 'Total notifications (active)', COUNT(*)
FROM funotifications WHERE isdeleted = 0;
