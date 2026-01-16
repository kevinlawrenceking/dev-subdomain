<cfcomponent displayname="ContactImportV2Service" hint="Main orchestration service for Contact Import V2 - failsafe two-phase import">

<!--- ========================================
      CONTACT IMPORT V2 SERVICE
      Purpose: Orchestrate the entire import
      workflow: upload, parse, validate, detect
      duplicates, review, and finalize.
     ======================================== --->

<!--- Service dependencies --->
<cfset variables.fileParserService = new FileParserService()>
<cfset variables.validationService = new ValidationService()>
<cfset variables.duplicateMatcherService = new DuplicateMatcherService()>
<cfset variables.contactService = new ContactService()>
<cfset variables.contactItemService = new ContactItemService()>
<cfset variables.dsn = "reach">

<!--- Safe JSON parser to handle NULL/blank/invalid JSON --->
<cffunction name="safeDeserializeJSON" access="private" returntype="any" output="false">
    <cfargument name="jsonString" type="string" required="true">
    <cfargument name="defaultValue" type="any" required="false" default="#{}#">
    <cfif not len(trim(arguments.jsonString))>
        <cfreturn arguments.defaultValue>
    </cfif>
    <cftry>
        <cfreturn deserializeJSON(arguments.jsonString)>
        <cfcatch type="any">
            <cfreturn arguments.defaultValue>
        </cfcatch>
    </cftry>
</cffunction>

<!--- ========================================
      JOB MANAGEMENT
     ======================================== --->

<cffunction name="computeFileHash" access="public" returntype="string" output="false"
    hint="Compute SHA-256 hash of file contents for idempotency">
    <cfargument name="filePath" type="string" required="true">

    <cftry>
        <!--- Read file as binary --->
        <cffile action="readbinary" file="#arguments.filePath#" variable="fileBytes">

        <!--- Use Java MessageDigest for SHA-256 --->
        <cfset var md = createObject("java", "java.security.MessageDigest").getInstance("SHA-256")>
        <cfset var hashBytes = md.digest(fileBytes)>

        <!--- Convert to hex string --->
        <cfset var hexChars = "0123456789abcdef">
        <cfset var result = "">
        <cfloop from="1" to="#arrayLen(hashBytes)#" index="i">
            <cfset var b = hashBytes[i]>
            <cfif b lt 0>
                <cfset b = b + 256>
            </cfif>
            <cfset result &= mid(hexChars, int(b / 16) + 1, 1) & mid(hexChars, (b mod 16) + 1, 1)>
        </cfloop>

        <cfreturn result>

        <cfcatch type="any">
            <!--- Return empty on error - hash is optional --->
            <cfreturn "">
        </cfcatch>
    </cftry>
</cffunction>


<cffunction name="findDuplicateJob" access="public" returntype="struct" output="false"
    hint="Check if file was already imported by hash">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fileHash" type="string" required="true">

    <cfset var result = {
        isDuplicate: false,
        existingJob: {}
    }>

    <cfif not len(arguments.fileHash)>
        <cfreturn result>
    </cfif>

    <cfquery name="qExisting" datasource="#variables.dsn#">
        SELECT
            job_id,
            source_filename,
            status,
            created_at,
            imported_rows
        FROM import_jobs
        WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
          AND file_hash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileHash#">
        ORDER BY created_at DESC
        LIMIT 1
    </cfquery>

    <cfif qExisting.recordCount gt 0>
        <cfset result.isDuplicate = true>
        <cfset result.existingJob = {
            job_id: qExisting.job_id,
            filename: qExisting.source_filename,
            status: qExisting.status,
            created_at: qExisting.created_at,
            imported_rows: qExisting.imported_rows
        }>
    </cfif>

    <cfreturn result>
</cffunction>


<cffunction name="createJob" access="public" returntype="struct" output="false"
    hint="Create a new import job">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="filename" type="string" required="true">
    <cfargument name="filetype" type="string" required="true">
    <cfargument name="filesize" type="numeric" required="false" default="0">
    <cfargument name="storedFilePath" type="string" required="false" default="">
    <cfargument name="fileHash" type="string" required="false" default="">
    <cfargument name="options" type="struct" required="false" default="#{}#">

    <cfset var result = {
        success: false,
        job_id: 0,
        message: "",
        isDuplicateFile: false,
        existingJob: {}
    }>

    <!--- Check for duplicate file by hash --->
    <cfset var hashToStore = arguments.fileHash>
    <cfif len(arguments.fileHash)>
        <cfset var dupeCheck = findDuplicateJob(arguments.userid, arguments.fileHash)>
        <cfif dupeCheck.isDuplicate>
            <cfset result.isDuplicateFile = true>
            <cfset result.existingJob = dupeCheck.existingJob>
            <cfset result.message = "This file was already imported on " & dateFormat(dupeCheck.existingJob.created_at, "mm/dd/yyyy")>
            <!--- Set hash to NULL to avoid unique constraint violation, allowing re-import --->
            <cfset hashToStore = "">
        </cfif>
    </cfif>

    <cftry>
        <cfquery name="qInsert" result="insertResult" datasource="#variables.dsn#">
            INSERT INTO import_jobs (
                userid,
                source_filename,
                file_type,
                file_size,
                stored_file_path,
                file_hash,
                status,
                options_json,
                created_at
            ) VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filename#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filetype#">,
                <cfqueryparam cfsqltype="cf_sql_bigint" value="#arguments.filesize#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.storedFilePath#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#hashToStore#" null="#not len(hashToStore)#">,
                'pending',
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJSON(arguments.options)#">,
                NOW()
            )
        </cfquery>

        <!--- Get generated key with fallback to LAST_INSERT_ID for MySQL --->
        <cfif structKeyExists(insertResult, "generatedKey") and len(insertResult.generatedKey)>
            <cfset result.job_id = insertResult.generatedKey>
        <cfelse>
            <cfquery name="qLastId" datasource="#variables.dsn#">
                SELECT LAST_INSERT_ID() AS lastid
            </cfquery>
            <cfset result.job_id = qLastId.lastid>
        </cfif>
        <cfset result.success = true>

        <!--- Log event --->
        <cfset logEvent(result.job_id, "created", {filename: arguments.filename, filetype: arguments.filetype})>

        <cfcatch type="any">
            <cfset result.message = cfcatch.message>
            <cfif structKeyExists(cfcatch, "detail") and len(cfcatch.detail)>
                <cfset result.message &= " | Detail: " & cfcatch.detail>
            </cfif>
            <cfif structKeyExists(cfcatch, "sql") and len(cfcatch.sql)>
                <cfset result.message &= " | SQL: " & cfcatch.sql>
            </cfif>
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<cffunction name="getJob" access="public" returntype="struct" output="false"
    hint="Get job details by ID">
    <cfargument name="job_id" type="numeric" required="true">

    <cfquery name="qJob" datasource="#variables.dsn#">
        SELECT *
        FROM import_jobs
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
    </cfquery>

    <cfif qJob.recordCount eq 0>
        <cfreturn {found: false}>
    </cfif>

    <cfset var job = {
        found: true,
        job_id: qJob.job_id,
        userid: qJob.userid,
        source_filename: qJob.source_filename,
        file_type: qJob.file_type,
        file_size: qJob.file_size,
        file_hash: listFindNoCase(qJob.columnList, "file_hash") ? qJob.file_hash : "",
        status: qJob.status,
        error_message: qJob.error_message,
        created_at: qJob.created_at,
        updated_at: qJob.updated_at,
        started_at: qJob.started_at,
        finished_at: qJob.finished_at,
        total_rows: qJob.total_rows,
        parsed_rows: qJob.parsed_rows,
        valid_rows: qJob.valid_rows,
        problem_rows: qJob.problem_rows,
        dupe_rows: qJob.dupe_rows,
        imported_rows: qJob.imported_rows,
        skipped_rows: qJob.skipped_rows,
        stored_file_path: qJob.stored_file_path,
        options: safeDeserializeJSON(qJob.options_json, {})
    }>

    <cfreturn job>
