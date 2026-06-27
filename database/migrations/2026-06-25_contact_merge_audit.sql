-- =============================================================================
-- Contact merge audit + reversibility tables
-- TAO / MySQL 8 (InnoDB)
-- Date: 2026-06-25
--
-- Supports services/ContactDuplicateService.mergeContacts(). Every merge writes
-- one contact_merge_log row and one contact_merge_map row per child row it
-- repoints / soft-deletes, so a merge can be audited and undone.
--
-- Safe to run on prod (actorsbusinessoffice) and dev (new_development):
-- CREATE TABLE IF NOT EXISTS only; no changes to existing tables; no locks of
-- significance.  Rollback script drops both tables.
-- =============================================================================

CREATE TABLE IF NOT EXISTS contact_merge_log (
    mergeid             INT           NOT NULL AUTO_INCREMENT,
    userid              INT           NOT NULL COMMENT 'Owner of both contacts',
    primary_contactid   INT           NOT NULL COMMENT 'Contact kept',
    duplicate_contactid INT           NOT NULL COMMENT 'Contact soft-deleted',
    merged_by           INT           NULL     COMMENT 'userid that ran the merge',
    merge_timestamp     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status              VARCHAR(20)   NOT NULL DEFAULT 'merged' COMMENT 'merged | undone',
    rows_affected       INT           NOT NULL DEFAULT 0,
    notes               VARCHAR(500)  NULL,
    PRIMARY KEY (mergeid),
    KEY IX_merge_log_user (userid),
    KEY IX_merge_log_dup  (duplicate_contactid),
    KEY IX_merge_log_pri  (primary_contactid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS contact_merge_map (
    mapid           INT          NOT NULL AUTO_INCREMENT,
    mergeid         INT          NOT NULL,
    tbl             VARCHAR(64)  NOT NULL COMMENT 'Base table repointed, e.g. contactitems_tbl',
    pkcol           VARCHAR(64)  NOT NULL COMMENT 'PK column name of that table',
    pkval           INT          NOT NULL COMMENT 'PK value of the repointed/affected row',
    old_contactid   INT          NOT NULL COMMENT 'Value before merge (duplicate)',
    new_contactid   INT          NOT NULL COMMENT 'Value after merge (primary)',
    action          VARCHAR(20)  NOT NULL COMMENT 'repointed | item_deleted | softdeleted | refer_repointed',
    PRIMARY KEY (mapid),
    KEY IX_merge_map_merge (mergeid),
    KEY IX_merge_map_tbl   (tbl, pkval)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
