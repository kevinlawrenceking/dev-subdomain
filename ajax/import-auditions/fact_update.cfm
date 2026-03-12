<cfsilent>
<!---
    Audition Import - Fact Update Endpoint
    POST /ajax/import-auditions/fact_update.cfm

    Updates fact values for a single row, revalidates, and recomputes row status.
    NEVER modifies raw_value - that is immutable.

    Request Parameters (from JSON body, form, or URL):
    - job_id (required): The import job ID
    - row_id (required): The row ID
    - fields (required): Object with field_name:new_value pairs to update
    - csrf_token (required): CSRF protection token (also accepts X-CSRF-Token header)

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - CSRF_INVALID: Invalid or missing CSRF token (403)
    - ACCESS_DENIED: Job does not belong to user (403)
    - NOT_FOUND: Job or row does not exist (404)
    - MISSING_PARAMS: Required parameters missing (400)
    - INVALID_STATE: Job not in allowed status for editing (409)
    - UPDATE_FAILED: Database update failed (500)

    Debug breadcrumbs (response.data.debug):
    - Example: ["start","auth_ok","csrf_ok","params_ok","service_init","job_loaded","status_ok","facts_updated","done"]
--->

<!--- Initialize response structure --->
<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<!--- Debug breadcrumbs array (no PII) --->
<cfset variables.debug = ["start"]>

<!--- Timing for observability --->
<cfset variables.startTick = getTickCount()>

<!--- Initialize variables for error handling --->
<cfset variables.jobId = 0>
<cfset variables.rowId = 0>
<cfset variables.userid = 0>
<cfset variables.auditionService = "">

<!--- Helper: Return JSON error response with debug trail --->
<cffunction name="returnError" access="private" returntype="void" output="true">
    <cfargument name="code" type="string" required="true">
    <cfargument name="message" type="string" required="true">
    <cfargument name="statusCode" type="numeric" required="true">
    <cfargument name="extraData" type="struct" required="false" default="#{}#">

    <cfset variables.response.code = arguments.code>
    <cfset variables.response.message = arguments.message>
    <cfset variables.response.data = arguments.extraData>
    <cfset variables.response.data.debug = variables.debug>
    <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 0 ? variables.debug[arrayLen(variables.debug)] : "none">
    <cfheader statuscode="#arguments.statusCode#">
    <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
</cffunction>

<!--- Helper: Strip BOM and whitespace from raw body --->
<cffunction name="cleanRawBody" access="private" returntype="string" output="false">
    <cfargument name="raw" type="string" required="true">
    <cfset var cleaned = arguments.raw>
    <cfif len(cleaned) gte 3 and asc(left(cleaned, 1)) eq 239 and asc(mid(cleaned, 2, 1)) eq 187 and asc(mid(cleaned, 3, 1)) eq 191>
        <cfset cleaned = mid(cleaned, 4, len(cleaned) - 3)>
    </cfif>
    <cfset cleaned = trim(cleaned)>
    <cfreturn cleaned>
</cffunction>

<!--- Helper: Safely parse JSON body --->
<cffunction name="parseJsonBody" access="private" returntype="struct" output="false">
    <cfargument name="rawBody" type="string" required="true">
    <cfset var body = {}>
    <cfset var cleaned = cleanRawBody(arguments.rawBody)>

    <cfif len(cleaned)>
        <cftry>
            <cfset body = deserializeJSON(cleaned)>
            <cfif not isStruct(body)>
                <cfset body = {}>
            </cfif>
            <cfcatch type="any">
                <cfset body = {}>
            </cfcatch>
        </cftry>
    </cfif>

    <cfreturn body>
