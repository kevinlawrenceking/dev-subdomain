-- ============================================================================
-- 2026-06-19_admin_analytics_probes.sql
-- TAO-ADMIN-ANALYTICS-01 -- Pre-implementation probes. READ-ONLY.
-- Run on new_development (abod). Paste results back into the proof bundle.
-- These gate two assumptions: flag literal type (=1) and date-anchor NULL rates.
-- ============================================================================

-- 1) user_yn distribution (NULL/empty must be included as real contacts).
SELECT user_yn, COUNT(*) AS cnt
FROM contactdetails
GROUP BY user_yn;

-- 2) Flag column types -- expect bit/tinyint -> keep integer literal = 1.
SHOW COLUMNS FROM audroles    LIKE 'isbooked';
SHOW COLUMNS FROM audprojects LIKE 'isDirect';

-- 3) contactCreationDate default + NULL prevalence (HARD dependency for the Relationships trend).
SHOW COLUMNS FROM contactdetails_tbl LIKE 'contactCreationDate';   -- expect Default = CURRENT_TIMESTAMP
SELECT SUM(contactCreationDate IS NULL) AS null_created,
       COUNT(*)                          AS total
FROM contactdetails
WHERE COALESCE(user_yn,'N') <> 'Y';

-- 4) projdate NULL prevalence (auditions/bookings anchor).
SELECT SUM(projdate IS NULL) AS null_projdate, COUNT(*) AS total
FROM audprojects
WHERE isDeleted = 0;

-- 5) notenddate NULL prevalence among completed reminders (Reminders trend coverage).
SELECT SUM(notenddate IS NULL) AS null_enddate, COUNT(*) AS completed_total
FROM funotifications
WHERE notstatus = 'Completed' AND isdeleted = 0;
