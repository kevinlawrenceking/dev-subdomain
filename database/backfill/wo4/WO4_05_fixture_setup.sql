-- ============================================================================
-- DIR-LNK-WO-4 -- FIXTURE SETUP (DEV ONLY: new_development) -- HELD
-- ============================================================================
-- Authorization: line-review relay item 4 (D-2) -- EXECUTION BLOCKED until the
--   D-2 stamp arrives AUTHORIZED. Executor per D-3 (CC pymysql narrow-auth or
--   operator HeidiSQL). Protocol: relay item 5 (binding).
-- Scope: INSERTs into contactdetails_tbl + contactitems_tbl ONLY, test user 30
--   ONLY, values clearly synthetic (fullname prefix 'ZZWO4FIXTURE', 555-01XX
--   fictional numbers, example.invalid emails). ZERO audit rows are written by
--   this script (protocol f). Zero DDL. No non-fixture rows touched.
-- Register: run WO4_06_fixture_register.sql immediately after; COMMIT THE
--   REGISTER OUTPUT TO THE REPO BEFORE any backfill script executes (protocol a).
-- Cases (protocol b):
--   F1 one (Phone)            F2 multi_one_primary (Email)
--   F3 rq1_carveout mzp-dupnorm (Company)   F4 rq1_carveout mm-dupnorm (Phone)
--   F5 rq2 Business+WorkFax (Phone)         F6 G-LNK probe (linked; must skip)
--   F7 G-WIDTH probe (raw > 100; must skip) F8 negative mm true-conflict (must skip)
-- Expected engine outcome: writes F1..F5 (5 columns: 3 phone, 1 email, 1 company);
--   F6/F7/F8 excluded -- F6 counted excluded_G_LNK, F7 excluded_G_WIDTH,
--   F8 not eligible (multi_multi true conflict).
-- ============================================================================

START TRANSACTION;

-- F1: one (Phone)
INSERT INTO contactdetails_tbl (contactFullName, userID) VALUES ('ZZWO4FIXTURE F1 one phone', 30);
SET @f1 = LAST_INSERT_ID();
INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valuetext, itemStatus, primary_YN)
VALUES (@f1, 'Phone', 'Business', '(310) 555-0141', 'Active', 'N');

-- F2: multi_one_primary (Email) -- designated primary must win
INSERT INTO contactdetails_tbl (contactFullName, userID) VALUES ('ZZWO4FIXTURE F2 m1p email', 30);
SET @f2 = LAST_INSERT_ID();
INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valuetext, itemStatus, primary_YN)
VALUES (@f2, 'Email', 'Work',     'wo4.f2.primary@example.invalid',   'Active', 'Y'),
       (@f2, 'Email', 'Personal', 'wo4.f2.secondary@example.invalid', 'Active', 'N');

-- F3: rq1_carveout, multi_zero_primary duplicate-normalized (Company)
--     two raw forms, identical under N-C; rep = lowest itemID (raw-representative rule ii)
INSERT INTO contactdetails_tbl (contactFullName, userID) VALUES ('ZZWO4FIXTURE F3 rq1 company', 30);
SET @f3 = LAST_INSERT_ID();
INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valueCompany, itemStatus, primary_YN)
VALUES (@f3, 'Company', 'Company', 'WO4 Fixture Testing Co',     'Active', 'N'),
       (@f3, 'Company', 'Company', 'WO4  Fixture   Testing  Co', 'Active', 'N');

-- F4: rq1_carveout, multi_multi_primary duplicate-normalized (Phone)
--     both primary, same normalized digits, different formatting
INSERT INTO contactdetails_tbl (contactFullName, userID) VALUES ('ZZWO4FIXTURE F4 rq1 phone mm', 30);
SET @f4 = LAST_INSERT_ID();
INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valuetext, itemStatus, primary_YN)
VALUES (@f4, 'Phone', 'Business', '(310) 555-0144', 'Active', 'Y'),
       (@f4, 'Phone', 'Business', '1-310-555-0144', 'Active', 'Y');

-- F5: rq2 Business-over-Fax (Phone) -- Business row must win; fax stays active
INSERT INTO contactdetails_tbl (contactFullName, userID) VALUES ('ZZWO4FIXTURE F5 rq2 biz fax', 30);
SET @f5 = LAST_INSERT_ID();
INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valuetext, itemStatus, primary_YN)
VALUES (@f5, 'Phone', 'Business', '(310) 555-0145', 'Active', 'Y'),
       (@f5, 'Phone', 'Work Fax', '(310) 555-0199', 'Active', 'Y');

-- F6: G-LNK probe -- linked contact (master_co_contact_id=1, established M1 fixture);
--     has a usable item + empty column but MUST be excluded
INSERT INTO contactdetails_tbl (contactFullName, userID, master_co_contact_id)
VALUES ('ZZWO4FIXTURE F6 glnk probe', 30, 1);
SET @f6 = LAST_INSERT_ID();
INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valuetext, itemStatus, primary_YN)
VALUES (@f6, 'Phone', 'Business', '(310) 555-0146', 'Active', 'N');

-- F7: G-WIDTH probe -- single usable Phone item whose TRIM(raw) exceeds varchar(100)
INSERT INTO contactdetails_tbl (contactFullName, userID) VALUES ('ZZWO4FIXTURE F7 gwidth probe', 30);
SET @f7 = LAST_INSERT_ID();
INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valuetext, itemStatus, primary_YN)
VALUES (@f7, 'Phone', 'Business', CONCAT('310-555-0147 ext ', REPEAT('9', 90)), 'Active', 'N');

-- F8: negative multi_multi true conflict -- two DIFFERENT numbers both primary,
--     same type (not the RQ-2 pattern) -> engine must skip entirely
INSERT INTO contactdetails_tbl (contactFullName, userID) VALUES ('ZZWO4FIXTURE F8 mm conflict', 30);
SET @f8 = LAST_INSERT_ID();
INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valuetext, itemStatus, primary_YN)
VALUES (@f8, 'Phone', 'Business', '(310) 555-0148', 'Active', 'Y'),
       (@f8, 'Phone', 'Business', '(310) 555-0177', 'Active', 'Y');

-- Sanity before COMMIT: exactly 8 fixture contacts, 13 fixture items
SELECT
  (SELECT COUNT(*) FROM contactdetails_tbl WHERE userID = 30 AND contactFullName LIKE 'ZZWO4FIXTURE%' AND IsDeleted = 0) AS fixture_contacts_expect_8,
  (SELECT COUNT(*) FROM contactitems_tbl ci JOIN contactdetails_tbl d ON d.contactID = ci.contactID
    WHERE d.userID = 30 AND d.contactFullName LIKE 'ZZWO4FIXTURE%' AND ci.IsDeleted = 0) AS fixture_items_expect_13;

COMMIT;
