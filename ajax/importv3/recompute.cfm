<cfsetting requesttimeout="300">
<cfsilent>
<!---
    Contact Import V3 - Recompute Endpoint
    POST /ajax/importv3/recompute.cfm

    Validates rows and detects duplicates based on current column mappings.
    Does NOT write to production contact tables.

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
--->

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
<cfset variables.v3Logger = "">
<cfset variables.loggerAvailable = false>
<cftry>
    <cfset variables.v3Logger = new services.ImportV3Logger(endpoint="recompute")>
    <cfset variables.response.correlation_id = getCorrelationId()>
    <cfset variables.loggerAvailable = true>
<cfcatch type="any">
    <!--- Logger CFC failed to load - continue without structured logging --->
    <cfset arrayAppend(variables.response.debug, "WARN: ImportV3Logger failed to init: " & cfcatch.message)>
    <cflog file="importv3" text="ImportV3Logger INIT FAILED: #cfcatch.message# | #cfcatch.detail#" type="error">
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
    "dupe_rows_with_keys": 0,
    "dupe_candidates_unique_total": 0,
    "dupe_index_build_ms": 0,
    "dupe_index_items_total": 0,
    "dupe_index_contactids_total": 0,
    "dupe_index_abort_reason": "",
    "dupe_details_fetch_batches": 0,
    "elapsed_ms_total": 0,
    "elapsed_ms_dupes_total": 0
}>
<cfset variables.warnings = []>
<cfset variables.recomputeStartTime = getTickCount()>
<cfset variables.dupeElapsedTotal = 0>

<!--- Phase 4 batch variables --->
<cfset variables.dupeIndex = {}>
<cfset variables.candidateDetailsCache = {}>
<cfset variables.allCandidateIds = {}>

<!--- Phase 4.1: Store dupeRowData per row for two-pass processing --->
<cfset variables.rowDupeData = []>

<!--- Helper: safe correlation ID accessor --->
<cffunction name="getCorrelationId" access="private" returntype="string" output="false">
    <cfif variables.loggerAvailable>
        <cfreturn getCorrelationId()>
    </cfif>
    <cfreturn "NO_LOGGER">
</cffunction>

<!--- Helper function to add debug breadcrumb + structured log --->
<cffunction name="addDebug" access="private" returntype="void" output="false">
    <cfargument name="msg" type="string" required="true">
    <cfset arrayAppend(variables.response.debug, "[" & timeFormat(now(), "HH:mm:ss.lll") & "] " & arguments.msg)>
    <cftry>
        <cfset variables.v3Logger.debug("recompute", arguments.msg)>
    <cfcatch type="any"></cfcatch>
    </cftry>
</cffunction>

<!--- Helper: start timing a named phase --->
<cffunction name="startPhase" access="private" returntype="void" output="false">
    <cfargument name="phaseName" type="string" required="true">
    <cfset variables.currentPhase = arguments.phaseName>
    <cfset variables.phaseStart = getTickCount()>
    <cftry>
        <cfif variables.loggerAvailable><cfset variables.v3Logger.info(arguments.phaseName, "phase_start")></cfif>
    <cfcatch type="any"></cfcatch>
    </cftry>
</cffunction>

<!--- Helper: end timing current phase --->
<cffunction name="endPhase" access="private" returntype="void" output="false">
    <cfif len(variables.currentPhase) and variables.phaseStart gt 0>
        <cfset var elapsed = getTickCount() - variables.phaseStart>
        <cfset variables.phaseTimes[variables.currentPhase] = elapsed>
        <cftry>
            <cfif variables.loggerAvailable><cfset variables.v3Logger.info(variables.currentPhase, "phase_end ms=" & elapsed)></cfif>
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
        <cftry><cfif variables.loggerAvailable><cfset variables.v3Logger.warn("first_failure", arguments.errorMsg, variables.firstFailure)></cfif><cfcatch type="any"></cfcatch></cftry>
    </cfif>
</cffunction>

<!--- URL param: skip_dupes --->
<cfparam name="url.skip_dupes" default="0">
<cfset variables.skipDupes = val(url.skip_dupes) eq 1>

