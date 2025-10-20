-- =====================================================
-- SHAREZ VIEW OPTIMIZATION
-- =====================================================
-- Current view has multiple performance issues:
-- 1. Multiple subqueries with correlated queries
-- 2. GROUP_CONCAT on all rows (very slow)
-- 3. Multiple LEFT JOINs that scan large tables
-- 4. Correlated subquery for last event (scans events table multiple times)
-- =====================================================

-- STEP 1: Create required indexes
-- =====================================================

-- Core lookup indexes
CREATE INDEX idx_contactdetails_userid_contactid ON contactdetails(userID, contactID);
CREATE INDEX idx_fusystemusers_userid_contactid ON fusystemusers(userID, contactID, suStatus, systemID);

-- ContactItems indexes (critical for the two LEFT JOINs)
CREATE INDEX idx_contactitems_lookup ON contactitems(contactID, valueCategory, itemStatus);

-- NotesLog index (for public notes aggregation)
CREATE INDEX idx_noteslog_contact_public ON noteslog(contactID, isPublic, noteID);

-- EventContactsXref indexes (for meeting counts and last meeting)
CREATE INDEX idx_eventcontactsxref_contact ON eventcontactsxref(contactID, eventID);
CREATE INDEX idx_events_id_start ON events(eventID, eventStart, eventTypeName);

-- MaxAudition index
CREATE INDEX idx_maxaudition_contactid ON maxaudition(contactid);


-- STEP 2: Create materialized helper tables (optional but recommended)
-- =====================================================

-- Pre-aggregate meeting counts (refresh periodically or via trigger)
CREATE TABLE cache_contact_meeting_counts (
    contactID INT PRIMARY KEY,
    no_mtgs INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_updated (last_updated)
) ENGINE=InnoDB;

-- Populate meeting counts cache
INSERT INTO cache_contact_meeting_counts (contactID, no_mtgs)
SELECT contactID, COUNT(*) 
FROM eventcontactsxref 
GROUP BY contactID
ON DUPLICATE KEY UPDATE no_mtgs = VALUES(no_mtgs), last_updated = CURRENT_TIMESTAMP;

-- Pre-aggregate last event info (refresh periodically or via trigger)
CREATE TABLE cache_contact_last_event (
    contactID INT PRIMARY KEY,
    eventTypeName VARCHAR(255),
    eventStart DATETIME,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_updated (last_updated)
) ENGINE=InnoDB;

-- Populate last event cache
INSERT INTO cache_contact_last_event (contactID, eventTypeName, eventStart)
SELECT x.contactID, e.eventTypeName, e.eventStart
FROM eventcontactsxref x
JOIN events e ON e.eventID = x.eventID
WHERE (x.contactID, e.eventStart) IN (
    SELECT x2.contactID, MAX(e2.eventStart)
    FROM eventcontactsxref x2
    JOIN events e2 ON e2.eventID = x2.eventID
    GROUP BY x2.contactID
)
ON DUPLICATE KEY UPDATE 
    eventTypeName = VALUES(eventTypeName), 
    eventStart = VALUES(eventStart),
    last_updated = CURRENT_TIMESTAMP;


-- STEP 3: Optimized view definition
-- =====================================================

DROP VIEW IF EXISTS sharez_optimized;

CREATE VIEW sharez_optimized AS
SELECT 
    d.contactID AS contactid,
    d.recordname AS NAME,
    ci_company.valueCompany AS Company,
    ci_tag.valueText AS Title,
    mx.audstep AS Audition,
    d.contactMeetingLoc AS WhereMet,
    d.contactMeetingDate AS WhenMet,
    -- Remove GROUP_CONCAT for better performance (move to application layer if needed)
    NULL AS NotesLog,
    u.userID AS userid,
    LEFT(u.passwordHash, 10) AS userHash,
    le.eventStart AS last_met,
    IFNULL(mc.no_mtgs, 0) AS no_mtgs,
    le.eventTypeName AS lasteventtype
FROM contactdetails d
-- Only join taousers (required)
JOIN taousers u ON u.userID = d.userID
-- Only get active system users FIRST (reduces result set early)
JOIN fusystemusers su ON su.contactID = d.contactID 
    AND su.userid = d.userID 
    AND su.suStatus = 'Active' 
    AND su.systemID IN (1,2,3,4)
-- Left joins for optional data
LEFT JOIN maxaudition mx ON mx.contactid = d.contactID
LEFT JOIN contactitems ci_company ON ci_company.contactID = d.contactID 
    AND ci_company.valueCategory = 'Company' 
    AND ci_company.itemStatus = 'active'
LEFT JOIN contactitems ci_tag ON ci_tag.contactID = d.contactID 
    AND ci_tag.valueCategory = 'Tag' 
    AND ci_tag.itemStatus = 'Active'
-- Use cached aggregates instead of subqueries
LEFT JOIN cache_contact_meeting_counts mc ON mc.contactID = d.contactID
LEFT JOIN cache_contact_last_event le ON le.contactID = d.contactID;


