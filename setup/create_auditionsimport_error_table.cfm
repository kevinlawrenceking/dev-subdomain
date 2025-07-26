<!---
    PURPOSE: Database setup script to create missing auditionsimport_error table
    AUTHOR: Kevin King
    DATE: 2025-07-26
    USAGE: Run this script once to create the missing table
--->

<cftry>
    <cfquery name="createTable">
        CREATE TABLE IF NOT EXISTS `auditionsimport_error` (
            `id` INT(11) NOT NULL,
            `error_msg` VARCHAR(500) NOT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX `idx_id` (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    </cfquery>
    
    <cfoutput>
        <h2>Database Setup Complete</h2>
        <p style="color: green;">✓ auditionsimport_error table created successfully</p>
    </cfoutput>
    
    <cfcatch type="any">
        <cfoutput>
            <h2>Database Setup Error</h2>
            <p style="color: red;">✗ Error creating table: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>