</cffunction>


<cffunction name="getJobsByUser" access="public" returntype="query" output="false"
    hint="Get all jobs for a user">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="statusFilter" type="string" required="false" default="">
    <cfargument name="limit" type="numeric" required="false" default="50">

    <cfquery name="qJobs" datasource="#variables.dsn#">
        SELECT
            job_id,
            source_filename,
            file_type,
            status,
            created_at,
            finished_at,
            total_rows,
            valid_rows,
            problem_rows,
            dupe_rows,
            imported_rows
        FROM import_jobs
        WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
        <cfif len(arguments.statusFilter)>
            AND status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.statusFilter#">
        </cfif>
        ORDER BY created_at DESC
        LIMIT <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.limit#">
    </cfquery>

    <cfreturn qJobs>
</cffunction>


<cffunction name="updateJobStatus" access="public" returntype="void" output="false"
    hint="Update job status">
    <cfargument name="job_id" type="numeric" required="true">
    <cfargument name="status" type="string" required="true">
    <cfargument name="errorMessage" type="string" required="false" default="">

    <cfquery datasource="#variables.dsn#">
        UPDATE import_jobs
        SET
            status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.status#">,
            <cfif len(arguments.errorMessage)>
                error_message = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.errorMessage#">,
            </cfif>
            <cfif arguments.status eq "parsing">
                started_at = NOW(),
            </cfif>
            <cfif arguments.status eq "completed" or arguments.status eq "failed">
                finished_at = NOW(),
            </cfif>
            updated_at = NOW()
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
    </cfquery>
</cffunction>


<cffunction name="tryAcquireImportLock" access="public" returntype="struct" output="false"
    hint="Atomically try to acquire import lock. Prevents concurrent double-finalize.">
    <cfargument name="job_id" type="numeric" required="true">

    <cfset var result = {
        acquired: false,
        current_status: "",
        message: ""
    }>

    <!--- Atomic conditional UPDATE - only succeeds if status allows import (MSSQL syntax) --->
    <cfquery result="lockResult" datasource="#variables.dsn#">
        UPDATE import_jobs
        SET
            status = 'importing',
            started_at = IFNULL(started_at, NOW()),
            updated_at = NOW()
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
          AND status NOT IN ('completed', 'importing', 'failed')
    </cfquery>

    <!--- Check affected rows using CFQUERY result.recordCount --->
    <cfif lockResult.recordCount gt 0>
        <!--- Lock acquired successfully --->
        <cfset result.acquired = true>
        <cfset result.current_status = "importing">
    <cfelse>
        <!--- Lock not acquired - check current status --->
        <cfquery name="qStatus" datasource="#variables.dsn#">
            SELECT status
            FROM import_jobs
            WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
        </cfquery>

        <cfif qStatus.recordCount gt 0>
            <cfset result.current_status = qStatus.status>

            <!--- Set appropriate message based on status --->
            <cfif qStatus.status eq "completed">
                <cfset result.message = "Import already completed">
            <cfelseif qStatus.status eq "importing">
                <cfset result.message = "Import already in progress">
            <cfelseif qStatus.status eq "failed">
                <cfset result.message = "Import previously failed. Please create a new import job.">
            <cfelse>
                <cfset result.message = "Import cannot be finalized in current status: " & qStatus.status>
            </cfif>
        <cfelse>
            <cfset result.current_status = "not_found">
            <cfset result.message = "Job not found">
        </cfif>
    </cfif>

    <cfreturn result>
</cffunction>


<cffunction name="deleteJob" access="public" returntype="void" output="false"
    hint="Delete a job and all related data">
    <cfargument name="job_id" type="numeric" required="true">

    <!--- Cascade delete will handle rows, columns, events --->
    <cfquery datasource="#variables.dsn#">
        DELETE FROM import_jobs
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
    </cfquery>
</cffunction>


<!--- ========================================
      FILE PARSING
     ======================================== --->

<cffunction name="parseFile" access="public" returntype="struct" output="false"
    hint="Parse the uploaded file and populate staging rows">
    <cfargument name="job_id" type="numeric" required="true">

    <cfset var result = {
        success: false,
        message: "",
        totalRows: 0,
        parsedRows: 0
    }>

    <!--- Get job details --->
    <cfset var job = getJob(arguments.job_id)>
    <cfif not job.found>
        <cfset result.message = "Job not found">
        <cfreturn result>
    </cfif>

    <!--- Update status to parsing --->
    <cfset updateJobStatus(arguments.job_id, "parsing")>
    <cfset logEvent(arguments.job_id, "parsing_started", {})>

    <cftry>
        <!--- Parse the file --->
        <cfset var parseResult = variables.fileParserService.parseFile(job.stored_file_path, job.options)>

        <cfif not parseResult.success>
            <cfset updateJobStatus(arguments.job_id, "failed", parseResult.errors[1].error_message)>
            <cfset logEvent(arguments.job_id, "parsing_failed", {errors: parseResult.errors})>
            <cfset result.message = "Parsing failed: " & parseResult.errors[1].error_message>
            <cfreturn result>
        </cfif>

        <!--- Store column mappings --->
        <cfset storeColumnMappings(arguments.job_id, parseResult.headers)>

        <!--- Store rows --->
        <cfset var rowNum = 0>
        <cfloop array="#parseResult.rows#" index="rowData">
            <cfset rowNum++>

            <!--- Convert row data to JSON --->
            <cfset var rawJson = serializeJSON(rowData)>

            <!--- Insert row --->
            <cfquery datasource="#variables.dsn#">
                INSERT INTO import_job_rows (
                    job_id,
                    row_num,
                    raw_json,
                    status,
                    updated_at
                ) VALUES (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#rowNum#">,
                    <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#rawJson#">,
                    'pending',
                    NOW()
                )
            </cfquery>
        </cfloop>

        <!--- Update job counts --->
        <cfquery datasource="#variables.dsn#">
            UPDATE import_jobs
            SET
                total_rows = <cfqueryparam cfsqltype="cf_sql_integer" value="#parseResult.totalRows#">,
                parsed_rows = <cfqueryparam cfsqltype="cf_sql_integer" value="#parseResult.parsedRows#">,
                status = 'parsed',
                updated_at = NOW()
            WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
        </cfquery>

        <cfset logEvent(arguments.job_id, "parsing_completed", {
            totalRows: parseResult.totalRows,
            parsedRows: parseResult.parsedRows,
            parseErrors: arrayLen(parseResult.errors)
        })>

        <cfset result.success = true>
        <cfset result.totalRows = parseResult.totalRows>
        <cfset result.parsedRows = parseResult.parsedRows>

        <cfcatch type="any">
            <cfset updateJobStatus(arguments.job_id, "failed", cfcatch.message)>
            <cfset logEvent(arguments.job_id, "parsing_failed", {error: cfcatch.message})>
            <cfset result.message = "Parsing failed: " & cfcatch.message>
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<!--- ========================================
      COLUMN MAPPING
     ======================================== --->

