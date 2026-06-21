-- Widen audprojects.projDescription (Project Description / Logline) from VARCHAR(500) to TEXT.
--
-- Background: FIX_charDescription_README.md (2025-11-30) states the fix "also updates
-- projDescription ... removing their 500-character limits", but fix_charDescription_length.sql
-- only altered audroles.charDescription and auditionsimport.charDescription. projDescription
-- was never widened, so long values entered via the audition add/edit form can still truncate
-- at 500 chars. The audition importer no longer writes notes here (see AuditionImportService.cfc),
-- but this completes the intended fix for the normal add/edit path.
--
-- Database: new_development (dev), actorsbusinessoffice (prod)
-- Idempotent: re-running MODIFY to the same type is a no-op.

ALTER TABLE audprojects MODIFY COLUMN projDescription TEXT NULL;

-- Verify:
-- SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'audprojects' AND COLUMN_NAME = 'projDescription';
-- Expected: DATA_TYPE = text
