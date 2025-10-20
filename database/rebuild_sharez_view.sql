-- =====================================================
-- REBUILD SHAREZ VIEW - OPTIMIZED VERSION
-- =====================================================
-- CRITICAL DISCOVERY: All tables are actually VIEWS with IsDeleted filters!
-- This creates 3-level view nesting which compounds performance issues.
--
-- Base table mapping:
-- contactdetails → contactdetails_tbl (WHERE IsDeleted <> 1)
-- taousers → taousers_tbl (WHERE IsDeleted <> 1)
-- fusystemusers → fusystemusers_tbl (WHERE IsDeleted <> 1)
-- contactitems → contactitems_tbl (WHERE IsDeleted <> 1)
-- eventcontactsxref → eventcontactsxref_tbl (WHERE IsDeleted <> 1)
-- events → events_tbl (WHERE IsDeleted <> 1)
-- noteslog → noteslog_tbl (WHERE IsDeleted <> 1)
-- maxaudition → complex view with multiple joins
--
-- Key optimizations:
-- 1. Query BASE TABLES directly instead of views
-- 2. Remove GROUP_CONCAT (major performance killer)
-- 3. Eliminate correlated subquery for last event
-- 4. Simplify maxaudition logic
-- 5. Add proper indexes on BASE tables
-- =====================================================

-- STEP 1: Drop existing view
-- =====================================================
DROP VIEW IF EXISTS sharez;

-- STEP 2: Create optimized view (querying BASE TABLES directly)
-- =====================================================
CREATE VIEW sharez AS
SELECT 
    d.contactID AS contactid,
    d.recordname AS NAME,
    ci_company.valueCompany AS Company,
    ci_tag.valueText AS Title,
    mx.audstep AS Audition,
    d.contactMeetingLoc AS WhereMet,
    d.contactMeetingDate AS WhenMet,
    NULL AS NotesLog,  -- Removed GROUP_CONCAT - retrieve notes separately
    u.userID AS userid,
    LEFT(u.passwordHash, 10) AS userHash,
    le.eventStart AS last_met,
    IFNULL(mc.no_mtgs, 0) AS no_mtgs,
    le.eventTypeName AS lasteventtype
FROM contactdetails_tbl d
-- Required joins first (filters early) - USING BASE TABLES
JOIN taousers_tbl u ON u.userID = d.userID AND u.IsDeleted <> 1
JOIN fusystemusers_tbl su ON su.contactID = d.contactID 
    AND su.userid = d.userID 
    AND su.suStatus = 'Active' 
    AND su.systemID IN (1,2,3,4)
    AND su.IsDeleted <> 1
-- Optional data - USING BASE TABLES with IsDeleted filters
LEFT JOIN (
    -- Simplified maxaudition logic - get max audstep per contact
    SELECT x.contactid, s.audstep
    FROM audcontacts_auditions_xref x
    JOIN events_tbl a ON a.audRoleID IS NOT NULL AND a.IsDeleted <> 1
    JOIN audsteps s ON s.audstepid = a.audStepID
    JOIN (
        SELECT x2.contactid, MAX(s2.audstepid) AS max_audstepid
        FROM audcontacts_auditions_xref x2
        JOIN events_tbl a2 ON a2.audRoleID IS NOT NULL AND a2.IsDeleted <> 1
        JOIN audsteps s2 ON s2.audstepid = a2.audStepID
        GROUP BY x2.contactid
    ) mxsub ON mxsub.contactid = x.contactid AND s.audstepid = mxsub.max_audstepid
    GROUP BY x.contactid, s.audstep
) mx ON mx.contactid = d.contactID
LEFT JOIN contactitems_tbl ci_company ON ci_company.contactID = d.contactID 
    AND ci_company.valueCategory = 'Company' 
    AND ci_company.itemStatus = 'active'
    AND ci_company.IsDeleted <> 1
LEFT JOIN contactitems_tbl ci_tag ON ci_tag.contactID = d.contactID 
    AND ci_tag.valueCategory = 'Tag' 
    AND ci_tag.itemStatus = 'Active'
    AND ci_tag.IsDeleted <> 1
