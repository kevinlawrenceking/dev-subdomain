-- ============================================================================
-- TAO-DT-SANDBOX: Reference page registration
--
-- Run this against new_development first; once verified, run the same SQL
-- against actorsbusinessoffice (production).
--
-- Schema gotchas (verified against probe results 2026-05-04):
--   - pgcomps_tbl.recordname is VIRTUAL GENERATED. Do NOT include it.
--   - pgpages_tbl.recordname is VIRTUAL GENERATED. Do NOT include it.
--   - pgpages_tbl.isDef is bit(1) NULLABLE with no default. MUST set to b'1'
--     (getPageDetails filters WHERE p.isdef = 1; otherwise the page 404s).
--   - pgpagespluginsxref.pgplugID is int NOT NULL DEFAULT 0 with NO auto_increment
--     and NO PK constraint. Omit from INSERT to use the default 0.
-- ============================================================================

START TRANSACTION;

-- 1) pgcomps_tbl: sidebar entry under Setup section
--    (compOwner='A' AND appID<>3 puts it in the sidebar's Setup collapse)
INSERT INTO pgcomps_tbl
    (compName, appID, compIcon, compOwner, menuYN, compDir, menuOrder,
     compTable, compInner, compRecordName, compActive, IsDeleted, service)
VALUES
    ('DataTables Reference', 2, 'table-2', 'A', 'Y', 'admin-datatables-reference', 9,
     NULL, NULL, NULL, 'Y', b'0', NULL);
SET @newCompID = LAST_INSERT_ID();

-- 2) pgpages_tbl: canonical page metadata
INSERT INTO pgpages_tbl
    (pgName, compID, pgDir, pgTitle, pgHeading, pgFilename,
     datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN,
     pk, isDef, allowdelete_yn, allowupdate_yn, allowadd_yn, allowdetails_yn,
     update_type, IsDeleted)
VALUES
    ('DataTables Reference', @newCompID, 'admin-datatables-reference',
     'DataTables Reference', 'DataTables Reference Sandbox', 'admin-datatables-reference.cfm',
     'Y', 'N', 'N', 'N',
     'pgid', b'1', 'N', 'N', 'N', 'N',
     'modal', b'0');
SET @newPGID = LAST_INSERT_ID();

-- 3) pgpagespluginsxref: two rows
--    pluginid 1 = 'datatable' (DataTables core+Buttons+Responsive bundle + Checkboxes)
--    pluginid 4 = 'global'    (jQuery, app.min.js, vendor.min.js, icons, etc.)
INSERT INTO pgpagespluginsxref (pluginid, pgid, IsDeleted) VALUES
    (1, @newPGID, b'0'),
    (4, @newPGID, b'0');

-- 4) Verification: print the new IDs
SELECT @newCompID AS new_compID, @newPGID AS new_pgID;

COMMIT;

-- ============================================================================
-- POST-INSERT SANITY CHECK (run after the COMMIT)
-- ============================================================================
-- SELECT pp.pgID, pp.pgDir, pp.pgFilename, pp.isDef, pc.compName, pc.appID, pc.menuYN
-- FROM pgpages_tbl pp
-- INNER JOIN pgcomps_tbl pc ON pp.compID = pc.compID
-- WHERE pp.pgDir = 'admin-datatables-reference';
--
-- SELECT ppx.pgid, ppx.pluginid, pl.pluginName
-- FROM pgpagespluginsxref ppx
-- INNER JOIN pgplugins pl ON pl.pluginid = ppx.pluginid
-- INNER JOIN pgpages_tbl pp ON pp.pgID = ppx.pgid
-- WHERE pp.pgDir = 'admin-datatables-reference';
