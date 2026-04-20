-- PURPOSE: Bring prod pgpages (pgID 89, 184, 200, 201, 202) in line with dev,
--          and fix the pgID=201 semantic collision.
-- AUTHOR:  Kevin King
-- DATE:    2026-04-18
-- REASON:  Three-way diff of actorsbusinessoffice.pgpages vs
--          new_development.pgpages showed:
--            - prod pgID=201 holds "Admin User Detail" (admin-users-detail)
--            - dev  pgID=201 holds "Casting Networks - Auditions"
--            - dev  pgID=202 holds "Admin User Detail" (the same content prod
--              currently has at 201)
--            - dev  pgID=200 is "Casting Networks - Notifications" (prod missing)
--            - pgID=89 differs on a handful of fields
--            - pgID=184 differs on a handful of fields
--          Blast radius check on prod (2026-04-18):
--            tickets_tbl.pgID = 201          0 rows
--            bigbrother.pgid = 201           0 rows
--            pgfields.pgid = 201             0 rows
--            pgpagespluginsxref.pgid = 201   2 rows   <-- follow the content to 202
--            pgpages.parentPGID = 201        0 rows
--          No declared FK constraints reference pgpages.
--
-- TARGET SCHEMA: actorsbusinessoffice (fully qualified on every statement so
--                the script cannot accidentally write to new_development or
--                any other schema regardless of the session's current DB).
--
-- SCHEMA NOTE:   `pgpages` is an updatable VIEW over base table `pgpages_tbl`.
--                Writes to the view route to the base table automatically.
--                `recordname` is a GENERATED column on `pgpages_tbl`
--                (derives from `pgName`), so it CANNOT appear in INSERT
--                column lists or UPDATE SET clauses -- MySQL rejects any
--                explicit value for it (SQLSTATE 3105). It is omitted below
--                and will auto-populate. The same generated-column pattern
--                applies to `pgcomps_tbl.recordname` (= compName), so Step 0b
--                omits it too.
--
-- FK NOTE:       `pgpages_tbl.compID` -> `pgcomps_tbl.compID` is a declared
--                FK (constraint FK_pgpages_pgcomps). Dev has pgcomps rows
--                136 and 137 that prod is missing; those must exist before
--                the pgpages writes, hence Step 0b.
--
-- STRATEGY:
--   1. INSERT dev's pgID=202 ("Admin User Detail") row into prod.
--   2. Remap pgpagespluginsxref rows from pgid=201 to pgid=202 so the plugin
--      bindings still point at "Admin User Detail" after the pgpages row
--      at 201 is overwritten.
--   3. Overwrite prod pgpages.pgID=201 with dev's "Casting Networks - Auditions"
--      content.
--   4. INSERT dev's pgID=200 ("Casting Networks - Notifications") row.
--   5. UPDATE pgID=184 to match dev verbatim.
--   6. UPDATE pgID=89 to match dev verbatim.
--
--   0b (runs BEFORE Step 1): seed pgcomps_tbl rows 136 and 137 that prod
--      is missing, so the pgpages writes don't trip FK_pgpages_pgcomps.
--
-- IDEMPOTENT: every step is guarded so a second run is a no-op on a
--             schema that has already been synced (or that never matched
--             the pre-migration signature).
--
-- ROLLBACK:
--   UPDATE actorsbusinessoffice.pgpagespluginsxref SET pgid = 201 WHERE pgid = 202;
--   DELETE FROM actorsbusinessoffice.pgpages WHERE pgID = 202;
--   DELETE FROM actorsbusinessoffice.pgpages WHERE pgID = 200;
--   DELETE FROM actorsbusinessoffice.pgcomps_tbl WHERE compID IN (136, 137);
--   UPDATE actorsbusinessoffice.pgpages SET
--       pgName='Admin User Detail', compID=6, pgDir='admin-users-detail',
--       pgTitle='User Detail', pgHeading='User Detail',
--       pgFilename='admin-users-detail.cfm',
--       datatables_YN='N', fullcalendar_YN='N', editable_YN='N',
--       newdatatables_YN='N', pk='userid',
--       corefile=NULL, parentPGID=NULL, pgtype=NULL, IsDeleted=0,
--       update_type='custom', isDef=1, allowdelete_yn='N',
--       allowupdate_yn='Y', allowadd_yn='Y', allowdetails_yn='Y'
--   WHERE pgID = 201;
--   -- (recordname is generated; do not set it explicitly)
--   -- pgID=89 and pgID=184 rollbacks require the pre-migration prod values;
--   -- capture them from the pre-check SELECT below before running Steps 5-6.

-- ============================================================================
-- PRE-CHECK (run first; capture output before applying any UPDATE)
-- ============================================================================
SELECT pgID, pgName, compID, pgDir, pgFilename, pgtype, update_type
FROM actorsbusinessoffice.pgpages
WHERE pgID IN (89, 184, 200, 201, 202)
ORDER BY pgID;

-- Which compIDs do we already have on prod?
SELECT compID, compName FROM actorsbusinessoffice.pgcomps_tbl
WHERE compID IN (52, 65, 136, 137)
ORDER BY compID;

-- ============================================================================
-- Step 0b: Seed pgcomps_tbl rows 136 and 137 on prod.
--          FK_pgpages_pgcomps (pgpages_tbl.compID -> pgcomps_tbl.compID)
--          requires these to exist before Step 3 (compID=137 for pgID=201)
--          and Step 4 (compID=136 for pgID=200). INSERT IGNORE -> no-op if
--          already present. `recordname` is omitted -- generated column
--          (same pattern as pgpages_tbl.recordname).
-- ============================================================================
INSERT IGNORE INTO actorsbusinessoffice.pgcomps_tbl
    (compID, compName, appID, compIcon, compOwner, menuYN, compDir,
     menuOrder, compTable, compInner, compRecordName, compActive,
     IsDeleted, service)
VALUES
    (136, 'Casting Networks - Notifications', 1, 'bell', 'U', 'N',
     'casting-networks-notifications',
     4, NULL, NULL, NULL, 'Y', 0, NULL);

INSERT IGNORE INTO actorsbusinessoffice.pgcomps_tbl
    (compID, compName, appID, compIcon, compOwner, menuYN, compDir,
     menuOrder, compTable, compInner, compRecordName, compActive,
     IsDeleted, service)
VALUES
    (137, 'Casting Networks - Auditions', 1, 'film', 'U', 'N',
     'casting-networks-auditions',
     5, NULL, NULL, NULL, 'Y', 0, NULL);

-- ============================================================================
-- Step 1: INSERT dev's pgID=202 row ("Admin User Detail").
--         Safe via INSERT IGNORE -- no-op if pgID=202 already present.
-- ============================================================================
INSERT IGNORE INTO actorsbusinessoffice.pgpages
    (pgID, pgName, compID, pgDir, pgTitle, pgHeading, pgFilename,
     datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN,
     pk, corefile, parentPGID, pgtype, IsDeleted, update_type,
     isDef, allowdelete_yn, allowupdate_yn, allowadd_yn, allowdetails_yn)
VALUES
    (202, 'Admin User Detail', 6, 'admin-users-detail', 'User Detail',
     'User Detail', 'admin-users-detail.cfm',
     'N', 'N', 'N', 'N',
     'userid', NULL, NULL, NULL, 0, 'custom',
     1, 'N', 'Y', 'Y', 'Y');

-- ============================================================================
-- Step 2: remap pgpagespluginsxref rows 201 -> 202.
--         Only fires when pgID=202 now exists (i.e. Step 1 succeeded or
--         was already in place). Safe to re-run: matches zero rows once done.
-- ============================================================================
UPDATE actorsbusinessoffice.pgpagespluginsxref x
JOIN (SELECT 1 AS ok FROM actorsbusinessoffice.pgpages WHERE pgID = 202 LIMIT 1) g
SET x.pgid = 202
WHERE x.pgid = 201;

-- ============================================================================
-- Step 3: overwrite pgID=201 with dev's "Casting Networks - Auditions" row.
--         Guarded by pgDir='admin-users-detail' so a re-run is a no-op.
-- ============================================================================
UPDATE actorsbusinessoffice.pgpages
SET pgName           = 'Casting Networks - Auditions',
    compID           = 137,
    pgDir            = 'casting-networks-auditions',
    pgTitle          = 'Casting Networks - Auditions',
    pgHeading        = 'Casting Networks - Auditions',
    pgFilename       = 'castingnetworks_auditions.cfm',
    datatables_YN    = 'Y',
    fullcalendar_YN  = 'N',
    editable_YN      = 'N',
    newdatatables_YN = 'Y',
    pk               = 'id',
    corefile         = 'castingnetworks_auditions.cfm',
    parentPGID       = NULL,
    pgtype           = 'results',
    IsDeleted        = 0,
    update_type      = 'modal',
    isDef            = 1,
    allowdelete_yn   = 'N',
    allowupdate_yn   = 'Y',
    allowadd_yn      = 'Y',
    allowdetails_yn  = 'Y'
WHERE pgID = 201
  AND pgDir = 'admin-users-detail';

-- ============================================================================
-- Step 4: INSERT dev's pgID=200 row ("Casting Networks - Notifications").
-- ============================================================================
INSERT IGNORE INTO actorsbusinessoffice.pgpages
    (pgID, pgName, compID, pgDir, pgTitle, pgHeading, pgFilename,
     datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN,
     pk, corefile, parentPGID, pgtype, IsDeleted, update_type,
     isDef, allowdelete_yn, allowupdate_yn, allowadd_yn, allowdetails_yn)
VALUES
    (200, 'Casting Networks - Notifications', 136,
     'casting-networks-notifications',
     'Casting Networks - Notifications',
     'Casting Networks - Notifications',
     'castingnetworks_notifications.cfm',
     'Y', 'N', 'N', 'Y',
     'id',
     'castingnetworks_notifications.cfm', NULL, 'results', 0, 'modal',
     1, 'N', 'Y', 'Y', 'Y');

-- ============================================================================
-- Step 5: UPDATE pgID=184 to match dev exactly.
--         Unguarded: writes dev's canonical values. Re-run writes the same
--         values (no-op in effect). CAPTURE the PRE-CHECK output above
--         before running if you may need to roll back.
-- ============================================================================
UPDATE actorsbusinessoffice.pgpages
SET pgName           = 'Audition Appointment Update Form',
    compID           = 65,
    pgDir            = 'audition-update',
    pgTitle          = 'Audition Update Form',
    pgHeading        = 'Audition Update Form',
    pgFilename       = 'audition-update.cfm',
    datatables_YN    = 'N',
    fullcalendar_YN  = 'n',
    editable_YN      = 'n',
    newdatatables_YN = 'n',
    pk               = 'audid',
    corefile         = 'audition-update.cfm',
    parentPGID       = NULL,
    pgtype           = 'Update',
    IsDeleted        = 0,
    update_type      = 'Update Form',
    isDef            = 1,
    allowdelete_yn   = 'N',
    allowupdate_yn   = 'Y',
    allowadd_yn      = 'Y',
    allowdetails_yn  = 'Y'
WHERE pgID = 184;

-- ============================================================================
-- Step 6: UPDATE pgID=89 to match dev exactly.
--         Unguarded; same idempotency pattern as Step 5.
--         Note: dev's pk column is empty string '', not NULL.
-- ============================================================================
UPDATE actorsbusinessoffice.pgpages
SET pgName           = 'Dashboard Panel',
    compID           = 52,
    pgDir            = 'dashboard',
    pgTitle          = 'Dashboard',
    pgHeading        = 'Dashboard',
    pgFilename       = 'dashboard_new.cfm',
    datatables_YN    = 'n',
    fullcalendar_YN  = 'N',
    editable_YN      = 'N',
    newdatatables_YN = 'N',
    pk               = '',
    corefile         = 'dashboard.cfm',
    parentPGID       = NULL,
    pgtype           = 'details',
    IsDeleted        = 0,
    update_type      = 'modal',
    isDef            = 1,
    allowdelete_yn   = 'N',
    allowupdate_yn   = 'Y',
    allowadd_yn      = 'Y',
    allowdetails_yn  = 'Y'
WHERE pgID = 89;

-- ============================================================================
-- POST-CHECK: prod rows should now exactly mirror dev.
--   Expect 5 rows. Compare against the dev SELECT you pasted earlier.
-- ============================================================================
SELECT pgID, pgName, compID, pgDir, pgTitle, pgHeading, pgFilename,
       datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN,
       pk, recordname, corefile, parentPGID, pgtype, IsDeleted, update_type,
       isDef, allowdelete_yn, allowupdate_yn, allowadd_yn, allowdetails_yn
FROM actorsbusinessoffice.pgpages
WHERE pgID IN (89, 184, 200, 201, 202)
ORDER BY pgID;

-- POST-CHECK: xref rows moved.
SELECT pgid, COUNT(*) AS rows_at_pgid
FROM actorsbusinessoffice.pgpagespluginsxref
WHERE pgid IN (201, 202)
GROUP BY pgid
ORDER BY pgid;
-- Expect: pgid=202 with 2 rows; pgid=201 with 0 rows (row absent from result).
