<cfsetting requesttimeout="300">
<cfsilent>
<!---
    Audition Import - Recompute Endpoint
    POST /ajax/import-auditions/recompute.cfm

    Validates rows and detects duplicates based on current column mappings.
    Does NOT write to production auditions tables.

    Request Parameters:
    - job_id (required): The import job ID

    URL Parameters:
    - skip_dupes (optional): If 1, skip duplicate detection (for debugging hangs)

    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job does not exist
    - MISSING_JOB_ID: job_id parameter missing
    - INVALID_STATE: Job not in allowed status (parsed, mapping, reviewing)
    - LOCKED: Job is locked by another operation
    - RECOMPUTE_FAILED: Recompute operation failed
    - SCHEMA_MISMATCH: Required columns missing from database tables
--->

<!--- ============================================================
     OUTERMOST SAFETY WRAPPER
     Guarantees JSON output even if variable init or function
     definitions fail. Nothing above this point can throw.
     ============================================================ --->
<cfset variables.outerDebugSteps = []>
<cfset variables.outerStartTime = getTickCount()>
<cftry>

<!--- Initialize response envelope with debug array --->
<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "debug": [],
    "data": {},
    "correlation_id": "",
    "elapsed_ms": 0
}>

<!--- Initialize structured logger (inside try/catch so CFC compilation errors don't crash the endpoint) --->
<cfset variables.audLogger = "">
<cfset variables.loggerAvailable = false>
<cftry>
    <cfset variables.audLogger = new services.ImportAuditionsLogger(endpoint="recompute")>
    <cfset variables.response.correlation_id = variables.audLogger.getCorrelationId()>
    <cfset variables.loggerAvailable = true>
<cfcatch type="any">
    <!--- Logger CFC failed to load - continue without structured logging --->
    <cfset arrayAppend(variables.response.debug, "WARN: ImportAuditionsLogger failed to init: " & cfcatch.message)>
    <cflog file="import_auditions" text="ImportAuditionsLogger INIT FAILED: #cfcatch.message# | #cfcatch.detail#" type="error">
</cfcatch>
</cftry>

<!--- Phase timing tracker --->
<cfset variables.phaseTimes = {}>
<cfset variables.currentPhase = "">
<cfset variables.phaseStart = 0>

<!--- First-failure capture --->
<cfset variables.firstFailure = {}>

<!--- Initialize metrics tracking --->
<cfset variables.metrics = {
    "total_rows_processed": 0,
    "dupe_detection_mode": "pending",
    "dupe_queries_total": 0,
    "dupe_errors_count": 0,
    "dupe_candidates_total": 0,
    "dupe_index_build_ms": 0,
    "dupe_index_items_total": 0,
    "dupe_index_abort_reason": "",
    "elapsed_ms_total": 0,
    "elapsed_ms_dupes_total": 0
}>
<cfset variables.warnings = []>
<cfset variables.recomputeStartTime = getTickCount()>
<cfset variables.dupeElapsedTotal = 0>

<!--- Dupe state --->
<cfset variables.dupeIndex = {}>

<!--- Helper: safe correlation ID accessor --->
<cffunction name="getCorrelationId" access="private" returntype="string" output="false">
    <cfif variables.loggerAvailable>
        <cfreturn variables.audLogger.getCorrelationId()>
    </cfif>
    <cfreturn "NO_LOGGER">
</cffunction>

<!--- Helper function to add debug breadcrumb + structured log --->
<cffunction name="addDebug" access="private" returntype="void" output="false">
    <cfargument name="msg" type="string" required="true">
    <cfargument name="meta" type="struct" required="false" default="#{}#">
    <cfset var entry = "[" & timeFormat(now(), "HH:mm:ss.lll") & "] " & arguments.msg>
    <cfif structCount(arguments.meta)>
        <cfset entry = entry & " | " & serializeJSON(arguments.meta)>
    </cfif>
    <cfset arrayAppend(variables.response.debug, entry)>
    <cfset arrayAppend(variables.outerDebugSteps, entry)>
    <cftry>
        <cfset variables.audLogger.debug("recompute", arguments.msg)>
    <cfcatch type="any"></cfcatch>
    </cftry>
</cffunction>

<!--- Helper: start timing a named phase --->
<cffunction name="startPhase" access="private" returntype="void" output="false">
    <cfargument name="phaseName" type="string" required="true">
    <cfset variables.currentPhase = arguments.phaseName>
    <cfset variables.phaseStart = getTickCount()>
    <cftry>
        <cfif variables.loggerAvailable><cfset variables.audLogger.info(arguments.phaseName, "phase_start")></cfif>
    <cfcatch type="any"></cfcatch>
    </cftry>
</cffunction>

<!--- Helper: end timing current phase --->
<cffunction name="endPhase" access="private" returntype="void" output="false">
    <cfif len(variables.currentPhase) and variables.phaseStart gt 0>
        <cfset var elapsed = getTickCount() - variables.phaseStart>
        <cfset variables.phaseTimes[variables.currentPhase] = elapsed>
        <cftry>
            <cfif variables.loggerAvailable><cfset variables.audLogger.info(variables.currentPhase, "phase_end ms=" & elapsed)></cfif>
        <cfcatch type="any"></cfcatch>
        </cftry>
        <cfset addDebug("phase_end=" & variables.currentPhase & " ms=" & elapsed)>
        <cfset variables.currentPhase = "">
        <cfset variables.phaseStart = 0>
    </cfif>
</cffunction>

<!--- Helper: capture first row failure --->
<cffunction name="captureFirstFailure" access="private" returntype="void" output="false">
    <cfargument name="rowId" type="numeric" required="true">
    <cfargument name="rowNum" type="numeric" required="true">
    <cfargument name="errorMsg" type="string" required="true">
    <cfargument name="stage" type="string" required="true">
    <cfif structIsEmpty(variables.firstFailure)>
        <cfset variables.firstFailure = {
            "row_id": arguments.rowId,
            "row_num": arguments.rowNum,
            "error": arguments.errorMsg,
            "stage": arguments.stage,
            "elapsed_ms": getTickCount() - variables.recomputeStartTime
        }>
        <cftry><cfif variables.loggerAvailable><cfset variables.audLogger.warn("first_failure", arguments.errorMsg, variables.firstFailure)></cfif><cfcatch type="any"></cfcatch></cftry>
    </cfif>
</cffunction>

<!--- URL param: skip_dupes --->
<cfparam name="url.skip_dupes" default="0">
<cfset variables.skipDupes = val(url.skip_dupes) eq 1>

<cfset addDebug("Audition recompute start, skip_dupes=" & variables.skipDupes)>
<cflog file="import_auditions" text="Audition recompute start skip_dupes=#variables.skipDupes#">
<cflog file="import_auditions" text="Audition import field_name convention: uses target field names directly">

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfset addDebug("step=auth_check")>
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset variables.response.code = "AUTH_REQUIRED">
        <cfset variables.response.message = "Authentication required">
        <cfset addDebug("FAIL: auth_required")>
        <cflog file="import_auditions" text="Audition recompute FAIL auth_required">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfif variables.loggerAvailable><cfset variables.audLogger.setUserId(variables.userid)></cfif>
    <cfset addDebug("step=auth_ok userid=" & variables.userid)>

    <!--- Runtime DSN + database diagnostics --->
    <cfset addDebug("step=dsn_diagnostics")>
    <cfset variables.runtimeDSN = structKeyExists(application, "datasource") ? application.datasource : "UNDEFINED">
    <cfset addDebug("dsn=" & variables.runtimeDSN & " host=" & cgi.server_name)>
    <cftry>
        <cfset variables.qDbInfo = queryExecute(
            "SELECT DATABASE() AS db_name, VERSION() AS mysql_version",
            {},
            { datasource: application.datasource }
        )>
        <cfset variables.dbName = variables.qDbInfo.db_name>
        <cfset variables.mysqlVersion = variables.qDbInfo.mysql_version>
        <cfset addDebug("db_name=" & variables.dbName & " mysql_version=" & variables.mysqlVersion)>
    <cfcatch type="any">
        <cfset variables.dbName = "QUERY_FAILED">
        <cfset variables.mysqlVersion = "UNKNOWN">
        <cfset addDebug("dsn_diag_error: " & cfcatch.message)>
    </cfcatch>
    </cftry>

    <!--- Introspect import_auditions table columns for diagnostics (full metadata) --->
    <cfset variables.tableCols = {}>
    <cftry>
        <cfset variables.qTableCols = queryExecute(
            "SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
             FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_NAME IN ('import_auditions_jobs','import_auditions_rows','import_auditions_facts','import_auditions_columns')
             ORDER BY TABLE_NAME, ORDINAL_POSITION",
            {},
            { datasource: application.datasource }
        )>
        <cfloop query="variables.qTableCols">
            <cfif not structKeyExists(variables.tableCols, variables.qTableCols.TABLE_NAME)>
                <cfset variables.tableCols[variables.qTableCols.TABLE_NAME] = []>
            </cfif>
            <cfset arrayAppend(variables.tableCols[variables.qTableCols.TABLE_NAME], variables.qTableCols.COLUMN_NAME)>
                "column": variables.qTableCols.COLUMN_NAME,
                "type": variables.qTableCols.DATA_TYPE,
                "nullable": variables.qTableCols.IS_NULLABLE,
                "default": isNull(variables.qTableCols.COLUMN_DEFAULT) ? "NULL" : variables.qTableCols.COLUMN_DEFAULT
            })>
        </cfloop>
        <cfloop collection="#variables.tableCols#" item="variables.tblName">
            <cfset addDebug("schema[" & variables.tblName & "]=" & arrayToList(variables.tableCols[variables.tblName]))>
        </cfloop>
    <cfcatch type="any">
        <cfset addDebug("schema_introspect_error: " & cfcatch.message)>
    </cfcatch>
    </cftry>

    <!--- SCHEMA GATE: Verify required columns exist in import_auditions_columns --->
    <cfset addDebug("step=schema_gate")>
    <cfset variables.audColsActual = structKeyExists(variables.tableCols, "import_auditions_columns") ? variables.tableCols["import_auditions_columns"] : []>
    <cfset variables.requiredCols = ["intent", "target_key", "transform_json"]>
    <cfset variables.missingCols = []>
    <cfloop array="#variables.requiredCols#" index="variables.reqCol">
        <cfif not arrayFindNoCase(variables.audColsActual, variables.reqCol)>
            <cfset arrayAppend(variables.missingCols, variables.reqCol)>
        </cfif>
    </cfloop>
    <cfif arrayLen(variables.missingCols) gt 0>
        <cfset variables.response.code = "SCHEMA_MISMATCH">
        <cfset variables.response.message = "import_auditions_columns is missing required mapping columns: " & arrayToList(variables.missingCols, ", ") & ". Run database/migrations/import_auditions_columns_mapping_fields.sql">
        <cfset addDebug("FAIL: schema_mismatch missing_cols=" & arrayToList(variables.missingCols), {
            "actual_columns": variables.audColsActual,
            "required_columns": variables.requiredCols,
            "missing_columns": variables.missingCols,
            "fix": "Run import_auditions_columns_mapping_fields.sql against " & variables.dbName
        })>
        <cfset variables.response.data = {
            "dsn": variables.runtimeDSN,
            "db_name": variables.dbName,
            "actual_columns": variables.audColsActual,
            "missing_columns": variables.missingCols,
            "fix_sql": "ALTER TABLE import_auditions_columns ADD COLUMN intent VARCHAR(20) DEFAULT NULL; ALTER TABLE import_auditions_columns ADD COLUMN target_key VARCHAR(100) DEFAULT NULL; ALTER TABLE import_auditions_columns ADD COLUMN transform_json TEXT DEFAULT NULL;",
            "migration_file": "database/migrations/import_auditions_columns_mapping_fields.sql"
        }>
        <cflog file="import_auditions" text="Audition recompute FAIL schema_mismatch missing=#arrayToList(variables.missingCols)# db=#variables.dbName# dsn=#variables.runtimeDSN#">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("schema_gate PASSED")>

    <!--- Parse JSON body first (for JSON content type requests) --->
    <cfset addDebug("step=parse_json_body")>
    <cfset variables.requestBody = "">
    <cfset variables.jsonData = {}>
    <cftry>
        <cfset variables.requestBody = toString(getHTTPRequestData().content)>
        <cfif len(variables.requestBody)>
            <cfset variables.jsonData = deserializeJSON(variables.requestBody)>
            <cfset addDebug("json_body_parsed keys=" & structKeyList(variables.jsonData))>
        <cfelse>
            <cfset addDebug("json_body_empty")>
        </cfif>
        <cfcatch type="any">
            <cfset addDebug("json_body_parse_error: " & cfcatch.message)>
        </cfcatch>
    </cftry>

    <!--- Validate job_id parameter (check JSON body, then form, then url) --->
    <cfset addDebug("step=validate_job_id")>
    <cfparam name="form.job_id" default="">
    <cfparam name="url.job_id" default="">
    <cfset variables.jobId = 0>

    <!--- Priority: JSON body > form > url --->
    <cfif structKeyExists(variables.jsonData, "job_id")>
        <cfset variables.jobId = val(variables.jsonData.job_id)>
    </cfif>
    <cfif variables.jobId eq 0>
        <cfset variables.jobId = val(form.job_id)>
    </cfif>
    <cfif variables.jobId eq 0>
        <cfset variables.jobId = val(url.job_id)>
    </cfif>

    <cfif variables.jobId lte 0>
        <cfset variables.response.code = "MISSING_JOB_ID">
        <cfset variables.response.message = "job_id is required">
        <cfset addDebug("FAIL: missing_job_id")>
        <cflog file="import_auditions" text="Audition recompute FAIL missing_job_id">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfif variables.loggerAvailable><cfset variables.audLogger.setJobId(variables.jobId)></cfif>
    <cfset addDebug("job_id=" & variables.jobId)>
    <cflog file="import_auditions" text="Audition recompute job_id=#variables.jobId# userid=#variables.userid#">

    <!--- Initialize services --->
    <cfset addDebug("step=init_services")>
    <cfset variables.audService = new services.AuditionImportService()>
    <cfset variables.dupeService = new services.AuditionDuplicateMatcherService()>
    <cfset addDebug("services_initialized")>

    <!--- Preflight check: Is duplicate detection available? --->
    <cfset addDebug("step=dupe_preflight_check")>
    <cfset variables.dupeAvailability = variables.dupeService.isDupeDetectionAvailable()>
    <cfset variables.dupeDetectionEnabled = false>

    <cfif variables.skipDupes>
        <cfset variables.metrics.dupe_detection_mode = "skipped_url_param">
        <cfset addDebug("dupe_detection DISABLED by skip_dupes=1 URL param")>
    <cfelseif not variables.dupeAvailability.available>
        <cfset variables.metrics.dupe_detection_mode = "skipped_missing_tables">
        <cfset arrayAppend(variables.warnings, "Duplicate detection skipped: " & variables.dupeAvailability.reason)>
    <cfelse>
        <cfset variables.dupeDetectionEnabled = true>
        <cfset variables.metrics.dupe_detection_mode = "ran">
    </cfif>

    <!--- PHASE 4: Build dupe index once if dupe detection is enabled --->
    <cfif variables.dupeDetectionEnabled>
        <cfset addDebug("step=build_dupe_index")>
        <cfset variables.dupeIndexStartTime = getTickCount()>
        <cftry>
            <cfset variables.dupeIndex = variables.dupeService.buildUserDupeIndex(variables.userid, variables.metrics)>

            <!--- Phase 4.1: Check for abort_reason from guardrails --->
            <cfif len(variables.dupeIndex.abort_reason)>
                <cfset variables.dupeDetectionEnabled = false>
                <cfif variables.dupeIndex.abort_reason eq "items_exceeded">
                    <cfset variables.metrics.dupe_detection_mode = "skipped_index_too_large">
                    <cfset arrayAppend(variables.warnings, "Dupe index skipped: too many items (" & variables.dupeIndex.items_total & " exceeds limit)")>
                            <cfelseif variables.dupeIndex.abort_reason eq "timeout">
                    <cfset variables.metrics.dupe_detection_mode = "skipped_index_timeout">
                    <cfset arrayAppend(variables.warnings, "Dupe index skipped: build timeout (" & variables.dupeIndex.build_ms & "ms)")>
                <cfelse>
                    <cfset variables.metrics.dupe_detection_mode = "skipped_index_error">
                    <cfset arrayAppend(variables.warnings, "Dupe index skipped: " & variables.dupeIndex.abort_reason)>
                </cfif>
                <cfset variables.metrics.dupe_index_abort_reason = variables.dupeIndex.abort_reason>
                <cfset variables.metrics.dupe_index_build_ms = variables.dupeIndex.build_ms>
                <cfset variables.metrics.dupe_index_items_total = variables.dupeIndex.items_total>
                <cfset addDebug("dupe_index_aborted reason=" & variables.dupeIndex.abort_reason & " items=" & variables.dupeIndex.items_total)>
            <cfelseif structKeyExists(variables.dupeIndex, "error")>
                <!--- Index build failed with exception --->
                <cfset variables.dupeDetectionEnabled = false>
                <cfset variables.metrics.dupe_detection_mode = "skipped_index_error">
                <cfset variables.metrics.dupe_index_abort_reason = "exception">
                <cfset arrayAppend(variables.warnings, "Dupe index build failed: " & variables.dupeIndex.error)>
                <cfset addDebug("dupe_index_build_error: " & variables.dupeIndex.error)>
            <cfelse>
                <cfset variables.metrics.dupe_index_build_ms = variables.dupeIndex.build_ms>
                <cfset variables.metrics.dupe_index_items_total = variables.dupeIndex.items_total>
                <cfset addDebug("dupe_index_built items=" & variables.dupeIndex.items_total & " ms=" & variables.dupeIndex.build_ms)>
            </cfif>
            <cfcatch type="any">
                <cfset variables.dupeDetectionEnabled = false>
                <cfset variables.metrics.dupe_detection_mode = "skipped_index_error">
                <cfset variables.metrics.dupe_index_abort_reason = "exception">
                <cfset arrayAppend(variables.warnings, "Dupe index build failed: " & cfcatch.message)>
                <cfset addDebug("dupe_index_build_exception: " & cfcatch.message)>
                <cflog file="import_auditions" text="Audition recompute dupe_index_build_exception job_id=#variables.jobId# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfset variables.dupeElapsedTotal += (getTickCount() - variables.dupeIndexStartTime)>
    </cfif>

    <!--- B) Verify job ownership --->
    <cfset addDebug("step=verify_job_ownership")>
    <cfset variables.jobResult = variables.audService.getJobForUser(variables.jobId, variables.userid)>
    <cfif not variables.jobResult.success>
        <cfset variables.response.code = variables.jobResult.code>
        <cfset variables.response.message = variables.jobResult.message>
        <cfset addDebug("FAIL: job_ownership code=" & variables.jobResult.code)>
        <cflog file="import_auditions" text="Audition recompute FAIL job_ownership job_id=#variables.jobId# code=#variables.jobResult.code#">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.job = variables.jobResult.data.job>
    <cfset addDebug("job_verified status=" & variables.job.status)>

    <!--- C) Validate job status - only allow recompute from these states --->
    <cfset addDebug("step=validate_job_status")>
    <cfset variables.ALLOWED_STATUSES = ["parsed", "mapping", "reviewing"]>
    <cfif not arrayFindNoCase(variables.ALLOWED_STATUSES, variables.job.status)>
        <cfset variables.response.code = "INVALID_STATE">
        <cfset variables.response.message = "Cannot recompute from status: " & variables.job.status & ". Allowed: " & arrayToList(variables.ALLOWED_STATUSES, ", ")>
        <cfset variables.response.data = { current_status: variables.job.status, allowed: variables.ALLOWED_STATUSES }>
        <cfset addDebug("FAIL: invalid_state current=" & variables.job.status)>
        <cflog file="import_auditions" text="Audition recompute FAIL invalid_state job_id=#variables.jobId# status=#variables.job.status#">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("job_status_valid")>

    <!--- Process incoming mappings from JSON body if provided --->
    <cfset addDebug("step=process_mappings")>
    <cfif structCount(variables.jsonData) gt 0>
        <cftry>
            <!--- Process mappings array if provided --->
            <cfif structKeyExists(variables.jsonData, "mappings") and isArray(variables.jsonData.mappings)>
                <cfset variables.mappingCount = arrayLen(variables.jsonData.mappings)>
                <cfset addDebug("mappings_count=" & variables.mappingCount)>
                <cfloop array="#variables.jsonData.mappings#" index="variables.mapping">
                    <cfif structKeyExists(variables.mapping, "column_id") and structKeyExists(variables.mapping, "field")>
                        <cfset variables.colId = val(variables.mapping.column_id)>
                        <cfset variables.targetField = trim(variables.mapping.field)>

                        <!--- Map field names to canonical keys (camelCase matches columns.cfm available_fields) --->
                        <!--- Audition fields: use target field directly as canonical key --->
                        <cfset variables.normalizedField = variables.targetField>

                        <!--- Determine intent based on field --->
                        <cfset variables.intent = len(variables.normalizedField) ? "audition_field" : "ignore">

                        <!--- Update column mapping in DB --->
                        <cfif variables.colId gt 0>
                            <cfset queryExecute(
                                "UPDATE import_auditions_columns
                                 SET intent = :intent,
                                     target_key = :target_key,
                                     user_confirmed = 1,
                                     updated_at = NOW()
                                 WHERE column_id = :column_id
                                   AND job_id = :job_id",
                                {
                                    column_id: { value: variables.colId, cfsqltype: "cf_sql_integer" },
                                    job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
                                    intent: { value: variables.intent, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                                    target_key: { value: variables.normalizedField, cfsqltype: "cf_sql_varchar", maxlength: 100, null: !len(variables.normalizedField) }
                                },
                                { datasource: application.datasource }
                            )>
                        </cfif>
                    </cfif>
                </cfloop>

                <!--- Log mappings applied --->
                <cfset variables.audService.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "mappings_applied",
                    detail = { mappings_count: arrayLen(variables.jsonData.mappings) },
                    correlation_id = getCorrelationId()
                )>
                <cfset addDebug("mappings_applied count=" & variables.mappingCount)>
            <cfelse>
                <cfset addDebug("no_mappings_in_request")>
            </cfif>
            <cfcatch type="any">
                <!--- Log JSON parse error but continue --->
                <cfset variables.audService.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "mappings_parse_error",
                    detail = { error: cfcatch.message },
                    correlation_id = getCorrelationId()
                )>
                <cfset addDebug("mappings_parse_error: " & cfcatch.message)>
                <cflog file="import_auditions" text="Audition recompute mappings_parse_error job_id=#variables.jobId# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
    <cfelse>
        <cfset addDebug("no_json_data_in_request")>
    </cfif>

    <!--- Log recompute started --->
    <cfset variables.audService.logEvent(
        job_id = variables.jobId,
        userid = variables.userid,
        event_type = "recompute_started",
        detail = { previous_status: variables.job.status, skip_dupes: variables.skipDupes },
        correlation_id = getCorrelationId()
    )>

    <!--- D) Load column mappings for this job (reload after applying incoming mappings) --->
    <cfset startPhase("load_columns")>
    <cfset addDebug("step=load_column_mappings")>
    <cfset variables.qColumns = queryExecute(
        "SELECT column_id, source_column_index, source_column_name,
                intent, target_key, transform_json
         FROM import_auditions_columns
         WHERE job_id = :job_id
         ORDER BY source_column_index",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <cfset addDebug("columns_loaded count=" & variables.qColumns.recordCount)>

    <!--- Build column lookup by column_id --->
    <cfset variables.columnMappings = {}>
    <cfset variables.mappingSummary = []>
    <cfloop query="variables.qColumns">
        <cfset variables.columnMappings[variables.qColumns.column_id] = {
            "column_id": variables.qColumns.column_id,
            "source_column_index": variables.qColumns.source_column_index,
            "source_column_name": variables.qColumns.source_column_name,
            "intent": isNull(variables.qColumns.intent) ? "" : variables.qColumns.intent,
            "target_key": isNull(variables.qColumns.target_key) ? "" : variables.qColumns.target_key,
            "transform_json": isNull(variables.qColumns.transform_json) ? "" : variables.qColumns.transform_json
        }>
        <cfset arrayAppend(variables.mappingSummary,
            variables.qColumns.source_column_name & "=" &
            (isNull(variables.qColumns.target_key) ? "NULL" : variables.qColumns.target_key) & "(" &
            (isNull(variables.qColumns.intent) ? "NULL" : variables.qColumns.intent) & ")")>
    </cfloop>
    <cfset addDebug("column_mappings_detail: " & arrayToList(variables.mappingSummary, " | "))>
    <cfset addDebug("column_mappings_keys: " & structKeyList(variables.columnMappings))>
    <cflog file="import_auditions" text="Audition recompute column_mappings job_id=#variables.jobId# keys=#structKeyList(variables.columnMappings)# count=#structCount(variables.columnMappings)# mappings=#arrayToList(variables.mappingSummary, ' | ')#">

    <cfset endPhase()>

    <!--- E) Load all rows for this job --->
    <cfset startPhase("load_rows")>
    <cfset addDebug("step=load_rows")>
    <cfset variables.qRows = queryExecute(
        "SELECT row_id, row_num, raw_json, status, user_action
         FROM import_auditions_rows
         WHERE job_id = :job_id
         ORDER BY row_num",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <cfset addDebug("rows_loaded count=" & variables.qRows.recordCount)>
    <cflog file="import_auditions" text="Audition recompute step=rows_loaded job_id=#variables.jobId# count=#variables.qRows.recordCount#">

    <!--- Counters for summary --->
    <cfset variables.totalRows = variables.qRows.recordCount>
    <cfset variables.validRows = 0>
    <cfset variables.problemRows = 0>
    <cfset variables.dupeRows = 0>
    <cfset variables.ignoredRows = 0>
    <cfset variables.rowsProcessed = 0>

    <cfset endPhase()>

    <!--- F) Process each row --->
    <cfset startPhase("process_rows")>
    <cfset addDebug("step=process_rows_start total=" & variables.totalRows)>
    <cfloop query="variables.qRows">
        <cfset variables.rowId = variables.qRows.row_id>
        <cfset variables.rowNum = variables.qRows.row_num>
        <cfset variables.userAction = isNull(variables.qRows.user_action) ? "" : variables.qRows.user_action>
        <cfset variables.rowsProcessed++>

        <!--- Log progress every 10 rows to avoid huge debug arrays --->
        <cfif variables.rowsProcessed mod 10 eq 0 or variables.rowsProcessed eq 1>
            <cfset addDebug("processing row " & variables.rowsProcessed & "/" & variables.totalRows & " row_id=" & variables.rowId)>
        </cfif>

        <cftry>
            <!--- If user explicitly skipped this row, mark as ignored --->
            <cfif variables.userAction eq "skip">
                <cfset queryExecute(
                    "UPDATE import_auditions_rows
                     SET status = 'ignored', updated_at = NOW()
                     WHERE row_id = :row_id",
                    { row_id: { value: variables.rowId, cfsqltype: "cf_sql_integer" } },
                    { datasource: application.datasource }
                )>
                <cfset variables.ignoredRows++>
                <cfcontinue>
            </cfif>

            <!--- Load facts for this row --->
            <cfset variables.qFacts = queryExecute(
                "SELECT fact_id, column_id, field_name, raw_value, normalized_value
                 FROM import_auditions_facts
                 WHERE row_id = :row_id",
                { row_id: { value: variables.rowId, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            )>

            <!--- Build rowData struct from facts, respecting column mappings --->
            <cfset variables.rowData = {}>
            <cfset variables.rowErrors = []>
            <cfset variables.rowWarnings = []>
            <cfset variables.errorCount = 0>
            <cfset variables.warningCount = 0>

            <cfloop query="variables.qFacts">
                <cfset variables.factId = variables.qFacts.fact_id>
                <cfset variables.columnId = variables.qFacts.column_id>
                <cfset variables.fieldName = variables.qFacts.field_name>
                <cfset variables.rawValue = isNull(variables.qFacts.raw_value) ? "" : variables.qFacts.raw_value>

                <!--- Get column mapping --->
                <cfset variables.columnMappingFound = structKeyExists(variables.columnMappings, variables.columnId)>
                <cfset variables.columnMapping = variables.columnMappingFound ? variables.columnMappings[variables.columnId] : {}>
                <cfset variables.intent = structKeyExists(variables.columnMapping, "intent") ? variables.columnMapping.intent : "">
                <cfset variables.targetKey = structKeyExists(variables.columnMapping, "target_key") ? variables.columnMapping.target_key : "">

                <!--- First row: log every fact's column mapping resolution (validates mapping correctness) --->
                <cfif variables.rowsProcessed eq 1>
                    <cfset addDebug("row1_fact col_id=#variables.columnId# found=#variables.columnMappingFound# field=#variables.fieldName# intent=#variables.intent# target=#variables.targetKey# val=#left(variables.rawValue,30)#")>
                    <cflog file="import_auditions" text="Audition recompute row1_fact job_id=#variables.jobId# col_id=#variables.columnId# found=#variables.columnMappingFound# field=#variables.fieldName# intent=#variables.intent# target=#variables.targetKey# effectiveName=#len(variables.targetKey) ? variables.targetKey : variables.fieldName#">
                    <cfif variables.loggerAvailable>
                    <cfset variables.audLogger.info("row1_mapping", "col_id=#variables.columnId# field=#variables.fieldName# target=#variables.targetKey# intent=#variables.intent#", {
                        "column_id": variables.columnId,
                        "field_name": variables.fieldName,
                        "target_key": variables.targetKey,
                        "intent": variables.intent,
                        "mapping_found": variables.columnMappingFound,
                        "sample_value": left(variables.rawValue, 30)
                    })>
                    </cfif>
                </cfif>

                <!--- Skip ignored columns --->
                <cfif variables.intent eq "ignore">
                    <cfset queryExecute(
                        "UPDATE import_auditions_facts
                         SET is_valid = 1, validation_code = NULL, validation_message = NULL,
                             normalized_value = NULL, updated_at = NOW()
                         WHERE fact_id = :fact_id",
                        { fact_id: { value: variables.factId, cfsqltype: "cf_sql_integer" } },
                        { datasource: application.datasource }
                    )>
                    <cfcontinue>
                </cfif>

                <!--- Determine the effective field name (use target_key if provided) --->
                <cfset variables.effectiveFieldName = len(variables.targetKey) ? variables.targetKey : variables.fieldName>

                <!--- Apply transform_json if present (basic implementation) --->
                <cfset variables.transformedValue = variables.rawValue>
                <cfif structKeyExists(variables.columnMapping, "transform_json") and len(variables.columnMapping.transform_json) gt 0>
                    <cftry>
                        <cfset variables.transformRules = deserializeJSON(variables.columnMapping.transform_json)>
                        <!--- Apply trim transform --->
                        <cfif structKeyExists(variables.transformRules, "trim") and variables.transformRules.trim>
                            <cfset variables.transformedValue = trim(variables.transformedValue)>
                        </cfif>
                        <!--- Apply lowercase transform --->
                        <cfif structKeyExists(variables.transformRules, "lowercase") and variables.transformRules.lowercase>
                            <cfset variables.transformedValue = lcase(variables.transformedValue)>
                        </cfif>
                        <!--- Apply uppercase transform --->
                        <cfif structKeyExists(variables.transformRules, "uppercase") and variables.transformRules.uppercase>
                            <cfset variables.transformedValue = ucase(variables.transformedValue)>
                        </cfif>
                        <cfcatch type="any">
                            <!--- Invalid transform JSON, skip transforms --->
                        </cfcatch>
                    </cftry>
                </cfif>

                <!--- Validate based on audition field type --->
                <cfset variables.factIsValid = true>
                <cfset variables.validationCode = "">
                <cfset variables.validationMessage = "">
                <cfset variables.normalizedValue = variables.transformedValue>

                <cfif len(variables.transformedValue)>
                    <cfswitch expression="#variables.effectiveFieldName#">

                        <!--- contact_name: trim, max 200 chars --->
                        <cfcase value="contact_name">
                            <cfset variables.normalizedValue = trim(variables.transformedValue)>
                            <cfif len(variables.normalizedValue) gt 200>
                                <cfset variables.normalizedValue = left(variables.normalizedValue, 200)>
                                <cfset variables.warningCount++>
                                <cfset arrayAppend(variables.rowWarnings, { field: variables.effectiveFieldName, warning: "Truncated to 200 characters" })>
                            </cfif>
                        </cfcase>

                        <!--- contact_email: basic email format check --->
                        <cfcase value="contact_email">
                            <cfset variables.normalizedValue = lcase(trim(variables.transformedValue))>
                            <cfif not reFindNoCase("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$", variables.normalizedValue)>
                                <cfset variables.factIsValid = false>
                                <cfset variables.validationCode = "INVALID_EMAIL">
                                <cfset variables.validationMessage = "Invalid email format">
                                <cfset variables.errorCount++>
                                <cfset arrayAppend(variables.rowErrors, { field: variables.effectiveFieldName, error: "Invalid email format" })>
                            </cfif>
                        </cfcase>

                        <!--- project_name: trim, max 500 chars --->
                        <cfcase value="project_name">
                            <cfset variables.normalizedValue = trim(variables.transformedValue)>
                            <cfif len(variables.normalizedValue) gt 500>
                                <cfset variables.normalizedValue = left(variables.normalizedValue, 500)>
                                <cfset variables.warningCount++>
                                <cfset arrayAppend(variables.rowWarnings, { field: variables.effectiveFieldName, warning: "Truncated to 500 characters" })>
                            </cfif>
                        </cfcase>

                        <!--- audition_date, callback_date, booking_date: date validation --->
                        <cfcase value="audition_date,callback_date,booking_date">
                            <cftry>
                                <cfset variables.parsedDate = parseDateTime(variables.transformedValue)>
                                <cfset variables.normalizedValue = dateFormat(variables.parsedDate, "yyyy-mm-dd")>
                            <cfcatch type="any">
                                <cfset variables.factIsValid = false>
                                <cfset variables.validationCode = "INVALID_DATE">
                                <cfset variables.validationMessage = "Could not parse as a valid date">
                                <cfset variables.errorCount++>
                                <cfset arrayAppend(variables.rowErrors, { field: variables.effectiveFieldName, error: "Could not parse as a valid date" })>
                            </cfcatch>
                            </cftry>
                        </cfcase>

                        <!--- medium: whitelist check --->
                        <cfcase value="medium">
                            <cfset variables.normalizedValue = trim(variables.transformedValue)>
                            <cfif len(variables.normalizedValue) and not listFindNoCase("Film,Television,Theater,Commercial,Industrial,New Media,Voiceover,Print,Music Video,Web Series,Short Film,Student Film,Other", variables.normalizedValue)>
                                <cfset variables.warningCount++>
                                <cfset arrayAppend(variables.rowWarnings, { field: variables.effectiveFieldName, warning: "Unrecognized medium value; will import as-is" })>
                            </cfif>
                        </cfcase>

                        <!--- status: whitelist check --->
                        <cfcase value="status">
                            <cfset variables.normalizedValue = trim(variables.transformedValue)>
                            <cfif len(variables.normalizedValue) and not listFindNoCase("scheduled,confirmed,cancelled,completed,callback,booked,pending", variables.normalizedValue)>
                                <cfset variables.warningCount++>
                                <cfset arrayAppend(variables.rowWarnings, { field: variables.effectiveFieldName, warning: "Unrecognized status value; will import as-is" })>
                            </cfif>
                        </cfcase>

                        <!--- audition_time: time validation --->
                        <cfcase value="audition_time">
                            <cftry>
                                <cfset variables.parsedTime = parseDateTime(variables.transformedValue)>
                                <cfset variables.normalizedValue = timeFormat(variables.parsedTime, "HH:mm")>
                            <cfcatch type="any">
                                <cfset variables.factIsValid = false>
                                <cfset variables.validationCode = "INVALID_TIME">
                                <cfset variables.validationMessage = "Could not parse as a valid time">
                                <cfset variables.errorCount++>
                                <cfset arrayAppend(variables.rowErrors, { field: variables.effectiveFieldName, error: "Could not parse as a valid time" })>
                            </cfcatch>
                            </cftry>
                        </cfcase>

                        <!--- self_tape: boolean normalization --->
                        <cfcase value="self_tape">
                            <cfset variables.stVal = lcase(trim(variables.transformedValue))>
                            <cfif listFindNoCase("yes,true,1,y", variables.stVal)>
                                <cfset variables.normalizedValue = "1">
                            <cfelseif listFindNoCase("no,false,0,n", variables.stVal)>
                                <cfset variables.normalizedValue = "0">
                            <cfelse>
                                <cfset variables.warningCount++>
                                <cfset arrayAppend(variables.rowWarnings, { field: variables.effectiveFieldName, warning: "Unrecognized boolean; expected yes/no/true/false/1/0" })>
                            </cfif>
                        </cfcase>

                        <!--- Default: trim and cap at 500 --->
                        <cfdefaultcase>
                            <cfset variables.normalizedValue = trim(variables.transformedValue)>
                            <cfif len(variables.normalizedValue) gt 500>
                                <cfset variables.normalizedValue = left(variables.normalizedValue, 500)>
                                <cfset variables.warningCount++>
                                <cfset arrayAppend(variables.rowWarnings, { field: variables.effectiveFieldName, warning: "Truncated to 500 characters" })>
                            </cfif>
                        </cfdefaultcase>

                    </cfswitch>
                </cfif>


                <!--- Update fact with validation results --->
                <cfset queryExecute(
                    "UPDATE import_auditions_facts
                     SET is_valid = :is_valid,
                         validation_code = :validation_code,
                         validation_message = :validation_message,
                         normalized_value = :normalized_value,
                         field_name = :field_name,
                         updated_at = NOW()
                     WHERE fact_id = :fact_id",
                    {
                        fact_id: { value: variables.factId, cfsqltype: "cf_sql_integer" },
                        is_valid: { value: variables.factIsValid ? 1 : 0, cfsqltype: "cf_sql_tinyint" },
                        validation_code: { value: variables.validationCode, cfsqltype: "cf_sql_varchar", maxlength: 30, null: !len(variables.validationCode) },
                        validation_message: { value: variables.validationMessage, cfsqltype: "cf_sql_varchar", maxlength: 255, null: !len(variables.validationMessage) },
                        normalized_value: { value: variables.normalizedValue, cfsqltype: "cf_sql_longvarchar", null: !len(variables.normalizedValue) },
                        field_name: { value: variables.effectiveFieldName, cfsqltype: "cf_sql_varchar", maxlength: 50 }
                    },
                    { datasource: application.datasource }
                )>

                <!--- Add to rowData for duplicate detection (use normalized value if valid) --->
                <cfif variables.factIsValid or len(variables.normalizedValue)>
                    <cfset variables.rowData[variables.effectiveFieldName] = variables.normalizedValue>
                </cfif>
            </cfloop>


            <!--- Diagnostic: log row data keys for first row to aid troubleshooting --->
            <cfif variables.rowsProcessed eq 1>
                <cfset addDebug("row1_data_keys=" & structKeyList(variables.rowData))>
                <cflog file="import_auditions" text="Audition recompute row1_data_keys job_id=#variables.jobId# keys=#structKeyList(variables.rowData)#">
            </cfif>

            <!--- Row-level validation: require contact_name, project_name, audition_date --->
            <cfset variables.hasContactName = structKeyExists(variables.rowData, "contact_name") and len(trim(variables.rowData.contact_name))>
            <cfset variables.hasProjectName = structKeyExists(variables.rowData, "project_name") and len(trim(variables.rowData.project_name))>
            <cfset variables.hasAuditionDate = structKeyExists(variables.rowData, "audition_date") and len(trim(variables.rowData.audition_date))>

            <cfif not variables.hasContactName>
                <cfset variables.errorCount++>
                <cfset arrayAppend(variables.rowErrors, { field: "contact_name", error: "Contact name is required" })>
            </cfif>
            <cfif not variables.hasProjectName>
                <cfset variables.errorCount++>
                <cfset arrayAppend(variables.rowErrors, { field: "project_name", error: "Project name is required" })>
            </cfif>
            <cfif not variables.hasAuditionDate>
                <cfset variables.errorCount++>
                <cfset arrayAppend(variables.rowErrors, { field: "audition_date", error: "Audition date is required" })>
            </cfif>

            <!--- Build validation summary JSON --->
            <cfset variables.validationSummary = {
                "errors": variables.rowErrors,
                "warnings": variables.rowWarnings
            }>

            <!--- Determine row status before duplicate check --->
            <cfset variables.rowStatus = "ready">
            <cfif variables.errorCount gt 0>
                <cfset variables.rowStatus = "problem">
            </cfif>

            <!--- G) Duplicate detection using AuditionDuplicateMatcherService (single-pass) --->
            <cfset variables.dupeCandidatesJson = "">
            <cfset variables.matchedAuditionId = "">
            <cfset variables.bestMatchScore = "">

            <cfif variables.rowStatus eq "ready" and structCount(variables.rowData) gt 0 and variables.dupeDetectionEnabled>
                <!--- Build rowFacts for AuditionDuplicateMatcherService.findDuplicates --->
                <cfset variables.rowFacts = {}>

                <cfif structKeyExists(variables.rowData, "contact_name") and len(trim(variables.rowData.contact_name))>
                    <cfset variables.rowFacts["contact_name"] = trim(variables.rowData.contact_name)>
                </cfif>
                <cfif structKeyExists(variables.rowData, "project_name") and len(trim(variables.rowData.project_name))>
                    <cfset variables.rowFacts["project_name"] = trim(variables.rowData.project_name)>
                </cfif>
                <cfif structKeyExists(variables.rowData, "audition_date") and len(trim(variables.rowData.audition_date))>
                    <cfset variables.rowFacts["audition_date"] = trim(variables.rowData.audition_date)>
                </cfif>
                <cfif structKeyExists(variables.rowData, "role_name") and len(trim(variables.rowData.role_name))>
                    <cfset variables.rowFacts["role_name"] = trim(variables.rowData.role_name)>
                </cfif>
                <cfif structKeyExists(variables.rowData, "casting_director") and len(trim(variables.rowData.casting_director))>
                    <cfset variables.rowFacts["casting_director"] = trim(variables.rowData.casting_director)>
                </cfif>

                <cftry>
                    <!--- Single-pass duplicate detection using in-memory index --->
                    <cfset variables.dupeResult = variables.dupeService.findDuplicates(
                        rowFacts = variables.rowFacts,
                        dupeIndex = variables.dupeIndex
                    )>

                    <!--- Apply threshold logic --->
                    <cfif variables.dupeResult.best_score gte variables.dupeService.THRESHOLD_HIGH>
                        <!--- Score >= 70: auto-mark as duplicate --->
                        <cfset variables.rowStatus = "dupe">
                        <cfset variables.dupeCandidatesJson = serializeJSON(variables.dupeResult.candidates)>
                        <cfset variables.matchedAuditionId = variables.dupeResult.best_audition_id>
                        <cfset variables.bestMatchScore = variables.dupeResult.best_score>
                    <cfelseif variables.dupeResult.best_score gte variables.dupeService.THRESHOLD_MEDIUM>
                        <!--- Score 40-69: store candidates for user review --->
                        <cfset variables.dupeCandidatesJson = serializeJSON(variables.dupeResult.candidates)>
                        <cfset variables.matchedAuditionId = variables.dupeResult.best_audition_id>
                        <cfset variables.bestMatchScore = variables.dupeResult.best_score>
                    <cfelseif variables.dupeResult.best_score gte variables.dupeService.THRESHOLD_LOW>
                        <!--- Score 25-39: store candidates only --->
                        <cfset variables.dupeCandidatesJson = serializeJSON(variables.dupeResult.candidates)>
                        <cfset variables.bestMatchScore = variables.dupeResult.best_score>
                    </cfif>
                    <!--- Score < 25: no action --->

                <cfcatch type="any">
                    <cfset variables.metrics.dupe_errors_count++>
                    <cfset addDebug("dupe_error row_id=" & variables.rowId & " err=" & cfcatch.message)>
                </cfcatch>
                </cftry>
            <cfelseif not variables.dupeDetectionEnabled and variables.rowStatus eq "ready">
                <!--- Dupe detection disabled --->
                <cfif variables.rowsProcessed mod 10 eq 0 or variables.rowsProcessed eq 1>
                    <cfset addDebug("dupe_detection_skipped row_id=" & variables.rowId & " mode=" & variables.metrics.dupe_detection_mode)>
                </cfif>
            </cfif>


            <!--- H) Update row with results --->
            <cfset queryExecute(
                "UPDATE import_auditions_rows
                 SET status = :status,
                     error_count = :error_count,
                     warning_count = :warning_count,
                     validation_summary = :validation_summary,
                     dupe_candidates_json = :dupe_candidates_json,
                     matched_audition_id = :matched_audition_id,
                     best_match_score = :best_match_score,
                     updated_at = NOW()
                 WHERE row_id = :row_id",
                {
                    row_id: { value: variables.rowId, cfsqltype: "cf_sql_integer" },
                    status: { value: variables.rowStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                    error_count: { value: variables.errorCount, cfsqltype: "cf_sql_integer" },
                    warning_count: { value: variables.warningCount, cfsqltype: "cf_sql_integer" },
                    validation_summary: { value: serializeJSON(variables.validationSummary), cfsqltype: "cf_sql_longvarchar" },
                    dupe_candidates_json: { value: variables.dupeCandidatesJson, cfsqltype: "cf_sql_longvarchar", null: !len(variables.dupeCandidatesJson) },
                    matched_audition_id: { value: variables.matchedAuditionId, cfsqltype: "cf_sql_integer", null: !len(variables.matchedAuditionId) },
                    best_match_score: { value: variables.bestMatchScore, cfsqltype: "cf_sql_integer", null: !len(variables.bestMatchScore) }
                },
                { datasource: application.datasource }
            )>

            <!--- Update counters --->
            <cfswitch expression="#variables.rowStatus#">
                <cfcase value="ready">
                    <cfset variables.validRows++>
                </cfcase>
                <cfcase value="problem">
                    <cfset variables.problemRows++>
                </cfcase>
                <cfcase value="dupe">
                    <cfset variables.dupeRows++>
                </cfcase>
                <cfcase value="ignored">
                    <cfset variables.ignoredRows++>
                </cfcase>
            </cfswitch>

            <cfcatch type="any">
                <!--- Log row processing error and update DB status, then continue --->
                <cfset captureFirstFailure(variables.rowId, variables.rowNum, cfcatch.message, "process_row")>
                <cfif variables.loggerAvailable><cfset variables.audLogger.error("row_fail", "row_id=" & variables.rowId & " row_num=" & variables.rowNum & " err=" & cfcatch.message, variables.audLogger.extractErrorDetail(cfcatch))></cfif>
                <cfset addDebug("row_fail row_id=" & variables.rowId & " err=" & cfcatch.message & " detail=" & cfcatch.detail)>
                <cflog file="import_auditions" text="Audition recompute row_fail job_id=#variables.jobId# row_id=#variables.rowId# err=#cfcatch.message# detail=#cfcatch.detail#">
                <cftry>
                    <cfset queryExecute(
                        "UPDATE import_auditions_rows
                         SET status = 'problem',
                             error_count = 1,
                             validation_summary = :validation_summary,
                             updated_at = NOW()
                         WHERE row_id = :row_id",
                        {
                            row_id: { value: variables.rowId, cfsqltype: "cf_sql_integer" },
                            validation_summary: { value: serializeJSON({ "errors": [{ "field": "_row", "error": "Processing error: " & cfcatch.message }], "warnings": [] }), cfsqltype: "cf_sql_longvarchar" }
                        },
                        { datasource: application.datasource }
                    )>
                    <cfcatch type="any">
                        <cflog file="import_auditions" text="Audition recompute row_fail_update_error row_id=#variables.rowId# err=#cfcatch.message#">
                    </cfcatch>
                </cftry>
                <cfset variables.problemRows++>
            </cfcatch>
        </cftry>
    </cfloop>
    <cfset addDebug("step=process_rows_end processed=" & variables.rowsProcessed)>
    <cfset endPhase()>



    <!--- I) Update job with counts --->
    <cfset startPhase("update_counts")>
    <cfset addDebug("step=update_job_counts")>
    <cfset queryExecute(
        "UPDATE import_auditions_jobs
         SET valid_rows = :valid_rows,
             problem_rows = :problem_rows,
             dupe_rows = :dupe_rows,
             skipped_rows = :skipped_rows,
             updated_at = NOW()
         WHERE job_id = :job_id AND userid = :userid",
        {
            job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
            userid: { value: variables.userid, cfsqltype: "cf_sql_integer" },
            valid_rows: { value: variables.validRows, cfsqltype: "cf_sql_integer" },
            problem_rows: { value: variables.problemRows, cfsqltype: "cf_sql_integer" },
            dupe_rows: { value: variables.dupeRows, cfsqltype: "cf_sql_integer" },
            skipped_rows: { value: variables.ignoredRows, cfsqltype: "cf_sql_integer" }
        },
        { datasource: application.datasource }
    )>
    <cfset addDebug("job_counts_updated valid=#variables.validRows# problem=#variables.problemRows# dupe=#variables.dupeRows# ignored=#variables.ignoredRows#")>

    <cfset endPhase()>

    <!--- J) Transition job status to reviewing if currently parsed or mapping --->
    <cfset startPhase("transition_status")>
    <cfset addDebug("step=transition_job_status")>
    <cfif variables.job.status eq "parsed" or variables.job.status eq "mapping">
        <cfset variables.statusResult = variables.audService.setJobStatus(variables.jobId, variables.userid, "reviewing")>
        <cfif not variables.statusResult.success>
            <!--- Log warning but continue - recompute data is already saved --->
            <cfset variables.audService.logEvent(
                job_id = variables.jobId,
                userid = variables.userid,
                event_type = "status_transition_warning",
                detail = { error: variables.statusResult.message, from_status: variables.job.status, to_status: "reviewing" },
                correlation_id = getCorrelationId()
            )>
            <cfset addDebug("status_transition_warning: " & variables.statusResult.message)>
        <cfelse>
            <cfset addDebug("status_transitioned to reviewing")>
        </cfif>
    <cfelse>
        <cfset addDebug("status_unchanged (already reviewing)")>
    </cfif>

    <!--- Log recompute completed --->
    <cfset variables.audService.logEvent(
        job_id = variables.jobId,
        userid = variables.userid,
        event_type = "recompute_completed",
        detail = {
            total_rows: variables.totalRows,
            valid_rows: variables.validRows,
            problem_rows: variables.problemRows,
            dupe_rows: variables.dupeRows,
            ignored_rows: variables.ignoredRows,
            skip_dupes: variables.skipDupes
        },
        correlation_id = getCorrelationId()
    )>
    <cflog file="import_auditions" text="Audition recompute DONE job_id=#variables.jobId# total=#variables.totalRows# valid=#variables.validRows# problem=#variables.problemRows# dupe=#variables.dupeRows# ignored=#variables.ignoredRows# skip_dupes=#variables.skipDupes#">

    <!--- Get updated job --->
    <cfset variables.updatedJobResult = variables.audService.getJobForUser(variables.jobId, variables.userid)>
    <cfset variables.updatedJob = variables.updatedJobResult.data.job>

    <!--- Finalize metrics --->
    <cfset variables.metrics.total_rows_processed = variables.rowsProcessed>
    <cfset variables.metrics.elapsed_ms_total = getTickCount() - variables.recomputeStartTime>
    <cfset variables.metrics.elapsed_ms_dupes_total = variables.dupeElapsedTotal>

    <!--- Enforce invariant: dupe time cannot exceed total time --->
    <cfif variables.metrics.elapsed_ms_dupes_total gt variables.metrics.elapsed_ms_total>
        <cfset variables.metrics.elapsed_ms_dupes_total = variables.metrics.elapsed_ms_total>
    </cfif>

    <!--- If dupe detection was skipped entirely, ensure dupe metrics are zeroed --->
    <cfif variables.metrics.dupe_detection_mode neq "ran">
        <cfset variables.metrics.dupe_queries_total = 0>
        <cfset variables.metrics.dupe_candidates_total = 0>
        <cfset variables.metrics.dupe_index_build_ms = 0>
        <cfset variables.metrics.dupe_index_items_total = 0>
        <cfset variables.metrics.elapsed_ms_dupes_total = 0>
    </cfif>

    <cfset endPhase()>

    <!--- Build success response --->
    <cfset variables.response.success = true>
    <cfset variables.response.message = "Recompute completed">
    <cfset variables.response.elapsed_ms = variables.loggerAvailable ? variables.audLogger.getElapsedMs() : (getTickCount() - variables.recomputeStartTime)>
    <cfif variables.loggerAvailable><cfset variables.audLogger.info("complete", "Recompute completed total=#variables.totalRows# valid=#variables.validRows# problem=#variables.problemRows# dupe=#variables.dupeRows#", variables.phaseTimes)></cfif>
    <cfset variables.response.data = {
        "job": {
            "job_id": variables.jobId,
            "status": variables.updatedJob.status,
            "total_rows": variables.totalRows,
            "valid_rows": variables.validRows,
            "problem_rows": variables.problemRows,
            "dupe_rows": variables.dupeRows,
            "ignored_rows": variables.ignoredRows
        },
        "metrics": variables.metrics,
        "warnings": variables.warnings,
        "phase_times": variables.phaseTimes,
        "first_failure": variables.firstFailure
    }>

    <cfcatch type="any">
        <!--- Use structured logger for full error extraction (with fallback if logger unavailable) --->
        <cfset variables.errDetail = { "message": cfcatch.message, "detail": cfcatch.detail, "type": cfcatch.type, "sql": "", "tagcontext": [] }>
        <cftry>
            <cfif variables.loggerAvailable>
                <cfset variables.errDetail = variables.audLogger.extractErrorDetail(cfcatch)>
                <cfset variables.audLogger.fatal("recompute_failed", cfcatch.message, variables.errDetail)>
            </cfif>
        <cfcatch type="any"></cfcatch>
        </cftry>

        <cfset addDebug("FATAL err=" & cfcatch.message & " detail=" & cfcatch.detail)>
        <cflog file="import_auditions" text="Audition recompute fatal cid=#getCorrelationId()# err=#cfcatch.message# detail=#cfcatch.detail#">

        <cftry>
            <cfset variables.audService.logEvent(
                job_id = variables.jobId,
                userid = variables.userid,
                event_type = "recompute_failed",
                detail = { error: cfcatch.message, detail: cfcatch.detail },
                correlation_id = getCorrelationId()
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>

        <!--- Finalize metrics even on error --->
        <cfset variables.metrics.elapsed_ms_total = getTickCount() - variables.recomputeStartTime>
        <cfset variables.metrics.elapsed_ms_dupes_total = variables.dupeElapsedTotal>

        <!--- Enforce invariant: dupe time cannot exceed total time --->
        <cfif variables.metrics.elapsed_ms_dupes_total gt variables.metrics.elapsed_ms_total>
            <cfset variables.metrics.elapsed_ms_dupes_total = variables.metrics.elapsed_ms_total>
        </cfif>

        <!--- If dupe detection was skipped entirely, ensure dupe metrics are zeroed --->
        <cfif variables.metrics.dupe_detection_mode neq "ran">
            <cfset variables.metrics.dupe_queries_total = 0>
            <cfset variables.metrics.dupe_candidates_total = 0>
            <cfset variables.metrics.dupe_index_build_ms = 0>
            <cfset variables.metrics.dupe_index_items_total = 0>
            <cfset variables.metrics.elapsed_ms_dupes_total = 0>
        </cfif>


        <cfset variables.response.code = "RECOMPUTE_FAILED">
        <cfset variables.response.message = "Recompute failed: " & cfcatch.message>
        <cfset variables.response.elapsed_ms = variables.loggerAvailable ? variables.audLogger.getElapsedMs() : (getTickCount() - variables.recomputeStartTime)>

        <cfset variables.response.data = {
            "error_type": variables.errDetail.type,
            "error_message": variables.errDetail.message,
            "error_detail": variables.errDetail.detail,
            "tagcontext": variables.errDetail.tagcontext,
            "failed_sql": variables.errDetail.sql,
            "dsn": structKeyExists(variables, "runtimeDSN") ? variables.runtimeDSN : "not_yet_resolved",
            "db_name": structKeyExists(variables, "dbName") ? variables.dbName : "not_yet_resolved",
            "metrics": variables.metrics,
            "warnings": variables.warnings,
            "phase_times": variables.phaseTimes,
            "first_failure": variables.firstFailure
        }>
    </cfcatch>
</cftry>

<!--- ============================================================
     OUTERMOST CATCH: Last-resort safety net.
     If ANYTHING above threw before the inner try/catch could
     handle it (variable init, function defs, etc.), this catches
     it and returns the exact diagnostic JSON schema.
     ============================================================ --->
<cfcatch type="any">
    <cfset variables.outerElapsed = getTickCount() - variables.outerStartTime>
    <cfset variables.outerDsn = "">
    <cfset variables.outerDbName = "">
    <cftry>
        <cfset variables.outerDsn = structKeyExists(application, "datasource") ? application.datasource : "UNDEFINED">
        <cfset variables.outerQDb = queryExecute("SELECT DATABASE() AS db_name", {}, { datasource: application.datasource })>
        <cfset variables.outerDbName = variables.outerQDb.db_name>
    <cfcatch type="any">
        <cfset variables.outerDbName = "QUERY_FAILED: " & cfcatch.message>
    </cfcatch>
    </cftry>

    <!--- Build the exact diagnostic schema requested --->
    <cfset variables.outerResponse = {
        "ok": false,
        "stage": "outermost_catch",
        "dsn": variables.outerDsn,
        "db_name": variables.outerDbName,
        "message": cfcatch.message,
        "detail": cfcatch.detail,
        "type": cfcatch.type,
        "sql": structKeyExists(cfcatch, "sql") ? cfcatch.sql : "",
        "tagcontext": structKeyExists(cfcatch, "tagcontext") ? cfcatch.tagcontext : [],
        "debug": variables.outerDebugSteps,
        "elapsed_ms": variables.outerElapsed
    }>
    <cflog file="import_auditions" text="Audition recompute OUTERMOST CATCH: #cfcatch.message# | #cfcatch.detail# | type=#cfcatch.type#" type="fatal">
    <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.outerResponse)#</cfoutput><cfabort>
</cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
