<cfsilent>
<!---
    Contact Import V3 - Finalize Endpoint
    POST /ajax/importv3/finalize.cfm

    Creates new contacts from approved rows (create-only mode).
    Per-row transactions for isolation. Idempotent via row_results check.

    Phase 5.1: Supports both JSON body and form POST.
    Phase 5.2: Hardened JSON parsing, debug breadcrumbs, belt+suspenders CSRF.

    Request Parameters (from JSON body, form, or URL):
    - job_id (required): The import job ID
    - csrf_token (required): CSRF protection token (also accepts X-CSRF-Token header)

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - CSRF_INVALID: Invalid or missing CSRF token (403)
    - ACCESS_DENIED: Job does not belong to user (403)
    - NOT_FOUND: Job does not exist (404)
    - MISSING_JOB_ID: job_id parameter missing (400)
    - INVALID_STATE: Job not in allowed status (409)
    - ALREADY_RUNNING: Finalize already in progress (409)
    - ALREADY_COMPLETED: Job already finalized (409)
    - INTERNAL_ERROR: Finalize operation failed (500)

    Debug breadcrumbs (response.data.debug):
    - Lightweight step markers for debugging without PII
    - Example: ["start","auth_ok","csrf_ok","job_id_ok","service_init","job_loaded","status_ok","finalize_called","done"]
--->

<!--- Initialize response structure --->
<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<!--- Phase 5.2: Debug breadcrumbs array (no PII) --->
<cfset variables.debug = ["start"]>

<!--- Initialize variables for error handling --->
<cfset variables.jobId = 0>
<cfset variables.userid = 0>
<cfset variables.v3Service = "">

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
    <cfset variables.startTick = getTickCount()>
    <cflog file="importv3" text="[finalize] START userid=#variables.userid#">

    <!--- B) Generate CSRF token if not exists --->
    <cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>

    <!--- C) Parse JSON request body (Phase 5.2: tolerant parsing) --->
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

    <!--- D) Read CSRF token: header -> body -> form (Phase 5.2: belt+suspenders) --->
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
    <cfset variables.jobIdSource = "none">

    <cfif isNumeric(url.job_id) and val(url.job_id) gt 0>
        <cfset variables.jobId = val(url.job_id)>
        <cfset variables.jobIdSource = "url">
    <cfelseif structKeyExists(variables.body, "job_id") and isNumeric(variables.body.job_id) and val(variables.body.job_id) gt 0>
        <cfset variables.jobId = val(variables.body.job_id)>
        <cfset variables.jobIdSource = "body">
    <cfelseif isNumeric(form.job_id) and val(form.job_id) gt 0>
        <cfset variables.jobId = val(form.job_id)>
        <cfset variables.jobIdSource = "form">
    </cfif>

    <cfif variables.jobId lte 0>
        <cfset returnError("MISSING_JOB_ID", "job_id is required", 400, { job_id_source: "missing" })>
    </cfif>
    <cfset arrayAppend(variables.debug, "job_id_ok")>

    <!--- F) Initialize service --->
    <cfset variables.v3Service = new services.ContactImportV3Service()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- G) Verify job ownership and get current status --->
    <cfset variables.jobResult = variables.v3Service.getJobForUser(variables.jobId, variables.userid)>
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

    <!--- H) Validate job status - only allow finalize from these states --->
    <cfset variables.ALLOWED_STATUSES = ["reviewing", "finalizing"]>
    <cfif not arrayFindNoCase(variables.ALLOWED_STATUSES, variables.job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot finalize from status: " & variables.job.status & ". Allowed: " & arrayToList(variables.ALLOWED_STATUSES, ", "),
            409,
            { current_status: variables.job.status, allowed: variables.ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(variables.debug, "status_ok")>

    <!--- I) Call finalize service method --->
    <cfset arrayAppend(variables.debug, "finalize_called")>
    <cflog file="importv3" text="[finalize] CALLING_SERVICE userid=#variables.userid# job_id=#variables.jobId# status=#variables.job.status#">
    <cfset variables.finalizeResult = variables.v3Service.finalizeJob(variables.jobId, variables.userid)>

    <cfif variables.finalizeResult.success>
        <cflog file="importv3" text="[finalize] SUCCESS userid=#variables.userid# job_id=#variables.jobId# elapsed_ms=#getTickCount() - variables.startTick#">
        <cfset arrayAppend(variables.debug, "done")>
        <cfset variables.response.success = true>
        <cfset variables.response.message = variables.finalizeResult.message>
        <cfset variables.response.data = variables.finalizeResult.data>
        <cfset variables.response.data.debug = variables.debug>
    <cfelse>
        <cfset variables.httpStatusCode = 500>
        <cfif variables.finalizeResult.code eq "ALREADY_RUNNING">
            <cfset variables.httpStatusCode = 409>
        <cfelseif variables.finalizeResult.code eq "ALREADY_COMPLETED">
            <cfset variables.httpStatusCode = 409>
        <cfelseif variables.finalizeResult.code eq "LOCK_FAILED">
            <cfset variables.httpStatusCode = 409>
        </cfif>

        <cfset arrayAppend(variables.debug, "finalize_failed")>
        <cfset variables.response.code = variables.finalizeResult.code>
        <cfset variables.response.message = variables.finalizeResult.message>
        <cfif structKeyExists(variables.finalizeResult, "data")>
            <cfset variables.response.data = variables.finalizeResult.data>
        </cfif>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = "finalize_called">
        <cfheader statuscode="#variables.httpStatusCode#">
    </cfif>

    <cfcatch type="any">
        <cflog file="importv3" text="[finalize] ERROR userid=#variables.userid# job_id=#variables.jobId# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cfset arrayAppend(variables.debug, "exception")>
        <cftry>
            <cfif isObject(variables.v3Service) and variables.jobId gt 0>
                <cfset variables.v3Service.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "finalize_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, debug: variables.debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Finalize failed: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 1 ? variables.debug[arrayLen(variables.debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
