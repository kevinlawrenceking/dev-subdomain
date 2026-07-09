-- ============================================================================
-- WO-1 Master linkage -- "~384 safe records" PREVIEW / MATERIALIZATION (prod)
--   READ-ONLY. Produces the exact contactID -> master-pointer set that the
--   optional tier-1 backfill would write, so it can be eyeballed and its
--   rollback keyset captured BEFORE any UPDATE runs.
--
-- PROJECT : TAO / dev-subdomain / branch dev
-- ENV     : PROD -- actorsbusinessoffice (fully schema-qualified; run from any DB)
-- ENGINE  : MySQL 8.0.41 (ROW_NUMBER / NULLIF)
-- BASIS   : docs/plans/evidence/2026-07-07-linkage-corroboration-check.sql
--           (Section B tiering). This file ADDS: (1) the userid<>11 exclusion of
--           the 22K master dump, (2) tier-1-only membership, (3) the actual keyed
--           rows + pointer targets, (4) fill-blank safety counts.
-- SCOPE   : person + company pointers only (master_co_contact_id, master_coid).
--           company_location_id (office) is DEFERRED -- no primary-office flag in
--           the master data and the co_locations link column is unconfirmed; the
--           FK accepts NULL, so office is left for the UI to fill on user confirm.
-- WRITES  : NONE. This file only SELECTs.
-- ============================================================================

-- ---------- SECTION 0: schema confirms (resolve the two unknowns) ----------
-- 0a. Which table carries userid for the uid<>11 exclusion? Expect a userid col
--     on contactdetails_tbl; if absent, report where userid actually lives.
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema='actorsbusinessoffice'
  AND column_name IN ('userid','userID','UserID')
  AND table_name IN ('contactdetails_tbl','contacts','contact');

-- 0b. co_locations columns -- confirm the company-link column (coid?) before any
--     office-pointer work is ever attempted.
SELECT column_name, data_type, column_key
FROM information_schema.columns
WHERE table_schema='actorsbusinessoffice' AND table_name='co_locations'
ORDER BY ordinal_position;

-- 0c. Current pointer state on contactdetails_tbl -- all three must be all-NULL
--     (no UI links written yet). Any non-zero => fill-blank guard is doing real work.
SELECT
  SUM(master_co_contact_id IS NOT NULL) AS person_ptr_set,
  SUM(master_coid          IS NOT NULL) AS coid_ptr_set,
  SUM(company_location_id  IS NOT NULL) AS office_ptr_set
FROM actorsbusinessoffice.contactdetails_tbl;

-- ---------- SECTION 1: target-set COUNT (expect ~384) ----------
-- The clean name-match set, EXCLUDING userid 11, tier-1 (user company present AND
-- fuzzy-matches the master company). Mirrors corroboration Section B predicates.
SELECT COUNT(*) AS tier1_uid_ne_11
FROM (
  SELECT m.contactID
  FROM (
    SELECT x.contactID, x.cc_id, x.coid
    FROM (
      SELECT d.contactID, c.id AS cc_id, c.coid,
             ROW_NUMBER() OVER (PARTITION BY d.contactID ORDER BY c.id) rn
      FROM actorsbusinessoffice.contactdetails_tbl d
      JOIN actorsbusinessoffice.co_contacts c ON c.fullname = d.contactFullName
      WHERE d.IsDeleted = 0 AND d.contactFullName <> ''
        AND c.imdbid IS NOT NULL AND c.imdbid <> ''
        AND d.userid <> 11                                   -- exclude master dump
    ) x
    JOIN (
      SELECT d.contactID
      FROM actorsbusinessoffice.contactdetails_tbl d
      JOIN actorsbusinessoffice.co_contacts c ON c.fullname = d.contactFullName
      WHERE d.IsDeleted = 0 AND d.contactFullName <> ''
        AND c.imdbid IS NOT NULL AND c.imdbid <> ''
        AND d.userid <> 11
      GROUP BY d.contactID HAVING COUNT(DISTINCT c.imdbid) = 1   -- exactly-1 imdbid
    ) clean ON clean.contactID = x.contactID
    WHERE x.rn = 1
  ) m
  WHERE EXISTS (                                              -- tier-1: company corroborated
    SELECT 1 FROM actorsbusinessoffice.contactitems_tbl ci
    JOIN actorsbusinessoffice.companies co ON co.coid = m.coid AND m.coid <> 0
    WHERE ci.contactID = m.contactID AND ci.valueCategory = 'Company'
      AND ci.itemStatus = 'Active' AND ci.IsDeleted = 0
      AND ( ci.valueCompany = co.coName
         OR co.coName       LIKE CONCAT('%', ci.valueCompany, '%')
         OR ci.valueCompany LIKE CONCAT('%', co.coName, '%') )
  )
) t;

