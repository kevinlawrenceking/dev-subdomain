-- =============================================================================
-- TAO Relationship System - Performance Indexes
-- Database: MySQL
-- Generated: 2026-01-11
-- =============================================================================
--
-- USAGE:
-- 1. Run the "Check Existing Indexes" queries first to see current state
-- 2. Run the CREATE INDEX statements
-- 3. Run the "Verify" queries to confirm creation
--
-- ROLLBACK: Each index has a corresponding DROP statement at the bottom
--
-- =============================================================================

-- =============================================================================
-- STEP 1: Check Existing Indexes (Run first to see what already exists)
-- =============================================================================

-- Check funotifications indexes
SELECT
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'funotifications'
GROUP BY TABLE_NAME, INDEX_NAME;

-- Check fusystemusers indexes
SELECT
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'fusystemusers'
GROUP BY TABLE_NAME, INDEX_NAME;

-- Check actionusers indexes
SELECT
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'actionusers'
GROUP BY TABLE_NAME, INDEX_NAME;

-- =============================================================================
-- STEP 2: Create Indexes
-- =============================================================================

-- -----------------------------------------------------------------------------
-- funotifications Indexes
-- -----------------------------------------------------------------------------

-- Index 1: Primary query pattern for loading reminders
-- Supports: getRemindersTotal(), SELfunotifications_24639(), SELfunotifications_24709()
-- Query pattern: WHERE userid = ? AND notstatus = 'Pending' AND notstartdate <= NOW()
CREATE INDEX IF NOT EXISTS idx_funot_user_status_date
ON funotifications (userid, notstatus, notstartdate);

-- Index 2: System-based notification lookup
-- Supports: getNotifications(), complete_not.cfm next notification lookup
-- Query pattern: WHERE suid = ? AND notstatus = 'Pending' AND notstartdate IS NULL
CREATE INDEX IF NOT EXISTS idx_funot_suid_status_date
ON funotifications (suid, notstatus, notstartdate);

-- Index 3: Action-based lookup
-- Supports: Queries joining on actionid
CREATE INDEX IF NOT EXISTS idx_funot_actionid
ON funotifications (actionid);

-- Index 4: Audit query support - orphan detection
-- Supports: Audit queries checking for orphaned notifications
CREATE INDEX IF NOT EXISTS idx_funot_isdeleted
ON funotifications (isdeleted);

-- -----------------------------------------------------------------------------
-- fusystemusers Indexes
-- -----------------------------------------------------------------------------

-- Index 1: Contact + User + System lookup (most common pattern)
-- Supports: Checking existing enrollments, duplicate detection
-- Query pattern: WHERE contactid = ? AND userid = ? AND systemid = ? AND sustatus = 'Active'
CREATE INDEX IF NOT EXISTS idx_fusu_contact_user_system_status
ON fusystemusers (contactid, userid, systemid, sustatus);

-- Index 2: User's active systems
-- Supports: Dashboard queries, system counts
-- Query pattern: WHERE userid = ? AND sustatus = 'Active' AND isdeleted = 0
CREATE INDEX IF NOT EXISTS idx_fusu_user_status_deleted
ON fusystemusers (userid, sustatus, isdeleted);

-- Index 3: Contact's systems (used for contact page)
-- Supports: SELfusystemusers_24343(), getRemindersByRelationship()
-- Query pattern: WHERE contactid = ? AND sustatus = 'Active'
CREATE INDEX IF NOT EXISTS idx_fusu_contact_status
ON fusystemusers (contactid, sustatus);

-- -----------------------------------------------------------------------------
-- actionusers Indexes
-- -----------------------------------------------------------------------------

-- Index 1: User + Action lookup (primary join pattern)
-- Supports: All queries joining actionusers to fuactions
-- Query pattern: WHERE userid = ? AND actionid = ?
CREATE INDEX IF NOT EXISTS idx_au_user_action
ON actionusers (userid, actionid);

-- Index 2: Missing actionusers detection
-- Supports: Audit queries for missing rows
CREATE INDEX IF NOT EXISTS idx_au_user_isdeleted
ON actionusers (userid, isdeleted);

-- =============================================================================
-- STEP 3: Verify Index Creation
-- =============================================================================

-- Verify funotifications indexes
SELECT
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns,
    INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'funotifications'
  AND INDEX_NAME LIKE 'idx_funot%'
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE;

-- Verify fusystemusers indexes
SELECT
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns,
    INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'fusystemusers'
  AND INDEX_NAME LIKE 'idx_fusu%'
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE;

-- Verify actionusers indexes
SELECT
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns,
    INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'actionusers'
  AND INDEX_NAME LIKE 'idx_au%'
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE;

-- =============================================================================
-- STEP 4: Test Query Performance (Optional - run EXPLAIN on key queries)
-- =============================================================================

