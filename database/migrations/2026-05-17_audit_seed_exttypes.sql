-- =============================================================================
-- TAO Prod Audit R2: exttypes seed (silent-bug fix)
-- Evidence: database/audit/2026-05-17_prod_audit_exttypes_seed.md
-- Live state (2026-05-17): exttypes has 0 rows; AuditionMediaService.cfc
-- LEFT JOINs it ~14 times -> every join returns NULL -> media-type lookup
-- silently returns blanks. Seed list grounded in actual audmedia.mediaExt
-- distribution (22 distinct extensions across 1,411 media rows).
--
-- Collation utf8mb4_unicode_ci is case-insensitive; HEIC matches heic. Store
-- lowercase.
--
-- Reversible: ROLLBACK removes only the rows this migration inserted.
-- Idempotent (UNIQUE key + INSERT IGNORE).
-- =============================================================================

-- 1. Ensure mediaext is unique (one row per extension).
DELIMITER //
DROP PROCEDURE IF EXISTS AddUniqExttypesMediaext //
CREATE PROCEDURE AddUniqExttypesMediaext()
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='exttypes'
        AND INDEX_NAME='uq_exttypes_mediaext';
    IF v = 0 THEN
        ALTER TABLE exttypes ADD UNIQUE KEY uq_exttypes_mediaext (mediaext);
        SELECT 'ADDED: uq_exttypes_mediaext' AS result;
    ELSE
        SELECT 'SKIPPED (exists): uq_exttypes_mediaext' AS result;
    END IF;
END //
DELIMITER ;
CALL AddUniqExttypesMediaext();
DROP PROCEDURE IF EXISTS AddUniqExttypesMediaext;

-- 2. Seed observed + safe-bet extensions.
INSERT IGNORE INTO exttypes (mediaext, isimage, exttype) VALUES
  -- Images (observed in audmedia)
  ('jpg',  b'1', 'image'),
  ('jpeg', b'1', 'image'),
  ('png',  b'1', 'image'),
  ('gif',  b'1', 'image'),
  ('bmp',  b'1', 'image'),
  ('webp', b'1', 'image'),
  ('heic', b'1', 'image'),
  -- Images (safe-bet additions; owner may prune)
  ('svg',  b'1', 'image'),
  ('tiff', b'1', 'image'),
  ('tif',  b'1', 'image'),
  -- Audio (observed)
  ('mp3',  b'0', 'audio'),
  ('m4a',  b'0', 'audio'),
  ('wav',  b'0', 'audio'),
  -- Audio (safe-bet)
  ('aac',  b'0', 'audio'),
  ('flac', b'0', 'audio'),
  ('ogg',  b'0', 'audio'),
  -- Video (observed)
  ('mp4',  b'0', 'video'),
  ('mov',  b'0', 'video'),
  -- Video (safe-bet)
  ('m4v',  b'0', 'video'),
  ('webm', b'0', 'video'),
  ('avi',  b'0', 'video'),
  -- Documents (observed)
  ('pdf',  b'0', 'document'),
  ('doc',  b'0', 'document'),
  ('docx', b'0', 'document'),
  ('xls',  b'0', 'document'),
  ('xlsx', b'0', 'document'),
  ('csv',  b'0', 'document'),
  ('txt',  b'0', 'document'),
  ('html', b'0', 'document'),
  -- Other (observed)
  ('zip',  b'0', 'archive');

SELECT exttype, COUNT(*) AS n FROM exttypes GROUP BY exttype;
SELECT CONCAT(COUNT(*), ' total exttypes rows after seed') AS result FROM exttypes;
