-- ========================================
-- Phase 1: Contact Import Upgrade
-- Create contact_import_log table
-- Date: 2025-11-26
-- Purpose: Track import results for better transparency and debugging
-- ========================================

USE new_development; -- Development database
GO

-- Create contact_import_log table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[contact_import_log]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[contact_import_log] (
        [logid] INT IDENTITY(1,1) PRIMARY KEY,
        [uploadid] INT NOT NULL,
        [userid] INT NOT NULL,
        [row_number] INT NULL,
        [import_action] VARCHAR(50) NULL, -- 'created', 'updated', 'skipped', 'error'
        [error_message] VARCHAR(MAX) NULL,
        [contactid] INT NULL,
        [row_data] VARCHAR(MAX) NULL, -- JSON or serialized data of the row for debugging
        [created_at] DATETIME NOT NULL DEFAULT GETDATE(),

        -- Foreign key constraints (assuming tables exist)
        CONSTRAINT [FK_contact_import_log_uploads]
            FOREIGN KEY ([uploadid]) REFERENCES [dbo].[uploads]([uploadid]),
        CONSTRAINT [FK_contact_import_log_taousers]
            FOREIGN KEY ([userid]) REFERENCES [dbo].[taousers]([userid])
    );

    -- Create indexes for common queries
    CREATE INDEX [IX_contact_import_log_uploadid] ON [dbo].[contact_import_log]([uploadid]);
    CREATE INDEX [IX_contact_import_log_userid] ON [dbo].[contact_import_log]([userid]);
    CREATE INDEX [IX_contact_import_log_action] ON [dbo].[contact_import_log]([import_action]);
    CREATE INDEX [IX_contact_import_log_created] ON [dbo].[contact_import_log]([created_at]);

    PRINT 'Table contact_import_log created successfully';
END
ELSE
BEGIN
    PRINT 'Table contact_import_log already exists';
END
GO

-- Add sample comment for documentation
EXEC sys.sp_addextendedproperty
    @name=N'MS_Description',
    @value=N'Logs each row processed during contact import, tracking success, updates, and errors' ,
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'TABLE',
    @level1name=N'contact_import_log';
GO

-- Production deployment instructions:
-- 1. Review this script
-- 2. Change USE new_development to USE abo
-- 3. Execute on production database
-- 4. Verify indexes were created
