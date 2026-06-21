-- Rollback for 2026-06-21_audprojects_projDescription_to_text.sql
-- WARNING: reverting to VARCHAR(500) truncates any projDescription longer than 500 chars.
-- Take a backup of audprojects before running this rollback.

ALTER TABLE audprojects MODIFY COLUMN projDescription VARCHAR(500) NULL;
