-- Add user_name column to error_tickets table
-- Stores the user's full name looked up from taousers at error time
-- Run against: new_development (dev), actorsbusinessoffice (prod)

ALTER TABLE error_tickets
  ADD COLUMN user_name VARCHAR(255) NULL DEFAULT NULL
  AFTER user_id;

-- Rollback:
-- ALTER TABLE error_tickets DROP COLUMN user_name;
