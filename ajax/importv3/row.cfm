<cfsilent>
<!---
    Contact Import V3 - Single Row Detail Endpoint
    GET /ajax/importv3/row.cfm

    Returns detailed information for a single row including all column facts.

    Phase 6: Enhanced with Phase 5.2 patterns (debug breadcrumbs, status gates).

    Request Parameters:
    - job_id (required): The import job ID
    - row_id (required): The row ID

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - ACCESS_DENIED: Job does not belong to user (403)
    - NOT_FOUND: Job or row does not exist (404)
    - MISSING_PARAMS: Required parameters missing (400)
    - INVALID_STATE: Job not in allowed status for row view (409)

    Debug breadcrumbs (response.data.debug):
    - Lightweight step markers for debugging without PII
    - Example: ["start","auth_ok","params_ok","service_init","job_loaded","status_ok","row_fetched","done"]
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

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset returnError("AUTH_REQUIRED", "Authentication required", 401)>
    </cfif>
    <cfset userid = session.userid>
    <cfset arrayAppend(debug, "auth_ok")>

    <!--- B) Validate required parameters --->
    <cfparam name="url.job_id" default="">
    <cfparam name="url.row_id" default="">

    <cfset jobId = val(url.job_id)>
    <cfset rowId = val(url.row_id)>

    <cfif jobId lte 0 or rowId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id and row_id are required", 400)>
    </cfif>
    <cfset arrayAppend(debug, "params_ok")>

    <!--- C) Initialize service --->
    <cfset v3Service = new services.ContactImportV3Service()>
    <cfset arrayAppend(debug, "service_init")>

    <!--- D) Verify job ownership and get current status --->
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

    <!--- E) Status gate: Only allow row view from these states --->
    <cfset ALLOWED_STATUSES = ["reviewing", "finalizing", "completed"]>
    <cfif not arrayFindNoCase(ALLOWED_STATUSES, job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot view row from status: " & job.status & ". Allowed: " & arrayToList(ALLOWED_STATUSES, ", "),
            409,
            { current_status: job.status, allowed: ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(debug, "status_ok")>

    <!--- F) Call service method to get row detail --->
    <cfset rowResult = v3Service.getRowDetail(
        job_id = jobId,
        row_id = rowId,
        userid = userid
    )>

    <cfif not rowResult.success>
        <!--- Determine HTTP status based on error code --->
        <cfset statusCode = 500>
        <cfif rowResult.code eq "NOT_FOUND">
            <cfset statusCode = 404>
        </cfif>
        <cfset returnError(rowResult.code, rowResult.message, statusCode)>
    </cfif>
    <cfset arrayAppend(debug, "row_fetched")>
    <cfset arrayAppend(debug, "done")>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = "">
    <cfset response.data = rowResult.data>
    <cfset response.data.debug = debug>
    <cfset response.data.elapsed_ms = getTickCount() - startTick>

    <cfcatch type="any">
        <!--- Log row detail error (if service available) --->
        <cfset arrayAppend(debug, "exception")>
        <cftry>
            <cfif isObject(v3Service) and jobId gt 0>
                <cfset v3Service.logEvent(
                    job_id = jobId,
                    userid = userid,
                    event_type = "row_detail_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, row_id: rowId, debug: debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "Row detail fetch failed: " & cfcatch.message>
        <cfset response.data.debug = debug>
        <cfset response.data.last_step = arrayLen(debug) gt 1 ? debug[arrayLen(debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
