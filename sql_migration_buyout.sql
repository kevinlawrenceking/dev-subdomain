-- ===========================================================================================
-- SQL Migration Script: Add Buyout Field to Auditions Module
-- ===========================================================================================
-- Purpose: Add a buyout field to store buyout terms or fee notes for auditions
-- Author: Kevin King
-- Date: 2025-01-16
-- ===========================================================================================

-- Add buyout field to audprojects table
ALTER TABLE audprojects 
ADD COLUMN buyout VARCHAR(255) NULL 
COMMENT 'Buyout terms or fee notes for the audition project';

-- Update any existing records to have empty buyout field (optional)
UPDATE audprojects 
SET buyout = '' 
WHERE buyout IS NULL;

-- ===========================================================================================
-- Verification Query (run after migration)
-- ===========================================================================================
-- SELECT audprojectid, projname, payrate, buyout FROM audprojects LIMIT 10;
