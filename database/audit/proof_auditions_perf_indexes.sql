-- =============================================================================
-- PROOF HARNESS: auditions xref index (2026-07-09_auditions_perf_indexes.sql)
--
-- Purpose: demonstrate the getAuditions plan improvement BEFORE the index ever
--          touches prod. Run the whole sequence on dev (new_development); the
--          migration + rollback are idempotent so dev is left clean.
--
-- HOW TO READ IT: watch the row whose `table` is the audcontacts_auditions_xref
-- alias `x`. That single line is the whole story:
--   BEFORE:  type=index   rows=~11289   Extra: Using where; Using index; Using join buffer
--   AFTER:   type=ref     rows=~1-2     Extra: Using index
--
-- Replace :UID with a heavy real user on the target schema. On prod the heaviest
-- were 629 (375 projects), 723 (364), 760 (255). Pick the equivalent on dev.
-- =============================================================================

-- ---- STEP 1: BEFORE ---------------------------------------------------------
EXPLAIN
SELECT
    p.audprojectid AS recid, p.audprojectid, r.payrate, r.buyout, r.audroleid,
    st.audstep, st.stepcss, r.iscallback, c.contactfullname, r.isredirect, ca.audcatname,
    r.ispin, r.isbooked, p.projdate AS col1, p.audprojectdate AS col1b, p.projname AS col2,
    ca.audcatname AS col3, ca.aud_cat_icon, r.audrolename AS col4, s.audsource AS col5,
    c2.recordname AS contactname, c.recordname, c.recordname AS castingfullname,
    sc.audsubcatname, p.projdate, rt.audroletype,
    CONCAT_WS("|", p.projname, rt.audroletype, c.recordname, st.audstep, rt.audroletype, s.audsource, p.projdescription) AS search_query,
    GROUP_CONCAT(c3.recordname) AS contacts_list
FROM audprojects p
INNER JOIN audroles r ON p.audprojectID = r.audprojectID
LEFT JOIN events a ON r.audroleid = a.audroleid
LEFT JOIN audsources s ON s.audSourceID = r.audSourceID
LEFT JOIN contactdetails c ON c.contactID = p.contactid
LEFT JOIN contactdetails c2 ON c2.contactID = r.contactid
LEFT JOIN audroletypes rt ON rt.audroletypeid = r.audroletypeid
LEFT JOIN audsteps st ON st.audstepid = a.audstepid
LEFT JOIN audsubcategories sc ON sc.audsubcatid = p.audsubcatid
LEFT JOIN audcategories ca ON ca.audcatid = sc.audcatid
LEFT JOIN audcontacts_auditions_xref x ON x.audprojectid = p.audprojectid
LEFT JOIN contactdetails c3 ON c3.contactid = x.contactid
WHERE r.isdeleted = 0 AND p.isDeleted = 0 AND p.userid = :UID
GROUP BY r.audroleid, p.projname, s.audsource, rt.audroletype, r.iscallback, r.isredirect, r.ispin, r.isbooked
ORDER BY p.projdate DESC;

-- ---- STEP 2: APPLY the forward migration ------------------------------------
-- SOURCE database/migrations/2026-07-09_auditions_perf_indexes.sql
-- (or in HeidiSQL, run that file). Confirm it prints CREATED: idx_aax_project_contact.

-- ---- STEP 3: AFTER (re-run the identical EXPLAIN from STEP 1) ----------------
-- Expected: the `x` line is now  type=ref | key=idx_aax_project_contact |
--           rows~1-2 | Extra: Using index   (join buffer + 11k-row scan gone).

-- ---- STEP 4 (optional): restore dev to baseline -----------------------------
-- SOURCE database/migrations/2026-07-09_auditions_perf_indexes_ROLLBACK.sql
-- =============================================================================
