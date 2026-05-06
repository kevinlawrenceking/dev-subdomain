-- =====================================================================
-- 2026-05-05_audunions_rollback.sql
--
-- Reverses the audunions migration regardless of which stage was
-- reached. Restores audunions to its original 67 rows and audprojects
-- to its pre-migration unionID values.
--
-- Requires the snapshot tables that the original (in-place) script's
-- stage 0 created:
--   audunions_pre_consolidation_20260505
--   audprojects_unionid_remap_20260505
-- =====================================================================

SET @@session.foreign_key_checks = 0;


-- 1. Restore audprojects.unionID from the remap snapshot
UPDATE audprojects p
INNER JOIN audprojects_unionid_remap_20260505 m
    ON m.audprojectid = p.audprojectid
SET p.unionID = m.old_unionID;


-- 2. Drop the failed parallel-build leftover (if present)
DROP TABLE IF EXISTS audunions_new;


-- 3. Drop the unique key (added in finish.sql; ignore error if absent)
ALTER TABLE audunions DROP INDEX uk_audunions_name_country;


-- 4. Restore the legacy audCatID column AND its FK to audcategories
--    (finish.sql dropped both FK_unions_audcategories and the column)
ALTER TABLE audunions
    ADD COLUMN audCatID INT NOT NULL DEFAULT 0 AFTER countryid;
ALTER TABLE audunions
    ADD CONSTRAINT FK_unions_audcategories
    FOREIGN KEY (audCatID) REFERENCES audcategories(audcatid);


-- 5. Empty the consolidated table
DELETE FROM audunions;


-- 6. Restore from the pre-consolidation snapshot
INSERT INTO audunions (unionID, unionName, countryid, audCatID, isDeleted)
SELECT unionID, unionName, countryid, audCatID, isDeleted
FROM audunions_pre_consolidation_20260505;


-- 7. Drop the consolidated audCatIDList column
ALTER TABLE audunions DROP COLUMN audCatIDList;


SET @@session.foreign_key_checks = 1;


-- ---------------------------------------------------------------------
-- POST-ROLLBACK
--
-- The snapshot tables can be dropped once you are confident the
-- rollback worked:
--
--   DROP TABLE audunions_pre_consolidation_20260505;
--   DROP TABLE audprojects_unionid_remap_20260505;
-- ---------------------------------------------------------------------
