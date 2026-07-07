-- =============================================================================
-- SEED DEV MASTER TABLES FROM PROD  (co_contacts, co_locations)
-- Staged 2026-07-07 (CC). Closes drift D-B (Addendum B): dev co_contacts=0 /
-- co_locations=0 vs prod 25,200 / 12,617. companies already matches (10,740) -> NOT copied.
-- Binding: TAO / dev-subdomain / branch dev.
--
-- SOURCE = actorsbusinessoffice (prod)   TARGET = new_development (dev)
-- Same MySQL server; kingk436@% has ALL PRIVILEGES on both (Q9b). Run in HeidiSQL.
-- utf8mb4_unicode_ci on both -> no collation conversion.
--
-- SAFETY: dev targets are EMPTY, so this only ADDS rows (no overwrite, no delete).
--   Run Step 1, EYEBALL the results, only then run Step 2. Do NOT re-run Step 2 (PKs
--   would collide) -- if you must, TRUNCATE the two dev tables first.
-- =============================================================================

-- --- STEP 1: PRE-FLIGHT (read-only) -------------------------------------------
-- 1a. Counts. Expect dev co_contacts=0, co_locations=0; companies equal on both.
SELECT 'prod co_contacts'  s, COUNT(*) n FROM actorsbusinessoffice.co_contacts
UNION ALL SELECT 'dev  co_contacts',      COUNT(*) FROM new_development.co_contacts
UNION ALL SELECT 'prod co_locations',     COUNT(*) FROM actorsbusinessoffice.co_locations
UNION ALL SELECT 'dev  co_locations',     COUNT(*) FROM new_development.co_locations
UNION ALL SELECT 'prod companies',        COUNT(*) FROM actorsbusinessoffice.companies
UNION ALL SELECT 'dev  companies',        COUNT(*) FROM new_development.companies;

-- 1b. Structure match -- the two 'cols' strings per table MUST be identical for
--     SELECT * to line up. If they differ, STOP and tell CC (column-explicit copy needed).
SELECT table_schema, table_name,
       GROUP_CONCAT(column_name ORDER BY ordinal_position) AS cols
FROM   information_schema.columns
WHERE  table_schema IN ('actorsbusinessoffice','new_development')
  AND  table_name IN ('co_contacts','co_locations')
GROUP  BY table_schema, table_name
ORDER  BY table_name, table_schema;

-- 1c. FK-safety -- any prod co_ rows whose coid is absent from DEV companies?
--     coid is a 0-sentinel, so exclude 0. Expect both = 0 (dev companies covers them).
SELECT 'co_contacts orphan coids vs dev companies' s, COUNT(*) n
FROM   actorsbusinessoffice.co_contacts c
LEFT JOIN new_development.companies d ON d.coid = c.coid
WHERE  d.coid IS NULL AND c.coid <> 0
UNION ALL
SELECT 'co_locations orphan coids vs dev companies', COUNT(*)
FROM   actorsbusinessoffice.co_locations l
LEFT JOIN new_development.companies d ON d.coid = l.coid
WHERE  d.coid IS NULL AND l.coid <> 0;
-- If both 0 -> proceed to Step 2. If >0 -> the dev companies set differs from prod;
-- ping CC before seeding (we'd refresh companies too, not just the two child tables).

-- --- STEP 2: COPY (writes to dev) ---------------------------------------------
-- Only after Step 1 shows: dev tables empty, structures identical, orphans = 0.
START TRANSACTION;
SET @fk := @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS := 0;                                   -- bulk-load guard
INSERT INTO new_development.co_locations SELECT * FROM actorsbusinessoffice.co_locations;
INSERT INTO new_development.co_contacts  SELECT * FROM actorsbusinessoffice.co_contacts;
SET FOREIGN_KEY_CHECKS := @fk;
COMMIT;

-- --- STEP 3: POST-VERIFY ------------------------------------------------------
SELECT 'dev co_contacts'  s, COUNT(*) n FROM new_development.co_contacts
UNION ALL SELECT 'dev co_locations',     COUNT(*) FROM new_development.co_locations;
-- Expect 25,200 and 12,617 (matching prod at capture time).

-- Post-load orphan recheck against dev's own companies (should still be 0 for coid<>0):
SELECT 'dev co_contacts orphan coids'  s, COUNT(*) n
FROM   new_development.co_contacts c
LEFT JOIN new_development.companies d ON d.coid = c.coid
WHERE  d.coid IS NULL AND c.coid <> 0
UNION ALL
SELECT 'dev co_locations orphan coids', COUNT(*)
FROM   new_development.co_locations l
LEFT JOIN new_development.companies d ON d.coid = l.coid
WHERE  d.coid IS NULL AND l.coid <> 0;
-- =============================================================================
-- After this, dev master-directory linkage is testable end-to-end -> clears D-B.
-- Note: prod row counts drift over time; re-seeding later means TRUNCATE + re-copy.
-- =============================================================================
