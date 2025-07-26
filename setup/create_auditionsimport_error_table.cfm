<!---
    PURPOSE: Database setup script to create missing auditionsimport_error table
    AUTHOR: Kevin King
    DATE: 2025-07-26
    USAGE: Run this script once to create the missing table
--->

<cftry>
    <!--- First, check if table already exists --->
    <cfquery name="checkTable">
        SHOW TABLES LIKE 'auditionsimport_error'
    </cfquery>
    
    <cfif checkTable.recordcount EQ 0>
        <cfquery name="createTable">
            CREATE TABLE `auditionsimport_error` (
                `id` INT(11) NOT NULL,
                `error_msg` VARCHAR(500) NOT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_id` (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        
        <cfoutput>
            <h2>Database Setup Complete</h2>
            <p style="color: green;">✓ auditionsimport_error table created successfully</p>
            <p>You can now proceed with your audition imports.</p>
        </cfoutput>
    <cfelse>
        <cfoutput>
            <h2>Database Setup</h2>
            <p style="color: blue;">ℹ auditionsimport_error table already exists</p>
            <p>No action needed. You can proceed with your audition imports.</p>
        </cfoutput>
    </cfif>
    
    <cfcatch type="any">
        <cfoutput>
            <h2>Database Setup Error</h2>
            <p style="color: red;">✗ Error: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
            <hr>
            <h3>Manual SQL</h3>
            <p>Please run this SQL manually in your database:</p>
            <pre style="background: #f5f5f5; padding: 10px; border: 1px solid #ccc;">
CREATE TABLE IF NOT EXISTS `auditionsimport_error` (
    `id` INT(11) NOT NULL,
    `error_msg` VARCHAR(500) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            </pre>
        </cfoutput>
    </cfcatch>
</cftry>