<cffunction name="storeColumnMappings" access="private" returntype="void" output="false"
    hint="Store column headers and auto-map to fields">
    <cfargument name="job_id" type="numeric" required="true">
    <cfargument name="headers" type="array" required="true">

    <cfloop from="1" to="#arrayLen(arguments.headers)#" index="i">
        <cfset var header = arguments.headers[i]>
        <cfset var mapping = autoMapColumn(header)>

        <cfquery datasource="#variables.dsn#">
            INSERT INTO import_job_columns (
                job_id,
                source_column_index,
                source_column_name,
                normalized_field,
                confidence,
                user_confirmed,
                created_at
            ) VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#i - 1#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#header#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#mapping.field#" null="#not len(mapping.field)#">,
                <cfqueryparam cfsqltype="cf_sql_decimal" value="#mapping.confidence#">,
                0,
                NOW()
            )
        </cfquery>
    </cfloop>
</cffunction>


<cffunction name="autoMapColumn" access="private" returntype="struct" output="false"
    hint="Auto-detect field mapping for a column header">
    <cfargument name="header" type="string" required="true">

    <cfset var result = {
        field: "",
        confidence: 0
    }>

    <cfset var cleanHeader = lcase(trim(arguments.header))>

    <!--- Look up in aliases table --->
    <cfquery name="qAlias" datasource="#variables.dsn#">
        SELECT canonical_field, confidence
        FROM import_field_aliases
        WHERE LOWER(alias_pattern) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cleanHeader#">
        ORDER BY confidence DESC
        LIMIT 1
    </cfquery>

    <cfif qAlias.recordCount gt 0>
        <cfset result.field = qAlias.canonical_field>
        <cfset result.confidence = qAlias.confidence>
    </cfif>

    <cfreturn result>
</cffunction>


<cffunction name="getColumnMappings" access="public" returntype="query" output="false"
    hint="Get column mappings for a job">
    <cfargument name="job_id" type="numeric" required="true">

    <cfquery name="qColumns" datasource="#variables.dsn#">
        SELECT
            column_id,
            source_column_index,
            source_column_name,
            normalized_field,
            confidence,
            user_confirmed
        FROM import_job_columns
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
        ORDER BY source_column_index
    </cfquery>

    <cfreturn qColumns>
</cffunction>


<cffunction name="updateColumnMapping" access="public" returntype="void" output="false"
    hint="Update a column's field mapping">
    <cfargument name="column_id" type="numeric" required="true">
    <cfargument name="normalized_field" type="string" required="true">

    <cfquery datasource="#variables.dsn#">
        UPDATE import_job_columns
        SET
            normalized_field = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.normalized_field#" null="#not len(arguments.normalized_field)#">,
            user_confirmed = 1
        WHERE column_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.column_id#">
    </cfquery>
</cffunction>


<cffunction name="confirmColumnMappings" access="public" returntype="void" output="false"
    hint="Confirm all column mappings and trigger validation">
    <cfargument name="job_id" type="numeric" required="true">

    <!--- Mark all as confirmed --->
    <cfquery datasource="#variables.dsn#">
        UPDATE import_job_columns
        SET user_confirmed = 1
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
    </cfquery>

    <!--- Update job status --->
    <cfset updateJobStatus(arguments.job_id, "mapping")>
    <cfset logEvent(arguments.job_id, "columns_mapped", {})>
</cffunction>


<!--- ========================================
      ROW OPERATIONS
     ======================================== --->

