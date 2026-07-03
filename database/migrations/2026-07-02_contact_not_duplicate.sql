-- =============================================================================
-- "Not a match" dismissals for the Possible-duplicates review list
-- TAO / MySQL (InnoDB)
-- Date: 2026-07-02
--
-- Supports services/ContactDuplicateService.findPossibleDuplicates() /
-- dismissDuplicatePair(). When a user decides two contacts presented as a
-- possible match are NOT the same person, we store the pair here and the
-- review list stops showing it.
--
-- The pair is stored order-independent: contactid_low is always the smaller
-- contactid and contactid_high the larger, so (A,B) and (B,A) collapse to one
-- row and the UNIQUE key makes a repeat dismissal idempotent.
--
-- Safe to run on prod (actorsbusinessoffice) and dev (new_development):
-- CREATE TABLE IF NOT EXISTS only; no changes to existing tables.
-- Rollback: 2026-07-02_contact_not_duplicate_ROLLBACK.sql
-- =============================================================================

CREATE TABLE IF NOT EXISTS contact_not_duplicate (
    id             INT       NOT NULL AUTO_INCREMENT,
    userid         INT       NOT NULL COMMENT 'Owner of both contacts',
    contactid_low  INT       NOT NULL COMMENT 'Smaller of the two contactids',
    contactid_high INT       NOT NULL COMMENT 'Larger of the two contactids',
    created_by     INT       NULL     COMMENT 'userid that dismissed the pair',
    created_at     DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY UQ_not_dupe (userid, contactid_low, contactid_high),
    KEY IX_not_dupe_user (userid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
