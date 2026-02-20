<cfsilent>
<!---
    Contact Import V3 - Status Change Endpoint
    POST /ajax/importv3/status.cfm

    Allows manual job status changes (reset stuck jobs, cancel, re-open).

    Request Parameters (from JSON body, form, or URL):
    - job_id (required): The import job ID
    - new_status (required): The target status
    - csrf_token (required): CSRF protection token

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - CSRF_INVALID: Invalid or missing CSRF token (403)
    - ACCESS_DENIED: Job does not belong to user (403)
    - NOT_FOUND: Job does not exist (404)
    - MISSING_PARAMS: Required parameters missing (400)
    - INVALID_TRANSITION: Status transition not allowed (409)
    - UPDATE_FAILED: Status update failed (500)

    Debug breadcrumbs (response.data.debug):
    - Lightweight step markers for debugging without PII
    - Example: ["start","auth_ok","csrf_ok","params_ok","service_init","job_loaded","transition_ok","status_updated","done"]
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
<cfset variables.userid = 0>
<cfset variables.v3Service = "">
<cfset variables.newStatus = "">

<!--- Allowed manual transitions: from_status -> [to_statuses] --->
<cfset variables.MANUAL_TRANSITIONS = {
    "finalizing": ["reviewing", "cancelled"],
    "completed": ["reviewing"],
    "reviewing": ["cancelled"],
    "failed": ["reviewing"],
    "parsing": ["cancelled"],
    "uploaded": ["cancelled"],
    "parsed": ["cancelled"],
    "mapping": ["cancelled"]
}>

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
    <!--- Remove UTF-8 BOM (EF BB BF) if present --->
    <cfif len(cleaned) gte 3 and asc(left(cleaned, 1)) eq 239 and asc(mid(cleaned, 2, 1)) eq 187 and asc(mid(cleaned, 3, 1)) eq 191>
        <cfset cleaned = mid(cleaned, 4, len(cleaned) - 3)>
    </cfif>
    <!--- Trim whitespace --->
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

    <!--- D) Read CSRF token: header -> body -> form (belt+suspenders) --->
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

    <cfif variables.jobId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id is required", 400)>
    </cfif>


    <!--- F) Read new_status: body -> form --->
    <cfparam name="form.new_status" default="">

    <cfif structKeyExists(variables.body, "new_status") and len(trim(variables.body.new_status))>
        <cfset variables.newStatus = lcase(trim(variables.body.new_status))>
    <cfelseif len(trim(form.new_status))>
        <cfset variables.newStatus = lcase(trim(form.new_status))>
    </cfif>

    <cfif not len(variables.newStatus)>
        <cfset returnError("MISSING_PARAMS", "new_status is required", 400)>
    </cfif>
    <cfset arrayAppend(variables.debug, "params_ok")>

    <!--- G) Initialize service --->
    <cfset variables.v3Service = new services.ContactImportV3Service()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- H) Verify job ownership and get current status --->
    <cfset variables.jobResult = variables.v3Service.getJobForUser(variables.jobId, variables.userid)>
    <cfif not variables.jobResult.success>
        <!--- Determine HTTP status based on error code --->
        <cfset variables.httpStatusCode = 400>
        <cfif variables.jobResult.code eq "NOT_FOUND">
            <cfset variables.httpStatusCode = 404>
        <cfelseif variables.jobResult.code eq "ACCESS_DENIED">
            <cfset variables.httpStatusCode = 403>
        </cfif>
        <cfset returnError(variables.jobResult.code, variables.jobResult.message, variables.httpStatusCode)>
    </cfif>
    <cfset variables.job = variables.jobResult.data.job>
    <cfset variables.currentStatus = lcase(variables.job.status)>
    <cfset arrayAppend(variables.debug, "job_loaded")>

    <!--- I) Validate the transition is allowed --->
    <!--- Check current status has manual transitions defined --->
    <cfif not structKeyExists(variables.MANUAL_TRANSITIONS, variables.currentStatus)>
        <cfset returnError(
            "INVALID_TRANSITION",
            "No manual transitions allowed from status: " & variables.currentStatus,
            409,
            { current_status: variables.currentStatus, requested_status: variables.newStatus }
        )>
    </cfif>

    <!--- Check the requested target status is in the allowed list --->
    <cfset variables.allowedTargets = variables.MANUAL_TRANSITIONS[variables.currentStatus]>
    <cfif not arrayFindNoCase(variables.allowedTargets, variables.newStatus)>
        <cfset returnError(
            "INVALID_TRANSITION",
            "Cannot transition from '" & variables.currentStatus & "' to '" & variables.newStatus & "'. Allowed targets: " & arrayToList(variables.allowedTargets, ", "),
            409,
            { current_status: variables.currentStatus, requested_status: variables.newStatus, allowed_targets: variables.allowedTargets }
        )>
    </cfif>
    <cfset arrayAppend(variables.debug, "transition_ok")>

    <!--- J) Direct UPDATE bypassing service transition rules --->
    <!--- Build additional fields based on target status --->
    <cfset variables.additionalFields = "">

    <!--- When going back to reviewing, clear finished_at since the job is being re-opened --->
    <cfif variables.newStatus eq "reviewing">
        <cfset variables.additionalFields = ", finished_at = NULL, error_message = NULL">
    </cfif>

    <!--- When cancelling, set finished_at --->
    <cfif variables.newStatus eq "cancelled">
        <cfset variables.additionalFields = ", finished_at = NOW()">
    </cfif>

    <cftry>
        <cfset queryExecute(
            "UPDATE import_v3_jobs
                SET status = :new_status,
                    updated_at = NOW()
                    #variables.additionalFields#
                WHERE job_id = :job_id
                  AND userid = :userid",
            {
                new_status: { value: variables.newStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
                userid: { value: variables.userid, cfsqltype: "cf_sql_integer" }
            },
            { datasource: application.datasource }
        )>
        <cfset arrayAppend(variables.debug, "status_updated")>

        <cfcatch type="any">
            <cfset arrayAppend(variables.debug, "update_failed")>
            <!--- Log the DB error via service --->
            <cftry>
                <cfif isObject(variables.v3Service)>
                    <cfset variables.v3Service.logEvent(
                        job_id = variables.jobId,
                        userid = variables.userid,
                        event_type = "manual_status_change_db_error",
                        detail = { error: cfcatch.message, from_status: variables.currentStatus, to_status: variables.newStatus, debug: variables.debug }
                    )>
                </cfif>
                <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
            </cftry>
            <cfset returnError("UPDATE_FAILED", "Failed to update job status: " & cfcatch.message, 500)>
        </cfcatch>
    </cftry>

    <!--- K) Log the manual status change via service --->
    <cftry>
        <cfset variables.v3Service.logEvent(
            job_id = variables.jobId,
            userid = variables.userid,
            event_type = "manual_status_change",
            detail = { from_status: variables.currentStatus, to_status: variables.newStatus, endpoint: "status.cfm" }
        )>
        <cfset arrayAppend(variables.debug, "logged")>
        <cfcatch type="any">
            <!--- Non-fatal: log failure should not block the response --->
            <cfset arrayAppend(variables.debug, "log_failed")>
        </cfcatch>
    </cftry>

    <cfset arrayAppend(variables.debug, "done")>

    <!--- Build success response --->
    <cfset variables.response.success = true>
    <cfset variables.response.message = "Job status changed from '" & variables.currentStatus & "' to '" & variables.newStatus & "'">
    <cfset variables.response.data = {
        "job_id": variables.jobId,
        "previous_status": variables.currentStatus,
        "new_status": variables.newStatus,
        "debug": variables.debug,
        "elapsed_ms": getTickCount() - variables.startTick
    }>

    <cfcatch type="any">
        <!--- Log status change error (if service available) --->
        <cfset arrayAppend(variables.debug, "exception")>
        <cftry>
            <cfif isObject(variables.v3Service) and variables.jobId gt 0>
                <cfset variables.v3Service.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "status_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, new_status: variables.newStatus, debug: variables.debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Status change failed: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 1 ? variables.debug[arrayLen(variables.debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