<cffunction name="processRows" access="public" returntype="struct" output="false"
    hint="Apply column mapping, validate, and detect duplicates for all rows">
    <cfargument name="job_id" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var result = {
        success: false,
        processed: 0,
        valid: 0,
        problem: 0,
        dupe: 0
    }>

    <!--- Get column mappings --->
    <cfset var mappings = getColumnMappings(arguments.job_id)>
    <cfset var fieldMap = {}>
    <cfloop query="mappings">
        <cfif len(mappings.normalized_field)>
            <cfset fieldMap[mappings.source_column_index] = mappings.normalized_field>
        </cfif>
    </cfloop>

    <!--- Get all pending rows --->
    <cfquery name="qRows" datasource="#variables.dsn#">
        SELECT row_id, row_num, raw_json
        FROM import_job_rows
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
          AND status = 'pending'
        ORDER BY row_num
    </cfquery>

    <cfloop query="qRows">
        <cfset var rawData = safeDeserializeJSON(qRows.raw_json, {})>

        <!--- Map raw data to normalized fields --->
        <cfset var normalizedData = {}>
        <cfloop collection="#fieldMap#" item="colIndex">
            <cfset var fieldName = fieldMap[colIndex]>
            <cfif structKeyExists(rawData, colIndex)>
                <cfset normalizedData[fieldName] = rawData[colIndex]>
            </cfif>
        </cfloop>

        <!--- Validate --->
        <cfset var validation = variables.validationService.validateRow(normalizedData)>

        <!--- Detect duplicates --->
        <cfset var dupeResult = variables.duplicateMatcherService.findDuplicates(arguments.userid, validation.normalized)>

        <!--- Determine status --->
        <cfset var rowStatus = "ready">
        <cfif not validation.valid>
            <cfset rowStatus = "problem">
            <cfset result.problem++>
        <cfelseif dupeResult.hasDuplicate>
            <cfset rowStatus = "dupe">
            <cfset result.dupe++>
        <cfelse>
            <cfset result.valid++>
        </cfif>

        <!--- Update row --->
        <cfquery datasource="#variables.dsn#">
            UPDATE import_job_rows
            SET
                normalized_json = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJSON(validation.normalized)#">,
                validation_json = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJSON(validation.validation)#">,
                dupe_json = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJSON(dupeResult.candidates)#" null="#not arrayLen(dupeResult.candidates)#">,
                status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rowStatus#">,
                error_count = <cfqueryparam cfsqltype="cf_sql_integer" value="#validation.errorCount#">,
                warning_count = <cfqueryparam cfsqltype="cf_sql_integer" value="#validation.warningCount#">,
                matched_contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#dupeResult.bestMatchContactId#" null="#dupeResult.bestMatchContactId eq 0#">,
                best_match_score = <cfqueryparam cfsqltype="cf_sql_integer" value="#dupeResult.bestMatchScore#" null="#dupeResult.bestMatchScore eq 0#">,
                updated_at = NOW()
            WHERE row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qRows.row_id#">
        </cfquery>

        <cfset result.processed++>
    </cfloop>

    <!--- Update job counts --->
    <cfquery datasource="#variables.dsn#">
        CALL sp_update_import_job_counts(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">)
    </cfquery>

    <!--- Update job status --->
    <cfset updateJobStatus(arguments.job_id, "reviewing")>

    <cfset result.success = true>
    <cfreturn result>
</cffunction>


<cffunction name="getRows" access="public" returntype="struct" output="false"
    hint="Get rows with filtering and pagination">
    <cfargument name="job_id" type="numeric" required="true">
    <cfargument name="row_id" type="numeric" required="false" default="0">
    <cfargument name="status" type="string" required="false" default="">
    <cfargument name="page" type="numeric" required="false" default="1">
    <cfargument name="limit" type="numeric" required="false" default="50">

    <cfset var result = {
        rows: [],
        total: 0,
        page: arguments.page,
        pages: 0
    }>

    <cfset var offset = (arguments.page - 1) * arguments.limit>

    <!--- If fetching specific row by row_id --->
    <cfif arguments.row_id gt 0>
        <cfquery name="qRows" datasource="#variables.dsn#">
            SELECT
                row_id,
                row_num,
                raw_json,
                normalized_json,
                validation_json,
                dupe_json,
                status,
                error_count,
                warning_count,
                matched_contactid,
                best_match_score,
                user_action,
                created_contactid
            FROM import_job_rows
            WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
            AND row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_id#">
        </cfquery>
        <cfset result.total = qRows.recordCount>
        <cfset result.pages = 1>
    <cfelse>
        <!--- Get total count --->
        <cfquery name="qCount" datasource="#variables.dsn#">
            SELECT COUNT(*) AS cnt
            FROM import_job_rows
            WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
            <cfif len(arguments.status)>
                AND status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.status#">
            </cfif>
        </cfquery>
        <cfset result.total = qCount.cnt>
        <cfset result.pages = ceiling(result.total / arguments.limit)>

        <!--- Get rows --->
        <cfquery name="qRows" datasource="#variables.dsn#">
            SELECT
                row_id,
                row_num,
                raw_json,
                normalized_json,
                validation_json,
                dupe_json,
                status,
                error_count,
                warning_count,
                matched_contactid,
                best_match_score,
                user_action,
                created_contactid
            FROM import_job_rows
            WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
            <cfif len(arguments.status)>
                AND status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.status#">
            </cfif>
            ORDER BY row_num
            LIMIT <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.limit#">
            OFFSET <cfqueryparam cfsqltype="cf_sql_integer" value="#offset#">
        </cfquery>
    </cfif>

    <cfloop query="qRows">
        <cfset var row = {
            row_id: qRows.row_id,
            row_num: qRows.row_num,
            status: qRows.status,
            error_count: qRows.error_count,
            warning_count: qRows.warning_count,
            matched_contactid: qRows.matched_contactid,
            best_match_score: qRows.best_match_score,
            user_action: qRows.user_action,
            created_contactid: qRows.created_contactid,
            raw: safeDeserializeJSON(qRows.raw_json, {}),
            data: safeDeserializeJSON(qRows.normalized_json, {}),
            validation: safeDeserializeJSON(qRows.validation_json, {}),
            duplicates: safeDeserializeJSON(qRows.dupe_json, [])
        }>
        <cfset arrayAppend(result.rows, row)>
    </cfloop>

    <cfreturn result>
</cffunction>


<cffunction name="updateRow" access="public" returntype="struct" output="false"
    hint="Update row data and revalidate">
    <cfargument name="row_id" type="numeric" required="true">
    <cfargument name="data" type="struct" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var result = {
        success: false,
        new_status: "",
        validation: {}
    }>

    <!--- Get current row --->
    <cfquery name="qRow" datasource="#variables.dsn#">
        SELECT job_id, normalized_json
        FROM import_job_rows
        WHERE row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_id#">
    </cfquery>

    <cfif qRow.recordCount eq 0>
        <cfset result.message = "Row not found">
        <cfreturn result>
    </cfif>

    <!--- Merge updates with existing data --->
    <cfset var currentData = safeDeserializeJSON(qRow.normalized_json, {})>
    <cfloop collection="#arguments.data#" item="field">
        <cfset currentData[field] = arguments.data[field]>
    </cfloop>

    <!--- Revalidate --->
    <cfset var validation = variables.validationService.validateRow(currentData)>

    <!--- Re-check duplicates --->
    <cfset var dupeResult = variables.duplicateMatcherService.findDuplicates(arguments.userid, validation.normalized)>

    <!--- Determine new status --->
    <cfset var newStatus = "ready">
    <cfif not validation.valid>
        <cfset newStatus = "problem">
    <cfelseif dupeResult.hasDuplicate>
        <cfset newStatus = "dupe">
    </cfif>

    <!--- Update row --->
    <cfquery datasource="#variables.dsn#">
        UPDATE import_job_rows
        SET
            normalized_json = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJSON(validation.normalized)#">,
            validation_json = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJSON(validation.validation)#">,
            dupe_json = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJSON(dupeResult.candidates)#" null="#not arrayLen(dupeResult.candidates)#">,
            status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newStatus#">,
            error_count = <cfqueryparam cfsqltype="cf_sql_integer" value="#validation.errorCount#">,
            warning_count = <cfqueryparam cfsqltype="cf_sql_integer" value="#validation.warningCount#">,
            matched_contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#dupeResult.bestMatchContactId#" null="#dupeResult.bestMatchContactId eq 0#">,
            best_match_score = <cfqueryparam cfsqltype="cf_sql_integer" value="#dupeResult.bestMatchScore#" null="#dupeResult.bestMatchScore eq 0#">,
            updated_at = NOW()
        WHERE row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_id#">
    </cfquery>

    <!--- Update job counts --->
    <cfquery datasource="#variables.dsn#">
        CALL sp_update_import_job_counts(<cfqueryparam cfsqltype="cf_sql_integer" value="#qRow.job_id#">)
    </cfquery>

    <cfset logEvent(qRow.job_id, "row_updated", {row_id: arguments.row_id})>

    <cfset result.success = true>
    <cfset result.new_status = newStatus>
    <cfset result.validation = validation.validation>

    <cfreturn result>
</cffunction>


<cffunction name="setRowAction" access="public" returntype="void" output="false"
    hint="Set user action for a row">
    <cfargument name="row_id" type="numeric" required="true">
    <cfargument name="action" type="string" required="true">

    <cfquery name="qRow" datasource="#variables.dsn#">
        SELECT job_id FROM import_job_rows
        WHERE row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_id#">
    </cfquery>

    <cfquery datasource="#variables.dsn#">
        UPDATE import_job_rows
        SET
            user_action = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action#">,
            <cfif arguments.action eq "skip">
                status = 'ignored',
            </cfif>
            updated_at = NOW()
        WHERE row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.row_id#">
    </cfquery>

    <cfif qRow.recordCount>
        <cfquery datasource="#variables.dsn#">
            CALL sp_update_import_job_counts(<cfqueryparam cfsqltype="cf_sql_integer" value="#qRow.job_id#">)
        </cfquery>
        <cfset logEvent(qRow.job_id, "row_action_set", {row_id: arguments.row_id, action: arguments.action})>
    </cfif>
</cffunction>


<cffunction name="bulkSetAction" access="public" returntype="void" output="false"
    hint="Set action for multiple rows">
    <cfargument name="job_id" type="numeric" required="true">
    <cfargument name="row_ids" type="array" required="true">
    <cfargument name="action" type="string" required="true">

    <cfif not arrayLen(arguments.row_ids)>
        <cfreturn>
    </cfif>

    <cfquery datasource="#variables.dsn#">
        UPDATE import_job_rows
        SET
            user_action = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action#">,
            <cfif arguments.action eq "skip">
                status = 'ignored',
            </cfif>
            updated_at = NOW()
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
          AND row_id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arrayToList(arguments.row_ids)#" list="true">)
    </cfquery>

    <cfquery datasource="#variables.dsn#">
        CALL sp_update_import_job_counts(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">)
    </cfquery>

    <cfset logEvent(arguments.job_id, "bulk_action_set", {count: arrayLen(arguments.row_ids), action: arguments.action})>
</cffunction>


<!--- ========================================
      IMPORT EXECUTION
     ======================================== --->

<cffunction name="validateForImport" access="public" returntype="struct" output="false"
    hint="Check if job is ready for import">
    <cfargument name="job_id" type="numeric" required="true">

    <cfset var result = {
        can_import: false,
        ready_count: 0,
        issues: []
    }>

    <!--- Count rows by status --->
    <cfquery name="qCounts" datasource="#variables.dsn#">
        SELECT
            status,
            user_action,
            COUNT(*) AS cnt
        FROM import_job_rows
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
        GROUP BY status, user_action
    </cfquery>

    <cfset var readyCount = 0>
    <cfset var problemCount = 0>
    <cfset var dupeWithActionCount = 0>

    <cfloop query="qCounts">
        <cfif qCounts.status eq "ready">
            <cfset readyCount += qCounts.cnt>
        <cfelseif qCounts.status eq "problem">
            <cfset problemCount += qCounts.cnt>
        <cfelseif qCounts.status eq "dupe" and len(qCounts.user_action)>
            <cfset dupeWithActionCount += qCounts.cnt>
        </cfif>
    </cfloop>

    <cfset result.ready_count = readyCount + dupeWithActionCount>

    <cfif problemCount gt 0>
        <cfset arrayAppend(result.issues, problemCount & " rows have validation errors")>
    </cfif>

    <!--- Check for dupes without action --->
    <cfquery name="qDupeNoAction" datasource="#variables.dsn#">
        SELECT COUNT(*) AS cnt
        FROM import_job_rows
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
          AND status = 'dupe'
          AND (user_action IS NULL OR user_action = '')
    </cfquery>
    <cfif qDupeNoAction.cnt gt 0>
        <cfset arrayAppend(result.issues, qDupeNoAction.cnt & " duplicate rows need action selection")>
    </cfif>

    <cfif result.ready_count gt 0 and arrayLen(result.issues) eq 0>
        <cfset result.can_import = true>
    <cfelseif result.ready_count eq 0>
        <cfset arrayAppend(result.issues, "No rows ready for import")>
    </cfif>

    <cfreturn result>
</cffunction>


<cffunction name="executeImport" access="public" returntype="struct" output="false"
    hint="Execute the import for all ready rows">
    <cfargument name="job_id" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var result = {
        success: false,
        imported: 0,
        skipped: 0,
        failed: 0,
        contacts: [],
        errors: []
    }>

    <!--- Get job --->
    <cfset var job = getJob(arguments.job_id)>
    <cfif not job.found>
        <cfset result.errors = ["Job not found"]>
        <cfreturn result>
    </cfif>

    <!--- Status already set to 'importing' by tryAcquireImportLock() --->
    <cfset logEvent(arguments.job_id, "import_started", {})>

    <!--- Get rows to import --->
    <cfquery name="qRows" datasource="#variables.dsn#">
        SELECT
            row_id,
            row_num,
            normalized_json,
            status,
            user_action,
            matched_contactid
        FROM import_job_rows
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
          AND (
              (status = 'ready')
              OR (status = 'dupe' AND user_action IN ('import_new', 'update_existing'))
          )
          AND status != 'imported'
        ORDER BY row_num
    </cfquery>

    <cftransaction>
        <cftry>
            <cfloop query="qRows">
                <cfset var rowData = safeDeserializeJSON(qRows.normalized_json, {})>
                <cfset var contactid = 0>
                <cfset var importAction = "created">

                <cftry>
                    <!--- Determine action --->
                    <cfif qRows.user_action eq "update_existing" and qRows.matched_contactid gt 0>
                        <!--- Update existing contact --->
                        <cfset contactid = qRows.matched_contactid>
                        <cfset updateExistingContact(contactid, rowData, arguments.userid)>
                        <cfset importAction = "updated">
                    <cfelse>
                        <!--- Create new contact --->
                        <cfset contactid = createContactFromRow(rowData, arguments.userid)>
                        <cfset importAction = "created">
                    </cfif>

                    <!--- Mark row as imported --->
                    <cfquery datasource="#variables.dsn#">
                        UPDATE import_job_rows
                        SET
                            status = 'imported',
                            created_contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#contactid#">,
                            updated_at = NOW()
                        WHERE row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qRows.row_id#">
                    </cfquery>

                    <cfset result.imported++>
                    <cfset arrayAppend(result.contacts, {contactid: contactid, action: importAction})>

                    <cfset logEvent(arguments.job_id, "row_imported", {
                        row_id: qRows.row_id,
                        contactid: contactid,
                        action: importAction
                    })>

                    <cfcatch type="any">
                        <!--- Mark row as failed --->
                        <cfquery datasource="#variables.dsn#">
                            UPDATE import_job_rows
                            SET
                                status = 'failed',
                                import_error = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#cfcatch.message#">,
                                updated_at = NOW()
                            WHERE row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qRows.row_id#">
                        </cfquery>

                        <cfset result.failed++>
                        <cfset arrayAppend(result.errors, "Row " & qRows.row_num & ": " & cfcatch.message)>

                        <cfset logEvent(arguments.job_id, "row_failed", {
                            row_id: qRows.row_id,
                            error: cfcatch.message
                        })>
                    </cfcatch>
                </cftry>
            </cfloop>

            <!--- Update job counts and status (MSSQL syntax) --->
            <cfquery datasource="#variables.dsn#">
                CALL sp_update_import_job_counts(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">)
            </cfquery>

            <cfset updateJobStatus(arguments.job_id, "completed")>
            <cfset logEvent(arguments.job_id, "import_completed", {
                imported: result.imported,
                failed: result.failed
            })>

            <cfset result.success = true>

            <cfcatch type="any">
                <!--- Force rollback of the active transaction --->
                <cftransaction action="rollback" />

                <!--- Post-rollback cleanup MUST be outside the rolled-back scope --->
                <cftransaction>
                    <cfset updateJobStatus(arguments.job_id, "reviewing")>
                    <cfset logEvent(arguments.job_id, "import_failed", {error: cfcatch.message})>
                </cftransaction>

                <cfset arrayAppend(result.errors, "Import failed: " & cfcatch.message)>
            </cfcatch>
        </cftry>
    </cftransaction>

    <cfreturn result>
</cffunction>


<cffunction name="createContactFromRow" access="private" returntype="numeric" output="false"
    hint="Create a new contact from import row data">
    <cfargument name="rowData" type="struct" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <!--- Build full name --->
    <cfset var fullName = "">
    <cfif structKeyExists(arguments.rowData, "contactFullName") and len(arguments.rowData.contactFullName)>
        <cfset fullName = arguments.rowData.contactFullName>
    <cfelseif structKeyExists(arguments.rowData, "firstName") or structKeyExists(arguments.rowData, "lastName")>
        <cfset var firstName = structKeyExists(arguments.rowData, "firstName") ? arguments.rowData.firstName : "">
        <cfset var lastName = structKeyExists(arguments.rowData, "lastName") ? arguments.rowData.lastName : "">
        <cfset fullName = trim(firstName & " " & lastName)>
    </cfif>

    <!--- Create contact --->
    <cfset var contactData = {
        userid: arguments.userid,
        contactFullName: fullName
    }>

    <!--- Add optional fields --->
    <cfif structKeyExists(arguments.rowData, "birthday") and len(arguments.rowData.birthday)>
        <cfset contactData.contactBirthday = arguments.rowData.birthday>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "meetingDate") and len(arguments.rowData.meetingDate)>
        <cfset contactData.contactMeetingDate = arguments.rowData.meetingDate>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "meetingLocation") and len(arguments.rowData.meetingLocation)>
        <cfset contactData.contactMeetingLoc = arguments.rowData.meetingLocation>
    </cfif>

    <cfset var contactid = variables.contactService.create(contactData)>

    <!--- Add contact items --->

    <!--- Emails --->
    <cfif structKeyExists(arguments.rowData, "email_business") and len(arguments.rowData.email_business)>
        <cfset addContactItem(contactid, "Email", "Business", arguments.rowData.email_business, true)>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "email_personal") and len(arguments.rowData.email_personal)>
        <cfset var isPrimary = not structKeyExists(arguments.rowData, "email_business") or not len(arguments.rowData.email_business)>
        <cfset addContactItem(contactid, "Email", "Personal", arguments.rowData.email_personal, isPrimary)>
    </cfif>

    <!--- Phones --->
    <cfset var hasPhone = false>
    <cfif structKeyExists(arguments.rowData, "phone_work") and len(arguments.rowData.phone_work)>
        <cfset addContactItem(contactid, "Phone", "Work", arguments.rowData.phone_work, true)>
        <cfset hasPhone = true>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_mobile") and len(arguments.rowData.phone_mobile)>
        <cfset addContactItem(contactid, "Phone", "Mobile", arguments.rowData.phone_mobile, not hasPhone)>
        <cfset hasPhone = true>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_home") and len(arguments.rowData.phone_home)>
        <cfset addContactItem(contactid, "Phone", "Home", arguments.rowData.phone_home, not hasPhone)>
    </cfif>

    <!--- Company --->
    <cfif structKeyExists(arguments.rowData, "company") and len(arguments.rowData.company)>
        <cfset var dept = structKeyExists(arguments.rowData, "department") ? arguments.rowData.department : "">
        <cfset var title = structKeyExists(arguments.rowData, "jobTitle") ? arguments.rowData.jobTitle : "">
        <cfset addCompanyItem(contactid, arguments.rowData.company, dept, title)>
    </cfif>

    <!--- Address --->
    <cfif structKeyExists(arguments.rowData, "address_street") and len(arguments.rowData.address_street)>
        <cfset addAddressItem(contactid, arguments.rowData)>
    </cfif>

    <!--- Tags --->
    <cfloop list="tag1,tag2,tag3" index="tagField">
        <cfif structKeyExists(arguments.rowData, tagField) and len(arguments.rowData[tagField])>
            <cfset addContactItem(contactid, "Tag", "Tags", arguments.rowData[tagField], false)>
        </cfif>
    </cfloop>

    <!--- Website --->
    <cfif structKeyExists(arguments.rowData, "website") and len(arguments.rowData.website)>
        <cfset addContactItem(contactid, "URL", "Company Website", arguments.rowData.website, true)>
    </cfif>

    <!--- Notes --->
    <cfif structKeyExists(arguments.rowData, "notes") and len(arguments.rowData.notes)>
        <cfset addNote(contactid, arguments.userid, arguments.rowData.notes)>
    </cfif>

    <!--- Create contact folders --->
    <cfset createContactFolders(contactid, arguments.userid)>

    <!--- Enroll in relationship system if specified --->
    <cfif structKeyExists(arguments.rowData, "relationship_system") and len(arguments.rowData.relationship_system)>
        <cfset var relSystem = trim(arguments.rowData.relationship_system)>
        <cfif listFindNoCase("Target,Maintenance", relSystem)>
            <cfset enrollInRelationshipSystem(contactid, arguments.userid, relSystem)>
        </cfif>
    </cfif>

    <cfreturn contactid>
