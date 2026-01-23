<cfsilent>
<!---
    Contact Import V3 - Recompute Endpoint
    POST /ajax/importv3/recompute.cfm

    Validates rows and detects duplicates based on current column mappings.
    Does NOT write to production contact tables.

    Request Parameters:
    - job_id (required): The import job ID

    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job does not exist
    - MISSING_JOB_ID: job_id parameter missing
    - INVALID_STATE: Job not in allowed status (parsed, mapping, reviewing)
    - LOCKED: Job is locked by another operation
    - RECOMPUTE_FAILED: Recompute operation failed
--->

<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- Parse JSON body first (for JSON content type requests) --->
    <cfset requestBody = "">
    <cfset jsonData = {}>
    <cftry>
        <cfset requestBody = toString(getHTTPRequestData().content)>
        <cfif len(requestBody)>
            <cfset jsonData = deserializeJSON(requestBody)>
        </cfif>
        <cfcatch type="any"><!--- ignore if no body or invalid JSON ---></cfcatch>
    </cftry>

    <!--- Validate job_id parameter (check JSON body, then form, then url) --->
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
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Initialize services --->
    <cfset v3Service = new services.ContactImportV3Service()>
    <cfset validationService = new services.ValidationService()>
    <cfset dupeService = new services.DuplicateMatcherService()>

    <!--- B) Verify job ownership --->
    <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
    <cfif not jobResult.success>
        <cfset response.code = jobResult.code>
        <cfset response.message = jobResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset job = jobResult.data.job>

    <!--- C) Validate job status - only allow recompute from these states --->
    <cfset ALLOWED_STATUSES = ["parsed", "mapping", "reviewing"]>
    <cfif not arrayFindNoCase(ALLOWED_STATUSES, job.status)>
        <cfset response.code = "INVALID_STATE">
        <cfset response.message = "Cannot recompute from status: " & job.status & ". Allowed: " & arrayToList(ALLOWED_STATUSES, ", ")>
        <cfset response.data = { current_status: job.status, allowed: ALLOWED_STATUSES }>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Process incoming mappings from JSON body if provided --->
    <cfif structCount(jsonData) gt 0>
        <cftry>
            <!--- Process mappings array if provided --->
            <cfif structKeyExists(jsonData, "mappings") and isArray(jsonData.mappings)>
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
            </cfif>
            <cfcatch type="any">
                <!--- Log JSON parse error but continue --->
                <cfset v3Service.logEvent(
                    job_id = jobId,
                    userid = userid,
                    event_type = "mappings_parse_error",
                    detail = { error: cfcatch.message }
                )>
            </cfcatch>
        </cftry>
    </cfif>

    <!--- Log recompute started --->
    <cfset v3Service.logEvent(
        job_id = jobId,
        userid = userid,
        event_type = "recompute_started",
        detail = { previous_status: job.status }
    )>

    <!--- D) Load column mappings for this job (reload after applying incoming mappings) --->
    <cfset qColumns = queryExecute(
        "SELECT column_id, source_column_index, source_column_name,
                intent, target_key, transform_json
         FROM import_v3_columns
         WHERE job_id = :job_id
         ORDER BY source_column_index",
        { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

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
    <cfset qRows = queryExecute(
        "SELECT row_id, row_num, raw_json, status, user_action
         FROM import_v3_rows
         WHERE job_id = :job_id
         ORDER BY row_num",
        { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <!--- Counters for summary --->
    <cfset totalRows = qRows.recordCount>
    <cfset validRows = 0>
    <cfset problemRows = 0>
    <cfset dupeRows = 0>
    <cfset ignoredRows = 0>

    <!--- F) Process each row --->
    <cfloop query="qRows">
        <cfset rowId = qRows.row_id>
        <cfset rowNum = qRows.row_num>
        <cfset userAction = isNull(qRows.user_action) ? "" : qRows.user_action>

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

        <!--- G) Duplicate detection (only if no validation errors) --->
        <cfset dupeCandidatesJson = "">
        <cfset matchedContactId = "">
        <cfset bestMatchScore = "">

        <cfif rowStatus eq "ready" and structCount(rowData) gt 0>
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

            <!--- Find duplicates using LOW threshold (25) for detection, MEDIUM (60) for flagging --->
            <cfset dupeResult = dupeService.findDuplicates(userid, dupeRowData, dupeService.THRESHOLD_LOW)>

            <cfif dupeResult.hasDuplicate>
                <cfset dupeCandidatesJson = serializeJSON(dupeResult.candidates)>
                <cfset bestMatchScore = dupeResult.bestMatchScore>
                <cfset matchedContactId = dupeResult.bestMatchContactId>

                <!--- Flag as duplicate if score >= 60 (MEDIUM threshold) --->
                <cfif bestMatchScore gte 60>
                    <cfset rowStatus = "dupe">
                </cfif>
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
    </cfloop>

    <!--- I) Update job with counts --->
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

    <!--- J) Transition job status to reviewing if currently parsed or mapping --->
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
        </cfif>
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
            ignored_rows: ignoredRows
        }
    )>

    <!--- Get updated job --->
    <cfset updatedJobResult = v3Service.getJobForUser(jobId, userid)>
    <cfset updatedJob = updatedJobResult.data.job>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = "Recompute completed">
    <cfset response.data = {
        "job": {
            "job_id": jobId,
            "status": updatedJob.status,
            "total_rows": totalRows,
            "valid_rows": validRows,
            "problem_rows": problemRows,
            "dupe_rows": dupeRows,
            "ignored_rows": ignoredRows
        }
    }>

    <cfcatch type="any">
        <!--- Log recompute failed --->
        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "recompute_failed",
                detail = { error: cfcatch.message, detail: cfcatch.detail }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>

        <cfset response.code = "RECOMPUTE_FAILED">
        <cfset response.message = "Recompute failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
