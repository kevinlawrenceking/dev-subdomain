<cfsilent>
<!--- Migration Runner for Contact Import V3 (V3_0) --->
<!--- Usage: /database/run-v3-migration.cfm?run=yes --->
<!--- Rollback: /database/run-v3-migration.cfm?run=yes&rollback=yes --->
</cfsilent>
<cfset response = {success: false, step: "", message: "", results: [], tables_affected: []}>
<cftry>
<cfif not structKeyExists(url, "run") or url.run neq "yes">
    <cfset response.message = "Add ?run=yes to execute V3 migration. Add &rollback=yes to rollback.">
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<!--- Use application datasource --->
<cfset schema = application.information_schema>
<cfset isRollback = structKeyExists(url, "rollback") and url.rollback eq "yes">

<cfif isRollback>
    <!--- ============================================================
         ROLLBACK MODE: Drop all V3 tables
         ============================================================ --->
    <cfset response.step = "V3_0 ROLLBACK: Starting">

    <!--- Drop tables in safe order --->
    <cfset tablesToDrop = [
        "import_v3_row_results",
        "import_v3_facts",
        "import_v3_events",
        "import_v3_rows",
        "import_v3_columns",
        "import_v3_jobs",
        "contact_custom_fields"
    ]>

    <cfloop array="#tablesToDrop#" index="tableName">
        <cfset response.step = "V3_0 ROLLBACK: Dropping #tableName#">
        <cfquery name="qCheck">
            SELECT COUNT(*) AS cnt FROM information_schema.tables
            WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
              AND table_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tableName#">
        </cfquery>

        <cfif qCheck.cnt gt 0>
            <cfquery>DROP TABLE IF EXISTS #schema#.#tableName#</cfquery>
            <cfset arrayAppend(response.results, "Dropped table: #tableName#")>
            <cfset arrayAppend(response.tables_affected, tableName)>
        <cfelse>
            <cfset arrayAppend(response.results, "Table not found (skip): #tableName#")>
        </cfif>
    </cfloop>

    <cfset response.success = true>
    <cfset response.message = "V3 ROLLBACK completed. Dropped #arrayLen(response.tables_affected)# tables.">