-- STEP 4: Alternative - denormalized table approach (fastest)
-- =====================================================

CREATE TABLE sharez_cache (
    contactid INT PRIMARY KEY,
    NAME VARCHAR(255),
    Company VARCHAR(255),
    Title VARCHAR(255),
    Audition VARCHAR(100),
    WhereMet VARCHAR(255),
    WhenMet DATE,
    NotesLog TEXT,
    userid INT,
    userHash VARCHAR(10),
    last_met DATETIME,
    no_mtgs INT DEFAULT 0,
    lasteventtype VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_userid (userid),
    INDEX idx_name (NAME),
    INDEX idx_updated (last_updated)
) ENGINE=InnoDB;

-- Populate cache table (run periodically via cron or trigger)
INSERT INTO sharez_cache 
SELECT 
    d.contactID,
    d.recordname,
    MAX(ci_company.valueCompany),
    MAX(ci_tag.valueText),
    MAX(mx.audstep),
    d.contactMeetingLoc,
    d.contactMeetingDate,
    GROUP_CONCAT(DISTINCT n.noteDetails ORDER BY n.noteID ASC SEPARATOR '<BR>'),
    u.userID,
    LEFT(u.passwordHash, 10),
    MAX(le.eventStart),
    IFNULL(mc.no_mtgs, 0),
    MAX(le.eventTypeName),
    CURRENT_TIMESTAMP
FROM contactdetails d
JOIN taousers u ON u.userID = d.userID
JOIN fusystemusers su ON su.contactID = d.contactID 
    AND su.userid = d.userID 
    AND su.suStatus = 'Active' 
    AND su.systemID IN (1,2,3,4)
LEFT JOIN maxaudition mx ON mx.contactid = d.contactID
LEFT JOIN contactitems ci_company ON ci_company.contactID = d.contactID 
    AND ci_company.valueCategory = 'Company' 
    AND ci_company.itemStatus = 'active'
LEFT JOIN contactitems ci_tag ON ci_tag.contactID = d.contactID 
    AND ci_tag.valueCategory = 'Tag' 
    AND ci_tag.itemStatus = 'Active'
LEFT JOIN noteslog n ON n.contactID = d.contactID AND n.isPublic = 1
LEFT JOIN cache_contact_meeting_counts mc ON mc.contactID = d.contactID
LEFT JOIN cache_contact_last_event le ON le.contactID = d.contactID
GROUP BY d.contactID
ON DUPLICATE KEY UPDATE
    NAME = VALUES(NAME),
    Company = VALUES(Company),
    Title = VALUES(Title),
    Audition = VALUES(Audition),
    WhereMet = VALUES(WhereMet),
    WhenMet = VALUES(WhenMet),
    NotesLog = VALUES(NotesLog),
    userid = VALUES(userid),
    userHash = VALUES(userHash),
    last_met = VALUES(last_met),
    no_mtgs = VALUES(no_mtgs),
    lasteventtype = VALUES(lasteventtype),
    last_updated = CURRENT_TIMESTAMP;


-- STEP 5: Trigger to keep cache fresh (optional)
-- =====================================================

DELIMITER $$

-- Update cache when contact details change
DROP TRIGGER IF EXISTS trg_contactdetails_after_update$$
CREATE TRIGGER trg_contactdetails_after_update
AFTER UPDATE ON contactdetails
FOR EACH ROW
BEGIN
    -- Mark cache as stale (simple approach)
    UPDATE sharez_cache 
    SET last_updated = CURRENT_TIMESTAMP 
    WHERE contactid = NEW.contactID;
END$$

-- Update meeting count cache when event contact added
DROP TRIGGER IF EXISTS trg_eventcontact_after_insert$$
CREATE TRIGGER trg_eventcontact_after_insert
AFTER INSERT ON eventcontactsxref
FOR EACH ROW
BEGIN
    INSERT INTO cache_contact_meeting_counts (contactID, no_mtgs)
    VALUES (NEW.contactID, 1)
    ON DUPLICATE KEY UPDATE no_mtgs = no_mtgs + 1;
END$$

DELIMITER ;


-- STEP 6: ColdFusion query optimization
-- =====================================================
-- Replace share.cfm query with:
/*
<cfquery name="sharesWithEvents" datasource="#dsn#" cachedwithin="#CreateTimeSpan(0,0,15,0)#">
    SELECT 
        contactid,
        NAME,
        Company,
        Title,
        Audition,
        last_met,
        no_mtgs,
        lasteventtype,
        NotesLog,
        userid,
        userHash
    FROM sharez_cache
    WHERE userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer">
        AND last_updated > DATE_SUB(NOW(), INTERVAL 1 HOUR)
    ORDER BY NAME
</cfquery>
*/

-- STEP 7: Scheduled cache refresh (run every 15-30 minutes)
-- =====================================================
-- Add to cron or scheduled task:
-- */15 * * * * mysql -u [user] -p[pass] [database] < refresh_sharez_cache.sql

