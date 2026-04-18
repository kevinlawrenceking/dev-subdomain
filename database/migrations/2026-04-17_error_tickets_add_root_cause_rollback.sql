ALTER TABLE error_tickets
  DROP INDEX idx_root_cause_type,
  DROP COLUMN cause_chain,
  DROP COLUMN root_cause_line,
  DROP COLUMN root_cause_file,
  DROP COLUMN root_cause_detail,
  DROP COLUMN root_cause_message,
  DROP COLUMN root_cause_type;
