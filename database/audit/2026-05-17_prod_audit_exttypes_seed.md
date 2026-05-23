# Prod DB Audit — R2: `exttypes` Silent-Bug Fix Proposal

Status: **DRAFT — owner sign-off required (AuditionMedia service owner).** Evidence captured live; the seed list is grounded in actual `audmedia.mediaExt` values, not guessed.

---

## 1. The bug

`services/AuditionMediaService.cfc` `LEFT JOIN`s `exttypes` ~14 times to enrich media records with a file-type description:
```sql
LEFT JOIN exttypes e ON e.mediaext = m.mediaext
```

`exttypes` is **empty in prod** (0 rows). Every join produces NULL, so:
- Media records have no type label.
- Any UI surfacing `exttype` shows blank.
- Anywhere `isimage` is read from `e.isimage`, it's NULL → treated as falsy.

The feature has been silently degraded. Not a structural bug — just missing seed data.

---

## 2. Evidence (captured 2026-05-17)

### Schema

```
exttypes
  exttypeid  INT NOT NULL PRIMARY KEY
  mediaext   VARCHAR    NULL
  isimage    BIT(1)     NULL DEFAULT b'0'
  exttype    VARCHAR    NULL
```

### Actual extensions in use (`SELECT mediaext, COUNT(*) FROM audmedia GROUP BY mediaext`)

22 distinct extensions across 1,411 media rows, plus 267 NULL:

| Extension | Count | Class |
|---|---|---|
| jpg | 824 | image |
| pdf | 401 | document |
| png | 139 | image |
| jpeg | 78 | image |
| mp3 | 36 | audio |
| docx | 27 | document |
| mp4 | 14 | video |
| mov | 13 | video |
| doc | 5 | document |
| txt | 3 | document |
| m4a | 3 | audio |
| xls | 2 | document |
| xlsx | 2 | document |
| webp | 2 | image |
| bmp | 2 | image |
| zip | 1 | archive |
| html | 1 | document |
| gif | 1 | image |
| HEIC | 1 | image |
| csv | 1 | document |
| wav | 1 | audio |
| (NULL) | 267 | unknown |

### Case sensitivity
`audmedia` lives in `utf8mb4_unicode_ci` (case-insensitive collation), so the `mediaext = mediaext` join treats `HEIC` and `heic` as equal. **No need to seed both cases.** Store lowercase in `exttypes`.

---

## 3. Proposed seed

One row per observed extension + a small set of "almost certain to appear next" extras (heic→from iPhones is already in the data, expect more; svg/tiff/aac/flac/m4v/webm — common variants). Owner can prune or add.

```sql
-- DRAFT: database/migrations/2026-05-17_audit_seed_exttypes.sql
-- Idempotent via INSERT IGNORE + unique key prerequisite. exttypes currently
-- has no uniqueness constraint on mediaext (see Open Questions); recommend
-- adding before seed so re-runs and future inserts are safe.

-- 3a. Ensure mediaext is unique (one row per extension).
DELIMITER //
DROP PROCEDURE IF EXISTS AddUniqueIfNotExists //
CREATE PROCEDURE AddUniqueIfNotExists()
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
CALL AddUniqueIfNotExists();
DROP PROCEDURE IF EXISTS AddUniqueIfNotExists;

-- 3b. Seed observed + safe-bet extensions. Idempotent via INSERT IGNORE.
INSERT IGNORE INTO exttypes (mediaext, isimage, exttype) VALUES
  -- Images (observed)
  ('jpg',  b'1', 'image'),
  ('jpeg', b'1', 'image'),
  ('png',  b'1', 'image'),
  ('gif',  b'1', 'image'),
  ('bmp',  b'1', 'image'),
  ('webp', b'1', 'image'),
  ('heic', b'1', 'image'),  -- collation is case-insensitive; HEIC matches
  -- Images (safe-bet additions)
  ('svg',  b'1', 'image'),
  ('tiff', b'1', 'image'),
  ('tif',  b'1', 'image'),
  -- Audio (observed)
  ('mp3',  b'0', 'audio'),
  ('m4a',  b'0', 'audio'),
  ('wav',  b'0', 'audio'),
  -- Audio (safe-bet additions)
  ('aac',  b'0', 'audio'),
  ('flac', b'0', 'audio'),
  ('ogg',  b'0', 'audio'),
  -- Video (observed)
  ('mp4',  b'0', 'video'),
  ('mov',  b'0', 'video'),
  -- Video (safe-bet additions)
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

SELECT COUNT(*) AS seeded_rows, exttype, COUNT(*) AS n FROM exttypes GROUP BY exttype WITH ROLLUP;
```

```sql
-- DRAFT rollback: database/migrations/2026-05-17_audit_seed_exttypes_ROLLBACK.sql
-- Removes only the rows this migration added. Safe even if the unique index was added.
DELETE FROM exttypes WHERE mediaext IN
  ('jpg','jpeg','png','gif','bmp','webp','heic','svg','tiff','tif',
   'mp3','m4a','wav','aac','flac','ogg',
   'mp4','mov','m4v','webm','avi',
   'pdf','doc','docx','xls','xlsx','csv','txt','html','zip');
-- Leave the uq_exttypes_mediaext index in place (harmless on an empty table;
-- if you want to fully revert: ALTER TABLE exttypes DROP INDEX uq_exttypes_mediaext;)
```

---

## 4. Verification plan

```sql
-- Before:
SELECT COUNT(*) FROM exttypes;  -- expect 0

-- After:
SELECT exttype, COUNT(*) FROM exttypes GROUP BY exttype;
-- expect: image 10, audio 6, video 5, document 8, archive 1 (= 30 rows)

-- Functional smoke: every distinct mediaext in audmedia (except NULL) now joins to a seeded row.
SELECT m.mediaext, COUNT(*) AS media_rows, COUNT(e.exttypeid) AS joined_rows
FROM audmedia m
LEFT JOIN exttypes e ON e.mediaext = m.mediaext
WHERE m.mediaext IS NOT NULL
GROUP BY m.mediaext
ORDER BY media_rows DESC;
-- All non-NULL mediaext values should show joined_rows = media_rows.
```

---

## 5. Open questions for the AuditionMedia owner

1. **267 NULL `mediaExt` rows in `audmedia`** — separate data-quality issue. Should the importer backfill `mediaExt` from `mediaFilename` (extract substring after last dot)? Not solved by this seed.
2. **`exttype` label values** — I used flat strings (`image`/`audio`/`video`/`document`/`archive`). If the UI expects a different vocabulary or i18n key, adjust before seeding.
3. **Safe-bet additions** (svg, tiff, tif, aac, flac, ogg, m4v, webm, avi) — keep or drop. Conservative answer: drop them; only seed observed extensions and let the importer add new rows as new extensions appear. The owner's call.
4. **Should `exttypes` rows be soft-deletable?** Schema has no `isdeleted`. If not, drop is just `DELETE`. Decide if this matters for the use case.
5. **Future extension policy** — should adding a new media extension be a code change (seed migration) or a UI-driven admin action? If UI-driven, this seed is a one-time bootstrap; if code-driven, every new format needs a migration.

---

## 6. Why this is a separate workstream from the May 2026 audit

The audit (R1–R12 / Phases 0–3) covered **schema** and **structural debt**. R2 is a **functional bug** that the audit happened to surface — the fix is data, not schema. Routing to AuditionMedia owner; gatekeeper-review the seed migration before any DBA execution. The audit's main scripts can ship independently of this.
