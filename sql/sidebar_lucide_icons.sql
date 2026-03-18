-- ==========================================================================
-- Sidebar Lucide Icon Migration
-- ==========================================================================
-- Updates pgcomps.compIcon values from Feather icon names to Lucide names.
-- Lucide is the maintained fork of Feather Icons used by the redesigned
-- sidebar (include/leftbar.cfm).
--
-- NOTE: The sidebar template includes a CF-side icon mapping
-- (variables.lucideIconMap) that overrides DB values at render time.
-- This DB migration is OPTIONAL but recommended so the DB values stay
-- accurate and consistent with what the UI actually displays.
--
-- Schema: actorsbusinessoffice (production) / new_development (dev)
-- Table:  pgcomps
-- Column: compIcon
-- ==========================================================================

-- --------------------------------------------------------------------------
-- FORWARD MIGRATION: Update compIcon to Lucide-compatible names
-- --------------------------------------------------------------------------

-- User menu items (compOwner = 'U')
-- Map each known compDir to its recommended Lucide icon name.

UPDATE pgcomps
SET compIcon = 'layout-dashboard'
WHERE compDir = 'dashboard' AND compOwner = 'U' AND compIcon != 'layout-dashboard';

UPDATE pgcomps
SET compIcon = 'users'
WHERE compDir = 'relationships' AND compOwner = 'U' AND compIcon != 'users';

UPDATE pgcomps
SET compIcon = 'calendar-days'
WHERE compDir IN ('calendar', 'calendar-new') AND compOwner = 'U' AND compIcon != 'calendar-days';

UPDATE pgcomps
SET compIcon = 'bell-ring'
WHERE compDir = 'reminders' AND compOwner = 'U' AND compIcon != 'bell-ring';

UPDATE pgcomps
SET compIcon = 'clapperboard'
WHERE compDir IN ('auditions', 'events') AND compOwner = 'U' AND compIcon != 'clapperboard';

UPDATE pgcomps
SET compIcon = 'bar-chart-3'
WHERE compDir = 'reports' AND compOwner = 'U' AND compIcon != 'bar-chart-3';

UPDATE pgcomps
SET compIcon = 'circle-user-round'
WHERE compDir IN ('myaccount', 'my-account') AND compOwner = 'U' AND compIcon != 'circle-user-round';


-- --------------------------------------------------------------------------
-- ROLLBACK: Restore original Feather icon names
-- --------------------------------------------------------------------------
-- Run these statements to revert if needed.
-- Adjust values to match your original DB state.

/*
UPDATE pgcomps SET compIcon = 'home'       WHERE compDir = 'dashboard' AND compOwner = 'U';
UPDATE pgcomps SET compIcon = 'users'      WHERE compDir = 'relationships' AND compOwner = 'U';
UPDATE pgcomps SET compIcon = 'calendar'   WHERE compDir IN ('calendar', 'calendar-new') AND compOwner = 'U';
UPDATE pgcomps SET compIcon = 'bell'       WHERE compDir = 'reminders' AND compOwner = 'U';
UPDATE pgcomps SET compIcon = 'film'       WHERE compDir IN ('auditions', 'events') AND compOwner = 'U';
UPDATE pgcomps SET compIcon = 'code'       WHERE compDir = 'reports' AND compOwner = 'U';
UPDATE pgcomps SET compIcon = 'user'       WHERE compDir IN ('myaccount', 'my-account') AND compOwner = 'U';
*/


-- --------------------------------------------------------------------------
-- Icon Reference Table
-- --------------------------------------------------------------------------
-- Menu Item       | compDir        | Old (Feather) | New (Lucide)       | Notes
-- --------------- | -------------- | ------------- | ------------------ | -----
-- Dashboard       | dashboard      | home          | layout-dashboard   | Feather had no dashboard-specific icon
-- Relationships   | relationships  | users         | users              | Same name, works in both
-- Calendar        | calendar-new   | calendar      | calendar-days      | Lucide variant with day grid
-- Reminders       | reminders      | bell          | bell-ring          | Conveys active notification
-- Auditions       | auditions      | film          | clapperboard       | Domain-specific for acting/film
-- Reports         | reports        | code           | bar-chart-3        | FIXES incorrect <> code icon
-- My Account      | myaccount      | user          | circle-user-round  | Distinct from Relationships "users"
-- Testing Log     | Testings       | clipboard     | clipboard-check    | Hardcoded in template (beta only)
--
-- Admin section headers (hardcoded in template, not from DB):
-- Relationships - Admin: uses "users" icon
-- Audition - Admin:      uses "clapperboard" icon
-- Collapse arrows:       uses "chevron-down" icon