<cfelse>
    <!--- ============================================================
         MIGRATION MODE: Create V3 tables
         ============================================================ --->

    <!--- Table 1: import_v3_jobs --->
    <cfset response.step = "V3_0: Check import_v3_jobs table">
    <cfquery name="qCheck">
        SELECT COUNT(*) AS cnt FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
          AND table_name = 'import_v3_jobs'
    </cfquery>

    <cfif qCheck.cnt eq 0>
        <cfset response.step = "V3_0: Create import_v3_jobs table">
        <cfquery>
            CREATE TABLE #schema#.import_v3_jobs (
                job_id INT AUTO_INCREMENT PRIMARY KEY,
                userid INT NOT NULL COMMENT 'Owner FK to taousers.userid',
                source_filename VARCHAR(255) NOT NULL,
                file_type VARCHAR(10) NOT NULL COMMENT 'csv, xls, xlsx, vcf',
                file_size BIGINT DEFAULT NULL,
                file_hash VARCHAR(64) DEFAULT NULL COMMENT 'SHA-256 for idempotency',
                stored_file_path VARCHAR(500) DEFAULT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending|parsing|parsed|mapping|validating|reviewing|importing|completed|failed|cancelled',
                error_message TEXT DEFAULT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                started_at DATETIME DEFAULT NULL,
                finished_at DATETIME DEFAULT NULL,
                total_rows INT DEFAULT 0,
                parsed_rows INT DEFAULT 0,
                valid_rows INT DEFAULT 0,
                problem_rows INT DEFAULT 0,
                dupe_rows INT DEFAULT 0,
                imported_rows INT DEFAULT 0,
                updated_rows INT DEFAULT 0 COMMENT 'New in V3: track updates separately',
                skipped_rows INT DEFAULT 0,
                options_json TEXT DEFAULT NULL COMMENT 'Parsing and import options',
                import_mode VARCHAR(20) DEFAULT 'create_only' COMMENT 'create_only|update_existing|create_and_update',
                allow_blank_overwrite TINYINT(1) DEFAULT 0 COMMENT 'If 1, blanks can clear existing values',
                relationship_system_default VARCHAR(50) DEFAULT NULL COMMENT 'Default system for new contacts',
                folder_assignment_json TEXT DEFAULT NULL COMMENT 'Folder assignment rules',
                INDEX IX_import_v3_jobs_userid_status (userid, status),
                INDEX IX_import_v3_jobs_created (created_at DESC),
                INDEX IX_import_v3_jobs_status (status),
                UNIQUE INDEX UX_import_v3_jobs_userid_file_hash (userid, file_hash)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_v3_jobs table")>
        <cfset arrayAppend(response.tables_affected, "import_v3_jobs")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_v3_jobs table exists")>
    </cfif>

    <!--- Table 2: import_v3_columns --->
    <cfset response.step = "V3_0: Check import_v3_columns table">
    <cfquery name="qCheck">
        SELECT COUNT(*) AS cnt FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
          AND table_name = 'import_v3_columns'
    </cfquery>

    <cfif qCheck.cnt eq 0>
        <cfset response.step = "V3_0: Create import_v3_columns table">
        <cfquery>
            CREATE TABLE #schema#.import_v3_columns (
                column_id INT AUTO_INCREMENT PRIMARY KEY,
                job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',
                source_column_index INT NOT NULL COMMENT '0-based index from file',
                source_column_name VARCHAR(255) DEFAULT NULL COMMENT 'Header text from file',
                mapped_field VARCHAR(50) DEFAULT NULL COMMENT 'TAO canonical field name or custom_field key',
                is_custom_field TINYINT(1) DEFAULT 0 COMMENT '1 if maps to contact_custom_fields',
                custom_field_id INT DEFAULT NULL COMMENT 'FK to contact_custom_fields.field_id if custom',
                confidence DECIMAL(3,2) DEFAULT NULL COMMENT 'Auto-map confidence 0.00-1.00',
                user_confirmed TINYINT(1) DEFAULT 0 COMMENT '1 if user approved mapping',
                sample_values TEXT DEFAULT NULL COMMENT 'JSON array of sample values',
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX IX_import_v3_columns_job (job_id),
                UNIQUE INDEX UX_import_v3_columns_job_index (job_id, source_column_index)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_v3_columns table")>
        <cfset arrayAppend(response.tables_affected, "import_v3_columns")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_v3_columns table exists")>
    </cfif>

    <!--- Table 3: import_v3_rows --->
    <cfset response.step = "V3_0: Check import_v3_rows table">
    <cfquery name="qCheck">
        SELECT COUNT(*) AS cnt FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
          AND table_name = 'import_v3_rows'
    </cfquery>

    <cfif qCheck.cnt eq 0>
        <cfset response.step = "V3_0: Create import_v3_rows table">
        <cfquery>
            CREATE TABLE #schema#.import_v3_rows (
                row_id INT AUTO_INCREMENT PRIMARY KEY,
                job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',
                row_num INT NOT NULL COMMENT '1-based row number from file',
                raw_json TEXT NOT NULL COMMENT 'Original cell values by column index',
                status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending|validating|ready|problem|dupe|ignored|importing|imported|updated|failed',
                error_count INT DEFAULT 0,
                warning_count INT DEFAULT 0,
                validation_summary TEXT DEFAULT NULL COMMENT 'JSON summary of validation issues',
                dupe_candidates_json TEXT DEFAULT NULL COMMENT 'JSON array of candidate contacts',
                matched_contactid INT DEFAULT NULL COMMENT 'Best match contact ID',
                best_match_score INT DEFAULT NULL COMMENT 'Match confidence 0-100',
                user_action VARCHAR(20) DEFAULT NULL COMMENT 'import_new|skip|update_existing|merge',
                user_action_at DATETIME DEFAULT NULL,
                created_contactid INT DEFAULT NULL COMMENT 'New contact ID if created',
                updated_contactid INT DEFAULT NULL COMMENT 'Existing contact ID if updated',
                import_error TEXT DEFAULT NULL COMMENT 'Error message if failed',
                imported_at DATETIME DEFAULT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX IX_import_v3_rows_job_status (job_id, status),
                INDEX IX_import_v3_rows_job_rownum (job_id, row_num),
                INDEX IX_import_v3_rows_status (status),
                INDEX IX_import_v3_rows_matched (matched_contactid),
                UNIQUE INDEX UX_import_v3_rows_job_rownum (job_id, row_num)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_v3_rows table")>
        <cfset arrayAppend(response.tables_affected, "import_v3_rows")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_v3_rows table exists")>
    </cfif>

    <!--- Table 4: import_v3_facts --->
    <cfset response.step = "V3_0: Check import_v3_facts table">
    <cfquery name="qCheck">
        SELECT COUNT(*) AS cnt FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
          AND table_name = 'import_v3_facts'
    </cfquery>

    <cfif qCheck.cnt eq 0>
        <cfset response.step = "V3_0: Create import_v3_facts table">
        <cfquery>
            CREATE TABLE #schema#.import_v3_facts (
                fact_id INT AUTO_INCREMENT PRIMARY KEY,
                row_id INT NOT NULL COMMENT 'FK to import_v3_rows.row_id',
                column_id INT NOT NULL COMMENT 'FK to import_v3_columns.column_id',
                field_name VARCHAR(50) NOT NULL COMMENT 'Canonical field name (e.g., email_business)',
                raw_value TEXT DEFAULT NULL COMMENT 'Original value from file',
                normalized_value TEXT DEFAULT NULL COMMENT 'Cleaned/normalized value',
                is_valid TINYINT(1) DEFAULT 1,
                validation_code VARCHAR(30) DEFAULT NULL COMMENT 'error code if invalid',
                validation_message VARCHAR(255) DEFAULT NULL COMMENT 'human-readable error',
                existing_value TEXT DEFAULT NULL COMMENT 'Current value in contact (for updates)',
                has_conflict TINYINT(1) DEFAULT 0 COMMENT '1 if normalized != existing and both non-empty',
                user_choice VARCHAR(20) DEFAULT NULL COMMENT 'keep_existing|use_import|clear',
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX IX_import_v3_facts_row (row_id),
                INDEX IX_import_v3_facts_field (field_name),
                INDEX IX_import_v3_facts_validation (is_valid, validation_code),
                UNIQUE INDEX UX_import_v3_facts_row_column (row_id, column_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_v3_facts table")>
        <cfset arrayAppend(response.tables_affected, "import_v3_facts")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_v3_facts table exists")>
    </cfif>

    <!--- Table 5: import_v3_row_results --->
    <cfset response.step = "V3_0: Check import_v3_row_results table">
    <cfquery name="qCheck">
        SELECT COUNT(*) AS cnt FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
          AND table_name = 'import_v3_row_results'
    </cfquery>

    <cfif qCheck.cnt eq 0>
        <cfset response.step = "V3_0: Create import_v3_row_results table">
        <cfquery>
            CREATE TABLE #schema#.import_v3_row_results (
                result_id INT AUTO_INCREMENT PRIMARY KEY,
                row_id INT NOT NULL COMMENT 'FK to import_v3_rows.row_id',
                job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id (denormalized for queries)',
                action_taken VARCHAR(20) NOT NULL COMMENT 'created|updated|skipped|failed',
                contactid INT DEFAULT NULL COMMENT 'Affected contact ID',
                fields_written INT DEFAULT 0 COMMENT 'Count of fields written',
                fields_skipped INT DEFAULT 0 COMMENT 'Count of fields skipped (blank/conflict)',
                items_created INT DEFAULT 0 COMMENT 'Count of contactitems created',
                notes_created INT DEFAULT 0 COMMENT 'Count of notes created',
                error_code VARCHAR(30) DEFAULT NULL,
                error_message TEXT DEFAULT NULL,
                undo_available TINYINT(1) DEFAULT 1,
                undo_json TEXT DEFAULT NULL COMMENT 'Data needed to reverse this import row',
                undone_at DATETIME DEFAULT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX IX_import_v3_row_results_job (job_id),
                INDEX IX_import_v3_row_results_action (action_taken),
                INDEX IX_import_v3_row_results_contact (contactid),
                UNIQUE INDEX UX_import_v3_row_results_row (row_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_v3_row_results table")>
        <cfset arrayAppend(response.tables_affected, "import_v3_row_results")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_v3_row_results table exists")>
    </cfif>

    <!--- Table 6: import_v3_events --->
    <cfset response.step = "V3_0: Check import_v3_events table">
    <cfquery name="qCheck">
        SELECT COUNT(*) AS cnt FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
          AND table_name = 'import_v3_events'
    </cfquery>

    <cfif qCheck.cnt eq 0>
        <cfset response.step = "V3_0: Create import_v3_events table">
        <cfquery>
            CREATE TABLE #schema#.import_v3_events (
                event_id INT AUTO_INCREMENT PRIMARY KEY,
                job_id INT NOT NULL COMMENT 'FK to import_v3_jobs.job_id',
                event_type VARCHAR(50) NOT NULL COMMENT 'created|parsing_started|parsing_completed|...',
                event_detail TEXT DEFAULT NULL COMMENT 'JSON details',
                row_id INT DEFAULT NULL COMMENT 'FK to import_v3_rows if row-specific',
                userid INT DEFAULT NULL COMMENT 'User who triggered event (for future multi-user)',
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX IX_import_v3_events_job (job_id),
                INDEX IX_import_v3_events_type (event_type),
                INDEX IX_import_v3_events_created (created_at DESC),
                INDEX IX_import_v3_events_row (row_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_v3_events table")>
        <cfset arrayAppend(response.tables_affected, "import_v3_events")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_v3_events table exists")>
    </cfif>

    <!--- Table 7: contact_custom_fields --->
    <cfset response.step = "V3_0: Check contact_custom_fields table">
    <cfquery name="qCheck">
        SELECT COUNT(*) AS cnt FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
          AND table_name = 'contact_custom_fields'
    </cfquery>

    <cfif qCheck.cnt eq 0>
        <cfset response.step = "V3_0: Create contact_custom_fields table">
        <cfquery>
            CREATE TABLE #schema#.contact_custom_fields (
                field_id INT AUTO_INCREMENT PRIMARY KEY,
                userid INT NOT NULL COMMENT 'Owner FK to taousers.userid',
                field_key VARCHAR(50) NOT NULL COMMENT 'Internal key (e.g., custom_assistant_name)',
                field_label VARCHAR(100) NOT NULL COMMENT 'Display label',
                field_type VARCHAR(20) NOT NULL DEFAULT 'text' COMMENT 'text|email|phone|date|url|select',
                options_json TEXT DEFAULT NULL COMMENT 'JSON array of options for select type',
                is_required TINYINT(1) DEFAULT 0,
                max_length INT DEFAULT NULL,
                validation_regex VARCHAR(255) DEFAULT NULL,
                sort_order INT DEFAULT 0,
                is_active TINYINT(1) DEFAULT 1,
                show_in_list TINYINT(1) DEFAULT 0 COMMENT 'Show in contact list view',
                show_in_card TINYINT(1) DEFAULT 1 COMMENT 'Show in contact card view',
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX IX_contact_custom_fields_userid (userid),
                INDEX IX_contact_custom_fields_active (userid, is_active),
                UNIQUE INDEX UX_contact_custom_fields_userid_key (userid, field_key)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created contact_custom_fields table")>
        <cfset arrayAppend(response.tables_affected, "contact_custom_fields")>
    <cfelse>
        <cfset arrayAppend(response.results, "contact_custom_fields table exists")>
    </cfif>

    <cfset response.success = true>
    <cfset response.message = "V3 migration completed. Created #arrayLen(response.tables_affected)# tables.">
</cfif>

<cfcatch type="any">
    <cfset response.message = "Error at step [" & response.step & "]: " & cfcatch.message>
    <cfif len(cfcatch.detail)>
        <cfset response.message = response.message & " | Detail: " & cfcatch.detail>
    </cfif>
    <cfif structKeyExists(cfcatch, "sql") and len(cfcatch.sql)>
        <cfset response.message = response.message & " | SQL: " & left(cfcatch.sql, 200)>
    </cfif>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
