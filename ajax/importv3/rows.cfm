<cfsilent>
<!---
    Contact Import V3 - Rows List Endpoint
    GET /ajax/importv3/rows.cfm

    Returns paginated list of rows for a job with summary counts.

    Phase 6: Enhanced with Phase 5.2 patterns (debug breadcrumbs, status gates).

    Request Parameters:
    - job_id (required): The import job ID
    - status (optional): Filter by status - ready|problem|dupe|ignored|imported|all (default: all)
    - page (optional): Page number (default: 1)
    - page_size (optional): Rows per page (default: 50, max: 200)
    - stats_only (optional): If 1, return only stats without row data

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - ACCESS_DENIED: Job does not belong to user (403)
    - NOT_FOUND: Job does not exist (404)
    - MISSING_PARAMS: job_id parameter missing (400)
    - INVALID_STATE: Job not in allowed status for rows view (409)

    Debug breadcrumbs (response.data.debug):
    - Lightweight step markers for debugging without PII
    - Example: ["start","auth_ok","job_id_ok","service_init","job_loaded","status_ok","rows_fetched","done"]
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

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset returnError("AUTH_REQUIRED", "Authentication required", 401)>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfset arrayAppend(variables.debug, "auth_ok")>
    <cflog file="importv3" text="[rows] START userid=#variables.userid#">

    <!--- B) Validate job_id parameter --->
    <cfparam name="url.job_id" default="">
    <cfset variables.jobId = val(url.job_id)>
    <cfif variables.jobId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id is required", 400)>
    </cfif>
    <cfset arrayAppend(variables.debug, "job_id_ok")>

    <!--- C) Parse optional parameters --->
    <cfparam name="url.status" default="all">
    <cfparam name="url.page" default="1">
    <cfparam name="url.page_size" default="50">
    <cfparam name="url.stats_only" default="0">
    <cfparam name="url.search" default="">

    <cfset variables.statusFilter = lcase(trim(url.status))>
    <cfset variables.page = max(1, val(url.page))>
    <cfset variables.pageSize = min(200, max(1, val(url.page_size)))>
    <cfset variables.statsOnly = val(url.stats_only) eq 1>
    <cfset variables.searchTerm = trim(url.search)>

    <!--- Validate status filter --->
    <cfset variables.validStatuses = ["ready", "problem", "dupe", "ignored", "imported", "all"]>
    <cfif not arrayFindNoCase(variables.validStatuses, variables.statusFilter)>
        <cfset variables.statusFilter = "all">
    </cfif>
    <cfset arrayAppend(variables.debug, "params_parsed")>

    <!--- D) Initialize service --->
    <cfset variables.v3Service = new services.ContactImportV3Service()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- E) Verify job ownership and get current status --->
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

    <!--- F) Status gate: Only allow rows view from these states --->
    <cfset variables.ALLOWED_STATUSES = ["reviewing", "finalizing", "completed"]>
    <cfif not arrayFindNoCase(variables.ALLOWED_STATUSES, variables.job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot view rows from status: " & variables.job.status & ". Allowed: " & arrayToList(variables.ALLOWED_STATUSES, ", "),
            409,
            { current_status: variables.job.status, allowed: variables.ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(variables.debug, "status_ok")>

    <!--- G) If stats_only, return just the stats --->
    <cfif variables.statsOnly>
        <cfset variables.stats = variables.v3Service.getJobStats(variables.jobId)>
        <cfset arrayAppend(variables.debug, "stats_fetched")>
        <cfset arrayAppend(variables.debug, "done")>
        <cflog file="importv3" text="[rows] STATS_ONLY userid=#variables.userid# job_id=#variables.jobId# elapsed_ms=#getTickCount() - variables.startTick#">

        <cfset variables.response.success = true>
        <cfset variables.response.message = "">
        <cfset variables.response.data = {
            stats: variables.stats,
            stats_only: true,
            debug: variables.debug,
            elapsed_ms: getTickCount() - variables.startTick
        }>
    <cfelse>
        <!--- H) Call service method to get rows (includes stats) --->
        <cfset variables.rowsResult = variables.v3Service.getRows(
            job_id = variables.jobId,
            userid = variables.userid,
            statusFilter = variables.statusFilter,
            page = variables.page,
            pageSize = variables.pageSize,
            search = variables.searchTerm
        )>

        <cfif not variables.rowsResult.success>
            <cfset returnError(variables.rowsResult.code, variables.rowsResult.message, 500)>
        </cfif>
        <cfset arrayAppend(variables.debug, "rows_fetched")>
        <cfset arrayAppend(variables.debug, "done")>
        <cflog file="importv3" text="[rows] SUCCESS userid=#variables.userid# job_id=#variables.jobId# filter=#variables.statusFilter# page=#variables.page# elapsed_ms=#getTickCount() - variables.startTick#">

        <!--- Build success response --->
        <cfset variables.response.success = true>
        <cfset variables.response.message = "">
        <cfset variables.response.data = variables.rowsResult.data>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.elapsed_ms = getTickCount() - variables.startTick>
    </cfif>

    <cfcatch type="any">
        <!--- Log rows error (if service available) --->
        <cfset arrayAppend(variables.debug, "exception")>
        <cftry>
            <cfif isObject(variables.v3Service) and variables.jobId gt 0>
                <cfset variables.v3Service.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "rows_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, debug: variables.debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <!--- Also log to importv3 log file --->
        <cflog file="importv3" text="rows.cfm ERROR job_id=#variables.jobId# user=#variables.userid# err=#cfcatch.message# detail=#cfcatch.detail# type=#cfcatch.type# tagcontext=#cfcatch.tagcontext[1].template#:#cfcatch.tagcontext[1].line#">

        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Rows fetch failed: " & cfcatch.message & " [" & cfcatch.tagcontext[1].template & ":" & cfcatch.tagcontext[1].line & "]">
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 1 ? variables.debug[arrayLen(variables.debug) - 1] : "start">
        <cfset variables.response.data.error_detail = cfcatch.detail>
        <cfset variables.response.data.error_type = cfcatch.type>
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
