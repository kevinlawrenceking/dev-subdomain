-- rebuild_contacts_ss_system_views.sql
-- Fixes #2191: New relationships not showing on Targeted list
--
-- ROOT CAUSE: The contacts_ss_target, contacts_ss_followup, and contacts_ss_maint
-- views filter on incorrect systemtype values. The fusystems table uses:
--   'Targeted List'  (views had 'Targeting')
--   'Follow Up'      (views had 'Follow-Up')
--   'Maintenance List' (views had 'Maintenance')
--
-- These views join contacts_ss + fusystemusers + fusystems to filter contacts
-- by which relationship system they are enrolled in with Active status.
--
-- IMPORTANT: Run against both new_development and actorsbusinessoffice schemas.

-- ============================================================
-- 1. Rebuild contacts_ss_target
-- ============================================================
CREATE OR REPLACE VIEW contacts_ss_target AS
SELECT DISTINCT cs.*
FROM contacts_ss cs
INNER JOIN fusystemusers su
    ON su.contactid = cs.contactid
    AND su.userid = cs.userid
INNER JOIN fusystems s
    ON s.systemID = su.systemID
WHERE s.systemtype = 'Targeted List'
  AND su.suStatus = 'Active';

-- ============================================================
-- 2. Rebuild contacts_ss_followup
-- ============================================================
CREATE OR REPLACE VIEW contacts_ss_followup AS
SELECT DISTINCT cs.*
FROM contacts_ss cs
INNER JOIN fusystemusers su
    ON su.contactid = cs.contactid
    AND su.userid = cs.userid
INNER JOIN fusystems s
    ON s.systemID = su.systemID
WHERE s.systemtype = 'Follow Up'
  AND su.suStatus = 'Active';

-- ============================================================
-- 3. Rebuild contacts_ss_maint
-- ============================================================
CREATE OR REPLACE VIEW contacts_ss_maint AS
SELECT DISTINCT cs.*
FROM contacts_ss cs
INNER JOIN fusystemusers su
    ON su.contactid = cs.contactid
    AND su.userid = cs.userid
INNER JOIN fusystems s
    ON s.systemID = su.systemID
WHERE s.systemtype = 'Maintenance List'
  AND su.suStatus = 'Active';

-- ============================================================
-- Verification: Confirm each view returns rows
-- ============================================================
SELECT 'contacts_ss_target' AS view_name, COUNT(*) AS row_count FROM contacts_ss_target
UNION ALL
SELECT 'contacts_ss_followup', COUNT(*) FROM contacts_ss_followup
UNION ALL
SELECT 'contacts_ss_maint', COUNT(*) FROM contacts_ss_maint;

-- ============================================================
-- Rollback: Restore original (broken) views
-- ============================================================
-- CREATE OR REPLACE VIEW contacts_ss_target AS
-- SELECT DISTINCT cs.*
-- FROM contacts_ss cs
-- INNER JOIN fusystemusers su ON su.contactid = cs.contactid AND su.userid = cs.userid
-- INNER JOIN fusystems s ON s.systemID = su.systemID
-- WHERE s.systemtype = 'Targeting' AND su.suStatus = 'Active';
--
-- CREATE OR REPLACE VIEW contacts_ss_followup AS
-- SELECT DISTINCT cs.*
-- FROM contacts_ss cs
-- INNER JOIN fusystemusers su ON su.contactid = cs.contactid AND su.userid = cs.userid
-- INNER JOIN fusystems s ON s.systemID = su.systemID
-- WHERE s.systemtype = 'Follow-Up' AND su.suStatus = 'Active';
--
-- CREATE OR REPLACE VIEW contacts_ss_maint AS
-- SELECT DISTINCT cs.*
-- FROM contacts_ss cs
-- INNER JOIN fusystemusers su ON su.contactid = cs.contactid AND su.userid = cs.userid
-- INNER JOIN fusystems s ON s.systemID = su.systemID
-- WHERE s.systemtype = 'Maintenance' AND su.suStatus = 'Active';
