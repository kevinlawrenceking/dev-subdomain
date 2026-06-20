-- ============================================================================
-- 2026-06-19_admin_analytics_explain.sql
-- TAO-ADMIN-ANALYTICS-01 -- EXPLAIN the heaviest system-wide series queries.
-- Run on new_development (abod). Capture output for the proof bundle.
-- Bound shown is the default 90-day window ending today (2026-06-19 -> toExcl 2026-06-20).
-- If any shows type=ALL on a costly scan, apply 2026-06-19_admin_analytics_indexes.sql.
-- ============================================================================

-- Auditions series
EXPLAIN
SELECT DATE_FORMAT(p.projdate,'%Y-%m') AS ym, COUNT(DISTINCT r.audroleid) AS cnt
FROM audprojects p INNER JOIN audroles r ON p.audprojectID = r.audprojectID
WHERE r.isdeleted = 0 AND p.isDeleted = 0
  AND p.projdate >= '2026-03-21' AND p.projdate < '2026-06-20'
GROUP BY DATE_FORMAT(p.projdate,'%Y-%m');

-- Bookings series
EXPLAIN
SELECT DATE_FORMAT(p.projdate,'%Y-%m') AS ym, COUNT(DISTINCT r.audroleid) AS cnt
FROM audprojects p INNER JOIN audroles r ON p.audprojectID = r.audprojectID
WHERE r.isdeleted = 0 AND p.isDeleted = 0 AND (r.isbooked = 1 OR p.isDirect = 1)
  AND p.projdate >= '2026-03-21' AND p.projdate < '2026-06-20'
GROUP BY DATE_FORMAT(p.projdate,'%Y-%m');

-- Relationships series
EXPLAIN
SELECT DATE_FORMAT(d.contactCreationDate,'%Y-%m') AS ym, COUNT(*) AS cnt
FROM contactdetails d
WHERE COALESCE(d.user_yn,'N') <> 'Y'
  AND d.contactCreationDate >= '2026-03-21' AND d.contactCreationDate < '2026-06-20'
GROUP BY DATE_FORMAT(d.contactCreationDate,'%Y-%m');

-- Reminders-completed series
EXPLAIN
SELECT DATE_FORMAT(notenddate,'%Y-%m') AS ym, COUNT(*) AS cnt
FROM funotifications
WHERE notstatus = 'Completed' AND isdeleted = 0
  AND notenddate >= '2026-03-21' AND notenddate < '2026-06-20'
GROUP BY DATE_FORMAT(notenddate,'%Y-%m');
