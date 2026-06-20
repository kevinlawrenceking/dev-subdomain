-- ============================================================================
-- 2026-06-19_admin_analytics_pgpages.sql
-- TAO-ADMIN-ANALYTICS-01 -- Register the admin Activity Analytics page.
--
-- Classifies the page as ADMIN via pgcomps_tbl.compOwner='A'. Mirrors the
-- schema-verified precedent app/admin-datatables-reference/insert-pgpages.sql.
--
-- NOTE: pg_comps is NAV-ONLY; it does NOT refuse non-admins. Enforcement is the
-- inline admin guard on app/admin-analytics/index.cfm AND on ajax/stats.cfm.
--
-- Schema gotchas (verified 2026-05-04): pgcomps_tbl.recordname and
-- pgpages_tbl.recordname are VIRTUAL GENERATED (omit); pgpages_tbl.isDef is
-- bit(1) NULLABLE -> MUST be b'1' or getPageDetails 404s; pgpagespluginsxref.pgplugID
-- defaults 0 (omit). Idempotent via NOT EXISTS guards.
--
-- Run on new_development (abod) first; verify; then actorsbusinessoffice (abo).
-- Rollback: 2026-06-19_admin_analytics_pgpages_ROLLBACK.sql
-- ============================================================================
START TRANSACTION;

INSERT INTO pgcomps_tbl
    (compName, appID, compIcon, compOwner, menuYN, compDir, menuOrder,
     compTable, compInner, compRecordName, compActive, IsDeleted, service)
SELECT 'Activity Analytics', 2, 'bar-chart-2', 'A', 'Y', 'admin-analytics', 10,
       NULL, NULL, NULL, 'Y', b'0', NULL
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgcomps_tbl WHERE compDir = 'admin-analytics');

SET @compID = (SELECT compID FROM pgcomps_tbl WHERE compDir = 'admin-analytics' LIMIT 1);

INSERT INTO pgpages_tbl
    (pgName, compID, pgDir, pgTitle, pgHeading, pgFilename,
     datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN,
     pk, isDef, allowdelete_yn, allowupdate_yn, allowadd_yn, allowdetails_yn,
     update_type, IsDeleted)
SELECT 'Activity Analytics', @compID, 'admin-analytics',
       'Activity Analytics', 'Admin Activity Analytics', 'index.cfm',
       'N','N','N','N',
       'pgid', b'1', 'N','N','N','N',
       'custom', b'0'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgpages_tbl WHERE pgDir = 'admin-analytics');

SET @pgID = (SELECT pgID FROM pgpages_tbl WHERE pgDir = 'admin-analytics' LIMIT 1);

-- pluginid 4 = 'global' (jQuery / app.min.js / vendor / icons) so page chrome assets load.
INSERT INTO pgpagespluginsxref (pluginid, pgid, IsDeleted)
SELECT 4, @pgID, b'0'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgpagespluginsxref WHERE pgid = @pgID AND pluginid = 4);

SELECT @compID AS new_compID, @pgID AS new_pgID;   -- verification echo
COMMIT;

-- POST-INSERT SANITY CHECK:
-- SELECT pp.pgID, pp.pgDir, pp.pgFilename, pp.isDef, pc.compName, pc.appID, pc.compOwner, pc.menuYN
-- FROM pgpages_tbl pp INNER JOIN pgcomps_tbl pc ON pp.compID = pc.compID
-- WHERE pp.pgDir = 'admin-analytics';