<cfset addDebug("V3 recompute start, skip_dupes=" & variables.skipDupes)>
<cflog file="importv3" text="V3 recompute start skip_dupes=#variables.skipDupes#">

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfset addDebug("step=auth_check")>
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset variables.response.code = "AUTH_REQUIRED">
        <cfset variables.response.message = "Authentication required">
        <cfset addDebug("FAIL: auth_required")>
        <cflog file="importv3" text="V3 recompute FAIL auth_required">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfif variables.loggerAvailable><cfset variables.v3Logger.setUserId(variables.userid)></cfif>
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

    <!--- Introspect import_v3 table columns for diagnostics --->
    <cftry>
        <cfset variables.qTableCols = queryExecute(
            "SELECT TABLE_NAME, COLUMN_NAME
             FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_NAME IN ('import_v3_jobs','import_v3_rows','import_v3_facts','import_v3_columns')
             ORDER BY TABLE_NAME, ORDINAL_POSITION",
            {},
            { datasource: application.datasource }
        )>
        <cfset variables.tableCols = {}>
        <cfloop query="variables.qTableCols">
            <cfif not structKeyExists(variables.tableCols, variables.qTableCols.TABLE_NAME)>
                <cfset variables.tableCols[variables.qTableCols.TABLE_NAME] = []>
            </cfif>
            <cfset arrayAppend(variables.tableCols[variables.qTableCols.TABLE_NAME], variables.qTableCols.COLUMN_NAME)>
        </cfloop>
        <cfloop collection="#variables.tableCols#" item="variables.tblName">
            <cfset addDebug("schema[" & variables.tblName & "]=" & arrayToList(variables.tableCols[variables.tblName]))>
        </cfloop>
    <cfcatch type="any">
        <cfset addDebug("schema_introspect_error: " & cfcatch.message)>
    </cfcatch>
    </cftry>

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
        <cflog file="importv3" text="V3 recompute FAIL missing_job_id">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfif variables.loggerAvailable><cfset variables.v3Logger.setJobId(variables.jobId)></cfif>
    <cfset addDebug("job_id=" & variables.jobId)>
    <cflog file="importv3" text="V3 recompute job_id=#variables.jobId# userid=#variables.userid#">

    <!--- Initialize services --->
    <cfset addDebug("step=init_services")>
    <cfset variables.v3Service = new services.ContactImportV3Service()>
    <cfset variables.validationService = new services.ValidationService()>
    <cfset variables.dupeService = new services.DuplicateMatcherService()>
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
        <cfset variables.metrics.dupe_schema = structKeyExists(variables.dupeAvailability, "schema") ? variables.dupeAvailability.schema : "unknown">
        <cfset arrayAppend(variables.warnings, "Duplicate detection skipped: " & variables.dupeAvailability.reason)>
        <cfset addDebug("dupe_detection DISABLED schema=" & variables.metrics.dupe_schema & " reason=" & variables.dupeAvailability.reason)>
        <cflog file="importv3" text="V3 recompute dupe_detection DISABLED job_id=#variables.jobId# schema=#variables.metrics.dupe_schema# reason=#variables.dupeAvailability.reason#">
    <cfelse>
        <cfset variables.dupeDetectionEnabled = true>
        <cfset variables.metrics.dupe_detection_mode = "ran">
        <cfset variables.metrics.dupe_schema = structKeyExists(variables.dupeAvailability, "schema") ? variables.dupeAvailability.schema : "unknown">
        <cfset addDebug("dupe_detection ENABLED schema=" & variables.metrics.dupe_schema & " tables available")>
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
                <cfelseif variables.dupeIndex.abort_reason eq "contactids_exceeded">
                    <cfset variables.metrics.dupe_detection_mode = "skipped_index_too_large">
                    <cfset arrayAppend(variables.warnings, "Dupe index skipped: too many contacts (" & variables.dupeIndex.contactids_total & " exceeds limit)")>
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
                <cfset variables.metrics.dupe_index_contactids_total = variables.dupeIndex.contactids_total>
                <cfset addDebug("dupe_index_aborted reason=" & variables.dupeIndex.abort_reason & " items=" & variables.dupeIndex.items_total & " contacts=" & variables.dupeIndex.contactids_total)>
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
                <cfset variables.metrics.dupe_index_contactids_total = variables.dupeIndex.contactids_total>
                <cfset addDebug("dupe_index_built items=" & variables.dupeIndex.items_total & " contacts=" & variables.dupeIndex.contactids_total & " emails=" & structCount(variables.dupeIndex.email_map) & " phones=" & structCount(variables.dupeIndex.phone_map) & " ms=" & variables.dupeIndex.build_ms)>
            </cfif>
            <cfcatch type="any">
                <cfset variables.dupeDetectionEnabled = false>
                <cfset variables.metrics.dupe_detection_mode = "skipped_index_error">
                <cfset variables.metrics.dupe_index_abort_reason = "exception">
                <cfset arrayAppend(variables.warnings, "Dupe index build failed: " & cfcatch.message)>
                <cfset addDebug("dupe_index_build_exception: " & cfcatch.message)>
                <cflog file="importv3" text="V3 recompute dupe_index_build_exception job_id=#variables.jobId# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfset variables.dupeElapsedTotal += (getTickCount() - variables.dupeIndexStartTime)>
    </cfif>

    <!--- B) Verify job ownership --->
    <cfset addDebug("step=verify_job_ownership")>
    <cfset variables.jobResult = variables.v3Service.getJobForUser(variables.jobId, variables.userid)>
    <cfif not variables.jobResult.success>
        <cfset variables.response.code = variables.jobResult.code>
        <cfset variables.response.message = variables.jobResult.message>
        <cfset addDebug("FAIL: job_ownership code=" & variables.jobResult.code)>
        <cflog file="importv3" text="V3 recompute FAIL job_ownership job_id=#variables.jobId# code=#variables.jobResult.code#">
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
        <cflog file="importv3" text="V3 recompute FAIL invalid_state job_id=#variables.jobId# status=#variables.job.status#">
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

                        <!--- Map JS camelCase field names to snake_case for validation --->
                        <cfset variables.fieldNameMap = {
                            "firstName": "first_name",
                            "lastName": "last_name",
                            "contactFullName": "full_name",
                            "email_business": "email_business",
                            "email_personal": "email_personal",
                            "phone_work": "phone_work",
                            "phone_mobile": "phone_mobile",
                            "phone_home": "phone_home",
                            "company": "company",
                            "title": "title",
                            "address1": "address1",
                            "address2": "address2",
                            "city": "city",
                            "state": "state",
                            "zip": "zip",
                            "country": "country",
                            "birthday": "birthday",
                            "relationship_start": "relationship_start",
                            "website": "website",
                            "linkedin": "linkedin",
                            "twitter": "twitter",
                            "instagram": "instagram",
                            "notes": "notes",
                            "tags": "tags",
                            "category": "category",
                            "contactType": "contact_type",
                            "relationship_system": "relationship_system"
                        }>

                        <!--- Convert to snake_case if mapped, otherwise use as-is --->
                        <cfset variables.normalizedField = structKeyExists(variables.fieldNameMap, variables.targetField) ? variables.fieldNameMap[variables.targetField] : variables.targetField>

                        <!--- Determine intent based on field --->
                        <cfset variables.intent = len(variables.normalizedField) ? "contact_field" : "ignore">

                        <!--- Update column mapping in DB --->
                        <cfif variables.colId gt 0>
                            <cfset queryExecute(
                                "UPDATE import_v3_columns
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
                <cfset variables.v3Service.logEvent(
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
                <cfset variables.v3Service.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "mappings_parse_error",
                    detail = { error: cfcatch.message },
                    correlation_id = getCorrelationId()
                )>
                <cfset addDebug("mappings_parse_error: " & cfcatch.message)>
                <cflog file="importv3" text="V3 recompute mappings_parse_error job_id=#variables.jobId# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
    <cfelse>
        <cfset addDebug("no_json_data_in_request")>
    </cfif>

    <!--- Log recompute started --->
    <cfset variables.v3Service.logEvent(
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
         FROM import_v3_columns
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
    <cflog file="importv3" text="V3 recompute column_mappings job_id=#variables.jobId# keys=#structKeyList(variables.columnMappings)# count=#structCount(variables.columnMappings)# mappings=#arrayToList(variables.mappingSummary, ' | ')#">

    <cfset endPhase()>

    <!--- E) Load all rows for this job --->
    <cfset startPhase("load_rows")>
    <cfset addDebug("step=load_rows")>
    <cfset variables.qRows = queryExecute(
        "SELECT row_id, row_num, raw_json, status, user_action
         FROM import_v3_rows
         WHERE job_id = :job_id
         ORDER BY row_num",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <cfset addDebug("rows_loaded count=" & variables.qRows.recordCount)>
    <cflog file="importv3" text="V3 recompute step=rows_loaded job_id=#variables.jobId# count=#variables.qRows.recordCount#">

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
                    "UPDATE import_v3_rows
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
                 FROM import_v3_facts
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
                    <cflog file="importv3" text="V3 recompute row1_fact job_id=#variables.jobId# col_id=#variables.columnId# found=#variables.columnMappingFound# field=#variables.fieldName# intent=#variables.intent# target=#variables.targetKey# effectiveName=#len(variables.targetKey) ? variables.targetKey : variables.fieldName#">
                    <cfif variables.loggerAvailable>
                    <cfset variables.v3Logger.info("row1_mapping", "col_id=#variables.columnId# field=#variables.fieldName# target=#variables.targetKey# intent=#variables.intent#", {
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
                        "UPDATE import_v3_facts
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

                <!--- Validate based on field type --->
                <cfset variables.factIsValid = true>
                <cfset variables.validationCode = "">
                <cfset variables.validationMessage = "">
                <cfset variables.normalizedValue = variables.transformedValue>

                <!--- Email validation --->
                <cfif reFindNoCase("^email", variables.effectiveFieldName) and len(variables.transformedValue)>
                    <cfset variables.vResult = variables.validationService.validateEmail(variables.transformedValue)>
                    <cfset variables.factIsValid = variables.vResult.valid>
                    <cfset variables.normalizedValue = variables.vResult.normalized>
                    <cfif not variables.vResult.valid>
                        <cfset variables.validationCode = "INVALID_EMAIL">
                        <cfset variables.validationMessage = variables.vResult.error>
                        <cfset variables.errorCount++>
                        <cfset arrayAppend(variables.rowErrors, { field: variables.effectiveFieldName, error: variables.vResult.error })>
                    <cfelseif len(variables.vResult.warning)>
                        <cfset variables.warningCount++>
                        <cfset arrayAppend(variables.rowWarnings, { field: variables.effectiveFieldName, warning: variables.vResult.warning })>
                    </cfif>
                <!--- Phone validation --->
                <cfelseif reFindNoCase("^phone", variables.effectiveFieldName) and len(variables.transformedValue)>
                    <cfset variables.vResult = variables.validationService.validatePhone(variables.transformedValue)>
                    <cfset variables.factIsValid = variables.vResult.valid>
                    <cfset variables.normalizedValue = variables.vResult.normalized>
                    <cfif not variables.vResult.valid>
                        <cfset variables.validationCode = "INVALID_PHONE">
                        <cfset variables.validationMessage = variables.vResult.error>
                        <cfset variables.errorCount++>
                        <cfset arrayAppend(variables.rowErrors, { field: variables.effectiveFieldName, error: variables.vResult.error })>
                    </cfif>
                <!--- Date validation --->
                <cfelseif reFindNoCase("(date|birthday)", variables.effectiveFieldName) and len(variables.transformedValue)>
                    <cfset variables.vResult = variables.validationService.validateDate(variables.transformedValue)>
                    <cfset variables.factIsValid = variables.vResult.valid>
                    <cfset variables.normalizedValue = variables.vResult.normalized>
                    <cfif not variables.vResult.valid>
                        <cfset variables.validationCode = "INVALID_DATE">
                        <cfset variables.validationMessage = variables.vResult.error>
                        <cfset variables.errorCount++>
                        <cfset arrayAppend(variables.rowErrors, { field: variables.effectiveFieldName, error: variables.vResult.error })>
                    </cfif>
                <!--- URL validation --->
                <cfelseif reFindNoCase("(url|website)", variables.effectiveFieldName) and len(variables.transformedValue)>
                    <cfset variables.vResult = variables.validationService.validateURL(variables.transformedValue)>
                    <cfset variables.factIsValid = variables.vResult.valid>
                    <cfset variables.normalizedValue = variables.vResult.normalized>
                    <cfif not variables.vResult.valid>
                        <cfset variables.validationCode = "INVALID_URL">
                        <cfset variables.validationMessage = variables.vResult.error>
                        <cfset variables.errorCount++>
                        <cfset arrayAppend(variables.rowErrors, { field: variables.effectiveFieldName, error: variables.vResult.error })>
                    </cfif>
                <!--- String validation (default) --->
                <cfelse>
                    <cfset variables.vResult = variables.validationService.validateString(variables.transformedValue)>
                    <cfset variables.normalizedValue = variables.vResult.normalized>
                    <cfif len(variables.vResult.warning)>
                        <cfset variables.warningCount++>
                        <cfset arrayAppend(variables.rowWarnings, { field: variables.effectiveFieldName, warning: variables.vResult.warning })>
                    </cfif>
                </cfif>

                <!--- Update fact with validation results --->
                <cfset queryExecute(
                    "UPDATE import_v3_facts
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
                <cflog file="importv3" text="V3 recompute row1_data_keys job_id=#variables.jobId# keys=#structKeyList(variables.rowData)#">
            </cfif>

            <!--- Row-level validation: require at least one name field --->
            <!--- ContactFullName is the only DB field; first+last get concatenated during finalize --->
            <cfset variables.hasFirstName = structKeyExists(variables.rowData, "first_name") and len(variables.rowData.first_name)>
            <cfset variables.hasLastName = structKeyExists(variables.rowData, "last_name") and len(variables.rowData.last_name)>
            <cfset variables.hasFullName = structKeyExists(variables.rowData, "full_name") and len(variables.rowData.full_name)>

            <cfif not variables.hasFirstName and not variables.hasLastName and not variables.hasFullName>
                <cfset variables.errorCount++>
                <cfset arrayAppend(variables.rowErrors, { field: "_row", error: "At least one name field (first_name, last_name, or full_name) is required" })>
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

            <!--- G) Phase 4.1 Pass 1: Collect candidate IDs (no DB, index lookup only) --->
            <cfset variables.dupeCandidatesJson = "">
            <cfset variables.matchedContactId = "">
            <cfset variables.bestMatchScore = "">

            <cfif variables.rowStatus eq "ready" and structCount(variables.rowData) gt 0 and variables.dupeDetectionEnabled>
                <!--- Map rowData fields to DuplicateMatcherService expected format --->
                <cfset variables.dupeRowData = {}>

                <!--- Map first_name/last_name to firstName/lastName --->
                <cfif structKeyExists(variables.rowData, "first_name")>
                    <cfset variables.dupeRowData["firstName"] = variables.rowData.first_name>
                </cfif>
                <cfif structKeyExists(variables.rowData, "last_name")>
                    <cfset variables.dupeRowData["lastName"] = variables.rowData.last_name>
                </cfif>
                <cfif structKeyExists(variables.rowData, "full_name")>
                    <cfset variables.dupeRowData["contactFullName"] = variables.rowData.full_name>
                </cfif>

                <!--- Map email fields --->
                <cfif structKeyExists(variables.rowData, "email_business") or structKeyExists(variables.rowData, "email_work")>
                    <cfset variables.dupeRowData["email_business"] = structKeyExists(variables.rowData, "email_business") ? variables.rowData.email_business : variables.rowData.email_work>
                </cfif>
                <cfif structKeyExists(variables.rowData, "email_personal") or structKeyExists(variables.rowData, "email_home")>
                    <cfset variables.dupeRowData["email_personal"] = structKeyExists(variables.rowData, "email_personal") ? variables.rowData.email_personal : variables.rowData.email_home>
                </cfif>

                <!--- Map phone fields --->
                <cfif structKeyExists(variables.rowData, "phone_work")>
                    <cfset variables.dupeRowData["phone_work"] = variables.rowData.phone_work>
                </cfif>
                <cfif structKeyExists(variables.rowData, "phone_mobile") or structKeyExists(variables.rowData, "phone_cell")>
                    <cfset variables.dupeRowData["phone_mobile"] = structKeyExists(variables.rowData, "phone_mobile") ? variables.rowData.phone_mobile : variables.rowData.phone_cell>
                </cfif>
                <cfif structKeyExists(variables.rowData, "phone_home")>
                    <cfset variables.dupeRowData["phone_home"] = variables.rowData.phone_home>
                </cfif>

                <!--- Map other fields --->
                <cfif structKeyExists(variables.rowData, "company")>
                    <cfset variables.dupeRowData["company"] = variables.rowData.company>
                </cfif>
                <cfif structKeyExists(variables.rowData, "city") or structKeyExists(variables.rowData, "address_city")>
                    <cfset variables.dupeRowData["address_city"] = structKeyExists(variables.rowData, "address_city") ? variables.rowData.address_city : variables.rowData.city>
                </cfif>
                <cfif structKeyExists(variables.rowData, "state") or structKeyExists(variables.rowData, "address_state")>
                    <cfset variables.dupeRowData["address_state"] = structKeyExists(variables.rowData, "address_state") ? variables.rowData.address_state : variables.rowData.state>
                </cfif>

                <!--- Phase 4.1: Collect candidate IDs using index (no DB call) --->
                <cftry>
                    <!--- Get candidate IDs from in-memory index lookup --->
                    <cfset variables.dupeResult = variables.dupeService.findDuplicatesWithIndex(
                        userid = variables.userid,
                        rowData = variables.dupeRowData,
                        dupeIndex = variables.dupeIndex,
                        candidateDetailsCache = variables.candidateDetailsCache,
                        threshold = variables.dupeService.THRESHOLD_LOW,
                        metricsRef = variables.metrics
                    )>

                    <!--- Track candidate IDs to fetch (will be batch-fetched after pass 1) --->
                    <cfloop array="#variables.dupeResult.candidateIdsToFetch#" index="variables.cid">
                        <cfset variables.allCandidateIds[variables.cid] = true>
                    </cfloop>

                    <!--- Store dupeRowData for pass 2 scoring --->
                    <cfset arrayAppend(variables.rowDupeData, {
                        "row_id": variables.rowId,
                        "row_index": variables.rowsProcessed,
                        "dupeRowData": variables.dupeRowData,
                        "rowStatus": variables.rowStatus
                    })>

                    <cfcatch type="any">
                        <cfset variables.metrics.dupe_errors_count++>
                        <cfset addDebug("dupe_pass1_error row_id=" & variables.rowId & " err=" & cfcatch.message)>
                    </cfcatch>
                </cftry>
            <cfelseif not variables.dupeDetectionEnabled and variables.rowStatus eq "ready">
                <!--- Dupe detection disabled: mark as ready without checking --->
                <cfif variables.rowsProcessed mod 10 eq 0 or variables.rowsProcessed eq 1>
                    <cfset addDebug("dupe_detection_skipped row_id=" & variables.rowId & " mode=" & variables.metrics.dupe_detection_mode)>
                </cfif>
            </cfif>

            <!--- H) Update row with results --->
            <cfset queryExecute(
                "UPDATE import_v3_rows
                 SET status = :status,
                     error_count = :error_count,
                     warning_count = :warning_count,
                     validation_summary = :validation_summary,
                     dupe_candidates_json = :dupe_candidates_json,
                     matched_contactid = :matched_contactid,
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
                    matched_contactid: { value: variables.matchedContactId, cfsqltype: "cf_sql_integer", null: !len(variables.matchedContactId) },
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
                <cfif variables.loggerAvailable><cfset variables.v3Logger.error("row_fail", "row_id=" & variables.rowId & " row_num=" & variables.rowNum & " err=" & cfcatch.message, variables.v3Logger.extractErrorDetail(cfcatch))></cfif>
                <cfset addDebug("row_fail row_id=" & variables.rowId & " err=" & cfcatch.message & " detail=" & cfcatch.detail)>
                <cflog file="importv3" text="V3 recompute row_fail job_id=#variables.jobId# row_id=#variables.rowId# err=#cfcatch.message# detail=#cfcatch.detail#">
                <cftry>
                    <cfset queryExecute(
                        "UPDATE import_v3_rows
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
                        <cflog file="importv3" text="V3 recompute row_fail_update_error row_id=#variables.rowId# err=#cfcatch.message#">
                    </cfcatch>
                </cftry>
                <cfset variables.problemRows++>
            </cfcatch>
        </cftry>
    </cfloop>
    <cfset addDebug("step=process_rows_end processed=" & variables.rowsProcessed)>
    <cfset endPhase()>

    <!--- Phase 4.1 Pass 2: Batch fetch all candidate details, then score rows --->
    <cfif variables.dupeDetectionEnabled and structCount(variables.allCandidateIds) gt 0>
        <cfset startPhase("dupe_pass2")>
        <cfset addDebug("step=dupe_pass2_start candidates_to_fetch=" & structCount(variables.allCandidateIds))>
        <cfset variables.dupePass2StartTime = getTickCount()>

        <!--- Convert allCandidateIds struct keys to array --->
        <cfset variables.candidateIdArray = structKeyArray(variables.allCandidateIds)>
        <cfset variables.metrics.dupe_candidates_unique_total = arrayLen(variables.candidateIdArray)>

        <!--- Batch fetch in chunks --->
        <cfset variables.chunkSize = variables.dupeService.DETAILS_BATCH_CHUNK_SIZE>
        <cfset variables.totalChunks = ceiling(arrayLen(variables.candidateIdArray) / variables.chunkSize)>
        <cfset addDebug("dupe_pass2_fetching total=" & arrayLen(variables.candidateIdArray) & " chunks=" & variables.totalChunks & " chunk_size=" & variables.chunkSize)>

        <cfloop from="1" to="#variables.totalChunks#" index="variables.chunkNum">
            <cfset variables.startIdx = ((variables.chunkNum - 1) * variables.chunkSize) + 1>
            <cfset variables.endIdx = min(variables.chunkNum * variables.chunkSize, arrayLen(variables.candidateIdArray))>
            <cfset variables.chunkIds = []>

            <cfloop from="#variables.startIdx#" to="#variables.endIdx#" index="variables.i">
                <cfset arrayAppend(variables.chunkIds, variables.candidateIdArray[variables.i])>
            </cfloop>

            <!--- Fetch this chunk (2 queries per chunk) --->
            <cftry>
                <cfset variables.chunkDetails = variables.dupeService.getCandidateDetailsBatch(
                    userid = variables.userid,
                    contactIds = variables.chunkIds,
                    metricsRef = variables.metrics
                )>
                <cfset variables.metrics.dupe_details_fetch_batches++>

                <!--- Merge into cache --->
                <cfloop collection="#variables.chunkDetails#" item="variables.cid">
                    <cfset variables.candidateDetailsCache[variables.cid] = variables.chunkDetails[variables.cid]>
                </cfloop>

                <cfcatch type="any">
                    <cfset addDebug("dupe_pass2_chunk_error chunk=" & variables.chunkNum & " err=" & cfcatch.message)>
                </cfcatch>
            </cftry>
        </cfloop>

        <cfset addDebug("dupe_pass2_fetch_complete cached=" & structCount(variables.candidateDetailsCache) & " batches=" & variables.metrics.dupe_details_fetch_batches)>

        <!--- Now score each row using cached details --->
        <cfset addDebug("step=dupe_pass2_scoring rows=" & arrayLen(variables.rowDupeData))>

        <cfloop array="#variables.rowDupeData#" index="variables.rowEntry">
            <cftry>
                <!--- Re-run findDuplicatesWithIndex with populated cache --->
                <cfset variables.dupeResult = variables.dupeService.findDuplicatesWithIndex(
                    userid = variables.userid,
                    rowData = variables.rowEntry.dupeRowData,
                    dupeIndex = variables.dupeIndex,
                    candidateDetailsCache = variables.candidateDetailsCache,
                    threshold = variables.dupeService.THRESHOLD_LOW,
                    metricsRef = variables.metrics
                )>

                <!--- Update row if duplicates found --->
                <cfif variables.dupeResult.hasDuplicate>
                    <cfset variables.dupeCandidatesJson = serializeJSON(variables.dupeResult.candidates)>
                    <cfset variables.bestMatchScore = variables.dupeResult.bestMatchScore>
                    <cfset variables.matchedContactId = variables.dupeResult.bestMatchContactId>
                    <cfset variables.newRowStatus = variables.rowEntry.rowStatus>

                    <!--- Flag as duplicate if score >= 60 (MEDIUM threshold) --->
                    <cfif variables.bestMatchScore gte 60>
                        <cfset variables.newRowStatus = "dupe">
                        <!--- Adjust counters --->
                        <cfif variables.rowEntry.rowStatus eq "ready">
                            <cfset variables.validRows = variables.validRows - 1>
                            <cfset variables.dupeRows = variables.dupeRows + 1>
                        </cfif>
                    </cfif>

                    <!--- Update row with dupe results --->
                    <cfset queryExecute(
                        "UPDATE import_v3_rows
                         SET status = :status,
                             dupe_candidates_json = :dupe_candidates_json,
                             matched_contactid = :matched_contactid,
                             best_match_score = :best_match_score,
                             updated_at = NOW()
                         WHERE row_id = :row_id",
                        {
                            row_id: { value: variables.rowEntry.row_id, cfsqltype: "cf_sql_integer" },
                            status: { value: variables.newRowStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                            dupe_candidates_json: { value: variables.dupeCandidatesJson, cfsqltype: "cf_sql_longvarchar" },
                            matched_contactid: { value: variables.matchedContactId, cfsqltype: "cf_sql_integer" },
                            best_match_score: { value: variables.bestMatchScore, cfsqltype: "cf_sql_integer" }
                        },
                        { datasource: application.datasource }
                    )>
                </cfif>

                <cfcatch type="any">
                    <cfset variables.metrics.dupe_errors_count++>
                    <cfset addDebug("dupe_pass2_score_error row_id=" & variables.rowEntry.row_id & " err=" & cfcatch.message)>
                </cfcatch>
            </cftry>
        </cfloop>

        <cfset variables.dupeElapsedTotal += (getTickCount() - variables.dupePass2StartTime)>
        <cfset addDebug("step=dupe_pass2_end elapsed_ms=" & (getTickCount() - variables.dupePass2StartTime))>
        <cfset endPhase()>
    </cfif>

    <!--- I) Update job with counts --->
    <cfset startPhase("update_counts")>
    <cfset addDebug("step=update_job_counts")>
    <cfset queryExecute(
        "UPDATE import_v3_jobs
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
        <cfset variables.statusResult = variables.v3Service.setJobStatus(variables.jobId, variables.userid, "reviewing")>
        <cfif not variables.statusResult.success>
            <!--- Log warning but continue - recompute data is already saved --->
            <cfset variables.v3Service.logEvent(
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
    <cfset variables.v3Service.logEvent(
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
    <cflog file="importv3" text="V3 recompute DONE job_id=#variables.jobId# total=#variables.totalRows# valid=#variables.validRows# problem=#variables.problemRows# dupe=#variables.dupeRows# ignored=#variables.ignoredRows# skip_dupes=#variables.skipDupes#">

    <!--- Get updated job --->
    <cfset variables.updatedJobResult = variables.v3Service.getJobForUser(variables.jobId, variables.userid)>
    <cfset variables.updatedJob = variables.updatedJobResult.data.job>

    <!--- Finalize metrics --->
    <cfset variables.metrics.total_rows_processed = variables.rowsProcessed>
    <cfset variables.metrics.elapsed_ms_total = getTickCount() - variables.recomputeStartTime>
    <cfset variables.metrics.elapsed_ms_dupes_total = variables.dupeElapsedTotal>
    <cfset variables.metrics.dupe_candidates_unique_total = structCount(variables.allCandidateIds)>

    <!--- Enforce invariant: dupe time cannot exceed total time --->
    <cfif variables.metrics.elapsed_ms_dupes_total gt variables.metrics.elapsed_ms_total>
        <cfset variables.metrics.elapsed_ms_dupes_total = variables.metrics.elapsed_ms_total>
    </cfif>

    <!--- If dupe detection was skipped entirely, ensure dupe metrics are zeroed --->
    <cfif variables.metrics.dupe_detection_mode neq "ran">
        <cfset variables.metrics.dupe_queries_total = 0>
        <cfset variables.metrics.dupe_candidates_total = 0>
        <cfset variables.metrics.dupe_candidates_unique_total = 0>
        <cfset variables.metrics.dupe_index_build_ms = 0>
        <cfset variables.metrics.dupe_index_items_total = 0>
        <cfset variables.metrics.dupe_index_contactids_total = 0>
        <cfset variables.metrics.dupe_details_fetch_batches = 0>
        <cfset variables.metrics.elapsed_ms_dupes_total = 0>
        <!--- dupe_rows_with_keys stays as-is: it counts rows that HAD keys, not rows processed for dupes --->
    </cfif>

    <cfset endPhase()>

    <!--- Build success response --->
    <cfset variables.response.success = true>
    <cfset variables.response.message = "Recompute completed">
    <cfset variables.response.elapsed_ms = variables.loggerAvailable ? variables.v3Logger.getElapsedMs() : (getTickCount() - variables.recomputeStartTime)>
    <cfset addDebug("step=metrics_final elapsed_total=" & variables.metrics.elapsed_ms_total & " elapsed_dupes=" & variables.metrics.elapsed_ms_dupes_total & " queries=" & variables.metrics.dupe_queries_total & " index_items=" & variables.metrics.dupe_index_items_total & " index_contacts=" & variables.metrics.dupe_index_contactids_total & " candidates_unique=" & variables.metrics.dupe_candidates_unique_total & " detail_batches=" & variables.metrics.dupe_details_fetch_batches & " mode=" & variables.metrics.dupe_detection_mode)>
    <cfif variables.loggerAvailable><cfset variables.v3Logger.info("complete", "Recompute completed total=#variables.totalRows# valid=#variables.validRows# problem=#variables.problemRows# dupe=#variables.dupeRows#", variables.phaseTimes)></cfif>
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
                <cfset variables.errDetail = variables.v3Logger.extractErrorDetail(cfcatch)>
                <cfset variables.v3Logger.fatal("recompute_failed", cfcatch.message, variables.errDetail)>
            </cfif>
        <cfcatch type="any"></cfcatch>
        </cftry>

        <cfset addDebug("FATAL err=" & cfcatch.message & " detail=" & cfcatch.detail)>
        <cflog file="importv3" text="V3 recompute fatal cid=#getCorrelationId()# err=#cfcatch.message# detail=#cfcatch.detail#">

        <cftry>
            <cfset variables.v3Service.logEvent(
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
        <cfset variables.metrics.dupe_candidates_unique_total = structCount(variables.allCandidateIds)>

        <!--- Enforce invariant: dupe time cannot exceed total time --->
        <cfif variables.metrics.elapsed_ms_dupes_total gt variables.metrics.elapsed_ms_total>
            <cfset variables.metrics.elapsed_ms_dupes_total = variables.metrics.elapsed_ms_total>
        </cfif>

        <!--- If dupe detection was skipped entirely, ensure dupe metrics are zeroed --->
        <cfif variables.metrics.dupe_detection_mode neq "ran">
            <cfset variables.metrics.dupe_queries_total = 0>
            <cfset variables.metrics.dupe_candidates_total = 0>
            <cfset variables.metrics.dupe_candidates_unique_total = 0>
            <cfset variables.metrics.dupe_index_build_ms = 0>
            <cfset variables.metrics.dupe_index_items_total = 0>
            <cfset variables.metrics.dupe_index_contactids_total = 0>
            <cfset variables.metrics.dupe_details_fetch_batches = 0>
            <cfset variables.metrics.elapsed_ms_dupes_total = 0>
        </cfif>

        <cfset addDebug("step=metrics_final elapsed_total=" & variables.metrics.elapsed_ms_total & " elapsed_dupes=" & variables.metrics.elapsed_ms_dupes_total & " queries=" & variables.metrics.dupe_queries_total & " index_items=" & variables.metrics.dupe_index_items_total & " index_contacts=" & variables.metrics.dupe_index_contactids_total & " candidates_unique=" & variables.metrics.dupe_candidates_unique_total & " detail_batches=" & variables.metrics.dupe_details_fetch_batches & " mode=" & variables.metrics.dupe_detection_mode)>

        <cfset variables.response.code = "RECOMPUTE_FAILED">
        <cfset variables.response.message = "Recompute failed: " & cfcatch.message>
        <cfset variables.response.elapsed_ms = variables.loggerAvailable ? variables.v3Logger.getElapsedMs() : (getTickCount() - variables.recomputeStartTime)>

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
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
