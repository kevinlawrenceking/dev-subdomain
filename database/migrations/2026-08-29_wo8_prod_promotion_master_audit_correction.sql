-- =============================================================================
-- WO-8 PROD PROMOTION -- master_audit_tbl + master_correction_requests_tbl
-- Forward migration.  PROD-SCHEMA-SYNC workstream.
--
-- PROJECT   : TAO / dev-subdomain / branch dev
-- TARGET    : actorsbusinessoffice (PROD).  Run `USE actorsbusinessoffice;` first.
-- ENGINE    : MySQL 8.0.41.
-- AUTHORED  : 2026-08-29.  AUTHORED FOR LINE REVIEW -- DO NOT RUN until reviewed + named-authorized.
-- ROLLBACK  : 2026-08-29_wo8_prod_promotion_master_audit_correction_ROLLBACK.sql
--
-- WHY THIS EXISTS
--   Prod's schema lags dev only in the two DIR-LNK master tables below. A live information_schema
--   diff (2026-08-29, docs/reports/PROD-SCHEMA-DRIFT-2026-08-29.md) proved that the other objects the
--   WO expected to be prod-missing are ALREADY on prod:
--     * contactdetails_tbl._src columns (contactCompany_src / contactEmail_src / contactPhone_src /
--       contactPhoto_src) -- present, enum('user','master') NOT NULL DEFAULT 'user'. (WO-1, 2026-07-08.)
--     * Tier-1 auditions perf indexes idx_aax_project_contact + idx_cd_user_fullname -- present.
--   So SECTION 1 is the only DDL that changes prod. SECTIONS 2/3 are guarded no-ops / opt-in.
--
-- DDL PROVENANCE
--   SECTION 1 is byte-faithful to the reviewed dev DDL of record:
--   database/migrations/V3_12__master_directory_wo2_audit_correction.sql (WO-2), which is itself
--   identical to the live new_development structure verified 2026-08-29 via SHOW CREATE TABLE.
--   No new_development qualifier appears anywhere (no views, no cross-schema refs).
--
-- SAFETY
--   * Both tables are brand-new + empty + have NO foreign keys, so there is no parent/child ordering
--     constraint and no lock taken on any existing prod table. Business-hours safe.
--   * IDEMPOTENT / REPLAY-SAFE: CREATE TABLE IF NOT EXISTS; guarded ADD COLUMN / CREATE INDEX. Re-run
--     is a no-op with no residue.
--   * NO DATA rows inserted. NO triggers (DIR-LNK ruling). NO view DDL. NO changes to existing tables
--     in Section 1.
--
-- GOVERNED VOCABULARIES (VARCHAR, service-enforced -- see V3_12 header for the full lists):
--   action_type: BACKFILL_FROM_CONTACTITEM | LINK_CREATED | PRELINK_VALUE_PRESERVED |
--     MASTER_SNAPSHOT_POPULATED | MASTER_AUTO_UPDATE | CORRECTION_SUBMITTED | CORRECTION_APPROVED |
--     CORRECTION_REJECTED | BAD_MATCH_REMOVED | MASTER_RELINKED | PRELINK_VALUE_RESTORED |
--     PRIMARY_FIELD_CLEARED_AFTER_UNLINK | ADMIN_REPAIR
--   actor_type: user | admin | system | migration
--   correction status: PENDING | NEEDS_CLARIFICATION | APPROVED | REJECTED | SUPERSEDED | WITHDRAWN
-- =============================================================================

-- Guard against running on the wrong schema by accident.
-- (Advisory: the operator must still `USE actorsbusinessoffice;` -- this only documents intent.)
SELECT CONCAT('Applying WO-8 prod promotion to schema: ', DATABASE()) AS target_schema;


