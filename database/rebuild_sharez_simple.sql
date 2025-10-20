-- =====================================================
-- REBUILD SHAREZ VIEW - SIMPLE VERSION (FROM SCRATCH)
-- =====================================================
-- Purpose: Get contacts for a specific user (userid = X)
-- Grouped by: number of meetings and last audition status
-- =====================================================

-- STEP 1: Drop existing view
-- =====================================================
DROP VIEW IF EXISTS sharez;

-- STEP 2: Create clean, optimized view
-- =====================================================
CREATE VIEW sharezz AS
SELECT 
    -- Contact basic info
    cd.contactID AS contactid,
    cd.recordname AS NAME,
    cd.contactMeetingLoc AS WhereMet,
    cd.contactMeetingDate AS WhenMet,
    cd.userID AS userid,
    
    -- User hash for share URLs
    LEFT(tu.passwordHash, 10) AS userHash,
    
    -- Company (first one found)
    (SELECT ci.valueCompany 
     FROM contactitems_tbl ci 
     WHERE ci.contactID = cd.contactID 
       AND ci.valueCategory = 'Company' 
       AND ci.itemStatus = 'active'
       AND ci.IsDeleted = 0
     LIMIT 1) AS Company,
    
    -- Title/Tag (first one found)
    (SELECT ci.valueText 
     FROM contactitems_tbl ci 
     WHERE ci.contactID = cd.contactID 
       AND ci.valueCategory = 'Tag' 
       AND ci.itemStatus = 'Active'
       AND ci.IsDeleted = 0
     LIMIT 1) AS Title,
    
    -- Last audition status
    (SELECT s.audstep
     FROM audcontacts_auditions_xref x
     JOIN events_tbl e ON e.audRoleID IS NOT NULL AND e.IsDeleted = 0
     JOIN audsteps s ON s.audstepid = e.audStepID
     WHERE x.contactid = cd.contactID
     ORDER BY s.audstepid DESC
     LIMIT 1) AS Audition,
    
    -- Number of meetings
    (SELECT COUNT(*) 
     FROM eventcontactsxref_tbl ecx
     WHERE ecx.contactID = cd.contactID 
       AND ecx.IsDeleted = 0) AS no_mtgs,
    
    -- Last meeting date
    (SELECT e.eventStart
     FROM eventcontactsxref_tbl ecx
     JOIN events_tbl e ON e.eventID = ecx.eventID AND e.IsDeleted = 0
     WHERE ecx.contactID = cd.contactID 
       AND ecx.IsDeleted = 0
     ORDER BY e.eventStart DESC
     LIMIT 1) AS last_met,
    
    -- Last meeting type
    (SELECT e.eventTypeName
     FROM eventcontactsxref_tbl ecx
     JOIN events_tbl e ON e.eventID = ecx.eventID AND e.IsDeleted = 0
     WHERE ecx.contactID = cd.contactID 
       AND ecx.IsDeleted = 0
     ORDER BY e.eventStart DESC
     LIMIT 1) AS lasteventtype,
    
    -- NotesLog placeholder (retrieve separately for performance)
    NULL AS NotesLog

FROM contactdetails_tbl cd
JOIN taousers_tbl tu ON tu.userID = cd.userID 
    AND tu.IsDeleted = 0
JOIN fusystemusers_tbl fsu ON fsu.contactID = cd.contactID 
    AND fsu.userid = cd.userID 
    AND fsu.suStatus = 'Active' 
    AND fsu.systemID IN (1,2,3,4)
    AND fsu.IsDeleted = 0
WHERE cd.IsDeleted = 0;


-- =====================================================
-- STEP 3: Add essential indexes for performance
-- =====================================================

-- Core contact lookups
CREATE INDEX idx_contactdetails_tbl_userid_deleted ON contactdetails_tbl(userID, IsDeleted);
CREATE INDEX idx_contactdetails_tbl_contactid ON contactdetails_tbl(contactID);

-- User lookups
CREATE INDEX idx_taousers_tbl_userid_deleted ON taousers_tbl(userID, IsDeleted);

-- System users (active contacts)
CREATE INDEX idx_fusystemusers_tbl_lookup ON fusystemusers_tbl(contactID, userid, suStatus, IsDeleted);

-- Contact items (company/tags)
CREATE INDEX idx_contactitems_tbl_contact_cat ON contactitems_tbl(contactID, valueCategory, itemStatus, IsDeleted);

-- Events and meetings
CREATE INDEX idx_eventcontactsxref_tbl_contact_deleted ON eventcontactsxref_tbl(contactID, IsDeleted);
CREATE INDEX idx_events_tbl_id_deleted ON events_tbl(eventID, IsDeleted);
CREATE INDEX idx_events_tbl_start_desc ON events_tbl(eventStart DESC);

-- Audition tracking
CREATE INDEX idx_audcontacts_xref_contactid ON audcontacts_auditions_xref(contactid);
CREATE INDEX idx_events_tbl_audroleid ON events_tbl(audRoleID, IsDeleted);
CREATE INDEX idx_audsteps_stepid ON audsteps(audstepid);


-- =====================================================
-- STEP 4: Test the view
-- =====================================================
/*
-- Test query speed
SELECT SQL_NO_CACHE COUNT(*) FROM sharez;

-- Test specific user
SELECT SQL_NO_CACHE * FROM sharez WHERE userid = 1234 LIMIT 10;

-- Test with WHERE clause filtering
SELECT * FROM sharez WHERE userid = 1234 AND no_mtgs > 0 ORDER BY last_met DESC;
*/


-- =====================================================
-- NOTES
-- =====================================================
/*
This simplified approach uses scalar subqueries instead of complex joins.
MySQL will optimize these efficiently with proper indexes.

Advantages:
1. Cleaner, more readable SQL
2. No GROUP_CONCAT performance issues
3. No complex window functions or correlated subqueries
4. Each subquery runs once per row with proper indexes
5. Easy to add/remove columns

Performance tips:
- The indexes above are critical for subquery performance
- Each subquery uses LIMIT 1 to stop scanning early
- IsDeleted filters applied in every subquery
- Run with --force flag if indexes already exist:
  mysql -u username -p abod --force < rebuild_sharez_simple.sql
*/
