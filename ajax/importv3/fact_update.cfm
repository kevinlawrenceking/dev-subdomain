<cfsilent>
<!---
    Contact Import V3 - Fact Update Endpoint
    POST /ajax/importv3/fact_update.cfm

    Updates fact values for a single row, revalidates, and recomputes row status.
    NEVER modifies raw_value - that is immutable.

    Phase 6: Enhanced with Phase 5.2 patterns (debug breadcrumbs, JSON body, belt+suspenders CSRF).

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
    - Lightweight step markers for debugging without PII
    - Example: ["start","auth_ok","csrf_ok","params_ok","service_init","job_loaded","status_ok","facts_updated","done"]
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

<!--- Phase 6.1: Timing for observability --->
<cfset startTick = getTickCount()>

<!--- Initialize variables for error handling --->
<cfset jobId = 0>
<cfset rowId = 0>
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

    <!--- Try to parse any non-empty content --->
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

    <!--- C) Parse JSON request body (tolerant parsing) --->
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

    <!--- D) Read CSRF token: header -> body -> form (belt+suspenders) --->
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

    <!--- 1) Check URL parameter --->
    <cfif isNumeric(url.job_id) and val(url.job_id) gt 0>
        <cfset jobId = val(url.job_id)>
    <!--- 2) Check JSON body --->
    <cfelseif structKeyExists(body, "job_id") and isNumeric(body.job_id) and val(body.job_id) gt 0>
        <cfset jobId = val(body.job_id)>
    <!--- 3) Check form field --->
    <cfelseif isNumeric(form.job_id) and val(form.job_id) gt 0>
        <cfset jobId = val(form.job_id)>
    </cfif>

    <!--- F) Read row_id: url -> body -> form --->
    <cfparam name="url.row_id" default="">
    <cfparam name="form.row_id" default="">

    <cfif isNumeric(url.row_id) and val(url.row_id) gt 0>
        <cfset rowId = val(url.row_id)>
    <cfelseif structKeyExists(body, "row_id") and isNumeric(body.row_id) and val(body.row_id) gt 0>
        <cfset rowId = val(body.row_id)>
    <cfelseif isNumeric(form.row_id) and val(form.row_id) gt 0>
        <cfset rowId = val(form.row_id)>
    </cfif>

    <cfif jobId lte 0 or rowId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id and row_id are required", 400)>
    </cfif>

    <!--- G) Read fields: body only (must be a struct) --->
    <cfset fields = {}>
    <cfif structKeyExists(body, "fields") and isStruct(body.fields)>
        <cfset fields = body.fields>
    </cfif>

    <cfif structIsEmpty(fields)>
        <cfset returnError("MISSING_PARAMS", "fields object is required with at least one field to update", 400)>
    </cfif>
    <cfset arrayAppend(debug, "params_ok")>

    <!--- H) Initialize service --->
    <cfset v3Service = new services.ContactImportV3Service()>
    <cfset arrayAppend(debug, "service_init")>

    <!--- I) Verify job ownership and get current status --->
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

    <!--- J) Status gate: Only allow fact editing from reviewing state --->
    <cfset ALLOWED_STATUSES = ["reviewing"]>
    <cfif not arrayFindNoCase(ALLOWED_STATUSES, job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot edit facts from status: " & job.status & ". Allowed: " & arrayToList(ALLOWED_STATUSES, ", "),
            409,
            { current_status: job.status, allowed: ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(debug, "status_ok")>

    <!--- K) Call service method to update facts --->
    <cfset arrayAppend(debug, "update_called")>
    <cfset updateResult = v3Service.updateRowFacts(
        jobId = jobId,
        rowId = rowId,
        fields = fields,
        userid = userid
    )>

    <cfif not updateResult.success>
        <!--- Determine HTTP status based on error code --->
        <cfset statusCode = 500>
        <cfif updateResult.code eq "NOT_FOUND">
            <cfset statusCode = 404>
        <cfelseif updateResult.code eq "VALIDATION_ERROR">
            <cfset statusCode = 400>
        </cfif>
        <cfset arrayAppend(debug, "update_failed")>
        <cfset returnError(updateResult.code, updateResult.message, statusCode, updateResult.data ?: {})>
    </cfif>
    <cfset arrayAppend(debug, "facts_updated")>
    <cfset arrayAppend(debug, "done")>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = updateResult.message>
    <cfset response.data = updateResult.data>
    <cfset response.data.debug = debug>
    <cfset response.data.elapsed_ms = getTickCount() - startTick>

    <cfcatch type="any">
        <!--- Log fact update error (if service available) --->
        <cfset arrayAppend(debug, "exception")>
        <cftry>
            <cfif isObject(v3Service) and jobId gt 0>
                <cfset v3Service.logEvent(
                    job_id = jobId,
                    userid = userid,
                    event_type = "fact_update_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, row_id: rowId, debug: debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "Fact update failed: " & cfcatch.message>
        <cfset response.data.debug = debug>
        <cfset response.data.last_step = arrayLen(debug) gt 1 ? debug[arrayLen(debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