-- =============================================================================
-- SECTION 1 -- WO-8 OBJECTS  (THE promotion; the only DDL that changes prod)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1.1) master_audit_tbl -- APPEND-ONLY master-link audit history.
--      No IsDeleted; no paired view; no foreign keys (audit history may outlive deleted/repaired
--      source records). Nullable reference IDs are historical context, not guaranteed live referents.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS master_audit_tbl (
    auditID               BIGINT        NOT NULL AUTO_INCREMENT,
    contactID             INT           NOT NULL,
    actor_userid          INT           DEFAULT NULL,
    actor_type            VARCHAR(20)   NOT NULL,                          -- user | admin | system | migration
    master_co_contact_id  INT           DEFAULT NULL,
    master_coid           INT           DEFAULT NULL,
    company_location_id   INT           DEFAULT NULL,
    action_type           VARCHAR(40)   NOT NULL,                          -- governed VARCHAR vocab (header)
    field_name            VARCHAR(40)   DEFAULT NULL,
    old_value             VARCHAR(500)  DEFAULT NULL,                      -- widened for co_locations 500 source
    new_value             VARCHAR(500)  DEFAULT NULL,
    previous_source       VARCHAR(10)   DEFAULT NULL,                      -- user | master
    new_source            VARCHAR(10)   DEFAULT NULL,
    correction_request_id INT           DEFAULT NULL,                      -- -> master_correction_requests_tbl.correctionID (historical)
    run_id                VARCHAR(64)   DEFAULT NULL,
    idempotency_key       VARCHAR(191)  DEFAULT NULL,                      -- NULL = distinct; retry-guarded writes supply a deterministic key
    reason                VARCHAR(255)  DEFAULT NULL,
    metadata              JSON          DEFAULT NULL,
    created_at            DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),  -- ms precision for ordering
    PRIMARY KEY (auditID),
    KEY IX_master_audit_contact       (contactID),
    KEY IX_master_audit_master_person (master_co_contact_id),
    KEY IX_master_audit_action        (action_type),
    KEY IX_master_audit_created        (created_at),
    KEY IX_master_audit_correction    (correction_request_id),
    KEY IX_master_audit_run           (run_id),
    UNIQUE KEY UQ_master_audit_idem   (idempotency_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 1.2) master_correction_requests_tbl -- LIFECYCLE record (NOT append-only).
--      active_guard is a STORED generated column (1 while active, NULL when terminal); the partial
--      UNIQUE below uses MySQL's NULL-distinct semantics so a duplicate active suggestion is blocked
--      while terminal rows never collide. No IsDeleted; terminal state is `status`.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS master_correction_requests_tbl (
    correctionID               INT           NOT NULL AUTO_INCREMENT,
    contactID                  INT           NOT NULL,
    master_co_contact_id       INT           NOT NULL,
    field_name                 VARCHAR(40)   NOT NULL,
    current_master_value       VARCHAR(500)  DEFAULT NULL,
    suggested_value            VARCHAR(500)  NOT NULL,
    normalized_suggested_value VARCHAR(500)  NOT NULL,                     -- shared normalizer -> dedup key
    explanation                VARCHAR(1000) DEFAULT NULL,
    requesting_userid          INT           NOT NULL,
    request_timestamp          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status                     VARCHAR(24)   NOT NULL DEFAULT 'PENDING',
    reviewer_userid            INT           DEFAULT NULL,
    resolution_notes           VARCHAR(1000) DEFAULT NULL,
    resolved_timestamp         DATETIME      DEFAULT NULL,
    applied_timestamp          DATETIME      DEFAULT NULL,
    updated_at                 DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active_guard               TINYINT       GENERATED ALWAYS AS (
                                                 CASE
                                                     WHEN status IN ('PENDING', 'NEEDS_CLARIFICATION') THEN 1
                                                     ELSE NULL
                                                 END
                                             ) STORED,
    PRIMARY KEY (correctionID),
    KEY IX_mcr_master_field (master_co_contact_id, field_name),
    KEY IX_mcr_status       (status),
    KEY IX_mcr_contact      (contactID),
    KEY IX_mcr_requester    (requesting_userid),
    UNIQUE KEY UQ_mcr_active_dedup (master_co_contact_id, field_name, normalized_suggested_value, active_guard)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- SECTION 2 -- ALREADY-PRESENT VERIFICATION (guarded no-ops on prod as of 2026-08-29)
--   These objects already exist on prod; the guards make this block a documented no-op. It exists so
--   the whole file is safe to run end-to-end and so a future rebuild-from-scratch stays complete.
--   If any guard here actually fires (creates something), prod had drifted BACKWARD -- investigate.
-- =============================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS _wo8_AddColumnIfNotExists //
CREATE PROCEDURE _wo8_AddColumnIfNotExists(IN p_table VARCHAR(64), IN p_col VARCHAR(64), IN p_def TEXT)
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND COLUMN_NAME = p_col;
    IF v = 0 THEN
        SET @s = CONCAT('ALTER TABLE ', p_table, ' ADD COLUMN ', p_col, ' ', p_def);
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
        SELECT CONCAT('CREATED COLUMN (prod had drifted back!): ', p_table, '.', p_col) AS result;
    ELSE
        SELECT CONCAT('OK present: ', p_table, '.', p_col) AS result;
    END IF;
END //

DROP PROCEDURE IF EXISTS _wo8_AddIndexIfNotExists //
CREATE PROCEDURE _wo8_AddIndexIfNotExists(IN p_table VARCHAR(64), IN p_index VARCHAR(64), IN p_def TEXT)
BEGIN
    DECLARE v INT DEFAULT 0;
    SELECT COUNT(*) INTO v FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND INDEX_NAME = p_index;
    IF v = 0 THEN
        SET @s = CONCAT('CREATE INDEX ', p_index, ' ON ', p_table, ' ', p_def);
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
        SELECT CONCAT('CREATED INDEX: ', p_index, ' on ', p_table) AS result;
    ELSE
        SELECT CONCAT('OK present: ', p_index, ' on ', p_table) AS result;
    END IF;
END //

DELIMITER ;

-- 2.1) contactdetails_tbl._src columns (expected: all four already present on prod).
CALL _wo8_AddColumnIfNotExists('contactdetails_tbl', 'contactPhone_src',   "ENUM('user','master') NOT NULL DEFAULT 'user'");
CALL _wo8_AddColumnIfNotExists('contactdetails_tbl', 'contactEmail_src',   "ENUM('user','master') NOT NULL DEFAULT 'user'");
CALL _wo8_AddColumnIfNotExists('contactdetails_tbl', 'contactCompany_src', "ENUM('user','master') NOT NULL DEFAULT 'user'");
CALL _wo8_AddColumnIfNotExists('contactdetails_tbl', 'contactPhoto_src',   "ENUM('user','master') NOT NULL DEFAULT 'user'");

