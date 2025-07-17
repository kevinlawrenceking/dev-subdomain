-- Add payrate column to audprojects table
-- This field stores the payrate or session fee associated with the project
ALTER TABLE audprojects ADD COLUMN payrate VARCHAR(100);
