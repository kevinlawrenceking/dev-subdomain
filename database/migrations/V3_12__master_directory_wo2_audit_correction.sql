-- ============================================================================
-- V3_12  Master Contact Directory -- DIR-LNK-WO-2 (schema/audit support)
--        master_audit_tbl + master_correction_requests_tbl  (BASE TABLES ONLY).
--
-- PROJECT     : TAO / dev-subdomain / branch dev
-- WORK ORDER  : DIR-LNK-WO-2 (schema authoring). Phase 2 authorized by architect.
-- ENGINE      : MySQL 8.0.41. Run `USE <schema>;` first. DEV APPLY ONLY -- prod DDL is WO-12.
-- CHARSET     : utf8mb4 / utf8mb4_unicode_ci -- house convention, verified against
--               contactdetails_tbl (TABLE_COLLATION=utf8mb4_unicode_ci, ROW_FORMAT=Dynamic).
-- NUMBERING   : V3_11 is a BURNED number (WO-1 Part B abandoned; never committed to any git
--               ref, never applied to any DB -- gate0 bundles: "V3_11 abandoned + dropped,
--               git 12c6c4a6/189700e8"). V3_12 is the next safe forward number.
--
-- IDEMPOTENT / REPLAY-SAFE (NN#5): CREATE TABLE IF NOT EXISTS -- re-run is a no-op; no residue.
-- ROLLBACK    : TWO-STAGE. V3_12__..._ROLLBACK.sql = precheck + STOP only (zero DDL).
--               V3_12__..._ROLLBACK_DESTRUCTIVE.sql = the DROP statements (named-auth gated).
-- NO TRIGGERS  (architect ruling: Hostek/DEFINER constraints; audit must be explicit + testable).
-- NO DATA      : this migration inserts zero rows. NO VIEW DDL. NO contactitems changes. NO FKs.
--
-- AUDIT WRITER POLICY (architect ruling):
--   * Normal application and scheduled RUNTIME audit writes must use the service layer.
--   * Approved migration/backfill scripts MAY insert audit rows directly when the insert
--     occurs transactionally with the approved data change (e.g. WO-4 backfill).
--   * No database triggers are permitted.
--
-- GOVERNED action_type VOCABULARY (VARCHAR, not ENUM -- DB does not enforce; runtime services
--   and approved migration/backfill scripts MUST use these constants; extend without schema change):
--     BACKFILL_FROM_CONTACTITEM
--     LINK_CREATED
--     PRELINK_VALUE_PRESERVED
--     MASTER_SNAPSHOT_POPULATED
--     MASTER_AUTO_UPDATE
--     CORRECTION_SUBMITTED
--     CORRECTION_APPROVED
--     CORRECTION_REJECTED
--     BAD_MATCH_REMOVED
--     MASTER_RELINKED
--     PRELINK_VALUE_RESTORED
--     PRIMARY_FIELD_CLEARED_AFTER_UNLINK
--     ADMIN_REPAIR
--
-- GOVERNED actor_type VOCABULARY (VARCHAR): user | admin | system | migration.
--
-- VALUE-COLUMN WIDTHS: value columns are varchar(500) because a master primary source can be
--   an office field co_locations.phone / co_locations.email = varchar(500) (> the primary
--   columns contactPhone/100, contactEmail/150, contactCompany/255 and companies.coName/200).
--   Widened to avoid silently truncating source data captured in audit/correction rows.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) master_audit_tbl -- APPEND-ONLY master-link audit history (spec 16, 9.3, 22).
--    No IsDeleted; no paired view by design; no foreign keys, so audit history can
--    outlive deleted or repaired source records. Nullable reference IDs are historical
--    context, not guaranteed live referents.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS master_audit_tbl (
    auditID               BIGINT        NOT NULL AUTO_INCREMENT,
    contactID             INT           NOT NULL,                          -- user contact (spec 16)
    actor_userid          INT           DEFAULT NULL,                      -- acting user; NULL for system ops
    actor_type            VARCHAR(20)   NOT NULL,                          -- user | admin | system | migration
    master_co_contact_id  INT           DEFAULT NULL,                      -- linked master person
    master_coid           INT           DEFAULT NULL,                      -- master company where relevant
    company_location_id   INT           DEFAULT NULL,                      -- selected office where relevant
    action_type           VARCHAR(40)   NOT NULL,                          -- governed VARCHAR vocab (see header)
    field_name            VARCHAR(40)   DEFAULT NULL,                      -- contactPhone|contactEmail|contactCompany|...
    old_value             VARCHAR(500)  DEFAULT NULL,                      -- widened for co_locations 500 source
    new_value             VARCHAR(500)  DEFAULT NULL,                      -- widened for co_locations 500 source
    previous_source       VARCHAR(10)   DEFAULT NULL,                      -- user | master
    new_source            VARCHAR(10)   DEFAULT NULL,                      -- user | master
    correction_request_id INT           DEFAULT NULL,                      -- -> master_correction_requests_tbl.correctionID (historical)
    run_id                VARCHAR(64)   DEFAULT NULL,                      -- migration / sync / operation run id
    idempotency_key       VARCHAR(191)  DEFAULT NULL,                      -- see UNIQUE below + NULL semantics
    reason                VARCHAR(255)  DEFAULT NULL,                      -- spec 16 "Reason" / source context
    metadata              JSON          DEFAULT NULL,                      -- optional structured meta (reviewer may drop)
    created_at            DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),  -- ms precision for ordering (N-1 guard)
    PRIMARY KEY (auditID),
    KEY IX_master_audit_contact       (contactID),
    KEY IX_master_audit_master_person (master_co_contact_id),
    KEY IX_master_audit_action        (action_type),
    KEY IX_master_audit_created       (created_at),
    KEY IX_master_audit_correction    (correction_request_id),
    KEY IX_master_audit_run           (run_id),
    -- MySQL treats NULL as distinct in a UNIQUE index, so many rows may leave idempotency_key
    -- NULL (inherently-unique per-change events need no dedup). Any retry-guarded write MUST
    -- supply a deterministic non-NULL key, which is then rejected on duplicate. That is the
    -- enforceable idempotency strategy (spec 17).
    UNIQUE KEY UQ_master_audit_idem   (idempotency_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 2) master_correction_requests_tbl -- LIFECYCLE record (NOT append-only): updated during
--    clarification, review, resolution, withdrawal, supersession, and optional application.
--    No IsDeleted; terminal lifecycle is represented by `status`. reviewer_userid,
--    resolution_notes, resolved_timestamp, applied_timestamp, updated_at are mutable
--    lifecycle fields. (spec 8.3 fields, 10.2 statuses, 10.5 duplicate prevention.)
--
--    STATUS vocabulary (VARCHAR; full lifecycle requires no future schema change):
--      PENDING | NEEDS_CLARIFICATION | APPROVED | REJECTED | SUPERSEDED | WITHDRAWN
--    APPLIED is NOT in the default governed set here. `applied_timestamp` is provided so WO-9
--    MAY separate (1) admin approval, (2) master-record mutation, (3) synchronization; if WO-9
--    adopts that separation it may use status 'APPLIED' with no schema change (column is VARCHAR).
--
--    ACTIVE = status IN ('PENDING','NEEDS_CLARIFICATION'). The active-status SET is LOAD-BEARING:
--    changing which statuses count as active requires ALTERing the active_guard generated-column
--    expression below. The guard spans BOTH active states so a duplicate request cannot be
--    submitted while the original awaits clarification.
--
--    BINDING dedup rule (spec 10.5): "Avoid repeated identical active correction requests for the
--    same master contact, field, and normalized suggested value." Enforced by UQ_mcr_active_dedup:
--    the same active normalized suggestion cannot be submitted twice for the same (master, field);
--    a different normalized value is a distinct request; terminal requests never collide because
--    active_guard becomes NULL.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS master_correction_requests_tbl (
    correctionID               INT           NOT NULL AUTO_INCREMENT,
    contactID                  INT           NOT NULL,                     -- requesting user contact
    master_co_contact_id       INT           NOT NULL,                     -- master person (spec 8.3)
    field_name                 VARCHAR(40)   NOT NULL,                     -- contactPhone|contactEmail|contactCompany
    current_master_value       VARCHAR(500)  DEFAULT NULL,                 -- widened for co_locations 500 source
    suggested_value            VARCHAR(500)  NOT NULL,                     -- widened for co_locations 500 source
    normalized_suggested_value VARCHAR(500)  NOT NULL,                     -- shared normalizer (spec 18) -> dedup key
    explanation                VARCHAR(1000) DEFAULT NULL,                 -- optional (spec 8.3)
    requesting_userid          INT           NOT NULL,
    request_timestamp          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status                     VARCHAR(24)   NOT NULL DEFAULT 'PENDING',   -- see status vocabulary above
    reviewer_userid            INT           DEFAULT NULL,                 -- resolver / reviewer
    resolution_notes           VARCHAR(1000) DEFAULT NULL,
    resolved_timestamp         DATETIME      DEFAULT NULL,
    applied_timestamp          DATETIME      DEFAULT NULL,                 -- set iff approval and application separated (WO-9)
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

-- ============================================================================
-- VERIFICATION (run after apply -- read-only)
--   SELECT COUNT(*) FROM information_schema.tables
--     WHERE table_schema=DATABASE() AND table_name IN
--       ('master_audit_tbl','master_correction_requests_tbl');            -- expect 2
--   SHOW CREATE TABLE master_audit_tbl\G
--   SHOW CREATE TABLE master_correction_requests_tbl\G
--   -- confirm active_guard dedup: two PENDING rows with identical
--   -- (master_co_contact_id, field_name, normalized_suggested_value) must fail on the 2nd insert.
-- ============================================================================