</cffunction>


<cffunction name="updateExistingContact" access="private" returntype="void" output="false"
    hint="Update an existing contact with import data">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="rowData" type="struct" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <!--- Update core contact fields if provided --->
    <cfset var updateData = {}>

    <cfif structKeyExists(arguments.rowData, "birthday") and len(arguments.rowData.birthday)>
        <cfset updateData.contactBirthday = arguments.rowData.birthday>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "meetingDate") and len(arguments.rowData.meetingDate)>
        <cfset updateData.contactMeetingDate = arguments.rowData.meetingDate>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "meetingLocation") and len(arguments.rowData.meetingLocation)>
        <cfset updateData.contactMeetingLoc = arguments.rowData.meetingLocation>
    </cfif>

    <cfif structCount(updateData) gt 0>
        <cfset variables.contactService.update(arguments.contactid, updateData)>
    </cfif>

    <!--- Add new items (don't duplicate existing) --->
    <!--- For simplicity, we add items that don't already exist --->

    <!--- Emails --->
    <cfif structKeyExists(arguments.rowData, "email_business") and len(arguments.rowData.email_business)>
        <cfif not itemExists(arguments.contactid, "Email", arguments.rowData.email_business)>
            <cfset addContactItem(arguments.contactid, "Email", "Business", arguments.rowData.email_business, false)>
        </cfif>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "email_personal") and len(arguments.rowData.email_personal)>
        <cfif not itemExists(arguments.contactid, "Email", arguments.rowData.email_personal)>
            <cfset addContactItem(arguments.contactid, "Email", "Personal", arguments.rowData.email_personal, false)>
        </cfif>
    </cfif>

    <!--- Phones --->
    <cfif structKeyExists(arguments.rowData, "phone_work") and len(arguments.rowData.phone_work)>
        <cfif not itemExists(arguments.contactid, "Phone", arguments.rowData.phone_work)>
            <cfset addContactItem(arguments.contactid, "Phone", "Work", arguments.rowData.phone_work, false)>
        </cfif>
    </cfif>
    <cfif structKeyExists(arguments.rowData, "phone_mobile") and len(arguments.rowData.phone_mobile)>
        <cfif not itemExists(arguments.contactid, "Phone", arguments.rowData.phone_mobile)>
            <cfset addContactItem(arguments.contactid, "Phone", "Mobile", arguments.rowData.phone_mobile, false)>
        </cfif>
    </cfif>

    <!--- Tags --->
    <cfloop list="tag1,tag2,tag3" index="tagField">
        <cfif structKeyExists(arguments.rowData, tagField) and len(arguments.rowData[tagField])>
            <cfif not itemExists(arguments.contactid, "Tag", arguments.rowData[tagField])>
                <cfset addContactItem(arguments.contactid, "Tag", "Tags", arguments.rowData[tagField], false)>
            </cfif>
        </cfif>
    </cfloop>

    <!--- Notes --->
    <cfif structKeyExists(arguments.rowData, "notes") and len(arguments.rowData.notes)>
        <cfset addNote(arguments.contactid, arguments.userid, arguments.rowData.notes)>
    </cfif>

    <!--- Enroll in relationship system if specified (for updates too) --->
    <cfif structKeyExists(arguments.rowData, "relationship_system") and len(arguments.rowData.relationship_system)>
        <cfset var relSystem = trim(arguments.rowData.relationship_system)>
        <cfif listFindNoCase("Target,Maintenance", relSystem)>
            <cfset enrollInRelationshipSystem(arguments.contactid, arguments.userid, relSystem)>
        </cfif>
    </cfif>
