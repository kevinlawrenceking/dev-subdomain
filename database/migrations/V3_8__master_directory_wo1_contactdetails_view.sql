-- ============================================================================
-- V3_8  Master Contact Directory -- WO-1 (part 2 of 3)
--       Rebuild the `contactdetails` VIEW to expose the 12 new WO-1 columns.
--
-- PROJECT     : TAO / dev-subdomain / branch dev
-- CLEARANCE   : WO-0b Decision Memo CLEARED WITH AMENDMENTS, 2026-07-06.
-- ENGINE      : MySQL 8.0.41. DATABASE()-scoped; runs verbatim on dev + prod.
--               Run USE <schema>; first. Apply IMMEDIATELY after V3_7, in the
--               SAME migration window (A4).
--
-- SECURITY MODEL -- SQL SECURITY INVOKER (deliberate, precedented):
--   The captured abo pane shows the current `contactdetails` view is DEFINER
--   (only `taousers` is INVOKER). This rebuild INTENTIONALLY converges it to the
--   TAO house INVOKER standard -- the same fix applied to the `tickets` view in
--   database/2026-04-18_rebuild_tickets_view_invoker_security.sql, which exists
--   precisely because a phpMyAdmin apply silently rewrote a DEFINER clause to
--   root@108.185.100.195 and broke reads (this is finding F19 / the DEFINER
--   drift class). Under INVOKER, privilege checks run as the CF DSN account,
--   which holds ALL PRIVILEGES on the base tables (Q9b) -- so the view "just
--   works" regardless of any DEFINER account. NN#12: mysql CLI only for this DDL.
--
-- NO SCHEMA QUALIFIERS (A4): table is referenced bare (`contactdetails_tbl`) so
--   the same script runs in either schema. Promotion to prod must re-verify no
--   schema qualifier (e.g. `actorsbusinessoffice.`) was reintroduced.
--
-- COLUMN SET: 32 existing base columns (ordinal order, per abo pane Q4Q5,
--   including the VIRTUAL GENERATED `recordname` and `IsDeleted`) + 12 new WO-1
--   columns = 44. WHERE IsDeleted = 0 (active records), matching the captured view.
--
-- === RECONCILED 2026-07-07 -- STOP-ON-DELTA CLEARED (DIR-WO-1 ruling 2) ===
--   The live `contactdetails` view was captured on BOTH environments and enumerates
--   exactly 32 columns, in the identical order and with the identical
--   WHERE (IsDeleted = 0) as the 32-column block below:
--     * prod (abo)  -- 2026-07-07 SHOW CREATE VIEW + abo pane 2026-07-04
--     * dev (abod)  -- 2026-07-07 abod pane, docs/plans/evidence/2026-07-07-wo0b-pane-abod.txt
--   The abo pane's "33-col" summary was a MISCOUNT; there is no 33rd base column,
--   alias, or expression. The only live-vs-this-file delta is the 12 additive WO-1
--   columns being ABSENT from the live view -> the expected case -> PROCEED.
--   Reconcile + drift register: docs/plans/evidence/2026-07-07-wo0b-addendum-B-drift.md.
--
--   PROMOTION SAFEGUARD (prod apply): still re-run, immediately before applying,
--       SHOW CREATE VIEW contactdetails\G
--   and confirm the live view is these same 32 base columns + WHERE. If a future
--   delta appears (added/removed base column, changed predicate/alias) -> STOP,
--   re-emit, report; do NOT apply blind. NN#1: do not guess. Runbook Step 2.
-- ============================================================================

-- --- Step 0: guard -- view + base table + all 12 new columns must be present ---
SET @is_view = (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'contactdetails' AND table_type = 'VIEW'
);
SET @tbl_ok = (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'contactdetails_tbl' AND table_type = 'BASE TABLE'
);
SET @new_cols = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE table_schema = DATABASE() AND table_name = 'contactdetails_tbl'
      AND column_name IN ('contactPhone','contactEmail','contactCompany',
                          'contactPhone_src','contactEmail_src','contactCompany_src','contactPhoto_src',
                          'company_location_id','master_co_contact_id','master_coid',
                          'master_linked_date','master_last_sync')
);
SET @proceed = (@is_view = 1 AND @tbl_ok = 1 AND @new_cols = 12);
SELECT IF(@proceed = 1,
          'OK: view + base table + 12 new columns present -- rebuilding',
          CONCAT('ABORT: preconditions not met (is_view=', @is_view,
                 ' tbl_ok=', @tbl_ok, ' new_cols=', @new_cols, '/12) -- run V3_7 first'))
       AS preflight;

