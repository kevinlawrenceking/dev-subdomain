-- =============================================================================
-- Cleanup: archive duplicate "My Team" contacts for one user (DEV test data)
-- TAO / MySQL 8
--
-- Keeps the EARLIEST contactid per recordname among the user's active My Team
-- contacts and soft-deletes the rest (isDeleted = 1). Reversible: the contactids
-- archived are captured in a backup table first; the ROLLBACK script restores
-- them.
--
-- NOTE: this archives the CONTACT RECORD only; it does not repoint auditions/
-- notes that reference the removed contactids. Fine for throwaway test contacts.
-- For real duplicates, use the merge tool (/app/contact-duplicates/), which moves
-- linked data onto the kept contact.
--
-- Usage: set @uid, run section 1 (preview), then sections 2 and 3.
-- =============================================================================

SET @uid = 0;   -- <-- the user's id

-- ----- 1) PREVIEW: rows that WILL be archived (everything except the keeper per name)
SELECT d.contactid, d.recordname
FROM   contactdetails_tbl d
JOIN ( SELECT recordname, MIN(contactid) AS keep_id
       FROM   contactdetails_tbl
       WHERE  userid = @uid AND isDeleted = 0
         AND  contactid IN (SELECT contactid FROM contactitems_tbl
                            WHERE valuecategory='Tag' AND valuetext='My Team' AND isDeleted=0)
       GROUP  BY recordname ) k ON k.recordname = d.recordname
WHERE  d.userid = @uid AND d.isDeleted = 0 AND d.contactid <> k.keep_id
  AND  d.contactid IN (SELECT contactid FROM contactitems_tbl
                       WHERE valuecategory='Tag' AND valuetext='My Team' AND isDeleted=0)
ORDER  BY d.recordname, d.contactid;

-- ----- 2) BACKUP the contactids to be archived (so the rollback is exact)
CREATE TABLE IF NOT EXISTS contact_dupe_cleanup_bak (
    contactid INT NOT NULL PRIMARY KEY,
    userid    INT NOT NULL,
    archived_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT IGNORE INTO contact_dupe_cleanup_bak (contactid, userid)
SELECT d.contactid, @uid
FROM   contactdetails_tbl d
JOIN ( SELECT recordname, MIN(contactid) AS keep_id
       FROM   contactdetails_tbl
       WHERE  userid = @uid AND isDeleted = 0
         AND  contactid IN (SELECT contactid FROM contactitems_tbl
                            WHERE valuecategory='Tag' AND valuetext='My Team' AND isDeleted=0)
       GROUP  BY recordname ) k ON k.recordname = d.recordname
WHERE  d.userid = @uid AND d.isDeleted = 0 AND d.contactid <> k.keep_id
  AND  d.contactid IN (SELECT contactid FROM contactitems_tbl
                       WHERE valuecategory='Tag' AND valuetext='My Team' AND isDeleted=0);

-- ----- 3) ARCHIVE (soft delete) exactly the backed-up rows
UPDATE contactdetails_tbl
SET    isDeleted = 1
WHERE  contactid IN (SELECT contactid FROM contact_dupe_cleanup_bak WHERE userid = @uid);

-- Verify: should now show only ONE contact per name
-- SELECT contactid, recordname FROM contactdetails_tbl
-- WHERE userid=@uid AND isDeleted=0
--   AND contactid IN (SELECT contactid FROM contactitems_tbl
--                     WHERE valuecategory='Tag' AND valuetext='My Team' AND isDeleted=0)
-- ORDER BY recordname;