</cffunction>


<!--- ========================================
      CONTACT ITEM HELPERS
     ======================================== --->

<cffunction name="addContactItem" access="private" returntype="void" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="category" type="string" required="true">
    <cfargument name="type" type="string" required="true">
    <cfargument name="value" type="string" required="true">
    <cfargument name="isPrimary" type="boolean" required="false" default="false">

    <cfquery datasource="#variables.dsn#">
        INSERT INTO contactitems (
            contactid, valueCategory, valueType, valuetext, itemStatus, primary_yn
        ) VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.value#">,
            'Active',
            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.isPrimary ? 'Y' : 'N'#">
        )
    </cfquery>
</cffunction>


<cffunction name="addCompanyItem" access="private" returntype="void" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="company" type="string" required="true">
    <cfargument name="department" type="string" required="false" default="">
    <cfargument name="title" type="string" required="false" default="">

    <cfquery datasource="#variables.dsn#">
        INSERT INTO contactitems (
            contactid, valueCategory, valueType, valueCompany, valueDepartment, valueTitle, itemStatus, primary_yn
        ) VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">,
            'Company',
            'Company',
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.company#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department#" null="#not len(arguments.department)#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#" null="#not len(arguments.title)#">,
            'Active',
            'Y'
        )
    </cfquery>