-- Test: Reminder count query
EXPLAIN SELECT count(*) AS reminderstotal
FROM funotifications n
INNER JOIN fusystemusers f ON f.suID = n.suID
INNER JOIN fusystems s ON s.systemID = f.systemID
INNER JOIN fuactions a ON a.actionID = n.actionID
INNER JOIN actionusers au ON a.actionID = au.actionID
INNER JOIN fuActionLinks l ON l.actionlinkid = a.actionlinkid
INNER JOIN notstatuses ns ON ns.notstatus = n.notStatus
INNER JOIN contactdetails c ON c.contactid = f.contactid
WHERE au.userid = 1  -- Replace with actual userid
AND c.userid = au.userid
AND n.notstartdate IS NOT NULL
AND DATE(n.notstartdate) <= CURDATE()
AND n.notstatus = 'Pending';

-- Test: Next pending notification lookup
EXPLAIN SELECT n.notid, n.actionid
FROM funotifications n
INNER JOIN fusystemusers su ON su.suid = n.suid
INNER JOIN fuactions a ON a.actionid = n.actionid
WHERE n.suid = 1  -- Replace with actual suid
  AND n.notstatus = 'Pending'
  AND n.notstartdate IS NULL
  AND n.isdeleted = 0
ORDER BY a.actionno, n.notid
LIMIT 1;

-- =============================================================================
-- ROLLBACK SCRIPT (if needed)
-- =============================================================================

/*
-- To remove all indexes created by this script:

DROP INDEX idx_funot_user_status_date ON funotifications;
DROP INDEX idx_funot_suid_status_date ON funotifications;
DROP INDEX idx_funot_actionid ON funotifications;
DROP INDEX idx_funot_isdeleted ON funotifications;

DROP INDEX idx_fusu_contact_user_system_status ON fusystemusers;
DROP INDEX idx_fusu_user_status_deleted ON fusystemusers;
DROP INDEX idx_fusu_contact_status ON fusystemusers;

DROP INDEX idx_au_user_action ON actionusers;
DROP INDEX idx_au_user_isdeleted ON actionusers;
*/

-- =============================================================================
-- INDEX DOCUMENTATION
-- =============================================================================

/*
INDEX: idx_funot_user_status_date
TABLE: funotifications
COLUMNS: userid, notstatus, notstartdate
PURPOSE: Optimize the primary reminder query pattern used in:
  - NotificationService.getRemindersTotal()
  - NotificationService.SELfunotifications_24639()
  - Dashboard reminder counts
QUERY PATTERN:
  SELECT ... FROM funotifications
  WHERE userid = ? AND notstatus = 'Pending' AND notstartdate <= NOW()

INDEX: idx_funot_suid_status_date
TABLE: funotifications
COLUMNS: suid, notstatus, notstartdate
PURPOSE: Optimize system-specific notification lookups used in:
  - NotificationService.getNotifications()
  - complete_not.cfm next notification lookup
  - RelationshipService.getNextPendingNotification()
QUERY PATTERN:
  SELECT ... FROM funotifications
  WHERE suid = ? AND notstatus = 'Pending' AND notstartdate IS NULL

INDEX: idx_funot_actionid
TABLE: funotifications
COLUMNS: actionid
PURPOSE: Optimize joins to fuactions table
QUERY PATTERN:
  INNER JOIN fuactions a ON a.actionid = n.actionid

INDEX: idx_fusu_contact_user_system_status
TABLE: fusystemusers
COLUMNS: contactid, userid, systemid, sustatus
PURPOSE: Optimize duplicate detection and enrollment checks
QUERY PATTERN:
  SELECT ... FROM fusystemusers
  WHERE contactid = ? AND userid = ? AND systemid = ? AND sustatus = 'Active'

INDEX: idx_fusu_user_status_deleted
TABLE: fusystemusers
COLUMNS: userid, sustatus, isdeleted
PURPOSE: Optimize user's system list queries
QUERY PATTERN:
  SELECT ... FROM fusystemusers
  WHERE userid = ? AND sustatus = 'Active' AND isdeleted = 0

INDEX: idx_fusu_contact_status
TABLE: fusystemusers
COLUMNS: contactid, sustatus
PURPOSE: Optimize contact page system queries
QUERY PATTERN:
  SELECT ... FROM fusystemusers
  WHERE contactid = ? AND sustatus = 'Active'

INDEX: idx_au_user_action
TABLE: actionusers
COLUMNS: userid, actionid
PURPOSE: Optimize the primary join pattern for action lookups
QUERY PATTERN:
  INNER JOIN actionusers au ON au.actionid = n.actionid AND au.userid = ?

INDEX: idx_au_user_isdeleted
TABLE: actionusers
COLUMNS: userid, isdeleted
PURPOSE: Optimize audit queries for missing actionusers
QUERY PATTERN:
  LEFT JOIN actionusers au ON au.userid = ? AND au.actionid = ?
  WHERE au.id IS NULL
*/
