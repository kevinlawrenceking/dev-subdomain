-- Rollback: restore the original pgFilename for auditions-import
UPDATE pgpages
SET pgFilename = 'import-auditions-v3.cfm'
WHERE pgDir = 'auditions-import';

-- If reverting to the legacy importer entirely:
-- UPDATE pgpages SET pgFilename = 'import-auditions.cfm' WHERE pgDir = 'auditions-import';
