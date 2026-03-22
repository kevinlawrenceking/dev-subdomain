-- Audition Import V3 Promotion
-- Renames V3 import to be the primary auditions-import page.
-- File renames (done in git):
--   app/auditions-import-v3/         -> app/auditions-import/
--   include/import-auditions.cfm     -> include/import-auditions_old.cfm
--   include/import-auditions-v3.cfm  -> include/import-auditions.cfm
--
-- This SQL ensures pgpages pgid 195 points to the correct dir and filename.

UPDATE pgpages
SET pgDir = 'auditions-import',
    pgFilename = 'import-auditions.cfm'
WHERE pgid = 195;

-- Verify:
-- SELECT pgid, pgDir, pgFilename FROM pgpages WHERE pgid = 195;
-- Expected: pgDir = 'auditions-import', pgFilename = 'import-auditions.cfm'

-- ROLLBACK:
-- UPDATE pgpages SET pgFilename = 'import-auditions-v3.cfm' WHERE pgid = 195;
