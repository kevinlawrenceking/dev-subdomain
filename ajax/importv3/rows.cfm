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

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset returnError("AUTH_REQUIRED", "Authentication required", 401)>
    </cfif>
    <cfset userid = session.userid>
    <cfset arrayAppend(debug, "auth_ok")>

    <!--- B) Validate job_id parameter --->
    <cfparam name="url.job_id" default="">
    <cfset jobId = val(url.job_id)>
    <cfif jobId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id is required", 400)>
    </cfif>
    <cfset arrayAppend(debug, "job_id_ok")>

    <!--- C) Parse optional parameters --->
    <cfparam name="url.status" default="all">
    <cfparam name="url.page" default="1">
    <cfparam name="url.page_size" default="50">
    <cfparam name="url.stats_only" default="0">

    <cfset statusFilter = lcase(trim(url.status))>
    <cfset page = max(1, val(url.page))>
    <cfset pageSize = min(200, max(1, val(url.page_size)))>
    <cfset statsOnly = val(url.stats_only) eq 1>

    <!--- Validate status filter --->
    <cfset validStatuses = ["ready", "problem", "dupe", "ignored", "imported", "all"]>
    <cfif not arrayFindNoCase(validStatuses, statusFilter)>
        <cfset statusFilter = "all">
    </cfif>
    <cfset arrayAppend(debug, "params_parsed")>

    <!--- D) Initialize service --->
    <cfset v3Service = new services.ContactImportV3Service()>
    <cfset arrayAppend(debug, "service_init")>

    <!--- E) Verify job ownership and get current status --->
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

    <!--- F) Status gate: Only allow rows view from these states --->
    <cfset ALLOWED_STATUSES = ["reviewing", "finalizing", "completed"]>
    <cfif not arrayFindNoCase(ALLOWED_STATUSES, job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot view rows from status: " & job.status & ". Allowed: " & arrayToList(ALLOWED_STATUSES, ", "),
            409,
            { current_status: job.status, allowed: ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(debug, "status_ok")>

    <!--- G) If stats_only, return just the stats --->
    <cfif statsOnly>
        <!--- Phase 7: getJobStats returns stats struct directly, not wrapped in result envelope --->
        <cfset stats = v3Service.getJobStats(jobId)>
        <cfset arrayAppend(debug, "stats_fetched")>
        <cfset arrayAppend(debug, "done")>

        <cfset response.success = true>
        <cfset response.message = "">
        <cfset response.data = {
            stats: stats,
            stats_only: true,
            debug: debug,
            elapsed_ms: getTickCount() - startTick
        }>
    <cfelse>
        <!--- H) Call service method to get rows (includes stats) --->
        <cfset rowsResult = v3Service.getRows(
            jobId = jobId,
            userid = userid,
            statusFilter = statusFilter,
            page = page,
            pageSize = pageSize
        )>

        <cfif not rowsResult.success>
            <cfset returnError(rowsResult.code, rowsResult.message, 500)>
        </cfif>
        <cfset arrayAppend(debug, "rows_fetched")>
        <cfset arrayAppend(debug, "done")>

        <!--- Build success response --->
        <cfset response.success = true>
        <cfset response.message = "">
        <cfset response.data = rowsResult.data>
        <cfset response.data.debug = debug>
        <cfset response.data.elapsed_ms = getTickCount() - startTick>
    </cfif>

    <cfcatch type="any">
        <!--- Log rows error (if service available) --->
        <cfset arrayAppend(debug, "exception")>
        <cftry>
            <cfif isObject(v3Service) and jobId gt 0>
                <cfset v3Service.logEvent(
                    job_id = jobId,
                    userid = userid,
                    event_type = "rows_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, debug: debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "Rows fetch failed: " & cfcatch.message>
        <cfset response.data.debug = debug>
        <cfset response.data.last_step = arrayLen(debug) gt 1 ? debug[arrayLen(debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
