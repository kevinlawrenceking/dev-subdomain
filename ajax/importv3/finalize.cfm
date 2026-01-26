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
<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<!--- Phase 5.2: Debug breadcrumbs array (no PII) --->
<cfset debug = ["start"]>

<!--- Initialize variables for error handling --->
<cfset jobId = 0>
<cfset userid = 0>
<cfset v3Service = "">

<!--- Helper: Return JSON error response with debug trail --->
<cffunction name="returnError" access="private" returntype="void" output="true">
    <cfargument name="code" type="string" required="true">
    <cfargument name="message" type="string" required="true">
    <cfargument name="statusCode" type="numeric" required="true">
    <cfargument name="extraData" type="struct" required="false" default="#{}#">

    <cfset response.code = arguments.code>
    <cfset response.message = arguments.message>
    <cfset response.data = arguments.extraData>
    <cfset response.data.debug = debug>
    <cfset response.data.last_step = arrayLen(debug) gt 0 ? debug[arrayLen(debug)] : "none">
    <cfheader statuscode="#arguments.statusCode#">
    <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
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

    <!--- Phase 5.2: Do NOT require "{" prefix - try to parse any non-empty content --->
    <cfif len(cleaned)>
        <cftry>
            <cfset body = deserializeJSON(cleaned)>
            <!--- Ensure it's a struct --->
            <cfif not isStruct(body)>
                <cfset body = {}>
            </cfif>
            <cfcatch type="any">
                <!--- Invalid JSON - continue with empty body --->
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
    <cfset userid = session.userid>
    <cfset arrayAppend(debug, "auth_ok")>

    <!--- B) Generate CSRF token if not exists --->
    <cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>

    <!--- C) Parse JSON request body (Phase 5.2: tolerant parsing) --->
    <cfset body = {}>
    <cftry>
        <cfset httpData = getHttpRequestData()>
        <cfset rawBody = toString(httpData.content)>
        <cfset body = parseJsonBody(rawBody)>
        <cfcatch type="any">
            <!--- If getHttpRequestData fails, continue with empty body --->
            <cfset body = {}>
        </cfcatch>
    </cftry>
    <cfset arrayAppend(debug, "body_parsed")>

    <!--- D) Read CSRF token: header -> body -> form (Phase 5.2: belt+suspenders) --->
    <cfset csrfToken = "">
    <cfset csrfSource = "none">

    <!--- 1) Check X-CSRF-Token header (preferred for JS clients) --->
    <cfif structKeyExists(cgi, "http_x_csrf_token") and len(trim(cgi.http_x_csrf_token))>
        <cfset csrfToken = trim(cgi.http_x_csrf_token)>
        <cfset csrfSource = "header">
    <!--- 2) Check JSON body --->
    <cfelseif structKeyExists(body, "csrf_token") and len(trim(body.csrf_token))>
        <cfset csrfToken = trim(body.csrf_token)>
        <cfset csrfSource = "body">
    <!--- 3) Check form field (fallback for traditional POST) --->
    <cfelseif structKeyExists(form, "csrf_token") and len(trim(form.csrf_token))>
        <cfset csrfToken = trim(form.csrf_token)>
        <cfset csrfSource = "form">
    </cfif>

    <!--- Validate CSRF token --->
    <cfif not len(csrfToken)>
        <cfset returnError("CSRF_INVALID", "CSRF token is required", 403, { csrf_source: "missing" })>
    </cfif>
    <cfif csrfToken neq session.csrf_token>
        <cfset returnError("CSRF_INVALID", "Invalid CSRF token", 403, { csrf_source: csrfSource })>
    </cfif>
    <cfset arrayAppend(debug, "csrf_ok")>

    <!--- E) Read job_id: url -> body -> form --->
    <cfparam name="url.job_id" default="">
    <cfparam name="form.job_id" default="">
    <cfset jobIdSource = "none">

    <!--- 1) Check URL parameter --->
    <cfif isNumeric(url.job_id) and val(url.job_id) gt 0>
        <cfset jobId = val(url.job_id)>
        <cfset jobIdSource = "url">
    <!--- 2) Check JSON body --->
    <cfelseif structKeyExists(body, "job_id") and isNumeric(body.job_id) and val(body.job_id) gt 0>
        <cfset jobId = val(body.job_id)>
        <cfset jobIdSource = "body">
    <!--- 3) Check form field --->
    <cfelseif isNumeric(form.job_id) and val(form.job_id) gt 0>
        <cfset jobId = val(form.job_id)>
        <cfset jobIdSource = "form">
    </cfif>

    <cfif jobId lte 0>
        <cfset returnError("MISSING_JOB_ID", "job_id is required", 400, { job_id_source: "missing" })>
    </cfif>
    <cfset arrayAppend(debug, "job_id_ok")>

    <!--- F) Initialize service --->
    <cfset v3Service = new services.ContactImportV3Service()>
    <cfset arrayAppend(debug, "service_init")>

    <!--- G) Verify job ownership and get current status --->
    <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
    <cfif not jobResult.success>
        <!--- Determine HTTP status based on error code --->
        <cfset statusCode = 400>
        <cfif jobResult.code eq "NOT_FOUND">
            <cfset statusCode = 404>
        <cfelseif jobResult.code eq "ACCESS_DENIED">
            <cfset statusCode = 403>
        </cfif>
        <cfset returnError(jobResult.code, jobResult.message, statusCode)>
    </cfif>
    <cfset job = jobResult.data.job>
    <cfset arrayAppend(debug, "job_loaded")>

    <!--- H) Validate job status - only allow finalize from these states --->
    <cfset ALLOWED_STATUSES = ["reviewing", "finalizing"]>
    <cfif not arrayFindNoCase(ALLOWED_STATUSES, job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot finalize from status: " & job.status & ". Allowed: " & arrayToList(ALLOWED_STATUSES, ", "),
            409,
            { current_status: job.status, allowed: ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(debug, "status_ok")>

    <!--- I) Call finalize service method --->
    <cfset arrayAppend(debug, "finalize_called")>
    <cfset finalizeResult = v3Service.finalizeJob(jobId, userid)>

    <cfif finalizeResult.success>
        <cfset arrayAppend(debug, "done")>
        <cfset response.success = true>
        <cfset response.message = finalizeResult.message>
        <cfset response.data = finalizeResult.data>
        <cfset response.data.debug = debug>
    <cfelse>
        <!--- Determine HTTP status based on error code --->
        <cfset statusCode = 500>
        <cfif finalizeResult.code eq "ALREADY_RUNNING">
            <cfset statusCode = 409>
        <cfelseif finalizeResult.code eq "ALREADY_COMPLETED">
            <cfset statusCode = 409>
        <cfelseif finalizeResult.code eq "LOCK_FAILED">
            <cfset statusCode = 409>
        </cfif>

        <cfset arrayAppend(debug, "finalize_failed")>
        <cfset response.code = finalizeResult.code>
        <cfset response.message = finalizeResult.message>
        <cfif structKeyExists(finalizeResult, "data")>
            <cfset response.data = finalizeResult.data>
        </cfif>
        <cfset response.data.debug = debug>
        <cfset response.data.last_step = "finalize_called">
        <cfheader statuscode="#statusCode#">
    </cfif>

    <cfcatch type="any">
        <!--- Log finalize error (if service available) --->
        <cfset arrayAppend(debug, "exception")>
        <cftry>
            <cfif isObject(v3Service) and jobId gt 0>
                <cfset v3Service.logEvent(
                    job_id = jobId,
                    userid = userid,
                    event_type = "finalize_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, debug: debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "Finalize failed: " & cfcatch.message>
        <cfset response.data.debug = debug>
        <cfset response.data.last_step = arrayLen(debug) gt 1 ? debug[arrayLen(debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