</cffunction>


<cffunction name="addAddressItem" access="private" returntype="void" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="rowData" type="struct" required="true">

    <cfquery datasource="#variables.dsn#">
        INSERT INTO contactitems (
            contactid, valueCategory, valueType,
            valueStreetAddress, valueExtendedAddress, valueCity, valueRegion, valuePostalCode, valueCountry,
            itemStatus, primary_yn
        ) VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">,
            'Address',
            'Home',
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#structKeyExists(arguments.rowData, 'address_street') ? arguments.rowData.address_street : ''#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#structKeyExists(arguments.rowData, 'address_extended') ? arguments.rowData.address_extended : ''#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#structKeyExists(arguments.rowData, 'address_city') ? arguments.rowData.address_city : ''#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#structKeyExists(arguments.rowData, 'address_state') ? arguments.rowData.address_state : ''#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#structKeyExists(arguments.rowData, 'address_zip') ? arguments.rowData.address_zip : ''#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#structKeyExists(arguments.rowData, 'address_country') ? arguments.rowData.address_country : ''#">,
            'Active',
            'Y'
        )
    </cfquery>
</cffunction>


<cffunction name="addNote" access="private" returntype="void" output="false">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="noteText" type="string" required="true">

    <cfquery datasource="#variables.dsn#">
        INSERT INTO noteslog (
            contactid, userid, noteDetails, notetimestamp
        ) VALUES (
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">,
            <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.noteText#">,
            NOW()
        )
    </cfquery>
</cffunction>


<cffunction name="itemExists" access="private" returntype="boolean" output="false"
    hint="Check if a contact item already exists">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="category" type="string" required="true">
    <cfargument name="value" type="string" required="true">

    <cfquery name="qCheck" datasource="#variables.dsn#">
        SELECT 1 AS cnt
        FROM contactitems
        WHERE contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
          AND valueCategory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category#">
          AND (
              LOWER(valuetext) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.value)#">
              OR LOWER(valueCompany) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.value)#">
          )
          AND (isDeleted IS NULL OR isDeleted = 0)
        LIMIT 1
    </cfquery>

    <cfreturn qCheck.recordCount gt 0>
</cffunction>


<!--- ========================================
      RELATIONSHIP SYSTEM ENROLLMENT
     ======================================== --->

<cffunction name="enrollInRelationshipSystem" access="private" returntype="struct" output="false"
    hint="Enroll contact in a relationship system (Target or Maintenance)">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="systemType" type="string" required="true" hint="Target or Maintenance">

    <cfset var result = {
        success: false,
        systemid: 0,
        fusystemuserid: 0,
        message: ""
    }>

    <cfif not listFindNoCase("Target,Maintenance", arguments.systemType)>
        <cfset result.message = "Invalid system type. Must be Target or Maintenance.">
        <cfreturn result>
    </cfif>

    <cftry>
        <!--- Determine system type and scope based on V1 logic --->
        <cfif arguments.systemType eq "Target">
            <cfset var newSystemType = "Targeted List">
        <cfelse>
            <cfset var newSystemType = "Maintenance List">
        </cfif>

        <!--- Check if contact has Casting Director tag to determine scope --->
        <cfquery name="qFindScope" datasource="#variables.dsn#">
            SELECT 1 AS cnt
            FROM contactitems
            WHERE valuecategory = 'Tag'
              AND LOWER(valuetext) = 'casting director'
              AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
              AND itemstatus = 'Active'
              AND (isDeleted IS NULL OR isDeleted = 0)
            LIMIT 1
        </cfquery>

        <cfif qFindScope.recordCount gt 0>
            <cfset var newSystemScope = "Casting Director">
        <cfelse>
            <cfset var newSystemScope = "Industry">
        </cfif>

        <!--- Find the appropriate system --->
        <cfquery name="qFindSystem" datasource="#variables.dsn#">
            SELECT systemid
            FROM fusystems
            WHERE systemtype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newSystemType#">
              AND systemscope = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newSystemScope#">
              AND (isActive = 1 OR isActive IS NULL)
            LIMIT 1
        </cfquery>

        <cfif qFindSystem.recordCount eq 0>
            <cfset result.message = "No matching relationship system found for #newSystemType# / #newSystemScope#">
            <cfreturn result>
        </cfif>

        <cfset var systemid = qFindSystem.systemid>
        <cfset result.systemid = systemid>

        <!--- Check if already enrolled --->
        <cfquery name="qCheckEnrollment" datasource="#variables.dsn#">
            SELECT fusystemuserid
            FROM fusystemusers
            WHERE systemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#systemid#">
              AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
              AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
              AND (isdeleted IS NULL OR isdeleted = 0)
            LIMIT 1
        </cfquery>

        <cfif qCheckEnrollment.recordCount gt 0>
            <cfset result.success = true>
            <cfset result.fusystemuserid = qCheckEnrollment.fusystemuserid>
            <cfset result.message = "Contact already enrolled in system">
            <cfreturn result>
        </cfif>

        <!--- Create fusystemusers record --->
        <cfset var startDate = dateFormat(now(), "yyyy-mm-dd")>

        <cfquery name="qInsertEnrollment" result="insertResult" datasource="#variables.dsn#">
            INSERT INTO fusystemusers (
                systemid,
                userid,
                contactid,
                enrollmentdate,
                sustartdate,
                sustatus
            ) VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#systemid#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">,
                NOW(),
                <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#">,
                'Active'
            )
        </cfquery>

        <!--- Get generated key with fallback to LAST_INSERT_ID for MySQL --->
        <cfif structKeyExists(insertResult, "generatedKey") and len(insertResult.generatedKey)>
            <cfset var fusystemuserid = insertResult.generatedKey>
        <cfelse>
            <cfquery name="qLastId" datasource="#variables.dsn#">
                SELECT LAST_INSERT_ID() AS lastid
            </cfquery>
            <cfset var fusystemuserid = qLastId.lastid>
        </cfif>
        <cfset result.fusystemuserid = fusystemuserid>

        <!--- Create initial notifications for the system actions --->
        <cfset createSystemNotifications(systemid, arguments.contactid, arguments.userid, fusystemuserid, startDate)>

        <cfset result.success = true>
        <cfset result.message = "Successfully enrolled in #newSystemType# (#newSystemScope#)">

        <cfcatch type="any">
            <cfset result.message = "Enrollment failed: " & cfcatch.message>
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<cffunction name="createSystemNotifications" access="private" returntype="void" output="false"
    hint="Create initial notifications for a system enrollment">
    <cfargument name="systemid" type="numeric" required="true">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="fusystemuserid" type="numeric" required="true">
    <cfargument name="startDate" type="date" required="true">

    <cftry>
        <!--- Get actions for this system --->
        <cfquery name="qActions" datasource="#variables.dsn#">
            SELECT
                a.actionid,
                a.actionname,
                a.actionDaysNo,
                a.actionDaysRecurring,
                a.isUnique,
                a.actiontext
            FROM fuactions a
            WHERE a.systemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.systemid#">
              AND (a.isActive = 1 OR a.isActive IS NULL)
            ORDER BY a.actionDaysNo
        </cfquery>

        <cfloop query="qActions">
            <cfset var addAction = true>

            <!--- Check uniqueness if required --->
            <cfif qActions.isUnique eq 1>
                <cfquery name="qCheckUnique" datasource="#variables.dsn#">
                    SELECT 1 AS cnt
                    FROM funotifications
                    WHERE actionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#qActions.actionid#">
                      AND contactid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">
                      AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                    LIMIT 1
                </cfquery>

                <cfif qCheckUnique.recordCount gt 0>
                    <cfset addAction = false>
                </cfif>
            </cfif>

            <cfif addAction>
                <!--- Calculate notification start date --->
                <cfset var notStartDate = dateAdd("d", qActions.actionDaysNo, arguments.startDate)>

                <!--- Create notification --->
                <cfquery datasource="#variables.dsn#">
                    INSERT INTO funotifications (
                        actionid,
                        contactid,
                        userid,
                        fusystemuserid,
                        notstartdate,
                        notstatus,
                        nottext
                    ) VALUES (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#qActions.actionid#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contactid#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fusystemuserid#">,
                        <cfqueryparam cfsqltype="cf_sql_date" value="#notStartDate#">,
                        'Pending',
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#qActions.actiontext#" null="#not len(qActions.actiontext)#">
                    )
                </cfquery>
            </cfif>
        </cfloop>

        <cfcatch type="any">
            <!--- Log but don't fail the import for notification errors --->
        </cfcatch>
    </cftry>
