-- =============================================================================
-- admin_enums: Registry table for the Admin Enum Dashboard
-- Purpose: Single source of truth that tells the admin dashboard which lookup
--          tables to render as panels and how to query them.
-- Created: 2026-04-02
-- Spec:    docs/specs/admin-enum-dashboard.md
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. CREATE TABLE
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS admin_enums (
    enum_id         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    enum_group      VARCHAR(20)     NOT NULL COMMENT 'audition | relationship',
    display_name    VARCHAR(100)    NOT NULL COMMENT 'Human label shown in panel header',
    table_name      VARCHAR(64)     NOT NULL COMMENT 'Actual MySQL table name',
    pk_column       VARCHAR(64)     NOT NULL COMMENT 'Primary key column in target table',
    pk_type         VARCHAR(10)     NOT NULL DEFAULT 'integer' COMMENT 'integer | varchar — cfqueryparam type for PK',
    name_column     VARCHAR(64)     NOT NULL COMMENT 'Display-name column in target table',
    parent_table    VARCHAR(64)     NULL     DEFAULT NULL COMMENT 'FK parent table (NULL if no parent)',
    parent_pk       VARCHAR(64)     NULL     DEFAULT NULL COMMENT 'PK column of parent table',
    parent_name_col VARCHAR(64)     NULL     DEFAULT NULL COMMENT 'Display-name column of parent table',
    fk_column       VARCHAR(64)     NULL     DEFAULT NULL COMMENT 'FK column in THIS table pointing to parent',
    fk_type         VARCHAR(10)     NULL     DEFAULT NULL COMMENT 'integer | varchar — cfqueryparam type for FK value',
    parent_label    VARCHAR(50)     NULL     DEFAULT NULL COMMENT 'UI label for parent dropdown (e.g. Category, System Type). NULL = generic Parent',
    has_soft_delete TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '1 = table has isDeleted column; filter on it',
    is_read_only    TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '1 = show in dashboard but disable add/edit/delete',
    sort_order      SMALLINT        NOT NULL DEFAULT 0 COMMENT 'Panel display order within enum_group',
    is_active       TINYINT(1)      NOT NULL DEFAULT 1 COMMENT '0 = hide panel from dashboard',
    created_at      DATETIME        NOT NULL DEFAULT NOW(),
    PRIMARY KEY (enum_id),
    UNIQUE KEY uq_admin_enums_table (table_name),
    KEY ix_admin_enums_group (enum_group, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. SEED DATA - AUDITION GROUP
--
-- Column names verified against service CFC INSERT/UPDATE/SELECT statements:
--   services/AuditionAgeRangeService.cfc       -> rangeid, rangename, isDeleted
--   services/AuditionBookTypeService.cfc        -> audbooktypeid, audbooktype, isDeleted
--   services/AuditionCallbackTypeService.cfc    -> callbacktypeid, callbacktype (+ audstepid, audcatid)
--   services/AuditionCategoryService.cfc        -> audcatid, audcatname, isDeleted
--   services/AuditionContractTypeService.cfc    -> contracttypeid, contracttype, audCatid, isDeleted
--   services/AuditionDialectService.cfc         -> auddialectid, auddialect, audcatid, isDeleted
--   services/AuditionGenreService.cfc           -> audgenreid, audgenre, audCatid, isDeleted
--   services/AuditionMediaTypeService.cfc       -> mediatypeid, mediatype, isDeleted
--   services/AuditionNetworkService.cfc         -> networkid, network, audcatid, isDeleted
--   services/AuditionPayCycleService.cfc        -> paycycleid, paycycle, (no isDeleted in INS/UPD)
--   services/AuditionPlatformsService.cfc       -> audplatformid, audplatform, isDeleted
--   services/AuditionQuestionTypeService.cfc    -> qtypeid, qtype, isDeleted
--   services/AuditionRoleTypeService.cfc        -> audroletypeid, audroletype, audCatid, isDeleted
--   services/AuditionSourceService.cfc          -> audsourceid, audsource, isDeleted
--   services/AuditionStepService.cfc            -> audstepid, audstep, isDeleted
--   services/AuditionSubcategorieService.cfc    -> audsubcatid, audsubcatname, audcatid, isDeleted
--   services/AuditionTonesService.cfc           -> toneid, tone, audCatid, isDeleted
--   services/AuditionTypeService.cfc            -> audtypeid, audtype, audCatid, isDeleted
--   services/AuditionUnionService.cfc           -> unionid, unionname, audcatid, isDeleted
--   services/AuditionVocalTypeService.cfc       -> vocaltypeid, vocaltype, isDeleted
--
-- EXCLUDED from admin enums:
--   audlocations  - per-user table (INSERT requires userid FK), not a global enum
--   *_user tables - per-user preference copies, not master admin enums
--   *_xref tables - junction tables managed at the audition/role level
-- -----------------------------------------------------------------------------

-- Simple audition enums (no parent FK, integer PKs, read-write)
INSERT INTO admin_enums
    (enum_group, display_name, table_name, pk_column, pk_type, name_column,
     has_soft_delete, is_read_only, sort_order)
VALUES
    ('audition', 'Categories',      'audcategories',    'audcatid',       'integer', 'audcatname',   1, 0, 10),
    ('audition', 'Age Ranges',      'audageranges',     'rangeid',        'integer', 'rangename',    1, 0, 30),
    ('audition', 'Booking Types',   'audbooktypes',     'audbooktypeid',  'integer', 'audbooktype',  1, 0, 40),
    ('audition', 'Media Types',     'audmediatypes',    'mediatypeid',    'integer', 'mediatype',    1, 0, 80),
    ('audition', 'Pay Cycles',      'audpaycycles',     'paycycleid',     'integer', 'paycycle',     0, 0, 100),
    ('audition', 'Platforms',       'audplatforms',     'audplatformid',  'integer', 'audplatform',  1, 0, 110),
    ('audition', 'Question Types',  'audqtypes',        'qtypeid',        'integer', 'qtype',        1, 0, 120),
    ('audition', 'Sources',         'audsources',       'audsourceid',    'integer', 'audsource',    1, 0, 140),
    ('audition', 'Steps',           'audsteps',         'audstepid',      'integer', 'audstep',      1, 0, 150),
    ('audition', 'Vocal Types',     'audvocaltypes',    'vocaltypeid',    'integer', 'vocaltype',    1, 0, 190);

-- Audition enums with category FK -> audcategories (integer PK, integer FK)
-- NOTE: audcatid on these tables is a category classifier, not a hierarchical parent.
--       The UI should label the dropdown "Category" not "Parent".
--       Verified: all 10 tables below reference audcatid in their service CFC
--       INSERT/UPDATE/SELECT statements.
INSERT INTO admin_enums
    (enum_group, display_name, table_name, pk_column, pk_type, name_column,
     parent_table, parent_pk, parent_name_col, fk_column, fk_type, parent_label,
     has_soft_delete, is_read_only, sort_order)
VALUES
    ('audition', 'Subcategories',   'audsubcategories', 'audsubcatid',    'integer', 'audsubcatname',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 20),

    ('audition', 'Callback Types',  'audcallbacktypes', 'callbacktypeid', 'integer', 'callbacktype',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     0, 0, 50),

    ('audition', 'Contract Types',  'audcontracttypes', 'contracttypeid', 'integer', 'contracttype',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 60),

    ('audition', 'Dialects',        'auddialects',      'auddialectid',  'integer', 'auddialect',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 70),

    ('audition', 'Genres',          'audgenres',         'audgenreid',    'integer', 'audgenre',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 75),

    ('audition', 'Networks',        'audnetworks',       'networkid',     'integer', 'network',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 90),

    ('audition', 'Role Types',      'audroletypes',      'audroletypeid', 'integer', 'audroletype',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 130),

    ('audition', 'Tones',           'audtones',          'toneid',        'integer', 'tone',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 160),

    ('audition', 'Types',           'audtypes',          'audtypeid',     'integer', 'audtype',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 170),

    ('audition', 'Unions',          'audunions',         'unionid',       'integer', 'unionname',
     'audcategories', 'audcatid', 'audcatname', 'audcatid', 'integer', 'Category',
     1, 0, 180);


-- -----------------------------------------------------------------------------
-- 3. SEED DATA - RELATIONSHIP GROUP
--
-- Column names verified against service CFC SELECT/INSERT statements:
--   services/FUSystemTypeService.cfc  -> systemtype (VARCHAR PK = display name)
--   services/SystemService.cfc        -> fusystems: systemid, systemname, systemtype, systemscope
--   services/SystemService.cfc        -> fuactions: actionid, actiontitle, systemid, actionno,
--                                        actiondaysno, actiondaysrecurring, isunique, uniquename,
--                                        actiondetails, actionnotes, actioninfo, navtourl
--
-- NOTE: fusystemtypes uses a VARCHAR PK (systemtype), not a numeric auto-increment.
--       pk_type = 'varchar' tells AdminEnumService to use CF_SQL_VARCHAR for PK params.
--       Editing a value would change the PK and break all FK references in fusystems,
--       so this table is marked is_read_only = 1.
--
-- NOTE: fuactions has many columns beyond name (actionno, actiondaysno,
--       actiondaysrecurring, isunique, uniquename, actiondetails, etc.).
--       An INSERT with only actiontitle would create broken rows missing required
--       scheduling data. An UPDATE of only actiontitle is safe but misleading.
--       Marked is_read_only = 1 so admins can view but not corrupt data.
--       If full editing is needed later, handle as a special-case panel in Phase 4.
--
-- NOTE: None of these three tables have an isDeleted column.
--       Soft deletes are handled at the per-user level (actionusers.isdeleted,
--       fusystemusers.isdeleted) not on the master definition tables.
-- -----------------------------------------------------------------------------

-- fusystemtypes: VARCHAR PK, no parent, READ-ONLY
-- PK is the display name; editing would break fusystems.systemtype FK references.
INSERT INTO admin_enums
    (enum_group, display_name, table_name, pk_column, pk_type, name_column,
     has_soft_delete, is_read_only, sort_order)
VALUES
    ('relationship', 'System Types', 'fusystemtypes', 'systemtype', 'varchar', 'systemtype',
     0, 1, 10);

-- fusystems: integer PK, VARCHAR FK -> fusystemtypes, read-write
INSERT INTO admin_enums
    (enum_group, display_name, table_name, pk_column, pk_type, name_column,
     parent_table, parent_pk, parent_name_col, fk_column, fk_type, parent_label,
     has_soft_delete, is_read_only, sort_order)
VALUES
    ('relationship', 'Systems', 'fusystems', 'systemid', 'integer', 'systemname',
     'fusystemtypes', 'systemtype', 'systemtype', 'systemtype', 'varchar', 'System Type',
     0, 0, 20);

-- fuactions: integer PK, integer FK -> fusystems, READ-ONLY
-- Has many required columns beyond name (actionno, actiondaysno, etc.).
-- Generic add/edit would create broken rows. View-only reference panel.
INSERT INTO admin_enums
    (enum_group, display_name, table_name, pk_column, pk_type, name_column,
     parent_table, parent_pk, parent_name_col, fk_column, fk_type, parent_label,
     has_soft_delete, is_read_only, sort_order)
VALUES
    ('relationship', 'Actions', 'fuactions', 'actionid', 'integer', 'actiontitle',
     'fusystems', 'systemid', 'systemname', 'systemid', 'integer', 'System',
     0, 1, 30);
