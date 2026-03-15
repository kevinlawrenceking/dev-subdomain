<cfsilent>
<!---
    Contact Import V2 - Combined Migration Runner
    Run: /database/run-import-v2-migrations.cfm?run=yes
    Creates all required tables and adds V2.1 enhancements
--->
<cfinclude template="/database/admin-guard.cfm">
</cfsilent>
<cfset response = {success: false, step: "", message: "", results: []}>

<cftry>
    <cfif not structKeyExists(url, "run") or url.run neq "yes">
        <cfset response.message = "Add ?run=yes to execute migration">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset dsn = application.dsn>
    <cfset schemaName = application.information_schema>

    <!--- ============================================================
         STEP 1: Check/Create import_jobs table
         ============================================================ --->
    <cfset response.step = "check_import_jobs">
    <cfquery name="qCheckTable" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'import_jobs'
    </cfquery>

    <cfif qCheckTable.cnt eq 0>
        <cfset response.step = "create_import_jobs">
        <cfquery datasource="#dsn#">
            CREATE TABLE import_jobs (
                job_id INT AUTO_INCREMENT PRIMARY KEY,
                userid INT NOT NULL,
                source_filename VARCHAR(255) NOT NULL,
                file_type VARCHAR(10) NOT NULL,
                file_size BIGINT DEFAULT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pending',
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
                skipped_rows INT DEFAULT 0,
                options_json TEXT DEFAULT NULL,
                stored_file_path VARCHAR(500) DEFAULT NULL,
                file_hash VARCHAR(64) DEFAULT NULL,
                INDEX IX_import_jobs_userid_status (userid, status),
                INDEX IX_import_jobs_created (created_at DESC),
                INDEX IX_import_jobs_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_jobs table")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_jobs table exists")>
    </cfif>

    <!--- ============================================================
         STEP 2: Check/Create import_job_columns table
         ============================================================ --->
    <cfset response.step = "check_import_job_columns">
    <cfquery name="qCheckColumns" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'import_job_columns'
    </cfquery>

    <cfif qCheckColumns.cnt eq 0>
        <cfset response.step = "create_import_job_columns">
        <cfquery datasource="#dsn#">
            CREATE TABLE import_job_columns (
                column_id INT AUTO_INCREMENT PRIMARY KEY,
                job_id INT NOT NULL,
                source_column_index INT NOT NULL,
                source_column_name VARCHAR(255) DEFAULT NULL,
                normalized_field VARCHAR(50) DEFAULT NULL,
                confidence DECIMAL(3,2) DEFAULT NULL,
                user_confirmed TINYINT(1) DEFAULT 0,
                sample_values TEXT DEFAULT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX IX_import_job_columns_job (job_id),
                UNIQUE INDEX UX_import_job_columns_job_index (job_id, source_column_index),
                CONSTRAINT FK_import_job_columns_job
                    FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
                    ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_job_columns table")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_job_columns table exists")>
    </cfif>

    <!--- ============================================================
         STEP 3: Check/Create import_job_rows table
         ============================================================ --->
    <cfset response.step = "check_import_job_rows">
    <cfquery name="qCheckRows" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'import_job_rows'
    </cfquery>

    <cfif qCheckRows.cnt eq 0>
        <cfset response.step = "create_import_job_rows">
        <cfquery datasource="#dsn#">
            CREATE TABLE import_job_rows (
                row_id INT AUTO_INCREMENT PRIMARY KEY,
                job_id INT NOT NULL,
                row_num INT NOT NULL,
                raw_json TEXT NOT NULL,
                normalized_json TEXT DEFAULT NULL,
                validation_json TEXT DEFAULT NULL,
                dupe_json TEXT DEFAULT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pending',
                error_count INT DEFAULT 0,
                warning_count INT DEFAULT 0,
                matched_contactid INT DEFAULT NULL,
                best_match_score INT DEFAULT NULL,
                created_contactid INT DEFAULT NULL,
                user_action VARCHAR(20) DEFAULT NULL,
                import_error TEXT DEFAULT NULL,
                updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX IX_import_job_rows_job_status (job_id, status),
                INDEX IX_import_job_rows_job_rownum (job_id, row_num),
                INDEX IX_import_job_rows_status (status),
                UNIQUE INDEX UX_import_job_rows_job_rownum (job_id, row_num),
                CONSTRAINT FK_import_job_rows_job
                    FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
                    ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_job_rows table")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_job_rows table exists")>
    </cfif>

    <!--- ============================================================
         STEP 4: Check/Create import_job_events table
         ============================================================ --->
    <cfset response.step = "check_import_job_events">
    <cfquery name="qCheckEvents" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'import_job_events'
    </cfquery>

    <cfif qCheckEvents.cnt eq 0>
        <cfset response.step = "create_import_job_events">
        <cfquery datasource="#dsn#">
            CREATE TABLE import_job_events (
                event_id INT AUTO_INCREMENT PRIMARY KEY,
                job_id INT NOT NULL,
                event_type VARCHAR(50) NOT NULL,
                event_detail TEXT DEFAULT NULL,
                row_id INT DEFAULT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX IX_import_job_events_job (job_id),
                INDEX IX_import_job_events_type (event_type),
                INDEX IX_import_job_events_created (created_at),
                CONSTRAINT FK_import_job_events_job
                    FOREIGN KEY (job_id) REFERENCES import_jobs(job_id)
                    ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_job_events table")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_job_events table exists")>
    </cfif>

    <!--- ============================================================
         STEP 5: Check/Create import_field_mappings table
         ============================================================ --->
    <cfset response.step = "check_import_field_mappings">
    <cfquery name="qCheckMappings" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'import_field_mappings'
    </cfquery>

    <cfif qCheckMappings.cnt eq 0>
        <cfset response.step = "create_import_field_mappings">
        <cfquery datasource="#dsn#">
            CREATE TABLE import_field_mappings (
                mapping_id INT AUTO_INCREMENT PRIMARY KEY,
                canonical_field VARCHAR(50) NOT NULL,
                display_name VARCHAR(100) NOT NULL,
                field_category VARCHAR(30) NOT NULL,
                field_type VARCHAR(20) NOT NULL,
                is_required TINYINT(1) DEFAULT 0,
                max_length INT DEFAULT NULL,
                validation_regex VARCHAR(255) DEFAULT NULL,
                sort_order INT DEFAULT 0,
                UNIQUE INDEX UX_import_field_mappings_field (canonical_field)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_field_mappings table")>

        <!--- Insert seed data --->
        <cfset response.step = "seed_field_mappings">
        <cfquery datasource="#dsn#">
            INSERT INTO import_field_mappings
                (canonical_field, display_name, field_category, field_type, is_required, max_length, sort_order)
            VALUES
                ('firstName', 'First Name', 'contact', 'string', 1, 100, 1),
                ('lastName', 'Last Name', 'contact', 'string', 0, 100, 2),
                ('contactFullName', 'Full Name', 'contact', 'string', 0, 255, 3),
                ('email_business', 'Business Email', 'email', 'email', 0, 254, 10),
                ('email_personal', 'Personal Email', 'email', 'email', 0, 254, 11),
                ('phone_work', 'Work Phone', 'phone', 'phone', 0, 50, 20),
                ('phone_mobile', 'Mobile Phone', 'phone', 'phone', 0, 50, 21),
                ('phone_home', 'Home Phone', 'phone', 'phone', 0, 50, 22),
                ('company', 'Company', 'company', 'string', 0, 255, 30),
                ('department', 'Department', 'company', 'string', 0, 255, 31),
                ('jobTitle', 'Job Title', 'company', 'string', 0, 255, 32),
                ('address_street', 'Street Address', 'address', 'string', 0, 255, 40),
                ('address_extended', 'Address Line 2', 'address', 'string', 0, 255, 41),
                ('address_city', 'City', 'address', 'string', 0, 100, 42),
                ('address_state', 'State/Province', 'address', 'string', 0, 100, 43),
                ('address_zip', 'Postal Code', 'address', 'string', 0, 20, 44),
                ('address_country', 'Country', 'address', 'string', 0, 100, 45),
                ('tag1', 'Tag 1', 'tag', 'string', 0, 40, 50),
                ('tag2', 'Tag 2', 'tag', 'string', 0, 40, 51),
                ('tag3', 'Tag 3', 'tag', 'string', 0, 40, 52),
                ('website', 'Website', 'url', 'url', 0, 500, 60),
                ('birthday', 'Birthday', 'contact', 'date', 0, NULL, 70),
                ('meetingDate', 'Meeting Date', 'contact', 'date', 0, NULL, 71),
                ('meetingLocation', 'Meeting Location', 'contact', 'string', 0, 255, 72),
                ('notes', 'Notes', 'note', 'text', 0, 65535, 80),
                ('relationship_system', 'Relationship System', 'contact', 'select', 0, 50, 90)
        </cfquery>
        <cfset arrayAppend(response.results, "Seeded field mappings")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_field_mappings table exists")>

        <!--- Add relationship_system if missing --->
        <cfquery name="qCheckRelSys" datasource="#dsn#">
            SELECT COUNT(*) AS cnt FROM import_field_mappings WHERE canonical_field = 'relationship_system'
        </cfquery>
        <cfif qCheckRelSys.cnt eq 0>
            <cfquery datasource="#dsn#">
                INSERT INTO import_field_mappings
                    (canonical_field, display_name, field_category, field_type, is_required, max_length, sort_order)
                VALUES
                    ('relationship_system', 'Relationship System', 'contact', 'select', 0, 50, 90)
            </cfquery>
            <cfset arrayAppend(response.results, "Added relationship_system mapping")>
        </cfif>
    </cfif>

    <!--- ============================================================
         STEP 6: Check/Create import_field_aliases table
         ============================================================ --->
    <cfset response.step = "check_import_field_aliases">
    <cfquery name="qCheckAliases" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.tables
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'import_field_aliases'
    </cfquery>

    <cfif qCheckAliases.cnt eq 0>
        <cfset response.step = "create_import_field_aliases">
        <cfquery datasource="#dsn#">
            CREATE TABLE import_field_aliases (
                alias_id INT AUTO_INCREMENT PRIMARY KEY,
                canonical_field VARCHAR(50) NOT NULL,
                alias_pattern VARCHAR(100) NOT NULL,
                confidence DECIMAL(3,2) DEFAULT 0.90,
                INDEX IX_import_field_aliases_field (canonical_field),
                INDEX IX_import_field_aliases_pattern (alias_pattern),
                CONSTRAINT FK_import_field_aliases_field
                    FOREIGN KEY (canonical_field) REFERENCES import_field_mappings(canonical_field)
                    ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        </cfquery>
        <cfset arrayAppend(response.results, "Created import_field_aliases table")>
    <cfelse>
        <cfset arrayAppend(response.results, "import_field_aliases table exists")>
    </cfif>

    <!--- ============================================================
         STEP 7: Insert/Update aliases (INSERT IGNORE for idempotency)
         ============================================================ --->
    <cfset response.step = "insert_aliases">
    <cfquery datasource="#dsn#">
        INSERT IGNORE INTO import_field_aliases (canonical_field, alias_pattern, confidence) VALUES
        ('firstName', 'first name', 0.95),
        ('firstName', 'firstname', 0.95),
        ('firstName', 'first', 0.85),
        ('firstName', 'fname', 0.90),
        ('firstName', 'given name', 0.98),
        ('firstName', 'givenname', 0.90),
        ('firstName', 'n_given', 0.98),
        ('lastName', 'last name', 0.95),
        ('lastName', 'lastname', 0.95),
        ('lastName', 'last', 0.85),
        ('lastName', 'lname', 0.90),
        ('lastName', 'surname', 0.90),
        ('lastName', 'family name', 0.98),
        ('lastName', 'familyname', 0.90),
        ('lastName', 'n_family', 0.98),
        ('contactFullName', 'full name', 0.95),
        ('contactFullName', 'fullname', 0.95),
        ('contactFullName', 'name', 0.85),
        ('contactFullName', 'contact name', 0.90),
        ('contactFullName', 'fn', 0.98),
        ('email_business', 'business email', 0.95),
        ('email_business', 'work email', 0.95),
        ('email_business', 'email', 0.80),
        ('email_business', 'e-mail', 0.80),
        ('email_business', 'e-mail 1 - value', 0.95),
        ('email_business', 'email_work', 0.98),
        ('email_personal', 'personal email', 0.95),
        ('email_personal', 'home email', 0.90),
        ('email_personal', 'e-mail 2 - value', 0.90),
        ('email_personal', 'email_home', 0.98),
        ('phone_work', 'work phone', 0.95),
        ('phone_work', 'office phone', 0.90),
        ('phone_work', 'phone', 0.75),
        ('phone_work', 'phone 1 - value', 0.90),
        ('phone_work', 'tel_work', 0.98),
        ('phone_mobile', 'mobile phone', 0.95),
        ('phone_mobile', 'mobile', 0.90),
        ('phone_mobile', 'cell phone', 0.95),
        ('phone_mobile', 'cell', 0.85),
        ('phone_mobile', 'phone 2 - value', 0.85),
        ('phone_mobile', 'tel_cell', 0.98),
        ('phone_home', 'home phone', 0.95),
        ('phone_home', 'phone 3 - value', 0.80),
        ('phone_home', 'tel_home', 0.98),
        ('company', 'company', 0.95),
        ('company', 'company name', 0.95),
        ('company', 'organization', 0.90),
        ('company', 'organization 1 - name', 0.98),
        ('company', 'org', 0.98),
        ('department', 'department', 0.95),
        ('department', 'organization 1 - department', 0.98),
        ('jobTitle', 'job title', 0.95),
        ('jobTitle', 'title', 0.85),
        ('jobTitle', 'organization 1 - title', 0.98),
        ('address_street', 'street address', 0.95),
        ('address_street', 'address', 0.85),
        ('address_street', 'address 1 - street', 0.98),
        ('address_street', 'adr_street', 0.98),
        ('address_city', 'city', 0.95),
        ('address_city', 'address 1 - city', 0.98),
        ('address_city', 'adr_city', 0.98),
        ('address_state', 'state', 0.95),
        ('address_state', 'address 1 - region', 0.98),
        ('address_state', 'adr_region', 0.98),
        ('address_zip', 'zip', 0.95),
        ('address_zip', 'zip code', 0.95),
        ('address_zip', 'postal code', 0.95),
        ('address_zip', 'address 1 - postal code', 0.98),
        ('address_zip', 'adr_postal', 0.98),
        ('address_country', 'country', 0.95),
        ('address_country', 'address 1 - country', 0.98),
        ('address_country', 'adr_country', 0.98),
        ('website', 'website', 0.95),
        ('website', 'url', 0.95),
        ('website', 'website 1 - value', 0.95),
        ('birthday', 'birthday', 0.98),
        ('birthday', 'birth date', 0.95),
        ('birthday', 'bday', 0.98),
        ('notes', 'notes', 0.98),
        ('notes', 'note', 0.95),
        ('relationship_system', 'relationship_system', 0.95),
        ('relationship_system', 'relationship system', 0.95),
        ('relationship_system', 'maintenance_or_target', 0.95),
        ('relationship_system', 'system', 0.70),
        ('relationship_system', 'fu system', 0.85)
    </cfquery>
    <cfset arrayAppend(response.results, "Inserted/updated field aliases")>

    <!--- ============================================================
         STEP 8: Add file_hash column if missing
         ============================================================ --->
    <cfset response.step = "check_file_hash_column">
    <cfquery name="qCheckHashCol" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.columns
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'import_jobs'
          AND column_name = 'file_hash'
    </cfquery>

    <cfif qCheckHashCol.cnt eq 0>
        <cfset response.step = "add_file_hash_column">
        <cfquery datasource="#dsn#">
            ALTER TABLE import_jobs ADD COLUMN file_hash VARCHAR(64) NULL
        </cfquery>
        <cfset arrayAppend(response.results, "Added file_hash column")>
    <cfelse>
        <cfset arrayAppend(response.results, "file_hash column exists")>
    </cfif>

    <!--- ============================================================
         STEP 9: Add unique index on (userid, file_hash)
         ============================================================ --->
    <cfset response.step = "check_file_hash_index">
    <cfquery name="qCheckHashIdx" datasource="#dsn#">
        SELECT COUNT(*) AS cnt
        FROM information_schema.statistics
        WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schemaName#">
          AND table_name = 'import_jobs'
          AND index_name = 'UX_import_jobs_userid_file_hash'
    </cfquery>

    <cfif qCheckHashIdx.cnt eq 0>
        <cfset response.step = "create_file_hash_index">
        <cfquery datasource="#dsn#">
            CREATE UNIQUE INDEX UX_import_jobs_userid_file_hash ON import_jobs(userid, file_hash)
        </cfquery>
        <cfset arrayAppend(response.results, "Created unique index on (userid, file_hash)")>
    <cfelse>
        <cfset arrayAppend(response.results, "Unique index on file_hash exists")>
    </cfif>

    <!--- Success --->
    <cfset response.success = true>
    <cfset response.message = "Contact Import V2 migrations completed successfully">
    <cfset response.step = "complete">

    <cfcatch type="any">
        <cfset response.message = "Error at step [" & response.step & "]: " & cfcatch.message>
        <cfif len(cfcatch.detail)>
            <cfset response.message = response.message & " | " & cfcatch.detail>
        </cfif>
    </cfcatch>
</cftry>

<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
