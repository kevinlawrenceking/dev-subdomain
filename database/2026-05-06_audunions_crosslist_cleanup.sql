-- =====================================================================
-- 2026-05-06_audunions_crosslist_cleanup.sql
--
-- Removes the two cross-listed audunions rows that were flagged in the
-- 2026-05-05 prod migration Stage 8 as data-entry errors:
--
--   unionID=24  "AGMA" at countryid='GB'
--               -> AGMA is American (already at unionID=173, US)
--   unionID=34  "Equity (UK)" at countryid='US'
--               -> Equity is the UK union (already at unionID=20, GB)
--
-- Strategy:
--   1. Snapshot any audprojects pointing at those unionIDs
--   2. Reset audprojects.unionID = 0 for those rows so the update form's
--      blank "--" option is selected and the user can re-pick. This
--      avoids a cross-country remap that would mismatch the form's
--      country filter and silently overwrite the saved value.
--   3. DELETE the two bogus audunions rows.
--   4. Verify: zero orphans, zero target rows remaining.
--
-- Idempotent. Safe to re-run.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Snapshot affected audprojects (audit trail / rollback source)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS _audprojects_crosslist_snapshot_20260506;
CREATE TABLE _audprojects_crosslist_snapshot_20260506 AS
SELECT audprojectid, unionID AS old_unionID, NOW() AS captured_at
FROM audprojects
WHERE unionID IN (24, 34);

-- Report what was captured (expect 0 on a clean dev DB)
SELECT old_unionID, COUNT(*) AS affected_audprojects
FROM _audprojects_crosslist_snapshot_20260506
GROUP BY old_unionID;

-- ---------------------------------------------------------------------
-- 2. Clear those projects' unionID so the form re-prompts the user
--    (audunions.unionID = 0 is treated as "unset" by the dropdown,
--    which renders <option value="">--</option> as the selection.)
-- ---------------------------------------------------------------------
UPDATE audprojects
SET unionID = 0
WHERE unionID IN (24, 34);

-- ---------------------------------------------------------------------
-- 3. Delete the two cross-listed audunions rows
-- ---------------------------------------------------------------------
DELETE FROM audunions
WHERE unionID IN (24, 34);

-- ---------------------------------------------------------------------
-- 4. Verification
-- ---------------------------------------------------------------------
-- 4a. Should return 0 rows
SELECT unionID, unionName, countryid
FROM audunions
WHERE unionID IN (24, 34);

-- 4b. Should return 0 orphans
SELECT COUNT(*) AS orphan_audprojects
FROM audprojects p
LEFT JOIN audunions u ON u.unionID = p.unionID
WHERE p.unionID IS NOT NULL
  AND p.unionID <> 0
  AND u.unionID IS NULL;

-- 4c. Confirm canonical rows still present (expect 2 rows)
SELECT unionID, unionName, countryid, audCatIDList
FROM audunions
WHERE (unionName = 'AGMA'   AND countryid = 'US')   -- expect unionID=173
   OR (unionName = 'Equity' AND countryid = 'GB');  -- expect unionID=20
