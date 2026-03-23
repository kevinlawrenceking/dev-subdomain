<cfsilent>
<!---
    Audition Import - Columns Endpoint
    GET/POST /ajax/import-auditions/columns.cfm

    GET: Returns columns for a job with sample values
    POST: Updates column mapping (intent, target_key, transform_json, user_confirmed)

    Request Parameters:
    - job_id (required): The import job ID

    POST Parameters (for single column update):
    - column_id (required): The column to update
    - intent (optional): ignore|audition_field|note
    - target_key (optional): Target field key (required for audition_field)
    - transform_json (optional): JSON transformation rules
    - user_confirmed (optional): 1 to confirm, 0 to unconfirm

    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job does not exist
    - MISSING_JOB_ID: job_id parameter missing
    - MISSING_COLUMN_ID: column_id parameter missing for POST
    - INVALID_INTENT: intent value not in allowed list
    - TARGET_KEY_REQUIRED: target_key required for this intent
    - INVALID_JSON: transform_json is not valid JSON
    - UPDATE_FAILED: Column update failed

    Debug breadcrumbs (response.data.debug):
    - Lightweight step markers for debugging without PII
    - Example GET:  ["start","auth_ok","job_id_ok","service_init","job_loaded","columns_fetched","done"]
    - Example POST: ["start","auth_ok","job_id_ok","service_init","job_loaded","column_id_ok","column_verified","validated","column_updated","done"]
--->

<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<!--- Debug breadcrumbs array (no PII) --->
<cfset variables.debug = ["start"]>
<cfset variables.startTick = getTickCount()>

<!--- Valid intent values for column mapping --->
<cfset variables.VALID_INTENTS = ["ignore", "audition_field", "note"]>
<cfset variables.INTENTS_REQUIRING_TARGET = ["audition_field"]>

