<cfsilent>
<!---
    Contact Import V3 - Row Action Endpoint
    POST /ajax/importv3/row_action.cfm

    Sets the user_action for one or more rows (ignore or create).
    Create-only mode: update_existing action is NOT supported.

    Phase 6: Enhanced with Phase 5.2 patterns (debug breadcrumbs, JSON body, bulk support).

    Request Parameters (from JSON body, form, or URL):
    - job_id (required): The import job ID
    - row_id (required for single): The row ID (use row_ids for bulk)
    - row_ids (required for bulk): Array of row IDs
    - action (required): ignore|create (mapped to skip|import_new internally)
    - csrf_token (required): CSRF protection token (also accepts X-CSRF-Token header)

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - CSRF_INVALID: Invalid or missing CSRF token (403)
    - ACCESS_DENIED: Job does not belong to user (403)
    - NOT_FOUND: Job or row does not exist (404)
    - MISSING_PARAMS: Required parameters missing (400)
    - INVALID_ACTION: Invalid action value (400)
    - UPDATE_NOT_SUPPORTED: Update action not supported in create-only mode (400)
    - INVALID_STATE: Job not in allowed status for row actions (409)
    - UPDATE_FAILED: Database update failed (500)

    Debug breadcrumbs (response.data.debug):
    - Lightweight step markers for debugging without PII
    - Example: ["start","auth_ok","csrf_ok","params_ok","service_init","job_loaded","status_ok","action_applied","done"]
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

    <cfif isNumeric(url.job_id) and val(url.job_id) gt 0>
        <cfset jobId = val(url.job_id)>
    <cfelseif structKeyExists(body, "job_id") and isNumeric(body.job_id) and val(body.job_id) gt 0>
        <cfset jobId = val(body.job_id)>
    <cfelseif isNumeric(form.job_id) and val(form.job_id) gt 0>
        <cfset jobId = val(form.job_id)>
    </cfif>

    <cfif jobId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id is required", 400)>
    </cfif>

    <!--- F) Read action: body -> form --->
    <cfparam name="form.action" default="">
    <cfparam name="form.user_action" default="">
    <cfset action = "">

    <!--- Check body.action first --->
    <cfif structKeyExists(body, "action") and len(trim(body.action))>
        <cfset action = lcase(trim(body.action))>
    <!--- Legacy: body.user_action --->
    <cfelseif structKeyExists(body, "user_action") and len(trim(body.user_action))>
        <cfset action = lcase(trim(body.user_action))>
    <!--- Form fallback --->
    <cfelseif len(trim(form.action))>
        <cfset action = lcase(trim(form.action))>
    <cfelseif len(trim(form.user_action))>
        <cfset action = lcase(trim(form.user_action))>
    </cfif>

    <!--- Validate action --->
    <cfset validActions = ["ignore", "create", "skip", "import_new"]>
    <cfif not len(action)>
        <cfset returnError("MISSING_PARAMS", "action is required (ignore or create)", 400)>
    </cfif>
    <cfif not arrayFindNoCase(validActions, action)>
        <cfset returnError("INVALID_ACTION", "action must be one of: ignore, create", 400, { provided: action })>
    </cfif>

    <!--- Normalize action names (UI names to DB names) --->
    <cfif action eq "ignore">
        <cfset action = "skip">
    <cfelseif action eq "create">
        <cfset action = "import_new">
    </cfif>

    <!--- G) Read row IDs: support both single row_id and bulk row_ids --->
    <cfparam name="url.row_id" default="">
    <cfparam name="form.row_id" default="">
    <cfset rowIds = []>
    <cfset isBulk = false>

    <!--- Check for bulk row_ids array in body --->
    <cfif structKeyExists(body, "row_ids") and isArray(body.row_ids) and arrayLen(body.row_ids) gt 0>
        <cfloop array="#body.row_ids#" index="rid">
            <cfif isNumeric(rid) and val(rid) gt 0>
                <cfset arrayAppend(rowIds, val(rid))>
            </cfif>
        </cfloop>
        <cfset isBulk = true>
    <!--- Single row_id from various sources --->
    <cfelseif structKeyExists(body, "row_id") and isNumeric(body.row_id) and val(body.row_id) gt 0>
        <cfset arrayAppend(rowIds, val(body.row_id))>
    <cfelseif isNumeric(url.row_id) and val(url.row_id) gt 0>
        <cfset arrayAppend(rowIds, val(url.row_id))>
    <cfelseif isNumeric(form.row_id) and val(form.row_id) gt 0>
        <cfset arrayAppend(rowIds, val(form.row_id))>
    </cfif>

    <cfif arrayLen(rowIds) eq 0>
        <cfset returnError("MISSING_PARAMS", "row_id or row_ids is required", 400)>
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

    <!--- J) Status gate: Allow row actions from reviewing and finalizing states --->
    <cfset ALLOWED_STATUSES = ["reviewing", "finalizing"]>
    <cfif not arrayFindNoCase(ALLOWED_STATUSES, job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot set row actions from status: " & job.status & ". Allowed: " & arrayToList(ALLOWED_STATUSES, ", "),
            409,
            { current_status: job.status, allowed: ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(debug, "status_ok")>

    <!--- K) Call service method(s) to set row action --->
    <cfset arrayAppend(debug, "action_called")>

    <cfif isBulk or arrayLen(rowIds) gt 1>
        <!--- Bulk operation --->
        <cfset actionResult = v3Service.bulkRowAction(
            jobId = jobId,
            rowIds = rowIds,
            action = action,
            userid = userid
        )>
    <cfelse>
        <!--- Single row operation --->
        <cfset actionResult = v3Service.setRowAction(
            jobId = jobId,
            rowId = rowIds[1],
            action = action,
            userid = userid
        )>
    </cfif>

    <cfif not actionResult.success>
        <!--- Determine HTTP status based on error code --->
        <cfset statusCode = 500>
        <cfif actionResult.code eq "NOT_FOUND">
            <cfset statusCode = 404>
        <cfelseif actionResult.code eq "UPDATE_NOT_SUPPORTED">
            <cfset statusCode = 400>
        <cfelseif actionResult.code eq "INVALID_ACTION">
            <cfset statusCode = 400>
        </cfif>
        <cfset arrayAppend(debug, "action_failed")>
        <cfset returnError(actionResult.code, actionResult.message, statusCode, actionResult.data ?: {})>
    </cfif>
    <cfset arrayAppend(debug, "action_applied")>
    <cfset arrayAppend(debug, "done")>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = actionResult.message>
    <cfset response.data = actionResult.data>
    <cfset response.data.debug = debug>
    <cfset response.data.elapsed_ms = getTickCount() - startTick>

    <cfcatch type="any">
        <!--- Log row action error (if service available) --->
        <cfset arrayAppend(debug, "exception")>
        <cftry>
            <cfif isObject(v3Service) and jobId gt 0>
                <cfset v3Service.logEvent(
                    job_id = jobId,
                    userid = userid,
                    event_type = "row_action_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, action: action, debug: debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "Row action failed: " & cfcatch.message>
        <cfset response.data.debug = debug>
        <cfset response.data.last_step = arrayLen(debug) gt 1 ? debug[arrayLen(debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
