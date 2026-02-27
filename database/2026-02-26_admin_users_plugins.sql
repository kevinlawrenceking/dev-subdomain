SET @source_pgid = (SELECT pgid FROM pgpages WHERE pgDir = 'admin-support' LIMIT 1);
SET @users_pgid = (SELECT pgid FROM pgpages WHERE pgDir = 'admin-users' LIMIT 1);
SET @detail_pgid = (SELECT pgid FROM pgpages WHERE pgDir = 'admin-users-detail' LIMIT 1);

INSERT IGNORE INTO pgpagespluginsxref (pgid, pluginid)
SELECT @users_pgid, pluginid
FROM pgpagespluginsxref
WHERE pgid = @source_pgid;

INSERT IGNORE INTO pgpagespluginsxref (pgid, pluginid)
SELECT @detail_pgid, pluginid
FROM pgpagespluginsxref
WHERE pgid = @source_pgid;