</cffunction>

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset returnError("AUTH_REQUIRED", "Authentication required", 401)>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfset arrayAppend(variables.debug, "auth_ok")>
    <cflog file="import_auditions" text="[fact_update] START userid=#variables.userid#">

    <!--- B) Generate CSRF token if not exists --->
    <cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>

    <!--- C) Parse JSON request body (tolerant parsing) --->
    <cfset variables.body = {}>
    <cftry>
        <cfset variables.httpData = getHttpRequestData()>
        <cfset variables.rawBody = toString(variables.httpData.content)>
        <cfset variables.body = parseJsonBody(variables.rawBody)>
        <cfcatch type="any">
            <cfset variables.body = {}>
        </cfcatch>
    </cftry>
    <cfset arrayAppend(variables.debug, "body_parsed")>

    <!--- D) Read CSRF token: header -> body -> form --->
    <cfset variables.csrfToken = "">
    <cfset variables.csrfSource = "none">

    <cfif structKeyExists(cgi, "http_x_csrf_token") and len(trim(cgi.http_x_csrf_token))>
        <cfset variables.csrfToken = trim(cgi.http_x_csrf_token)>
        <cfset variables.csrfSource = "header">
    <cfelseif structKeyExists(variables.body, "csrf_token") and len(trim(variables.body.csrf_token))>
        <cfset variables.csrfToken = trim(variables.body.csrf_token)>
        <cfset variables.csrfSource = "body">
    <cfelseif structKeyExists(form, "csrf_token") and len(trim(form.csrf_token))>
        <cfset variables.csrfToken = trim(form.csrf_token)>
        <cfset variables.csrfSource = "form">
    </cfif>

    <cfif not len(variables.csrfToken)>
        <cfset returnError("CSRF_INVALID", "CSRF token is required", 403, { csrf_source: "missing" })>
    </cfif>
    <cfif variables.csrfToken neq session.csrf_token>
        <cfset returnError("CSRF_INVALID", "Invalid CSRF token", 403, { csrf_source: variables.csrfSource })>
    </cfif>
    <cfset arrayAppend(variables.debug, "csrf_ok")>

    <!--- E) Read job_id: url -> body -> form --->
    <cfparam name="url.job_id" default="">
    <cfparam name="form.job_id" default="">

    <cfif isNumeric(url.job_id) and val(url.job_id) gt 0>
        <cfset variables.jobId = val(url.job_id)>
    <cfelseif structKeyExists(variables.body, "job_id") and isNumeric(variables.body.job_id) and val(variables.body.job_id) gt 0>
        <cfset variables.jobId = val(variables.body.job_id)>
    <cfelseif isNumeric(form.job_id) and val(form.job_id) gt 0>
        <cfset variables.jobId = val(form.job_id)>
    </cfif>

    <!--- F) Read row_id: url -> body -> form --->
    <cfparam name="url.row_id" default="">
    <cfparam name="form.row_id" default="">

    <cfif isNumeric(url.row_id) and val(url.row_id) gt 0>
        <cfset variables.rowId = val(url.row_id)>
    <cfelseif structKeyExists(variables.body, "row_id") and isNumeric(variables.body.row_id) and val(variables.body.row_id) gt 0>
        <cfset variables.rowId = val(variables.body.row_id)>
    <cfelseif isNumeric(form.row_id) and val(form.row_id) gt 0>
        <cfset variables.rowId = val(form.row_id)>
    </cfif>

    <cfif variables.jobId lte 0 or variables.rowId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id and row_id are required", 400)>
    </cfif>

    <!--- G) Read fields: body only (must be a struct) --->
    <cfset variables.fields = {}>
    <cfif structKeyExists(variables.body, "fields") and isStruct(variables.body.fields)>
        <cfset variables.fields = variables.body.fields>
    </cfif>

    <cfif structIsEmpty(variables.fields)>
        <cfset returnError("MISSING_PARAMS", "fields object is required with at least one field to update", 400)>
    </cfif>
    <cfset arrayAppend(variables.debug, "params_ok")>

    <!--- H) Initialize service --->
    <cfset variables.auditionService = new services.AuditionImportService()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- I) Verify job ownership and get current status --->
    <cfset variables.jobResult = variables.auditionService.getJobForUser(variables.jobId, variables.userid)>
    <cfif not variables.jobResult.success>
        <cfset variables.httpStatusCode = 400>
        <cfif variables.jobResult.code eq "NOT_FOUND">
            <cfset variables.httpStatusCode = 404>
        <cfelseif variables.jobResult.code eq "ACCESS_DENIED">
            <cfset variables.httpStatusCode = 403>
        </cfif>
        <cfset returnError(variables.jobResult.code, variables.jobResult.message, variables.httpStatusCode)>
    </cfif>
    <cfset variables.job = variables.jobResult.data.job>
    <cfset arrayAppend(variables.debug, "job_loaded")>

    <!--- J) Status gate: Allow fact editing during review and finalization --->
    <cfset variables.ALLOWED_STATUSES = ["reviewing", "finalizing"]>
    <cfif not arrayFindNoCase(variables.ALLOWED_STATUSES, variables.job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot edit facts from status: " & variables.job.status & ". Allowed: " & arrayToList(variables.ALLOWED_STATUSES, ", "),
            409,
            { current_status: variables.job.status, allowed: variables.ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(variables.debug, "status_ok")>

    <!--- K) Call service method to update facts --->
    <cfset arrayAppend(variables.debug, "update_called")>
    <cfset variables.updateResult = variables.auditionService.updateRowFacts(
        job_id = variables.jobId,
        row_id = variables.rowId,
        fields = variables.fields,
        userid = variables.userid
    )>

    <cfif not variables.updateResult.success>
        <cfset variables.httpStatusCode = 500>
        <cfif variables.updateResult.code eq "NOT_FOUND">
            <cfset variables.httpStatusCode = 404>
        <cfelseif variables.updateResult.code eq "VALIDATION_ERROR">
            <cfset variables.httpStatusCode = 400>
        </cfif>
        <cfset arrayAppend(variables.debug, "update_failed")>
        <cfset returnError(variables.updateResult.code, variables.updateResult.message, variables.httpStatusCode, variables.updateResult.data ?: {})>
    </cfif>
    <cfset arrayAppend(variables.debug, "facts_updated")>
    <cflog file="import_auditions" text="[fact_update] SUCCESS userid=#variables.userid# job_id=#variables.jobId# row_id=#variables.rowId# field_count=#structCount(variables.fields)# elapsed_ms=#getTickCount() - variables.startTick#">
    <cfset arrayAppend(variables.debug, "done")>

    <!--- Build success response --->
    <cfset variables.response.success = true>
    <cfset variables.response.message = variables.updateResult.message>
    <cfset variables.response.data = variables.updateResult.data>
    <cfset variables.response.data.debug = variables.debug>
    <cfset variables.response.data.elapsed_ms = getTickCount() - variables.startTick>

    <cfcatch type="any">
        <cflog file="import_auditions" text="[fact_update] ERROR userid=#variables.userid# job_id=#variables.jobId# row_id=#variables.rowId# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cfset arrayAppend(variables.debug, "exception")>
        <cftry>
            <cfif isObject(variables.auditionService) and variables.jobId gt 0>
                <cfset variables.auditionService.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "fact_update_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, row_id: variables.rowId, debug: variables.debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Fact update failed: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 1 ? variables.debug[arrayLen(variables.debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>