-- --- Step 1: drop the current view (only if preconditions met) ---
SET @sql = IF(@proceed = 1, 'DROP VIEW IF EXISTS `contactdetails`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- --- Step 2: recreate with SQL SECURITY INVOKER, 44 columns, no schema qualifier ---
SET @sql = IF(@proceed = 1,
    CONCAT(
        'CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `contactdetails` AS SELECT ',
            -- 32 existing base columns, ordinal order
            '`contactdetails_tbl`.`contactID` AS `contactID`,',
            '`contactdetails_tbl`.`contactTitle` AS `contactTitle`,',
            '`contactdetails_tbl`.`contactFullName` AS `contactFullName`,',
            '`contactdetails_tbl`.`contactFirst` AS `contactFirst`,',
            '`contactdetails_tbl`.`contactMiddle` AS `contactMiddle`,',
            '`contactdetails_tbl`.`contactLast` AS `contactLast`,',
            '`contactdetails_tbl`.`contactSuffix` AS `contactSuffix`,',
            '`contactdetails_tbl`.`contactNickname` AS `contactNickname`,',
            '`contactdetails_tbl`.`contactPhoto` AS `contactPhoto`,',
            '`contactdetails_tbl`.`contactShortName` AS `contactShortName`,',
            '`contactdetails_tbl`.`contactMaidenName` AS `contactMaidenName`,',
            '`contactdetails_tbl`.`contactBirthday` AS `contactBirthday`,',
            '`contactdetails_tbl`.`refer_contact_id` AS `refer_contact_id`,',
            '`contactdetails_tbl`.`contactMeetingLoc` AS `contactMeetingLoc`,',
            '`contactdetails_tbl`.`contactCreationDate` AS `contactCreationDate`,',
            '`contactdetails_tbl`.`contactLastUpdated` AS `contactLastUpdated`,',
            '`contactdetails_tbl`.`contactStatus` AS `contactStatus`,',
            '`contactdetails_tbl`.`contactNotes` AS `contactNotes`,',
            '`contactdetails_tbl`.`userID` AS `userID`,',
            '`contactdetails_tbl`.`user_yn` AS `user_yn`,',
            '`contactdetails_tbl`.`IsDeleted` AS `IsDeleted`,',
            '`contactdetails_tbl`.`contactPronoun` AS `contactPronoun`,',
            '`contactdetails_tbl`.`contactMeetingDate` AS `contactMeetingDate`,',
            '`contactdetails_tbl`.`birthday_DD` AS `birthday_DD`,',
            '`contactdetails_tbl`.`birthday_MM` AS `birthday_MM`,',
            '`contactdetails_tbl`.`newsletter_yn` AS `newsletter_yn`,',
            '`contactdetails_tbl`.`googlealert_yn` AS `googlealert_yn`,',
            '`contactdetails_tbl`.`socialmedia_yn` AS `socialmedia_yn`,',
            '`contactdetails_tbl`.`dateAdded` AS `dateAdded`,',
            '`contactdetails_tbl`.`imdbid` AS `imdbid`,',
            '`contactdetails_tbl`.`recordname` AS `recordname`,',
            '`contactdetails_tbl`.`avatar_yn` AS `avatar_yn`,',
            -- 12 new WO-1 columns
            '`contactdetails_tbl`.`contactPhone` AS `contactPhone`,',
            '`contactdetails_tbl`.`contactEmail` AS `contactEmail`,',
            '`contactdetails_tbl`.`contactCompany` AS `contactCompany`,',
            '`contactdetails_tbl`.`contactPhone_src` AS `contactPhone_src`,',
            '`contactdetails_tbl`.`contactEmail_src` AS `contactEmail_src`,',
            '`contactdetails_tbl`.`contactCompany_src` AS `contactCompany_src`,',
            '`contactdetails_tbl`.`contactPhoto_src` AS `contactPhoto_src`,',
            '`contactdetails_tbl`.`company_location_id` AS `company_location_id`,',
            '`contactdetails_tbl`.`master_co_contact_id` AS `master_co_contact_id`,',
            '`contactdetails_tbl`.`master_coid` AS `master_coid`,',
            '`contactdetails_tbl`.`master_linked_date` AS `master_linked_date`,',
            '`contactdetails_tbl`.`master_last_sync` AS `master_last_sync` ',
        'FROM `contactdetails_tbl` WHERE (`contactdetails_tbl`.`IsDeleted` = 0)'
    ),
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- --- POST-CHECK: view is INVOKER-secured and exposes 44 columns ---
SELECT table_schema, table_name, security_type, is_updatable
FROM information_schema.views
WHERE table_schema = DATABASE() AND table_name = 'contactdetails';

SELECT COUNT(*) AS view_col_count_expect_44
FROM information_schema.COLUMNS
WHERE table_schema = DATABASE() AND table_name = 'contactdetails';

-- Smoke test: prove the new columns read through the view.
SELECT contactID, contactPhone, contactEmail, contactCompany,
       contactPhone_src, master_co_contact_id, master_coid, master_last_sync
FROM contactdetails
ORDER BY contactID DESC
LIMIT 1;