-- Aggregated meeting counts - USING BASE TABLE
LEFT JOIN (
    SELECT contactID, COUNT(*) AS no_mtgs
    FROM eventcontactsxref_tbl
    WHERE IsDeleted <> 1
    GROUP BY contactID
) mc ON mc.contactID = d.contactID
-- Last event - USING BASE TABLES with window function
LEFT JOIN (
    SELECT x.contactID, e.eventTypeName, e.eventStart,
           ROW_NUMBER() OVER (PARTITION BY x.contactID ORDER BY e.eventStart DESC) AS rn
    FROM eventcontactsxref_tbl x
    JOIN events_tbl e ON e.eventID = x.eventID AND e.IsDeleted <> 1
    WHERE x.IsDeleted <> 1
) le ON le.contactID = d.contactID AND le.rn = 1
WHERE d.IsDeleted <> 1;


-- ALTERNATIVE: If ROW_NUMBER not supported, use this version
-- =====================================================
/*
DROP VIEW IF EXISTS sharez;

CREATE VIEW sharez AS
SELECT 
    d.contactID AS contactid,
    d.recordname AS NAME,
    ci_company.valueCompany AS Company,
    ci_tag.valueText AS Title,
    mx.audstep AS Audition,
    d.contactMeetingLoc AS WhereMet,
    d.contactMeetingDate AS WhenMet,
    NULL AS NotesLog,
    u.userID AS userid,
    LEFT(u.passwordHash, 10) AS userHash,
    le.eventStart AS last_met,
    IFNULL(mc.no_mtgs, 0) AS no_mtgs,
    le.eventTypeName AS lasteventtype
FROM contactdetails_tbl d
JOIN taousers_tbl u ON u.userID = d.userID AND u.IsDeleted <> 1
JOIN fusystemusers_tbl su ON su.contactID = d.contactID 
    AND su.userid = d.userID 
    AND su.suStatus = 'Active' 
    AND su.systemID IN (1,2,3,4)
    AND su.IsDeleted <> 1
LEFT JOIN (
    SELECT x.contactid, s.audstep
    FROM audcontacts_auditions_xref x
    JOIN events_tbl a ON a.audRoleID IS NOT NULL AND a.IsDeleted <> 1
    JOIN audsteps s ON s.audstepid = a.audStepID
    JOIN (
        SELECT x2.contactid, MAX(s2.audstepid) AS max_audstepid
        FROM audcontacts_auditions_xref x2
        JOIN events_tbl a2 ON a2.audRoleID IS NOT NULL AND a2.IsDeleted <> 1
        JOIN audsteps s2 ON s2.audstepid = a2.audStepID
        GROUP BY x2.contactid
    ) mxsub ON mxsub.contactid = x.contactid AND s.audstepid = mxsub.max_audstepid
    GROUP BY x.contactid, s.audstep
) mx ON mx.contactid = d.contactID
LEFT JOIN contactitems_tbl ci_company ON ci_company.contactID = d.contactID 
    AND ci_company.valueCategory = 'Company' 
    AND ci_company.itemStatus = 'active'
    AND ci_company.IsDeleted <> 1
LEFT JOIN contactitems_tbl ci_tag ON ci_tag.contactID = d.contactID 
    AND ci_tag.valueCategory = 'Tag' 
    AND ci_tag.itemStatus = 'Active'
    AND ci_tag.IsDeleted <> 1
LEFT JOIN (
    SELECT contactID, COUNT(*) AS no_mtgs
    FROM eventcontactsxref_tbl
    WHERE IsDeleted <> 1
    GROUP BY contactID
) mc ON mc.contactID = d.contactID
LEFT JOIN (
    SELECT x1.contactID, e1.eventTypeName, e1.eventStart
    FROM eventcontactsxref_tbl x1
    JOIN events_tbl e1 ON e1.eventID = x1.eventID AND e1.IsDeleted <> 1
    WHERE x1.IsDeleted <> 1
      AND e1.eventStart = (
        SELECT MAX(e2.eventStart)
        FROM eventcontactsxref_tbl x2
        JOIN events_tbl e2 ON e2.eventID = x2.eventID AND e2.IsDeleted <> 1
        WHERE x2.contactID = x1.contactID AND x2.IsDeleted <> 1
    )
    GROUP BY x1.contactID, e1.eventTypeName, e1.eventStart
) le ON le.contactID = d.contactID
WHERE d.IsDeleted <> 1;
*/


-- STEP 3: Add critical indexes on BASE TABLES
-- =====================================================

-- CRITICAL: All the "tables" are actually VIEWS with IsDeleted filters!
-- We MUST index the BASE TABLES (_tbl suffix), not the views.

-- IMPORTANT: Run this script with --force flag to ignore duplicate index errors:
-- mysql -u username -p abod --force < rebuild_sharez_view.sql
-- 
-- Or manually check and drop conflicting indexes first:
-- SELECT DISTINCT TABLE_NAME, INDEX_NAME FROM information_schema.STATISTICS 
-- WHERE TABLE_SCHEMA = 'abod' AND INDEX_NAME LIKE 'idx_%tbl%';

