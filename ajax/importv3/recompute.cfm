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
<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "debug": [],
    "data": {}
}>

<!--- Initialize metrics tracking --->
<cfset metrics = {
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
<cfset warnings = []>
<cfset recomputeStartTime = getTickCount()>
<cfset dupeElapsedTotal = 0>

<!--- Phase 4 batch variables --->
<cfset dupeIndex = {}>
<cfset candidateDetailsCache = {}>
<cfset allCandidateIds = {}>

<!--- Phase 4.1: Store dupeRowData per row for two-pass processing --->
<cfset rowDupeData = []>

<!--- Helper function to add debug breadcrumb --->
<cffunction name="addDebug" access="private" returntype="void" output="false">
    <cfargument name="msg" type="string" required="true">
    <cfset arrayAppend(response.debug, "[" & timeFormat(now(), "HH:mm:ss.lll") & "] " & arguments.msg)>
</cffunction>

<!--- URL param: skip_dupes --->
<cfparam name="url.skip_dupes" default="0">
<cfset skipDupes = val(url.skip_dupes) eq 1>

<cfset addDebug("V3 recompute start, skip_dupes=" & skipDupes)>
<cflog file="importv3" text="V3 recompute start skip_dupes=#skipDupes#">

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfset addDebug("step=auth_check")>
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfset addDebug("FAIL: auth_required")>
        <cflog file="importv3" text="V3 recompute FAIL auth_required">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>
    <cfset addDebug("step=auth_ok userid=" & userid)>

    <!--- Parse JSON body first (for JSON content type requests) --->
    <cfset addDebug("step=parse_json_body")>
    <cfset requestBody = "">
    <cfset jsonData = {}>
    <cftry>
        <cfset requestBody = toString(getHTTPRequestData().content)>
        <cfif len(requestBody)>
            <cfset jsonData = deserializeJSON(requestBody)>
            <cfset addDebug("json_body_parsed keys=" & structKeyList(jsonData))>
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
    <cfset jobId = 0>

    <!--- Priority: JSON body > form > url --->
    <cfif structKeyExists(jsonData, "job_id")>
        <cfset jobId = val(jsonData.job_id)>
    </cfif>
    <cfif jobId eq 0>
        <cfset jobId = val(form.job_id)>
    </cfif>
    <cfif jobId eq 0>
        <cfset jobId = val(url.job_id)>
    </cfif>

    <cfif jobId lte 0>
        <cfset response.code = "MISSING_JOB_ID">
        <cfset response.message = "job_id is required">
        <cfset addDebug("FAIL: missing_job_id")>
        <cflog file="importv3" text="V3 recompute FAIL missing_job_id">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("job_id=" & jobId)>
    <cflog file="importv3" text="V3 recompute job_id=#jobId# userid=#userid#">

    <!--- Initialize services --->
    <cfset addDebug("step=init_services")>
    <cfset v3Service = new services.ContactImportV3Service()>
    <cfset validationService = new services.ValidationService()>
    <cfset dupeService = new services.DuplicateMatcherService()>
    <cfset addDebug("services_initialized")>

    <!--- Preflight check: Is duplicate detection available? --->
    <cfset addDebug("step=dupe_preflight_check")>
    <cfset dupeAvailability = dupeService.isDupeDetectionAvailable()>
    <cfset dupeDetectionEnabled = false>

    <cfif skipDupes>
        <cfset metrics.dupe_detection_mode = "skipped_url_param">
        <cfset addDebug("dupe_detection DISABLED by skip_dupes=1 URL param")>
    <cfelseif not dupeAvailability.available>
        <cfset metrics.dupe_detection_mode = "skipped_missing_tables">
        <cfset metrics.dupe_schema = structKeyExists(dupeAvailability, "schema") ? dupeAvailability.schema : "unknown">
        <cfset arrayAppend(warnings, "Duplicate detection skipped: " & dupeAvailability.reason)>
        <cfset addDebug("dupe_detection DISABLED schema=" & metrics.dupe_schema & " reason=" & dupeAvailability.reason)>
        <cflog file="importv3" text="V3 recompute dupe_detection DISABLED job_id=#jobId# schema=#metrics.dupe_schema# reason=#dupeAvailability.reason#">
    <cfelse>
        <cfset dupeDetectionEnabled = true>
        <cfset metrics.dupe_detection_mode = "ran">
        <cfset metrics.dupe_schema = structKeyExists(dupeAvailability, "schema") ? dupeAvailability.schema : "unknown">
        <cfset addDebug("dupe_detection ENABLED schema=" & metrics.dupe_schema & " tables available")>
    </cfif>

    <!--- PHASE 4: Build dupe index once if dupe detection is enabled --->
    <cfif dupeDetectionEnabled>
        <cfset addDebug("step=build_dupe_index")>
        <cfset dupeIndexStartTime = getTickCount()>
        <cftry>
            <cfset dupeIndex = dupeService.buildUserDupeIndex(userid, metrics)>

            <!--- Phase 4.1: Check for abort_reason from guardrails --->
            <cfif len(dupeIndex.abort_reason)>
                <cfset dupeDetectionEnabled = false>
                <cfif dupeIndex.abort_reason eq "items_exceeded">
                    <cfset metrics.dupe_detection_mode = "skipped_index_too_large">
                    <cfset arrayAppend(warnings, "Dupe index skipped: too many items (" & dupeIndex.items_total & " exceeds limit)")>
                <cfelseif dupeIndex.abort_reason eq "contactids_exceeded">
                    <cfset metrics.dupe_detection_mode = "skipped_index_too_large">
                    <cfset arrayAppend(warnings, "Dupe index skipped: too many contacts (" & dupeIndex.contactids_total & " exceeds limit)")>
                <cfelseif dupeIndex.abort_reason eq "timeout">
                    <cfset metrics.dupe_detection_mode = "skipped_index_timeout">
                    <cfset arrayAppend(warnings, "Dupe index skipped: build timeout (" & dupeIndex.build_ms & "ms)")>
                <cfelse>
                    <cfset metrics.dupe_detection_mode = "skipped_index_error">
                    <cfset arrayAppend(warnings, "Dupe index skipped: " & dupeIndex.abort_reason)>
                </cfif>
                <cfset metrics.dupe_index_abort_reason = dupeIndex.abort_reason>
                <cfset metrics.dupe_index_build_ms = dupeIndex.build_ms>
                <cfset metrics.dupe_index_items_total = dupeIndex.items_total>
                <cfset metrics.dupe_index_contactids_total = dupeIndex.contactids_total>
                <cfset addDebug("dupe_index_aborted reason=" & dupeIndex.abort_reason & " items=" & dupeIndex.items_total & " contacts=" & dupeIndex.contactids_total)>
            <cfelseif structKeyExists(dupeIndex, "error")>
                <!--- Index build failed with exception --->
                <cfset dupeDetectionEnabled = false>
                <cfset metrics.dupe_detection_mode = "skipped_index_error">
                <cfset metrics.dupe_index_abort_reason = "exception">
                <cfset arrayAppend(warnings, "Dupe index build failed: " & dupeIndex.error)>
                <cfset addDebug("dupe_index_build_error: " & dupeIndex.error)>
            <cfelse>
                <cfset metrics.dupe_index_build_ms = dupeIndex.build_ms>
                <cfset metrics.dupe_index_items_total = dupeIndex.items_total>
                <cfset metrics.dupe_index_contactids_total = dupeIndex.contactids_total>
                <cfset addDebug("dupe_index_built items=" & dupeIndex.items_total & " contacts=" & dupeIndex.contactids_total & " emails=" & structCount(dupeIndex.email_map) & " phones=" & structCount(dupeIndex.phone_map) & " ms=" & dupeIndex.build_ms)>
            </cfif>
            <cfcatch type="any">
                <cfset dupeDetectionEnabled = false>
                <cfset metrics.dupe_detection_mode = "skipped_index_error">
                <cfset metrics.dupe_index_abort_reason = "exception">
                <cfset arrayAppend(warnings, "Dupe index build failed: " & cfcatch.message)>
                <cfset addDebug("dupe_index_build_exception: " & cfcatch.message)>
                <cflog file="importv3" text="V3 recompute dupe_index_build_exception job_id=#jobId# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfset dupeElapsedTotal += (getTickCount() - dupeIndexStartTime)>
    </cfif>

    <!--- B) Verify job ownership --->
    <cfset addDebug("step=verify_job_ownership")>
    <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
    <cfif not jobResult.success>
        <cfset response.code = jobResult.code>
        <cfset response.message = jobResult.message>
        <cfset addDebug("FAIL: job_ownership code=" & jobResult.code)>
        <cflog file="importv3" text="V3 recompute FAIL job_ownership job_id=#jobId# code=#jobResult.code#">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset job = jobResult.data.job>
    <cfset addDebug("job_verified status=" & job.status)>

    <!--- C) Validate job status - only allow recompute from these states --->
    <cfset addDebug("step=validate_job_status")>
    <cfset ALLOWED_STATUSES = ["parsed", "mapping", "reviewing"]>
    <cfif not arrayFindNoCase(ALLOWED_STATUSES, job.status)>
        <cfset response.code = "INVALID_STATE">
        <cfset response.message = "Cannot recompute from status: " & job.status & ". Allowed: " & arrayToList(ALLOWED_STATUSES, ", ")>
        <cfset response.data = { current_status: job.status, allowed: ALLOWED_STATUSES }>
        <cfset addDebug("FAIL: invalid_state current=" & job.status)>
        <cflog file="importv3" text="V3 recompute FAIL invalid_state job_id=#jobId# status=#job.status#">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("job_status_valid")>

    <!--- Process incoming mappings from JSON body if provided --->
    <cfset addDebug("step=process_mappings")>
    <cfif structCount(jsonData) gt 0>
        <cftry>
            <!--- Process mappings array if provided --->
            <cfif structKeyExists(jsonData, "mappings") and isArray(jsonData.mappings)>
                <cfset mappingCount = arrayLen(jsonData.mappings)>
                <cfset addDebug("mappings_count=" & mappingCount)>
                <cfloop array="#jsonData.mappings#" index="mapping">
                    <cfif structKeyExists(mapping, "column_id") and structKeyExists(mapping, "field")>
                        <cfset colId = val(mapping.column_id)>
                        <cfset targetField = trim(mapping.field)>

                        <!--- Map JS camelCase field names to snake_case for validation --->
                        <cfset fieldNameMap = {
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
                        <cfset normalizedField = structKeyExists(fieldNameMap, targetField) ? fieldNameMap[targetField] : targetField>

                        <!--- Determine intent based on field --->
                        <cfset intent = len(normalizedField) ? "contact_field" : "ignore">

                        <!--- Update column mapping in DB --->
                        <cfif colId gt 0>
                            <cfset queryExecute(
                                "UPDATE import_v3_columns
                                 SET intent = :intent,
                                     target_key = :target_key,
                                     user_confirmed = 1,
                                     updated_at = NOW()
                                 WHERE column_id = :column_id
                                   AND job_id = :job_id",
                                {
                                    column_id: { value: colId, cfsqltype: "cf_sql_integer" },
                                    job_id: { value: jobId, cfsqltype: "cf_sql_integer" },
                                    intent: { value: intent, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                                    target_key: { value: normalizedField, cfsqltype: "cf_sql_varchar", maxlength: 100, null: !len(normalizedField) }
                                },
                                { datasource: application.datasource }
                            )>
                        </cfif>
                    </cfif>
                </cfloop>

                <!--- Log mappings applied --->
                <cfset v3Service.logEvent(
                    job_id = jobId,
                    userid = userid,
                    event_type = "mappings_applied",
                    detail = { mappings_count: arrayLen(jsonData.mappings) }
                )>
                <cfset addDebug("mappings_applied count=" & mappingCount)>
            <cfelse>
                <cfset addDebug("no_mappings_in_request")>
            </cfif>
            <cfcatch type="any">
                <!--- Log JSON parse error but continue --->
                <cfset v3Service.logEvent(
                    job_id = jobId,
                    userid = userid,
                    event_type = "mappings_parse_error",
                    detail = { error: cfcatch.message }
                )>
                <cfset addDebug("mappings_parse_error: " & cfcatch.message)>
                <cflog file="importv3" text="V3 recompute mappings_parse_error job_id=#jobId# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
    <cfelse>
        <cfset addDebug("no_json_data_in_request")>
    </cfif>

    <!--- Log recompute started --->
    <cfset v3Service.logEvent(
        job_id = jobId,
        userid = userid,
        event_type = "recompute_started",
        detail = { previous_status: job.status, skip_dupes: skipDupes }
    )>

    <!--- D) Load column mappings for this job (reload after applying incoming mappings) --->
    <cfset addDebug("step=load_column_mappings")>
    <cfset qColumns = queryExecute(
        "SELECT column_id, source_column_index, source_column_name,
                intent, target_key, transform_json
         FROM import_v3_columns
         WHERE job_id = :job_id
         ORDER BY source_column_index",
        { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <cfset addDebug("columns_loaded count=" & qColumns.recordCount)>

    <!--- Build column lookup by column_id --->
    <cfset columnMappings = {}>
    <cfloop query="qColumns">
        <cfset columnMappings[qColumns.column_id] = {
            "column_id": qColumns.column_id,
            "source_column_index": qColumns.source_column_index,
            "source_column_name": qColumns.source_column_name,
            "intent": isNull(qColumns.intent) ? "" : qColumns.intent,
            "target_key": isNull(qColumns.target_key) ? "" : qColumns.target_key,
            "transform_json": isNull(qColumns.transform_json) ? "" : qColumns.transform_json
        }>
    </cfloop>

    <!--- E) Load all rows for this job --->
    <cfset addDebug("step=load_rows")>
    <cfset qRows = queryExecute(
        "SELECT row_id, row_num, raw_json, status, user_action
         FROM import_v3_rows
         WHERE job_id = :job_id
         ORDER BY row_num",
        { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <cfset addDebug("rows_loaded count=" & qRows.recordCount)>
    <cflog file="importv3" text="V3 recompute step=rows_loaded job_id=#jobId# count=#qRows.recordCount#">

    <!--- Counters for summary --->
    <cfset totalRows = qRows.recordCount>
    <cfset validRows = 0>
    <cfset problemRows = 0>
    <cfset dupeRows = 0>
    <cfset ignoredRows = 0>
    <cfset rowsProcessed = 0>

    <!--- F) Process each row --->
    <cfset addDebug("step=process_rows_start total=" & totalRows)>
    <cfloop query="qRows">
        <cfset rowId = qRows.row_id>
        <cfset rowNum = qRows.row_num>
        <cfset userAction = isNull(qRows.user_action) ? "" : qRows.user_action>
        <cfset rowsProcessed++>

        <!--- Log progress every 10 rows to avoid huge debug arrays --->
        <cfif rowsProcessed mod 10 eq 0 or rowsProcessed eq 1>
            <cfset addDebug("processing row " & rowsProcessed & "/" & totalRows & " row_id=" & rowId)>
        </cfif>

        <cftry>
            <!--- If user explicitly skipped this row, mark as ignored --->
            <cfif userAction eq "skip">
                <cfset queryExecute(
                    "UPDATE import_v3_rows
                     SET status = 'ignored', updated_at = NOW()
                     WHERE row_id = :row_id",
                    { row_id: { value: rowId, cfsqltype: "cf_sql_integer" } },
                    { datasource: application.datasource }
                )>
                <cfset ignoredRows++>
                <cfcontinue>
            </cfif>

            <!--- Load facts for this row --->
            <cfset qFacts = queryExecute(
                "SELECT fact_id, column_id, field_name, raw_value, normalized_value
                 FROM import_v3_facts
                 WHERE row_id = :row_id",
                { row_id: { value: rowId, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            )>

            <!--- Build rowData struct from facts, respecting column mappings --->
            <cfset rowData = {}>
            <cfset rowErrors = []>
            <cfset rowWarnings = []>
            <cfset errorCount = 0>
            <cfset warningCount = 0>

            <cfloop query="qFacts">
                <cfset factId = qFacts.fact_id>
                <cfset columnId = qFacts.column_id>
                <cfset fieldName = qFacts.field_name>
                <cfset rawValue = isNull(qFacts.raw_value) ? "" : qFacts.raw_value>

                <!--- Get column mapping --->
                <cfset columnMapping = structKeyExists(columnMappings, columnId) ? columnMappings[columnId] : {}>
                <cfset intent = structKeyExists(columnMapping, "intent") ? columnMapping.intent : "">
                <cfset targetKey = structKeyExists(columnMapping, "target_key") ? columnMapping.target_key : "">

                <!--- Skip ignored columns --->
                <cfif intent eq "ignore">
                    <cfset queryExecute(
                        "UPDATE import_v3_facts
                         SET is_valid = 1, validation_code = NULL, validation_message = NULL,
                             normalized_value = NULL, updated_at = NOW()
                         WHERE fact_id = :fact_id",
                        { fact_id: { value: factId, cfsqltype: "cf_sql_integer" } },
                        { datasource: application.datasource }
                    )>
                    <cfcontinue>
                </cfif>

                <!--- Determine the effective field name (use target_key if provided) --->
                <cfset effectiveFieldName = len(targetKey) ? targetKey : fieldName>

                <!--- Apply transform_json if present (basic implementation) --->
                <cfset transformedValue = rawValue>
                <cfif len(columnMapping.transform_json) gt 0>
                    <cftry>
                        <cfset transformRules = deserializeJSON(columnMapping.transform_json)>
                        <!--- Apply trim transform --->
                        <cfif structKeyExists(transformRules, "trim") and transformRules.trim>
                            <cfset transformedValue = trim(transformedValue)>
                        </cfif>
                        <!--- Apply lowercase transform --->
                        <cfif structKeyExists(transformRules, "lowercase") and transformRules.lowercase>
                            <cfset transformedValue = lcase(transformedValue)>
                        </cfif>
                        <!--- Apply uppercase transform --->
                        <cfif structKeyExists(transformRules, "uppercase") and transformRules.uppercase>
                            <cfset transformedValue = ucase(transformedValue)>
                        </cfif>
                        <cfcatch type="any">
                            <!--- Invalid transform JSON, skip transforms --->
                        </cfcatch>
                    </cftry>
                </cfif>

                <!--- Validate based on field type --->
                <cfset factIsValid = true>
                <cfset validationCode = "">
                <cfset validationMessage = "">
                <cfset normalizedValue = transformedValue>

                <!--- Email validation --->
                <cfif reFindNoCase("^email", effectiveFieldName) and len(transformedValue)>
                    <cfset vResult = validationService.validateEmail(transformedValue)>
                    <cfset factIsValid = vResult.valid>
                    <cfset normalizedValue = vResult.normalized>
                    <cfif not vResult.valid>
                        <cfset validationCode = "INVALID_EMAIL">
                        <cfset validationMessage = vResult.error>
                        <cfset errorCount++>
                        <cfset arrayAppend(rowErrors, { field: effectiveFieldName, error: vResult.error })>
                    <cfelseif len(vResult.warning)>
                        <cfset warningCount++>
                        <cfset arrayAppend(rowWarnings, { field: effectiveFieldName, warning: vResult.warning })>
                    </cfif>
                <!--- Phone validation --->
                <cfelseif reFindNoCase("^phone", effectiveFieldName) and len(transformedValue)>
                    <cfset vResult = validationService.validatePhone(transformedValue)>
                    <cfset factIsValid = vResult.valid>
                    <cfset normalizedValue = vResult.normalized>
                    <cfif not vResult.valid>
                        <cfset validationCode = "INVALID_PHONE">
                        <cfset validationMessage = vResult.error>
                        <cfset errorCount++>
                        <cfset arrayAppend(rowErrors, { field: effectiveFieldName, error: vResult.error })>
                    </cfif>
                <!--- Date validation --->
                <cfelseif reFindNoCase("(date|birthday)", effectiveFieldName) and len(transformedValue)>
                    <cfset vResult = validationService.validateDate(transformedValue)>
                    <cfset factIsValid = vResult.valid>
                    <cfset normalizedValue = vResult.normalized>
                    <cfif not vResult.valid>
                        <cfset validationCode = "INVALID_DATE">
                        <cfset validationMessage = vResult.error>
                        <cfset errorCount++>
                        <cfset arrayAppend(rowErrors, { field: effectiveFieldName, error: vResult.error })>
                    </cfif>
                <!--- URL validation --->
                <cfelseif reFindNoCase("(url|website)", effectiveFieldName) and len(transformedValue)>
                    <cfset vResult = validationService.validateURL(transformedValue)>
                    <cfset factIsValid = vResult.valid>
                    <cfset normalizedValue = vResult.normalized>
                    <cfif not vResult.valid>
                        <cfset validationCode = "INVALID_URL">
                        <cfset validationMessage = vResult.error>
                        <cfset errorCount++>
                        <cfset arrayAppend(rowErrors, { field: effectiveFieldName, error: vResult.error })>
                    </cfif>
                <!--- String validation (default) --->
                <cfelse>
                    <cfset vResult = validationService.validateString(transformedValue)>
                    <cfset normalizedValue = vResult.normalized>
                    <cfif len(vResult.warning)>
                        <cfset warningCount++>
                        <cfset arrayAppend(rowWarnings, { field: effectiveFieldName, warning: vResult.warning })>
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
                        fact_id: { value: factId, cfsqltype: "cf_sql_integer" },
                        is_valid: { value: factIsValid ? 1 : 0, cfsqltype: "cf_sql_tinyint" },
                        validation_code: { value: validationCode, cfsqltype: "cf_sql_varchar", maxlength: 30, null: !len(validationCode) },
                        validation_message: { value: validationMessage, cfsqltype: "cf_sql_varchar", maxlength: 255, null: !len(validationMessage) },
                        normalized_value: { value: normalizedValue, cfsqltype: "cf_sql_longvarchar", null: !len(normalizedValue) },
                        field_name: { value: effectiveFieldName, cfsqltype: "cf_sql_varchar", maxlength: 50 }
                    },
                    { datasource: application.datasource }
                )>

                <!--- Add to rowData for duplicate detection (use normalized value if valid) --->
                <cfif factIsValid or len(normalizedValue)>
                    <cfset rowData[effectiveFieldName] = normalizedValue>
                </cfif>
            </cfloop>

            <!--- Row-level validation: require first_name or last_name --->
            <cfset hasFirstName = structKeyExists(rowData, "first_name") and len(rowData.first_name)>
            <cfset hasLastName = structKeyExists(rowData, "last_name") and len(rowData.last_name)>
            <cfset hasFullName = structKeyExists(rowData, "full_name") and len(rowData.full_name)>

            <cfif not hasFirstName and not hasLastName and not hasFullName>
                <cfset errorCount++>
                <cfset arrayAppend(rowErrors, { field: "_row", error: "At least one name field (first_name, last_name, or full_name) is required" })>
            </cfif>

            <!--- Check required fields per spec: first_name required, last_name required --->
            <!--- NOTE: The spec says both required, but practically we accept full_name as alternative --->
            <cfif not hasFirstName and not hasFullName>
                <cfset errorCount++>
                <cfset arrayAppend(rowErrors, { field: "first_name", error: "First name is required" })>
            </cfif>
            <cfif not hasLastName and not hasFullName>
                <cfset errorCount++>
                <cfset arrayAppend(rowErrors, { field: "last_name", error: "Last name is required" })>
            </cfif>

            <!--- Build validation summary JSON --->
            <cfset validationSummary = {
                "errors": rowErrors,
                "warnings": rowWarnings
            }>

            <!--- Determine row status before duplicate check --->
            <cfset rowStatus = "ready">
            <cfif errorCount gt 0>
                <cfset rowStatus = "problem">
            </cfif>

            <!--- G) Phase 4.1 Pass 1: Collect candidate IDs (no DB, index lookup only) --->
            <cfset dupeCandidatesJson = "">
            <cfset matchedContactId = "">
            <cfset bestMatchScore = "">

            <cfif rowStatus eq "ready" and structCount(rowData) gt 0 and dupeDetectionEnabled>
                <!--- Map rowData fields to DuplicateMatcherService expected format --->
                <cfset dupeRowData = {}>

                <!--- Map first_name/last_name to firstName/lastName --->
                <cfif structKeyExists(rowData, "first_name")>
                    <cfset dupeRowData["firstName"] = rowData.first_name>
                </cfif>
                <cfif structKeyExists(rowData, "last_name")>
                    <cfset dupeRowData["lastName"] = rowData.last_name>
                </cfif>
                <cfif structKeyExists(rowData, "full_name")>
                    <cfset dupeRowData["contactFullName"] = rowData.full_name>
                </cfif>

                <!--- Map email fields --->
                <cfif structKeyExists(rowData, "email_business") or structKeyExists(rowData, "email_work")>
                    <cfset dupeRowData["email_business"] = structKeyExists(rowData, "email_business") ? rowData.email_business : rowData.email_work>
                </cfif>
                <cfif structKeyExists(rowData, "email_personal") or structKeyExists(rowData, "email_home")>
                    <cfset dupeRowData["email_personal"] = structKeyExists(rowData, "email_personal") ? rowData.email_personal : rowData.email_home>
                </cfif>

                <!--- Map phone fields --->
                <cfif structKeyExists(rowData, "phone_work")>
                    <cfset dupeRowData["phone_work"] = rowData.phone_work>
                </cfif>
                <cfif structKeyExists(rowData, "phone_mobile") or structKeyExists(rowData, "phone_cell")>
                    <cfset dupeRowData["phone_mobile"] = structKeyExists(rowData, "phone_mobile") ? rowData.phone_mobile : rowData.phone_cell>
                </cfif>
                <cfif structKeyExists(rowData, "phone_home")>
                    <cfset dupeRowData["phone_home"] = rowData.phone_home>
                </cfif>

                <!--- Map other fields --->
                <cfif structKeyExists(rowData, "company")>
                    <cfset dupeRowData["company"] = rowData.company>
                </cfif>
                <cfif structKeyExists(rowData, "city") or structKeyExists(rowData, "address_city")>
                    <cfset dupeRowData["address_city"] = structKeyExists(rowData, "address_city") ? rowData.address_city : rowData.city>
                </cfif>
                <cfif structKeyExists(rowData, "state") or structKeyExists(rowData, "address_state")>
                    <cfset dupeRowData["address_state"] = structKeyExists(rowData, "address_state") ? rowData.address_state : rowData.state>
                </cfif>

                <!--- Phase 4.1: Collect candidate IDs using index (no DB call) --->
                <cftry>
                    <!--- Get candidate IDs from in-memory index lookup --->
                    <cfset dupeResult = dupeService.findDuplicatesWithIndex(
                        userid = userid,
                        rowData = dupeRowData,
                        dupeIndex = dupeIndex,
                        candidateDetailsCache = candidateDetailsCache,
                        threshold = dupeService.THRESHOLD_LOW,
                        metricsRef = metrics
                    )>

                    <!--- Track candidate IDs to fetch (will be batch-fetched after pass 1) --->
                    <cfloop array="#dupeResult.candidateIdsToFetch#" index="cid">
                        <cfset allCandidateIds[cid] = true>
                    </cfloop>

                    <!--- Store dupeRowData for pass 2 scoring --->
                    <cfset arrayAppend(rowDupeData, {
                        "row_id": rowId,
                        "row_index": rowsProcessed,
                        "dupeRowData": dupeRowData,
                        "rowStatus": rowStatus
                    })>

                    <cfcatch type="any">
                        <cfset metrics.dupe_errors_count++>
                        <cfset addDebug("dupe_pass1_error row_id=" & rowId & " err=" & cfcatch.message)>
                    </cfcatch>
                </cftry>
            <cfelseif not dupeDetectionEnabled and rowStatus eq "ready">
                <!--- Dupe detection disabled: mark as ready without checking --->
                <cfif rowsProcessed mod 10 eq 0 or rowsProcessed eq 1>
                    <cfset addDebug("dupe_detection_skipped row_id=" & rowId & " mode=" & metrics.dupe_detection_mode)>
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
                    row_id: { value: rowId, cfsqltype: "cf_sql_integer" },
                    status: { value: rowStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                    error_count: { value: errorCount, cfsqltype: "cf_sql_integer" },
                    warning_count: { value: warningCount, cfsqltype: "cf_sql_integer" },
                    validation_summary: { value: serializeJSON(validationSummary), cfsqltype: "cf_sql_longvarchar" },
                    dupe_candidates_json: { value: dupeCandidatesJson, cfsqltype: "cf_sql_longvarchar", null: !len(dupeCandidatesJson) },
                    matched_contactid: { value: matchedContactId, cfsqltype: "cf_sql_integer", null: !len(matchedContactId) },
                    best_match_score: { value: bestMatchScore, cfsqltype: "cf_sql_integer", null: !len(bestMatchScore) }
                },
                { datasource: application.datasource }
            )>

            <!--- Update counters --->
            <cfswitch expression="#rowStatus#">
                <cfcase value="ready">
                    <cfset validRows++>
                </cfcase>
                <cfcase value="problem">
                    <cfset problemRows++>
                </cfcase>
                <cfcase value="dupe">
                    <cfset dupeRows++>
                </cfcase>
                <cfcase value="ignored">
                    <cfset ignoredRows++>
                </cfcase>
            </cfswitch>

            <cfcatch type="any">
                <!--- Log row processing error but continue to next row --->
                <cfset addDebug("row_fail row_id=" & rowId & " err=" & cfcatch.message)>
                <cflog file="importv3" text="V3 recompute row_fail job_id=#jobId# row_id=#rowId# err=#cfcatch.message#">
                <cfset problemRows++>
            </cfcatch>
        </cftry>
    </cfloop>
    <cfset addDebug("step=process_rows_end processed=" & rowsProcessed)>

    <!--- Phase 4.1 Pass 2: Batch fetch all candidate details, then score rows --->
    <cfif dupeDetectionEnabled and structCount(allCandidateIds) gt 0>
        <cfset addDebug("step=dupe_pass2_start candidates_to_fetch=" & structCount(allCandidateIds))>
        <cfset dupePass2StartTime = getTickCount()>

        <!--- Convert allCandidateIds struct keys to array --->
        <cfset candidateIdArray = structKeyArray(allCandidateIds)>
        <cfset metrics.dupe_candidates_unique_total = arrayLen(candidateIdArray)>

        <!--- Batch fetch in chunks --->
        <cfset chunkSize = dupeService.DETAILS_BATCH_CHUNK_SIZE>
        <cfset totalChunks = ceiling(arrayLen(candidateIdArray) / chunkSize)>
        <cfset addDebug("dupe_pass2_fetching total=" & arrayLen(candidateIdArray) & " chunks=" & totalChunks & " chunk_size=" & chunkSize)>

        <cfloop from="1" to="#totalChunks#" index="chunkNum">
            <cfset startIdx = ((chunkNum - 1) * chunkSize) + 1>
            <cfset endIdx = min(chunkNum * chunkSize, arrayLen(candidateIdArray))>
            <cfset chunkIds = []>

            <cfloop from="#startIdx#" to="#endIdx#" index="i">
                <cfset arrayAppend(chunkIds, candidateIdArray[i])>
            </cfloop>

            <!--- Fetch this chunk (2 queries per chunk) --->
            <cftry>
                <cfset chunkDetails = dupeService.getCandidateDetailsBatch(
                    userid = userid,
                    contactIds = chunkIds,
                    metricsRef = metrics
                )>
                <cfset metrics.dupe_details_fetch_batches++>

                <!--- Merge into cache --->
                <cfloop collection="#chunkDetails#" item="cid">
                    <cfset candidateDetailsCache[cid] = chunkDetails[cid]>
                </cfloop>

                <cfcatch type="any">
                    <cfset addDebug("dupe_pass2_chunk_error chunk=" & chunkNum & " err=" & cfcatch.message)>
                </cfcatch>
            </cftry>
        </cfloop>

        <cfset addDebug("dupe_pass2_fetch_complete cached=" & structCount(candidateDetailsCache) & " batches=" & metrics.dupe_details_fetch_batches)>

        <!--- Now score each row using cached details --->
        <cfset addDebug("step=dupe_pass2_scoring rows=" & arrayLen(rowDupeData))>

        <cfloop array="#rowDupeData#" index="rowEntry">
            <cftry>
                <!--- Re-run findDuplicatesWithIndex with populated cache --->
                <cfset dupeResult = dupeService.findDuplicatesWithIndex(
                    userid = userid,
                    rowData = rowEntry.dupeRowData,
                    dupeIndex = dupeIndex,
                    candidateDetailsCache = candidateDetailsCache,
                    threshold = dupeService.THRESHOLD_LOW,
                    metricsRef = metrics
                )>

                <!--- Update row if duplicates found --->
                <cfif dupeResult.hasDuplicate>
                    <cfset dupeCandidatesJson = serializeJSON(dupeResult.candidates)>
                    <cfset bestMatchScore = dupeResult.bestMatchScore>
                    <cfset matchedContactId = dupeResult.bestMatchContactId>
                    <cfset newRowStatus = rowEntry.rowStatus>

                    <!--- Flag as duplicate if score >= 60 (MEDIUM threshold) --->
                    <cfif bestMatchScore gte 60>
                        <cfset newRowStatus = "dupe">
                        <!--- Adjust counters --->
                        <cfif rowEntry.rowStatus eq "ready">
                            <cfset validRows = validRows - 1>
                            <cfset dupeRows = dupeRows + 1>
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
                            row_id: { value: rowEntry.row_id, cfsqltype: "cf_sql_integer" },
                            status: { value: newRowStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                            dupe_candidates_json: { value: dupeCandidatesJson, cfsqltype: "cf_sql_longvarchar" },
                            matched_contactid: { value: matchedContactId, cfsqltype: "cf_sql_integer" },
                            best_match_score: { value: bestMatchScore, cfsqltype: "cf_sql_integer" }
                        },
                        { datasource: application.datasource }
                    )>
                </cfif>

                <cfcatch type="any">
                    <cfset metrics.dupe_errors_count++>
                    <cfset addDebug("dupe_pass2_score_error row_id=" & rowEntry.row_id & " err=" & cfcatch.message)>
                </cfcatch>
            </cftry>
        </cfloop>

        <cfset dupeElapsedTotal += (getTickCount() - dupePass2StartTime)>
        <cfset addDebug("step=dupe_pass2_end elapsed_ms=" & (getTickCount() - dupePass2StartTime))>
    </cfif>

    <!--- I) Update job with counts --->
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
            job_id: { value: jobId, cfsqltype: "cf_sql_integer" },
            userid: { value: userid, cfsqltype: "cf_sql_integer" },
            valid_rows: { value: validRows, cfsqltype: "cf_sql_integer" },
            problem_rows: { value: problemRows, cfsqltype: "cf_sql_integer" },
            dupe_rows: { value: dupeRows, cfsqltype: "cf_sql_integer" },
            skipped_rows: { value: ignoredRows, cfsqltype: "cf_sql_integer" }
        },
        { datasource: application.datasource }
    )>
    <cfset addDebug("job_counts_updated valid=#validRows# problem=#problemRows# dupe=#dupeRows# ignored=#ignoredRows#")>

    <!--- J) Transition job status to reviewing if currently parsed or mapping --->
    <cfset addDebug("step=transition_job_status")>
    <cfif job.status eq "parsed" or job.status eq "mapping">
        <cfset statusResult = v3Service.setJobStatus(jobId, userid, "reviewing")>
        <cfif not statusResult.success>
            <!--- Log warning but continue - recompute data is already saved --->
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "status_transition_warning",
                detail = { error: statusResult.message, from_status: job.status, to_status: "reviewing" }
            )>
            <cfset addDebug("status_transition_warning: " & statusResult.message)>
        <cfelse>
            <cfset addDebug("status_transitioned to reviewing")>
        </cfif>
    <cfelse>
        <cfset addDebug("status_unchanged (already reviewing)")>
    </cfif>

    <!--- Log recompute completed --->
    <cfset v3Service.logEvent(
        job_id = jobId,
        userid = userid,
        event_type = "recompute_completed",
        detail = {
            total_rows: totalRows,
            valid_rows: validRows,
            problem_rows: problemRows,
            dupe_rows: dupeRows,
            ignored_rows: ignoredRows,
            skip_dupes: skipDupes
        }
    )>
    <cflog file="importv3" text="V3 recompute DONE job_id=#jobId# total=#totalRows# valid=#validRows# problem=#problemRows# dupe=#dupeRows# ignored=#ignoredRows# skip_dupes=#skipDupes#">

    <!--- Get updated job --->
    <cfset updatedJobResult = v3Service.getJobForUser(jobId, userid)>
    <cfset updatedJob = updatedJobResult.data.job>

    <!--- Finalize metrics --->
    <cfset metrics.total_rows_processed = rowsProcessed>
    <cfset metrics.elapsed_ms_total = getTickCount() - recomputeStartTime>
    <cfset metrics.elapsed_ms_dupes_total = dupeElapsedTotal>
    <cfset metrics.dupe_candidates_unique_total = structCount(allCandidateIds)>

    <!--- Enforce invariant: dupe time cannot exceed total time --->
    <cfif metrics.elapsed_ms_dupes_total gt metrics.elapsed_ms_total>
        <cfset metrics.elapsed_ms_dupes_total = metrics.elapsed_ms_total>
    </cfif>

    <!--- If dupe detection was skipped entirely, ensure dupe metrics are zeroed --->
    <cfif metrics.dupe_detection_mode neq "ran">
        <cfset metrics.dupe_queries_total = 0>
        <cfset metrics.dupe_candidates_total = 0>
        <cfset metrics.dupe_candidates_unique_total = 0>
        <cfset metrics.dupe_index_build_ms = 0>
        <cfset metrics.dupe_index_items_total = 0>
        <cfset metrics.dupe_index_contactids_total = 0>
        <cfset metrics.dupe_details_fetch_batches = 0>
        <cfset metrics.elapsed_ms_dupes_total = 0>
        <!--- dupe_rows_with_keys stays as-is: it counts rows that HAD keys, not rows processed for dupes --->
    </cfif>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = "Recompute completed">
    <cfset addDebug("step=metrics_final elapsed_total=" & metrics.elapsed_ms_total & " elapsed_dupes=" & metrics.elapsed_ms_dupes_total & " queries=" & metrics.dupe_queries_total & " index_items=" & metrics.dupe_index_items_total & " index_contacts=" & metrics.dupe_index_contactids_total & " candidates_unique=" & metrics.dupe_candidates_unique_total & " detail_batches=" & metrics.dupe_details_fetch_batches & " mode=" & metrics.dupe_detection_mode)>
    <cfset response.data = {
        "job": {
            "job_id": jobId,
            "status": updatedJob.status,
            "total_rows": totalRows,
            "valid_rows": validRows,
            "problem_rows": problemRows,
            "dupe_rows": dupeRows,
            "ignored_rows": ignoredRows
        },
        "metrics": metrics,
        "warnings": warnings
    }>

    <cfcatch type="any">
        <!--- Log recompute failed --->
        <cfset addDebug("FATAL err=" & cfcatch.message & " detail=" & cfcatch.detail)>
        <cflog file="importv3" text="V3 recompute fatal err=#cfcatch.message# detail=#cfcatch.detail#">

        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "recompute_failed",
                detail = { error: cfcatch.message, detail: cfcatch.detail }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>

        <!--- Finalize metrics even on error --->
        <cfset metrics.elapsed_ms_total = getTickCount() - recomputeStartTime>
        <cfset metrics.elapsed_ms_dupes_total = dupeElapsedTotal>
        <cfset metrics.dupe_candidates_unique_total = structCount(allCandidateIds)>

        <!--- Enforce invariant: dupe time cannot exceed total time --->
        <cfif metrics.elapsed_ms_dupes_total gt metrics.elapsed_ms_total>
            <cfset metrics.elapsed_ms_dupes_total = metrics.elapsed_ms_total>
        </cfif>

        <!--- If dupe detection was skipped entirely, ensure dupe metrics are zeroed --->
        <cfif metrics.dupe_detection_mode neq "ran">
            <cfset metrics.dupe_queries_total = 0>
            <cfset metrics.dupe_candidates_total = 0>
            <cfset metrics.dupe_candidates_unique_total = 0>
            <cfset metrics.dupe_index_build_ms = 0>
            <cfset metrics.dupe_index_items_total = 0>
            <cfset metrics.dupe_index_contactids_total = 0>
            <cfset metrics.dupe_details_fetch_batches = 0>
            <cfset metrics.elapsed_ms_dupes_total = 0>
        </cfif>

        <cfset addDebug("step=metrics_final elapsed_total=" & metrics.elapsed_ms_total & " elapsed_dupes=" & metrics.elapsed_ms_dupes_total & " queries=" & metrics.dupe_queries_total & " index_items=" & metrics.dupe_index_items_total & " index_contacts=" & metrics.dupe_index_contactids_total & " candidates_unique=" & metrics.dupe_candidates_unique_total & " detail_batches=" & metrics.dupe_details_fetch_batches & " mode=" & metrics.dupe_detection_mode)>

        <cfset response.code = "RECOMPUTE_FAILED">
        <cfset response.message = "Recompute failed: " & cfcatch.message & " | Detail: " & cfcatch.detail>
        <cfset response.data = {
            "error_type": cfcatch.type,
            "tagcontext": cfcatch.tagcontext[1].template & ":" & cfcatch.tagcontext[1].line,
            "metrics": metrics,
            "warnings": warnings
        }>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
