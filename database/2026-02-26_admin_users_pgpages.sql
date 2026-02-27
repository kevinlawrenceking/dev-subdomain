SET @admin_compid = (SELECT compid FROM pgpages WHERE pgDir = 'admin-support' LIMIT 1);

UPDATE pgpages
SET pgFilename = 'admin-users.cfm',
    pgTitle = 'User Management',
    pgHeading = 'User Management',
    isdef = 1
WHERE pgDir = 'admin-users';

UPDATE pgpages
SET pgFilename = 'admin-users-detail.cfm',
    pgTitle = 'User Detail',
    pgHeading = 'User Detail',
    isdef = 1
WHERE pgDir = 'admin-users-detail';

INSERT INTO pgpages (pgDir, pgname, pgTitle, pgHeading, pgFilename, compid, isdef, pk, update_type, datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN)
SELECT 'admin-users', 'Admin Users', 'User Management', 'User Management', 'admin-users.cfm', @admin_compid, 1, 'userid', 'custom', 'N', 'N', 'N', 'N'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgpages WHERE pgDir = 'admin-users');

INSERT INTO pgpages (pgDir, pgname, pgTitle, pgHeading, pgFilename, compid, isdef, pk, update_type, datatables_YN, fullcalendar_YN, editable_YN, newdatatables_YN)
SELECT 'admin-users-detail', 'Admin User Detail', 'User Detail', 'User Detail', 'admin-users-detail.cfm', @admin_compid, 1, 'userid', 'custom', 'N', 'N', 'N', 'N'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pgpages WHERE pgDir = 'admin-users-detail');
