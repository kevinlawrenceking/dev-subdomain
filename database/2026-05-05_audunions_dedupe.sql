-- =====================================================================
-- 2026-05-05_audunions_dedupe.sql
--
-- Cleanup script for the duplicate seed rows that were inserted when
-- the audunions seed INSERT ran twice without the unique key in place
-- (HeidiSQL "continue on errors" + repeated paste of the seed block).
--
-- Removes higher-ID duplicates per (unionName, countryid), keeping the
-- lowest unionID -- safe because audprojects.unionID was already
-- remapped to the lowest survivor IDs in the original consolidation.
--
-- Then adds the unique key so future seed re-runs are idempotent.
-- =====================================================================

-- 1. Sanity: list any duplicates remaining
SELECT unionName, countryid, COUNT(*) AS n
FROM audunions
GROUP BY unionName, countryid
HAVING n > 1;

-- 2. Delete duplicates, keep lowest unionID per (unionName, countryid)
DELETE a FROM audunions a
INNER JOIN (
    SELECT unionName, countryid, MIN(unionID) AS keep_id
    FROM audunions
    GROUP BY unionName, countryid
) keep
    ON keep.unionName = a.unionName
   AND keep.countryid = a.countryid
WHERE a.unionID > keep.keep_id;

-- 3. Add the unique key. If it already exists, this errors with
--    "Duplicate key name 'uk_audunions_name_country'" -- safe to ignore.
ALTER TABLE audunions
    ADD UNIQUE KEY uk_audunions_name_country (unionName, countryid);

-- 4. Verification
--    Expect: total = 48, 17 countries, 0 orphans
SELECT COUNT(*) AS total FROM audunions;

SELECT countryid, COUNT(*) AS n
FROM audunions
WHERE isDeleted = b'0'
GROUP BY countryid
ORDER BY countryid;

SELECT COUNT(*) AS orphans
FROM audprojects p
LEFT JOIN audunions u ON u.unionID = p.unionID
WHERE p.unionID IS NOT NULL AND u.unionID IS NULL;