-- 2.2) Tier-1 auditions perf indexes (expected: both already present on prod).
CALL _wo8_AddIndexIfNotExists('audcontacts_auditions_xref', 'idx_aax_project_contact',
    '(audprojectid, contactid) ALGORITHM=INPLACE LOCK=NONE');
CALL _wo8_AddIndexIfNotExists('contactdetails_tbl', 'idx_cd_user_fullname',
    '(userID, contactFullName) ALGORITHM=INPLACE LOCK=NONE');


-- =============================================================================
-- SECTION 3 -- OPTIONAL other perf indexes (NOT a WO-8 dependency)
--   COMMENTED OUT by default. These are dev-only perf indexes genuinely absent on prod. They are
--   additive and safe, but they belong to a perf-tuning review, not this WO. Do NOT enable without
--   per-index EXPLAIN justification on prod. Redundant dev-only indexes are deliberately EXCLUDED
--   (idx_audcontacts_xref_contactid duplicates idx_audcontacts_auditions_xref; idx_audroles_project_deleted
--   duplicates idx_ar_project_deleted).
-- =============================================================================
-- CALL _wo8_AddIndexIfNotExists('audprojects', 'idx_audprojects_deleted_date', '(isDeleted, projDate) ALGORITHM=INPLACE LOCK=NONE');
-- CALL _wo8_AddIndexIfNotExists('events_tbl', 'idx_events_id_start', '(eventID, eventStart, eventTypeName) ALGORITHM=INPLACE LOCK=NONE');
-- CALL _wo8_AddIndexIfNotExists('contactitems_tbl', 'idx_contactitems_lookup', '(contactID, valueCategory, itemStatus) ALGORITHM=INPLACE LOCK=NONE');
-- CALL _wo8_AddIndexIfNotExists('eventcontactsxref_tbl', 'idx_eventcontactsxref_contact', '(contactID, eventID) ALGORITHM=INPLACE LOCK=NONE');
-- (contactdetails_tbl / noteslog_tbl / tickets_tbl composites: see the drift report; evaluate individually.)


-- Clean up helper procedures (do not persist as schema drift).
DROP PROCEDURE IF EXISTS _wo8_AddColumnIfNotExists;
DROP PROCEDURE IF EXISTS _wo8_AddIndexIfNotExists;

SELECT 'WO-8 prod promotion forward migration complete' AS status;

-- =============================================================================
-- VERIFICATION (read-only, run after apply)
--   SELECT COUNT(*) FROM information_schema.tables
--     WHERE table_schema = DATABASE()
--       AND table_name IN ('master_audit_tbl','master_correction_requests_tbl');   -- expect 2
--   SHOW CREATE TABLE master_audit_tbl\G
--   SHOW CREATE TABLE master_correction_requests_tbl\G
--   -- active_guard dedup: two PENDING rows with identical
--   -- (master_co_contact_id, field_name, normalized_suggested_value) -> 2nd insert must fail.
-- =============================================================================
