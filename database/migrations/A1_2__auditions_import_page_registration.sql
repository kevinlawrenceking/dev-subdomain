-- Update the pgpages record for auditions-import to use the new V3 include file
-- The old file (import-auditions.cfm) is preserved as a legacy backup
-- Note: index.cfm now directly includes import-auditions-v3.cfm, so this
-- migration is optional if the direct include approach is used.

UPDATE pgpages
SET pgFilename = 'import-auditions-v3.cfm'
WHERE pgDir = 'auditions-import';