-- ---------- SECTION 2: the KEYED SET (this is the source of truth for the apply) --
-- Every row that would be written, with its pointer targets and current state.
-- Save this result verbatim as evidence; it is also the rollback keyset.
SELECT
  d.contactID,
  d.userid,
  d.contactFullName,
  m.cc_id                        AS write_master_co_contact_id,   -- co_contacts.id
  NULLIF(m.coid, 0)              AS write_master_coid,            -- companies.coid, 0 -> NULL
  d.master_co_contact_id         AS current_person_ptr,          -- must be NULL
  d.master_coid                  AS current_coid_ptr,            -- must be NULL
  (SELECT GROUP_CONCAT(DISTINCT ci.valueCompany SEPARATOR ' | ')
     FROM actorsbusinessoffice.contactitems_tbl ci
    WHERE ci.contactID = d.contactID AND ci.valueCategory = 'Company'
      AND ci.itemStatus = 'Active' AND ci.IsDeleted = 0
      AND TRIM(COALESCE(ci.valueCompany,'')) <> '')             AS user_company,
  co.coName                                                     AS master_company
FROM actorsbusinessoffice.contactdetails_tbl d
JOIN (
  SELECT x.contactID, x.cc_id, x.coid
  FROM (
    SELECT d.contactID, c.id AS cc_id, c.coid,
           ROW_NUMBER() OVER (PARTITION BY d.contactID ORDER BY c.id) rn
    FROM actorsbusinessoffice.contactdetails_tbl d
    JOIN actorsbusinessoffice.co_contacts c ON c.fullname = d.contactFullName
    WHERE d.IsDeleted = 0 AND d.contactFullName <> ''
      AND c.imdbid IS NOT NULL AND c.imdbid <> '' AND d.userid <> 11
  ) x
  JOIN (
    SELECT d.contactID
    FROM actorsbusinessoffice.contactdetails_tbl d
    JOIN actorsbusinessoffice.co_contacts c ON c.fullname = d.contactFullName
    WHERE d.IsDeleted = 0 AND d.contactFullName <> ''
      AND c.imdbid IS NOT NULL AND c.imdbid <> '' AND d.userid <> 11
    GROUP BY d.contactID HAVING COUNT(DISTINCT c.imdbid) = 1
  ) clean ON clean.contactID = x.contactID
  WHERE x.rn = 1
) m ON m.contactID = d.contactID
LEFT JOIN actorsbusinessoffice.companies co ON co.coid = m.coid AND m.coid <> 0
WHERE d.IsDeleted = 0
  AND EXISTS (                                                  -- tier-1 gate
    SELECT 1 FROM actorsbusinessoffice.contactitems_tbl ci
    JOIN actorsbusinessoffice.companies co2 ON co2.coid = m.coid AND m.coid <> 0
    WHERE ci.contactID = m.contactID AND ci.valueCategory = 'Company'
      AND ci.itemStatus = 'Active' AND ci.IsDeleted = 0
      AND ( ci.valueCompany = co2.coName
         OR co2.coName      LIKE CONCAT('%', ci.valueCompany, '%')
         OR ci.valueCompany LIKE CONCAT('%', co2.coName, '%') )
  )
ORDER BY d.contactID;

-- ---------- SECTION 3: safety readouts ----------
-- Rows whose person/coid pointer is ALREADY set (would be SKIPPED by fill-blank
-- apply). Expect 0 today. If >0, investigate before writing -- someone/something
-- linked those contacts already.
SELECT COUNT(*) AS already_linked_would_skip
FROM actorsbusinessoffice.contactdetails_tbl d
JOIN (
  SELECT x.contactID
  FROM (
    SELECT d.contactID,
           ROW_NUMBER() OVER (PARTITION BY d.contactID ORDER BY c.id) rn
    FROM actorsbusinessoffice.contactdetails_tbl d
    JOIN actorsbusinessoffice.co_contacts c ON c.fullname = d.contactFullName
    WHERE d.IsDeleted = 0 AND d.contactFullName <> ''
      AND c.imdbid IS NOT NULL AND c.imdbid <> '' AND d.userid <> 11
  ) x
  JOIN (
    SELECT d.contactID
    FROM actorsbusinessoffice.contactdetails_tbl d
    JOIN actorsbusinessoffice.co_contacts c ON c.fullname = d.contactFullName
    WHERE d.IsDeleted = 0 AND d.contactFullName <> ''
      AND c.imdbid IS NOT NULL AND c.imdbid <> '' AND d.userid <> 11
    GROUP BY d.contactID HAVING COUNT(DISTINCT c.imdbid) = 1
  ) clean ON clean.contactID = x.contactID
  WHERE x.rn = 1
) m ON m.contactID = d.contactID
WHERE d.IsDeleted = 0
  AND (d.master_co_contact_id IS NOT NULL OR d.master_coid IS NOT NULL);
