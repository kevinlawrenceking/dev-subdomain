-- TAO-SPEC-2026-005 Phase 2: root-cause capture columns on error_tickets
-- Additive. All columns nullable with NULL default — backward compatible
-- with all existing ErrorService writes.
-- Run against: new_development (dev), then actorsbusinessoffice (prod)

ALTER TABLE error_tickets
  ADD COLUMN root_cause_type     VARCHAR(255) NULL DEFAULT NULL  AFTER error_detail,
  ADD COLUMN root_cause_message  TEXT         NULL DEFAULT NULL  AFTER root_cause_type,
  ADD COLUMN root_cause_detail   TEXT         NULL DEFAULT NULL  AFTER root_cause_message,
  ADD COLUMN root_cause_file     VARCHAR(500) NULL DEFAULT NULL  AFTER root_cause_detail,
  ADD COLUMN root_cause_line     INT          NULL DEFAULT NULL  AFTER root_cause_file,
  ADD COLUMN cause_chain         MEDIUMTEXT   NULL DEFAULT NULL  AFTER root_cause_line;

ALTER TABLE error_tickets
  ADD INDEX idx_root_cause_type (root_cause_type);
