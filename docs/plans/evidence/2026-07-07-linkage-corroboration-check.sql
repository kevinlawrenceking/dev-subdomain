-- ============================================================================
-- Linkage corroboration check (prod, READ-ONLY). Compares the USER's contact
-- info (contactitems) against the MASTER (co_contacts -> companies -> co_locations)
-- for the clean name-match set, to (a) confirm correctness / catch homonyms and
-- (b) tier confidence. Fully schema-qualified (actorsbusinessoffice) -> run from any DB.
-- HeidiSQL: load file, run each SECTION, paste results.
-- ============================================================================

-- ---------- SECTION A: master table columns (so we can extend to location) ----------
SELECT table_name, GROUP_CONCAT(column_name ORDER BY ordinal_position SEPARATOR ', ') AS cols
FROM information_schema.columns
WHERE table_schema='actorsbusinessoffice' AND table_name IN ('companies','co_locations')
GROUP BY table_name;


-- ---------- SECTION B: confidence tiering of the clean 15,954 by COMPANY corroboration ----------
-- user company (any active contactitems Company) vs master company (companies.coName),
-- fuzzy both-way LIKE so "CESD" ~ "CESD Talent Agency".
SELECT
  COUNT(*)                                        AS clean_total,
  SUM(comp_match)                                 AS tier1_company_corroborated,
  SUM(has_user_company AND NOT comp_match)        AS tier3_company_mismatch,
  SUM(NOT has_user_company)                       AS tier2_no_user_company
FROM (
  SELECT m.contactID,
    EXISTS(SELECT 1 FROM actorsbusinessoffice.contactitems_tbl ci
             WHERE ci.contactID=m.contactID AND ci.valueCategory='Company'
               AND ci.itemStatus='Active' AND ci.IsDeleted=0
               AND TRIM(COALESCE(ci.valueCompany,''))<>'') AS has_user_company,
    EXISTS(SELECT 1 FROM actorsbusinessoffice.contactitems_tbl ci
             JOIN actorsbusinessoffice.companies co ON co.coid=m.coid AND m.coid<>0
             WHERE ci.contactID=m.contactID AND ci.valueCategory='Company'
               AND ci.itemStatus='Active' AND ci.IsDeleted=0
               AND (ci.valueCompany = co.coName
                    OR co.coName    LIKE CONCAT('%',ci.valueCompany,'%')
                    OR ci.valueCompany LIKE CONCAT('%',co.coName,'%'))) AS comp_match
  FROM (
    SELECT x.contactID, x.coid
    FROM (
      SELECT d.contactID, c.coid,
             ROW_NUMBER() OVER (PARTITION BY d.contactID ORDER BY c.id) rn
      FROM actorsbusinessoffice.contactdetails_tbl d
      JOIN actorsbusinessoffice.co_contacts c ON c.fullname=d.contactFullName
      WHERE d.IsDeleted=0 AND d.contactFullName<>'' AND c.imdbid IS NOT NULL AND c.imdbid<>''
    ) x
    JOIN (
      SELECT d.contactID FROM actorsbusinessoffice.contactdetails_tbl d
      JOIN actorsbusinessoffice.co_contacts c ON c.fullname=d.contactFullName
      WHERE d.IsDeleted=0 AND d.contactFullName<>'' AND c.imdbid IS NOT NULL AND c.imdbid<>''
      GROUP BY d.contactID HAVING COUNT(DISTINCT c.imdbid)=1
    ) clean ON clean.contactID=x.contactID
    WHERE x.rn=1
  ) m
) t;


-- ---------- SECTION C: 40-row side-by-side sample (eyeball user vs master) ----------
SELECT cd.contactID, cd.contactFullName, m.imdbid,
  (SELECT GROUP_CONCAT(DISTINCT ci.valueCompany SEPARATOR ' | ')
     FROM actorsbusinessoffice.contactitems_tbl ci
    WHERE ci.contactID=cd.contactID AND ci.valueCategory='Company'
      AND ci.itemStatus='Active' AND ci.IsDeleted=0
      AND TRIM(COALESCE(ci.valueCompany,''))<>'')          AS user_company,
  co.coName                                                AS master_company,
  cc.jobtitle_type                                         AS master_title
FROM actorsbusinessoffice.contactdetails_tbl cd
JOIN (
  SELECT x.contactID, x.cc_id, x.imdbid, x.coid
  FROM (
    SELECT d.contactID, c.id AS cc_id, c.imdbid, c.coid,
           ROW_NUMBER() OVER (PARTITION BY d.contactID ORDER BY c.id) rn
    FROM actorsbusinessoffice.contactdetails_tbl d
    JOIN actorsbusinessoffice.co_contacts c ON c.fullname=d.contactFullName
    WHERE d.IsDeleted=0 AND d.contactFullName<>'' AND c.imdbid IS NOT NULL AND c.imdbid<>''
  ) x
  JOIN (
    SELECT d.contactID FROM actorsbusinessoffice.contactdetails_tbl d
    JOIN actorsbusinessoffice.co_contacts c ON c.fullname=d.contactFullName
    WHERE d.IsDeleted=0 AND d.contactFullName<>'' AND c.imdbid IS NOT NULL AND c.imdbid<>''
    GROUP BY d.contactID HAVING COUNT(DISTINCT c.imdbid)=1
  ) clean ON clean.contactID=x.contactID
  WHERE x.rn=1
) m ON m.contactID=cd.contactID
JOIN actorsbusinessoffice.co_contacts cc ON cc.id=m.cc_id
LEFT JOIN actorsbusinessoffice.companies co ON co.coid=m.coid AND m.coid<>0
WHERE cd.IsDeleted=0
ORDER BY cd.contactID DESC
LIMIT 40;