<!--- Initialize variables for error handling --->
<cfset variables.jobId = 0>
<cfset variables.userid = 0>
<cfset variables.auditionService = "">

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset variables.response.code = "AUTH_REQUIRED">
        <cfset variables.response.message = "Authentication required">
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = "start">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfset arrayAppend(variables.debug, "auth_ok")>

    <!--- Validate job_id parameter --->
    <cfparam name="form.job_id" default="">
    <cfparam name="url.job_id" default="">
    <cfset variables.jobId = val(url.job_id)>
    <cfif variables.jobId eq 0>
        <cfset variables.jobId = val(form.job_id)>
    </cfif>
    <cfif variables.jobId lte 0>
        <cfset variables.response.code = "MISSING_JOB_ID">
        <cfset variables.response.message = "job_id is required">
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = "auth_ok">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset arrayAppend(variables.debug, "job_id_ok")>

    <!--- Initialize Audition Import service --->
    <cfset variables.auditionService = new services.AuditionImportService()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- Verify job ownership --->
    <cfset variables.jobResult = variables.auditionService.getJobForUser(variables.jobId, variables.userid)>
    <cfif not variables.jobResult.success>
        <cfset variables.response.code = variables.jobResult.code>
        <cfset variables.response.message = variables.jobResult.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = "service_init">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.job = variables.jobResult.data.job>
    <cfset arrayAppend(variables.debug, "job_loaded")>
    <cflog file="import_auditions" text="[columns] START method=#cgi.request_method# userid=#variables.userid# job_id=#variables.jobId#">

    <!--- Branch based on HTTP method --->
    <cfset variables.httpMethod = cgi.request_method>

    <!--- ======================= GET: Retrieve columns ======================= --->
    <cfif variables.httpMethod eq "GET">

        <!--- Get columns for this job --->
        <cfset variables.qColumns = queryExecute(
            "SELECT
                c.column_id,
                c.source_column_index,
                c.source_column_name,
                c.mapped_field,
                c.confidence,
                c.user_confirmed,
                c.sample_values,
                c.intent,
                c.target_key,
                c.transform_json
            FROM import_auditions_columns c
            WHERE c.job_id = :job_id
            ORDER BY c.source_column_index ASC",
            { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <cfset arrayAppend(variables.debug, "columns_fetched")>

        <cflog file="import_auditions" text="[columns] GET_COLUMNS_LOADED userid=#variables.userid# job_id=#variables.jobId# column_count=#variables.qColumns.recordCount#">

        <!--- Build columns array with sample values pulled from import_auditions_facts --->
        <cfset variables.columnsArray = []>
        <cfloop query="variables.qColumns">
            <cfset variables.columnData = {
                "column_id": variables.qColumns.column_id,
                "source_column_index": variables.qColumns.source_column_index,
                "source_name": variables.qColumns.source_column_name,
                "intent": isNull(variables.qColumns.intent) ? "" : variables.qColumns.intent,
                "target_key": isNull(variables.qColumns.target_key) ? "" : variables.qColumns.target_key,
                "transform_json": isNull(variables.qColumns.transform_json) ? "" : variables.qColumns.transform_json,
                "user_confirmed": variables.qColumns.user_confirmed,
                "mapped_field": isNull(variables.qColumns.mapped_field) ? "" : variables.qColumns.mapped_field,
                "confidence": isNull(variables.qColumns.confidence) ? "" : variables.qColumns.confidence,
                "sample_values": []
            }>

            <!--- Try to get sample values from facts table (up to 5 non-empty values) --->
            <cfset variables.qSamples = queryExecute(
                "SELECT DISTINCT f.raw_value
                FROM import_auditions_facts f
                INNER JOIN import_auditions_rows r ON f.row_id = r.row_id
                WHERE f.column_id = :column_id
                  AND r.job_id = :job_id
                  AND f.raw_value IS NOT NULL
                  AND TRIM(f.raw_value) != ''
                LIMIT 5",
                {
                    column_id: { value: variables.qColumns.column_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            )>

            <!--- Build sample values array --->
            <cfset variables.sampleVals = []>
            <cfloop query="variables.qSamples">
                <cfset arrayAppend(variables.sampleVals, variables.qSamples.raw_value)>
            </cfloop>

            <!--- If no samples from facts, try to parse from stored sample_values JSON --->
            <cfif arrayLen(variables.sampleVals) eq 0 and len(variables.qColumns.sample_values)>
                <cftry>
                    <cfset variables.storedSamples = deserializeJSON(variables.qColumns.sample_values)>
                    <cfif isArray(variables.storedSamples)>
                        <cfloop array="#variables.storedSamples#" index="variables.sv">
                            <cfif len(trim(variables.sv)) and arrayLen(variables.sampleVals) lt 5>
                                <cfset arrayAppend(variables.sampleVals, variables.sv)>
                            </cfif>
                        </cfloop>
                    </cfif>
                    <cfcatch type="any"><!--- ignore JSON parse errors ---></cfcatch>
                </cftry>
            </cfif>

            <cfset variables.columnData.sample_values = variables.sampleVals>
            <cfset arrayAppend(variables.columnsArray, variables.columnData)>
        </cfloop>

        <!--- Define available audition fields for the column mapping dropdown in the UI --->
        <cfset variables.availableFields = [
            { "field": "contact_name", "display_name": "Actor Name" },
            { "field": "contact_email", "display_name": "Actor Email" },
            { "field": "project_name", "display_name": "Project Name" },
            { "field": "role_name", "display_name": "Role" },
            { "field": "casting_director", "display_name": "Casting Director" },
            { "field": "agency", "display_name": "Agency/CD Office" },
            { "field": "audition_date", "display_name": "Audition Date" },
            { "field": "audition_time", "display_name": "Audition Time" },
            { "field": "location", "display_name": "Location" },
            { "field": "medium", "display_name": "Medium" },
            { "field": "status", "display_name": "Status" },
            { "field": "callback_date", "display_name": "Callback Date" },
            { "field": "booking_date", "display_name": "Booking Date" },
            { "field": "self_tape", "display_name": "Self Tape?" },
            { "field": "notes", "display_name": "Notes" }
        ]>

        <cfset arrayAppend(variables.debug, "done")>

        <!--- Build success response --->
        <cfset variables.response.success = true>
        <cfset variables.response.message = "">
        <cfset variables.response.data = {
            "job": {
                "job_id": variables.jobId,
                "status": variables.job.status
            },
            "columns": variables.columnsArray,
            "available_fields": variables.availableFields,
            "debug": variables.debug,
            "elapsed_ms": getTickCount() - variables.startTick
        }>

    <!--- ======================= POST: Update column mapping ======================= --->
    <cfelseif variables.httpMethod eq "POST">

        <!--- Validate column_id --->
        <cfparam name="form.column_id" default="">
        <cfset variables.columnId = val(form.column_id)>
        <cfif variables.columnId lte 0>
            <cfset variables.response.code = "MISSING_COLUMN_ID">
            <cfset variables.response.message = "column_id is required">
            <cfset variables.response.data.debug = variables.debug>
            <cfset variables.response.data.last_step = "job_loaded">
            <cflog file="import_auditions" text="[columns] ERROR_MISSING_COLUMN_ID userid=#variables.userid# job_id=#variables.jobId#">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>
        <cfset arrayAppend(variables.debug, "column_id_ok")>

        <!--- Verify column belongs to this job --->
        <cfset variables.qColumnCheck = queryExecute(
            "SELECT c.column_id
            FROM import_auditions_columns c
            INNER JOIN import_auditions_jobs j ON c.job_id = j.job_id
            WHERE c.column_id = :column_id
              AND c.job_id = :job_id
              AND j.userid = :userid",
            {
                column_id: { value: variables.columnId, cfsqltype: "cf_sql_integer" },
                job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
                userid: { value: variables.userid, cfsqltype: "cf_sql_integer" }
            },
            { datasource: application.datasource }
        )>

        <cfif variables.qColumnCheck.recordCount eq 0>
            <cfset variables.response.code = "ACCESS_DENIED">
            <cfset variables.response.message = "Column not found or access denied">
            <cfset variables.response.data.debug = variables.debug>
            <cfset variables.response.data.last_step = "column_id_ok">
            <cflog file="import_auditions" text="[columns] ERROR_ACCESS_DENIED userid=#variables.userid# job_id=#variables.jobId# column_id=#variables.columnId#">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>
        <cfset arrayAppend(variables.debug, "column_verified")>

        <!--- Get POST parameters --->
        <cfparam name="form.intent" default="">
        <cfparam name="form.target_key" default="">
        <cfparam name="form.transform_json" default="">
        <cfparam name="form.user_confirmed" default="">

        <cfset variables.newIntent = trim(form.intent)>
        <cfset variables.newTargetKey = trim(form.target_key)>
        <cfset variables.newTransformJson = trim(form.transform_json)>
        <cfset variables.newUserConfirmed = val(form.user_confirmed)>

        <!--- Validate intent if provided --->
        <cfif len(variables.newIntent) and not arrayFindNoCase(variables.VALID_INTENTS, variables.newIntent)>
            <cfset variables.response.code = "INVALID_INTENT">
            <cfset variables.response.message = "Invalid intent value. Allowed: " & arrayToList(variables.VALID_INTENTS, ", ")>
            <cfset variables.response.data.debug = variables.debug>
            <cfset variables.response.data.last_step = "column_verified">
            <cflog file="import_auditions" text="[columns] ERROR_INVALID_INTENT userid=#variables.userid# job_id=#variables.jobId# column_id=#variables.columnId# intent=#variables.newIntent#">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>

        <!--- Validate target_key is provided when required --->
        <cfif len(variables.newIntent) and arrayFindNoCase(variables.INTENTS_REQUIRING_TARGET, variables.newIntent) and not len(variables.newTargetKey)>
            <cfset variables.response.code = "TARGET_KEY_REQUIRED">
            <cfset variables.response.message = "target_key is required when intent is " & variables.newIntent>
            <cfset variables.response.data.debug = variables.debug>
            <cfset variables.response.data.last_step = "column_verified">
            <cflog file="import_auditions" text="[columns] ERROR_TARGET_KEY_REQUIRED userid=#variables.userid# job_id=#variables.jobId# column_id=#variables.columnId# intent=#variables.newIntent#">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>

        <!--- Validate transform_json is valid JSON if provided --->
        <cfif len(variables.newTransformJson)>
            <cftry>
                <cfset variables.testJson = deserializeJSON(variables.newTransformJson)>
                <cfcatch type="any">
                    <cfset variables.response.code = "INVALID_JSON">
                    <cfset variables.response.message = "transform_json must be valid JSON">
                    <cfset variables.response.data.debug = variables.debug>
                    <cfset variables.response.data.last_step = "column_verified">
                    <cflog file="import_auditions" text="[columns] ERROR_INVALID_JSON userid=#variables.userid# job_id=#variables.jobId# column_id=#variables.columnId#">
                    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
                </cfcatch>
            </cftry>
        </cfif>
        <cfset arrayAppend(variables.debug, "validated")>

        <!--- Track which fields were changed for event logging audit trail --->
        <cfset variables.changedFields = []>

        <!--- Build dynamic UPDATE query: only include fields that were submitted --->
        <cfset variables.updateParts = []>
        <cfset variables.updateParams = {
            column_id: { value: variables.columnId, cfsqltype: "cf_sql_integer" },
            job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" }
        }>

        <!--- Intent --->
        <cfif len(form.intent) or structKeyExists(form, "intent")>
            <cfset arrayAppend(variables.updateParts, "intent = :intent")>
            <cfif len(variables.newIntent)>
                <cfset variables.updateParams.intent = { value: variables.newIntent, cfsqltype: "cf_sql_varchar", maxlength: 20 }>
            <cfelse>
                <cfset variables.updateParams.intent = { value: "", cfsqltype: "cf_sql_varchar", null: true }>
            </cfif>
            <cfset arrayAppend(variables.changedFields, "intent")>
        </cfif>

        <!--- Target key --->
        <cfif len(form.target_key) or structKeyExists(form, "target_key")>
            <cfset arrayAppend(variables.updateParts, "target_key = :target_key")>
            <cfif len(variables.newTargetKey)>
                <cfset variables.updateParams.target_key = { value: variables.newTargetKey, cfsqltype: "cf_sql_varchar", maxlength: 100 }>
            <cfelse>
                <cfset variables.updateParams.target_key = { value: "", cfsqltype: "cf_sql_varchar", null: true }>
            </cfif>
            <cfset arrayAppend(variables.changedFields, "target_key")>
        </cfif>

        <!--- Transform JSON --->
        <cfif len(form.transform_json) or structKeyExists(form, "transform_json")>
            <cfset arrayAppend(variables.updateParts, "transform_json = :transform_json")>
            <cfif len(variables.newTransformJson)>
                <cfset variables.updateParams.transform_json = { value: variables.newTransformJson, cfsqltype: "cf_sql_longvarchar" }>
            <cfelse>
                <cfset variables.updateParams.transform_json = { value: "", cfsqltype: "cf_sql_longvarchar", null: true }>
            </cfif>
            <cfset arrayAppend(variables.changedFields, "transform_json")>
        </cfif>

        <!--- User confirmed --->
        <cfif len(form.user_confirmed) or structKeyExists(form, "user_confirmed")>
            <cfset arrayAppend(variables.updateParts, "user_confirmed = :user_confirmed")>
            <cfset variables.updateParams.user_confirmed = { value: (variables.newUserConfirmed gt 0 ? 1 : 0), cfsqltype: "cf_sql_tinyint" }>
            <cfset arrayAppend(variables.changedFields, "user_confirmed")>
        </cfif>

        <!--- Execute update if we have fields to update --->
        <cfif arrayLen(variables.updateParts) gt 0>
            <cfset variables.updateSQL = "UPDATE import_auditions_columns SET " & arrayToList(variables.updateParts, ", ") & " WHERE column_id = :column_id AND job_id = :job_id">

            <cfset variables.qUpdateResult = {}>
            <cftry>
                <cfset queryExecute(variables.updateSQL, variables.updateParams, { datasource: application.datasource, result: "variables.qUpdateResult" })>
                <cfcatch type="any">
                    <cfset variables.response.code = "UPDATE_FAILED">
                    <cfset variables.response.message = "Failed to update column: " & cfcatch.message>
                    <cfset arrayAppend(variables.debug, "update_failed")>
                    <cfset variables.response.data.debug = variables.debug>
                    <cfset variables.response.data.last_step = "validated">
                    <cflog file="import_auditions" text="[columns] ERROR_UPDATE_FAILED userid=#variables.userid# job_id=#variables.jobId# column_id=#variables.columnId# err=#cfcatch.message#">
                    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
                </cfcatch>
            </cftry>

            <!--- Auto-transition: if user confirms a column and job is still in parsed state, move to mapping --->
            <cfif variables.newUserConfirmed gt 0 and variables.job.status eq "parsed">
                <cftry>
                    <cfset variables.auditionService.setJobStatus(variables.jobId, variables.userid, "mapping")>
                    <cfcatch type="any"><!--- ignore status transition errors ---></cfcatch>
                </cftry>
            </cfif>

            <!--- Log event --->
            <cfset variables.auditionService.logEvent(
                job_id = variables.jobId,
                userid = variables.userid,
                event_type = "columns_updated",
                detail = {
                    column_id: variables.columnId,
                    changed_fields: variables.changedFields,
                    intent: variables.newIntent,
                    target_key: variables.newTargetKey,
                    user_confirmed: variables.newUserConfirmed
                }
            )>
        </cfif>
        <cfset arrayAppend(variables.debug, "column_updated")>
        <cflog file="import_auditions" text="[columns] POST_COLUMNS_UPDATED userid=#variables.userid# job_id=#variables.jobId# column_id=#variables.columnId# changed=#arrayToList(variables.changedFields)# elapsed_ms=#getTickCount() - variables.startTick#">

        <!--- Return updated columns list (same as GET) --->
        <cfset variables.qColumns = queryExecute(
            "SELECT
                c.column_id,
                c.source_column_index,
                c.source_column_name,
                c.mapped_field,
                c.confidence,
                c.user_confirmed,
                c.sample_values,
                c.intent,
                c.target_key,
                c.transform_json
            FROM import_auditions_columns c
            WHERE c.job_id = :job_id
            ORDER BY c.source_column_index ASC",
            { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>

        <!--- Build columns array --->
        <cfset variables.columnsArray = []>
        <cfloop query="variables.qColumns">
            <cfset variables.columnData = {
                "column_id": variables.qColumns.column_id,
                "source_column_index": variables.qColumns.source_column_index,
                "source_name": variables.qColumns.source_column_name,
                "intent": isNull(variables.qColumns.intent) ? "" : variables.qColumns.intent,
                "target_key": isNull(variables.qColumns.target_key) ? "" : variables.qColumns.target_key,
                "transform_json": isNull(variables.qColumns.transform_json) ? "" : variables.qColumns.transform_json,
                "user_confirmed": variables.qColumns.user_confirmed,
                "mapped_field": isNull(variables.qColumns.mapped_field) ? "" : variables.qColumns.mapped_field,
                "confidence": isNull(variables.qColumns.confidence) ? "" : variables.qColumns.confidence,
                "sample_values": []
            }>

            <!--- Get sample values from facts --->
            <cfset variables.qSamples = queryExecute(
                "SELECT DISTINCT f.raw_value
                FROM import_auditions_facts f
                INNER JOIN import_auditions_rows r ON f.row_id = r.row_id
                WHERE f.column_id = :column_id
                  AND r.job_id = :job_id
                  AND f.raw_value IS NOT NULL
                  AND TRIM(f.raw_value) != ''
                LIMIT 5",
                {
                    column_id: { value: variables.qColumns.column_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            )>

            <cfset variables.sampleVals = []>
            <cfloop query="variables.qSamples">
                <cfset arrayAppend(variables.sampleVals, variables.qSamples.raw_value)>
            </cfloop>

            <!--- Fallback to stored sample_values --->
            <cfif arrayLen(variables.sampleVals) eq 0 and len(variables.qColumns.sample_values)>
                <cftry>
                    <cfset variables.storedSamples = deserializeJSON(variables.qColumns.sample_values)>
                    <cfif isArray(variables.storedSamples)>
                        <cfloop array="#variables.storedSamples#" index="variables.sv">
                            <cfif len(trim(variables.sv)) and arrayLen(variables.sampleVals) lt 5>
                                <cfset arrayAppend(variables.sampleVals, variables.sv)>
                            </cfif>
                        </cfloop>
                    </cfif>
                    <cfcatch type="any"></cfcatch>
                </cftry>
            </cfif>

            <cfset variables.columnData.sample_values = variables.sampleVals>
            <cfset arrayAppend(variables.columnsArray, variables.columnData)>
        </cfloop>

        <!--- Get updated job status --->
        <cfset variables.updatedJobResult = variables.auditionService.getJobForUser(variables.jobId, variables.userid)>
        <cfset variables.updatedJob = variables.updatedJobResult.data.job>

        <cfset arrayAppend(variables.debug, "done")>

        <!--- Build success response --->
        <cfset variables.response.success = true>
        <cfset variables.response.message = "Column mapping updated">
        <cfset variables.response.data = {
            "job": {
                "job_id": variables.jobId,
                "status": variables.updatedJob.status
            },
            "columns": variables.columnsArray,
            "updated_column_id": variables.columnId,
            "debug": variables.debug,
            "elapsed_ms": getTickCount() - variables.startTick
        }>

    <cfelse>
        <!--- Unsupported method --->
        <cfset variables.response.code = "INVALID_METHOD">
        <cfset variables.response.message = "Only GET and POST methods are supported">
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = "job_loaded">
    </cfif>

    <cfcatch type="any">
        <cfset arrayAppend(variables.debug, "exception")>
        <cflog file="import_auditions" text="[columns] ERROR userid=#variables.userid# job_id=#variables.jobId# message=#cfcatch.message# detail=#cfcatch.detail# debug=#arrayToList(variables.debug)#">
        <cftry>
            <cfif isObject(variables.auditionService) and variables.jobId gt 0>
                <cfset variables.auditionService.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "columns_error",
                    detail = { error: cfcatch.message, debug: variables.debug }
                )>
            </cfif>
            <cfcatch type="any"></cfcatch>
        </cftry>
        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "An error occurred: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 1 ? variables.debug[arrayLen(variables.debug) - 1] : "start">
        <cfset variables.response.data.error_detail = cfcatch.detail>
        <cfset variables.response.data.error_type = cfcatch.type>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
