-- =============================================================================
-- Contact Duplicate Report (per user)
-- TAO / MySQL 8 (new_development = dev, actorsbusinessoffice = prod)
--
-- Reads the contactdetails / contactitems VIEWS (auto-filter IsDeleted) and
-- scopes every match to a single user (duplicates only matter within one
-- user's contact pool). Verified columns:
--   contactdetails.contactFullName, .recordname, .userid, .isdeleted
--   contactitems.valueCategory IN ('Email','Phone'), .valuetext, .itemStatus
--
-- Usage: set @uid to the target user, then run the FULL and/or POSSIBLE block.
--        Remove the "userid = @uid" predicate for an admin-wide sweep.
-- =============================================================================

SET @uid = 30;   -- <-- target userid

-- -----------------------------------------------------------------------------
-- FULL DUPLICATES  (high confidence: exact email, exact phone, or exact name)
-- One row per match group, with the colliding contact ids + names.
-- -----------------------------------------------------------------------------

-- a) Same EMAIL (case/space-insensitive)
SELECT cd.userid,
       'EMAIL'                                AS match_type,
       LOWER(TRIM(ci.valuetext))             AS match_key,
       COUNT(DISTINCT cd.contactid)          AS dupe_count,
       GROUP_CONCAT(DISTINCT cd.contactid ORDER BY cd.contactid)                       AS contact_ids,
       GROUP_CONCAT(DISTINCT cd.contactFullName ORDER BY cd.contactid SEPARATOR ' | ') AS names
FROM   contactitems ci
JOIN   contactdetails cd ON cd.contactid = ci.contactid
WHERE  cd.userid = @uid
  AND  cd.isdeleted = 0
  AND  ci.itemStatus = 'Active'
  AND  ci.valueCategory = 'Email'
  AND  ci.valuetext LIKE '%@%'
  AND  TRIM(ci.valuetext) <> ''
GROUP  BY cd.userid, LOWER(TRIM(ci.valuetext))
HAVING COUNT(DISTINCT cd.contactid) > 1

UNION ALL

-- b) Same PHONE (digits only, compared on the last 10 digits)
SELECT cd.userid,
       'PHONE',
       RIGHT(REGEXP_REPLACE(ci.valuetext, '[^0-9]', ''), 10),
       COUNT(DISTINCT cd.contactid),
       GROUP_CONCAT(DISTINCT cd.contactid ORDER BY cd.contactid),
       GROUP_CONCAT(DISTINCT cd.contactFullName ORDER BY cd.contactid SEPARATOR ' | ')
FROM   contactitems ci
JOIN   contactdetails cd ON cd.contactid = ci.contactid
WHERE  cd.userid = @uid
  AND  cd.isdeleted = 0
  AND  ci.itemStatus = 'Active'
  AND  ci.valueCategory = 'Phone'
  AND  LENGTH(REGEXP_REPLACE(ci.valuetext, '[^0-9]', '')) >= 10
GROUP  BY cd.userid, RIGHT(REGEXP_REPLACE(ci.valuetext, '[^0-9]', ''), 10)
HAVING COUNT(DISTINCT cd.contactid) > 1

UNION ALL

-- c) Same NAME (trim, collapse interior whitespace, lowercase)
SELECT cd.userid,
       'NAME',
       LOWER(REGEXP_REPLACE(TRIM(cd.contactFullName), '\\s+', ' ')),
       COUNT(*),
       GROUP_CONCAT(cd.contactid ORDER BY cd.contactid),
       GROUP_CONCAT(cd.contactFullName ORDER BY cd.contactid SEPARATOR ' | ')
FROM   contactdetails cd
WHERE  cd.userid = @uid
  AND  cd.isdeleted = 0
  AND  TRIM(COALESCE(cd.contactFullName, '')) <> ''
GROUP  BY cd.userid, LOWER(REGEXP_REPLACE(TRIM(cd.contactFullName), '\\s+', ' '))
HAVING COUNT(*) > 1

ORDER BY match_type, dupe_count DESC;

-- -----------------------------------------------------------------------------
-- POSSIBLE DUPLICATES  (slightly different names: "Jon Smith" vs "John Smith",
-- middle-name / spelling variants).  Returned as contact pairs.  SOUNDEX is a
-- coarse phonetic match -- expect some noise; this is the "review me" bucket.
-- -----------------------------------------------------------------------------
SELECT a.userid,
       'POSSIBLE_NAME'      AS match_type,
       a.contactid          AS id_a,
       a.contactFullName    AS name_a,
       b.contactid          AS id_b,
       b.contactFullName    AS name_b
FROM   contactdetails a
JOIN   contactdetails b
       ON  b.userid    = a.userid
       AND b.contactid > a.contactid          -- each pair once, no self-pair
WHERE  a.userid = @uid
  AND  a.isdeleted = 0
  AND  b.isdeleted = 0
  AND  TRIM(COALESCE(a.contactFullName,'')) <> ''
  AND  TRIM(COALESCE(b.contactFullName,'')) <> ''
  AND  SOUNDEX(a.contactFullName) = SOUNDEX(b.contactFullName)
  AND  LOWER(REGEXP_REPLACE(TRIM(a.contactFullName), '\\s+', ' '))
    <> LOWER(REGEXP_REPLACE(TRIM(b.contactFullName), '\\s+', ' '))   -- exclude exact (those are FULL)
ORDER BY name_a;