</cffunction>


<!--- ========================================
      FOLDER CREATION
     ======================================== --->

<cffunction name="createContactFolders" access="private" returntype="struct" output="false"
    hint="Create folder structure for a newly imported contact">
    <cfargument name="contactid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var result = {
        success: false,
        contactFolder: "",
        message: ""
    }>

    <cftry>
        <!--- Determine media path based on server --->
        <cfset var currentURL = cgi.server_name>
        <cfset var host = listFirst(currentURL, ".")>

        <!--- Base media path --->
        <cfset var mediaRoot = "C:\home\theactorsoffice.com\wwwroot\" & host & "-subdomain\media-" & host>

        <!--- User folder path --->
        <cfset var userFolder = mediaRoot & "\users\" & arguments.userid>

        <!--- Contacts folder path --->
        <cfset var contactsFolder = userFolder & "\contacts">

        <!--- Contact-specific folder --->
        <cfset var contactFolder = contactsFolder & "\" & arguments.contactid>

        <!--- Attachments folder --->
        <cfset var attachmentsFolder = contactFolder & "\attachments">

        <!--- Create user folder if needed --->
        <cfif not directoryExists(userFolder)>
            <cfdirectory directory="#userFolder#" action="create">
        </cfif>

        <!--- Create contacts folder if needed --->
        <cfif not directoryExists(contactsFolder)>
            <cfdirectory directory="#contactsFolder#" action="create">
        </cfif>

        <!--- Create contact folder if needed --->
        <cfif not directoryExists(contactFolder)>
            <cfdirectory directory="#contactFolder#" action="create">
        </cfif>

        <!--- Create attachments folder if needed --->
        <cfif not directoryExists(attachmentsFolder)>
            <cfdirectory directory="#attachmentsFolder#" action="create">
        </cfif>

        <!--- Copy default avatar if not exists --->
        <cfset var avatarPath = contactFolder & "\avatar.jpg">
        <cfset var defaultAvatarPath = mediaRoot & "\defaults\avatar.jpg">

        <cfif not fileExists(avatarPath) and fileExists(defaultAvatarPath)>
            <cffile action="copy" source="#defaultAvatarPath#" destination="#contactFolder#\">
        </cfif>

        <cfset result.success = true>
        <cfset result.contactFolder = contactFolder>
        <cfset result.message = "Folders created successfully">

        <cfcatch type="any">
            <!--- Don't fail import for folder errors, just log --->
            <cfset result.message = "Folder creation warning: " & cfcatch.message>
            <cfset result.success = true>
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<!--- ========================================
      EVENT LOGGING
     ======================================== --->

<cffunction name="logEvent" access="private" returntype="void" output="false"
    hint="Log an import job event">
    <cfargument name="job_id" type="numeric" required="true">
    <cfargument name="event_type" type="string" required="true">
    <cfargument name="detail" type="any" required="false" default="#{}#">

    <cftry>
        <cfquery datasource="#variables.dsn#">
            INSERT INTO import_job_events (
                job_id, event_type, event_detail, created_at
            ) VALUES (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.event_type#">,
                <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#serializeJSON(arguments.detail)#">,
                NOW()
            )
        </cfquery>
        <cfcatch>
            <!--- Silently fail event logging --->
        </cfcatch>
    </cftry>
</cffunction>


<cffunction name="getJobEvents" access="public" returntype="query" output="false"
    hint="Get events for a job">
    <cfargument name="job_id" type="numeric" required="true">

    <cfquery name="qEvents" datasource="#variables.dsn#">
        SELECT
            event_id,
            event_type,
            event_detail,
            created_at
        FROM import_job_events
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
        ORDER BY created_at DESC
    </cfquery>

    <cfreturn qEvents>
</cffunction>


<!--- ========================================
      UTILITY METHODS
     ======================================== --->

<cffunction name="getAvailableFields" access="public" returntype="query" output="false"
    hint="Get list of available fields for mapping">

    <cfquery name="qFields" datasource="#variables.dsn#">
        SELECT
            canonical_field,
            display_name,
            field_category,
            field_type,
            is_required,
            max_length,
            sort_order
        FROM import_field_mappings
        ORDER BY sort_order
    </cfquery>

    <cfreturn qFields>
</cffunction>


<cffunction name="getJobStats" access="public" returntype="struct" output="false"
    hint="Get statistics for a job">
    <cfargument name="job_id" type="numeric" required="true">

    <cfset var stats = {
        total: 0,
        pending: 0,
        ready: 0,
        problem: 0,
        dupe: 0,
        ignored: 0,
        imported: 0,
        failed: 0
    }>

    <cfquery name="qStats" datasource="#variables.dsn#">
        SELECT status, COUNT(*) AS cnt
        FROM import_job_rows
        WHERE job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.job_id#">
        GROUP BY status
    </cfquery>

    <cfloop query="qStats">
        <cfset stats.total += qStats.cnt>
        <cfif structKeyExists(stats, qStats.status)>
            <cfset stats[qStats.status] = qStats.cnt>
        </cfif>
    </cfloop>

    <cfreturn stats>
</cffunction>

</cfcomponent>
