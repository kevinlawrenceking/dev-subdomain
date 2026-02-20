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
<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<!--- Phase 5.2: Debug breadcrumbs array (no PII) --->
<cfset variables.debug = ["start"]>

<!--- Phase 6.1: Timing for observability --->
<cfset variables.startTick = getTickCount()>

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
            <!--- If getHttpRequestData fails, continue with empty body --->
            <cfset variables.body = {}>
        </cfcatch>
    </cftry>
    <cfset arrayAppend(variables.debug, "body_parsed")>

    <!--- D) Read CSRF token: header -> body -> form (belt+suspenders) --->
    <cfset variables.csrfToken = "">
    <cfset variables.csrfSource = "none">

    <!--- 1) Check X-CSRF-Token header (preferred for JS clients) --->
    <cfif structKeyExists(cgi, "http_x_csrf_token") and len(trim(cgi.http_x_csrf_token))>
        <cfset variables.csrfToken = trim(cgi.http_x_csrf_token)>
        <cfset variables.csrfSource = "header">
    <!--- 2) Check JSON body --->
    <cfelseif structKeyExists(variables.body, "csrf_token") and len(trim(variables.body.csrf_token))>
        <cfset variables.csrfToken = trim(variables.body.csrf_token)>
        <cfset variables.csrfSource = "body">
    <!--- 3) Check form field (fallback for traditional POST) --->
    <cfelseif structKeyExists(form, "csrf_token") and len(trim(form.csrf_token))>
        <cfset variables.csrfToken = trim(form.csrf_token)>
        <cfset variables.csrfSource = "form">
    </cfif>

    <!--- Validate CSRF token --->
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

    <!--- F) Read action: body -> form --->
    <cfparam name="form.action" default="">
    <cfparam name="form.user_action" default="">
    <cfset variables.rowAction = "">

    <!--- Check body.action first --->
    <cfif structKeyExists(variables.body, "action") and len(trim(variables.body.action))>
        <cfset variables.rowAction = lcase(trim(variables.body.action))>
    <!--- Legacy: body.user_action --->
    <cfelseif structKeyExists(variables.body, "user_action") and len(trim(variables.body.user_action))>
        <cfset variables.rowAction = lcase(trim(variables.body.user_action))>
    <!--- Form fallback --->
    <cfelseif len(trim(form.action))>
        <cfset variables.rowAction = lcase(trim(form.action))>
    <cfelseif len(trim(form.user_action))>
        <cfset variables.rowAction = lcase(trim(form.user_action))>
    </cfif>

    <!--- Validate action --->
    <cfset variables.validActions = ["ignore", "create", "skip", "import_new"]>
    <cfif not len(variables.rowAction)>
        <cfset returnError("MISSING_PARAMS", "action is required (ignore or create)", 400)>
    </cfif>
    <cfif not arrayFindNoCase(variables.validActions, variables.rowAction)>
        <cfset returnError("INVALID_ACTION", "action must be one of: ignore, create", 400, { provided: variables.rowAction })>
    </cfif>

    <!--- Normalize action names (UI names to DB names) --->
    <cfif variables.rowAction eq "ignore">
        <cfset variables.rowAction = "skip">
    <cfelseif variables.rowAction eq "create">
        <cfset variables.rowAction = "import_new">
    </cfif>

    <!--- G) Read row IDs: support both single row_id and bulk row_ids --->
    <cfparam name="url.row_id" default="">
    <cfparam name="form.row_id" default="">
    <cfset variables.rowIds = []>
    <cfset variables.isBulk = false>

    <!--- Check for bulk row_ids array in body --->
    <cfif structKeyExists(variables.body, "row_ids") and isArray(variables.body.row_ids) and arrayLen(variables.body.row_ids) gt 0>
        <cfloop array="#variables.body.row_ids#" index="rid">
            <cfif isNumeric(rid) and val(rid) gt 0>
                <cfset arrayAppend(variables.rowIds, val(rid))>
            </cfif>
        </cfloop>
        <cfset variables.isBulk = true>
    <!--- Single row_id from various sources --->
    <cfelseif structKeyExists(variables.body, "row_id") and isNumeric(variables.body.row_id) and val(variables.body.row_id) gt 0>
        <cfset arrayAppend(variables.rowIds, val(variables.body.row_id))>
    <cfelseif isNumeric(url.row_id) and val(url.row_id) gt 0>
        <cfset arrayAppend(variables.rowIds, val(url.row_id))>
    <cfelseif isNumeric(form.row_id) and val(form.row_id) gt 0>
        <cfset arrayAppend(variables.rowIds, val(form.row_id))>
    </cfif>

    <cfif arrayLen(variables.rowIds) eq 0>
        <cfset returnError("MISSING_PARAMS", "row_id or row_ids is required", 400)>
    </cfif>
    <cfset arrayAppend(variables.debug, "params_ok")>

    <!--- H) Initialize service --->
    <cfset variables.v3Service = new services.ContactImportV3Service()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- I) Verify job ownership and get current status --->
    <cfset variables.jobResult = variables.v3Service.getJobForUser(variables.jobId, variables.userid)>
    <cfif not variables.jobResult.success>
        <!--- Determine HTTP status based on error code --->
        <cfset variables.statusCode = 400>
        <cfif variables.jobResult.code eq "NOT_FOUND">
            <cfset variables.statusCode = 404>
        <cfelseif variables.jobResult.code eq "ACCESS_DENIED">
            <cfset variables.statusCode = 403>
        </cfif>
        <cfset returnError(variables.jobResult.code, variables.jobResult.message, variables.statusCode)>
    </cfif>
    <cfset variables.job = variables.jobResult.data.job>
    <cfset arrayAppend(variables.debug, "job_loaded")>

    <!--- J) Status gate: Allow row actions from reviewing, finalizing, and completed states --->
    <cfset variables.ALLOWED_STATUSES = ["reviewing", "finalizing", "completed"]>
    <cfif not arrayFindNoCase(variables.ALLOWED_STATUSES, variables.job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot set row actions from status: " & variables.job.status & ". Allowed: " & arrayToList(variables.ALLOWED_STATUSES, ", "),
            409,
            { current_status: variables.job.status, allowed: variables.ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(variables.debug, "status_ok")>

    <!--- K) Call service method(s) to set row action --->
    <cfset arrayAppend(variables.debug, "action_called")>

    <cfif variables.isBulk or arrayLen(variables.rowIds) gt 1>
        <!--- Bulk operation --->
        <cfset variables.actionResult = variables.v3Service.bulkRowAction(
            job_id = variables.jobId,
            row_ids = variables.rowIds,
            action = variables.rowAction,
            userid = variables.userid
        )>
    <cfelse>
        <!--- Single row operation --->
        <cfset variables.actionResult = variables.v3Service.setRowAction(
            job_id = variables.jobId,
            row_id = variables.rowIds[1],
            action = variables.rowAction,
            userid = variables.userid
        )>
    </cfif>

    <cfif not variables.actionResult.success>
        <!--- Determine HTTP status based on error code --->
        <cfset variables.statusCode = 500>
        <cfif variables.actionResult.code eq "NOT_FOUND">
            <cfset variables.statusCode = 404>
        <cfelseif variables.actionResult.code eq "UPDATE_NOT_SUPPORTED">
            <cfset variables.statusCode = 400>
        <cfelseif variables.actionResult.code eq "INVALID_ACTION">
            <cfset variables.statusCode = 400>
        </cfif>
        <cfset arrayAppend(variables.debug, "action_failed")>
        <cfset returnError(variables.actionResult.code, variables.actionResult.message, variables.statusCode, variables.actionResult.data ?: {})>
    </cfif>
    <cfset arrayAppend(variables.debug, "action_applied")>
    <cfset arrayAppend(variables.debug, "done")>

    <!--- Build success response --->
    <cfset variables.response.success = true>
    <cfset variables.response.message = variables.actionResult.message>
    <cfset variables.response.data = variables.actionResult.data>
    <cfset variables.response.data.debug = variables.debug>
    <cfset variables.response.data.elapsed_ms = getTickCount() - variables.startTick>

    <cfcatch type="any">
        <!--- Log row action error (if service available) --->
        <cfset arrayAppend(variables.debug, "exception")>
        <cftry>
            <cfif isObject(variables.v3Service) and variables.jobId gt 0>
                <cfset variables.v3Service.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "row_action_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, action: variables.rowAction, debug: variables.debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Row action failed: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 1 ? variables.debug[arrayLen(variables.debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