-- Indexes on contactdetails_tbl
CREATE INDEX idx_contactdetails_tbl_userid ON contactdetails_tbl(userID);
CREATE INDEX idx_contactdetails_tbl_isdeleted ON contactdetails_tbl(IsDeleted);
CREATE INDEX idx_contactdetails_tbl_contactid ON contactdetails_tbl(contactID);
-- Compound index for optimal filtering: (userID, IsDeleted, contactID)
CREATE INDEX idx_contactdetails_tbl_user_deleted ON contactdetails_tbl(userID, IsDeleted, contactID);

-- Indexes on taousers_tbl
CREATE INDEX idx_taousers_tbl_userid ON taousers_tbl(userID);
CREATE INDEX idx_taousers_tbl_isdeleted ON taousers_tbl(IsDeleted);

-- Indexes on fusystemusers_tbl
CREATE INDEX idx_fusystemusers_tbl_contact_status ON fusystemusers_tbl(contactID, userid, suStatus, systemID);
CREATE INDEX idx_fusystemusers_tbl_isdeleted ON fusystemusers_tbl(IsDeleted);

-- Indexes on contactitems_tbl
CREATE INDEX idx_contactitems_tbl_lookup ON contactitems_tbl(contactID, valueCategory, itemStatus);
CREATE INDEX idx_contactitems_tbl_isdeleted ON contactitems_tbl(IsDeleted);

-- Indexes on eventcontactsxref_tbl
CREATE INDEX idx_eventcontactsxref_tbl_contact ON eventcontactsxref_tbl(contactID, eventID);
CREATE INDEX idx_eventcontactsxref_tbl_isdeleted ON eventcontactsxref_tbl(IsDeleted);

-- Indexes on events_tbl
CREATE INDEX idx_events_tbl_id_start ON events_tbl(eventID, eventStart DESC);
CREATE INDEX idx_events_tbl_isdeleted ON events_tbl(IsDeleted);
CREATE INDEX idx_events_tbl_audroleid ON events_tbl(audRoleID);

-- Indexes on noteslog_tbl
CREATE INDEX idx_noteslog_tbl_contact_public ON noteslog_tbl(contactID, isPublic);
CREATE INDEX idx_noteslog_tbl_isdeleted ON noteslog_tbl(IsDeleted);

-- Indexes for maxaudition subquery optimization
CREATE INDEX idx_audcontacts_xref_contactid ON audcontacts_auditions_xref(contactid);
CREATE INDEX idx_audsteps_stepid ON audsteps(audstepid);


-- STEP 4: Test the view performance
-- =====================================================
-- Run this to test the new view:
/*
SELECT SQL_NO_CACHE COUNT(*) FROM sharez;
SELECT SQL_NO_CACHE * FROM sharez WHERE userid = 1234 LIMIT 10;
*/


-- STEP 5: Optional - Create materialized cache table for best performance
-- =====================================================
/*
CREATE TABLE sharez_cache (
    contactid INT PRIMARY KEY,
    NAME VARCHAR(255),
    Company VARCHAR(255),
    Title VARCHAR(255),
    Audition VARCHAR(100),
    WhereMet VARCHAR(255),
    WhenMet DATE,
    userid INT,
    userHash VARCHAR(10),
    last_met DATETIME,
    no_mtgs INT DEFAULT 0,
    lasteventtype VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_userid (userid),
    INDEX idx_name (NAME)
) ENGINE=InnoDB;

-- Populate cache (run this periodically via cron)
INSERT INTO sharez_cache 
SELECT contactid, NAME, Company, Title, Audition, WhereMet, WhenMet,
       userid, userHash, last_met, no_mtgs, lasteventtype,
       CURRENT_TIMESTAMP
FROM sharez
ON DUPLICATE KEY UPDATE
    NAME = VALUES(NAME),
    Company = VALUES(Company),
    Title = VALUES(Title),
    Audition = VALUES(Audition),
    WhereMet = VALUES(WhereMet),
    WhenMet = VALUES(WhenMet),
    userid = VALUES(userid),
    userHash = VALUES(userHash),
    last_met = VALUES(last_met),
    no_mtgs = VALUES(no_mtgs),
    lasteventtype = VALUES(lasteventtype),
    last_updated = CURRENT_TIMESTAMP;

-- Then update share.cfm to query sharez_cache instead of sharez
*/
