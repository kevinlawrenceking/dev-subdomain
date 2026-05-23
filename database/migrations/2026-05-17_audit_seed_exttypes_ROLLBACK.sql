-- =============================================================================
-- ROLLBACK: 2026-05-17_audit_seed_exttypes.sql
-- Removes only the rows this migration inserted; drops the unique key it added.
-- Safe to re-run.
-- =============================================================================

DELETE FROM exttypes WHERE mediaext IN
  ('jpg','jpeg','png','gif','bmp','webp','heic','svg','tiff','tif',
   'mp3','m4a','wav','aac','flac','ogg',
   'mp4','mov','m4v','webm','avi',
   'pdf','doc','docx','xls','xlsx','csv','txt','html','zip');

-- Drop the unique key only if present (idempotent).
DELIMITER //
DROP PROCEDURE IF EXISTS DropUniqExttypesMediaext //
CREATE PROCEDURE DropUniqExttypesMediaext()
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='exttypes'
        AND INDEX_NAME='uq_exttypes_mediaext';
    IF v > 0 THEN
        ALTER TABLE exttypes DROP INDEX uq_exttypes_mediaext;
        SELECT 'DROPPED: uq_exttypes_mediaext' AS result;
    ELSE
        SELECT 'SKIPPED (absent): uq_exttypes_mediaext' AS result;
    END IF;
END //
DELIMITER ;
CALL DropUniqExttypesMediaext();
DROP PROCEDURE IF EXISTS DropUniqExttypesMediaext;

SELECT CONCAT(COUNT(*), ' exttypes rows remaining') AS result FROM exttypes;
