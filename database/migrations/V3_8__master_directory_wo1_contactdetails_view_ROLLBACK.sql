-- ============================================================================
-- V3_8 ROLLBACK  Master Contact Directory -- WO-1 (part 2 of 3)
--   Rebuild `contactdetails` at its ORIGINAL 32-column shape (dropping the 12
--   WO-1 columns from the view). Must run BEFORE V3_7 rollback drops those
--   columns from the base table, or the live 44-column view would break.
--
-- PROJECT : TAO / dev-subdomain / branch dev
-- ENGINE  : MySQL 8.0.41. DATABASE()-scoped; run USE <schema>; first.
--
-- SECURITY MODEL: rebuilt as SQL SECURITY INVOKER (the TAO house standard), NOT
--   restored to the pre-WO-1 DEFINER form. This mirrors the tickets-view
--   precedent: reintroducing a DEFINER=root@... clause is the very drift class
--   (F19) the INVOKER standard exists to avoid. If a true DEFINER restore is ever
--   required, capture the exact prior definition from a backup and apply manually.
-- ============================================================================

SET @is_view = (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'contactdetails' AND table_type = 'VIEW'
);
SET @tbl_ok = (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'contactdetails_tbl' AND table_type = 'BASE TABLE'
);
SET @proceed = (@is_view = 1 AND @tbl_ok = 1);

SET @sql = IF(@proceed = 1, 'DROP VIEW IF EXISTS `contactdetails`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql = IF(@proceed = 1,
    CONCAT(
        'CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `contactdetails` AS SELECT ',
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
            '`contactdetails_tbl`.`avatar_yn` AS `avatar_yn` ',
        'FROM `contactdetails_tbl` WHERE (`contactdetails_tbl`.`IsDeleted` = 0)'
    ),
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT COUNT(*) AS view_col_count_expect_32
FROM information_schema.COLUMNS
WHERE table_schema = DATABASE() AND table_name = 'contactdetails';
