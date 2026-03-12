<cfsilent>
<!---
    Audition Import - Single Row Detail Endpoint
    GET /ajax/import-auditions/row.cfm

    Returns detailed information for a single audition import row including all column facts.

    Ported from Contact Import V3 for audition import module.

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

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset returnError("AUTH_REQUIRED", "Authentication required", 401)>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfset arrayAppend(variables.debug, "auth_ok")>
    <cflog file="import_auditions" text="[row] START userid=#variables.userid#">

    <!--- B) Validate required parameters --->
    <cfparam name="url.job_id" default="">
    <cfparam name="url.row_id" default="">

    <cfset variables.jobId = val(url.job_id)>
    <cfset variables.rowId = val(url.row_id)>

    <cfif variables.jobId lte 0 or variables.rowId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id and row_id are required", 400)>
    </cfif>
    <cfset arrayAppend(variables.debug, "params_ok")>

    <!--- C) Initialize service --->
    <cfset variables.auditionService = new services.AuditionImportService()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- D) Verify job ownership and get current status --->
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

    <!--- E) Status gate: Only allow row view from these states --->
    <cfset variables.ALLOWED_STATUSES = ["reviewing", "finalizing", "completed"]>
    <cfif not arrayFindNoCase(variables.ALLOWED_STATUSES, variables.job.status)>
        <cfset returnError(
            "INVALID_STATE",
            "Cannot view row from status: " & variables.job.status & ". Allowed: " & arrayToList(variables.ALLOWED_STATUSES, ", "),
            409,
            { current_status: variables.job.status, allowed: variables.ALLOWED_STATUSES }
        )>
    </cfif>
    <cfset arrayAppend(variables.debug, "status_ok")>

    <!--- F) Call service method to get row detail --->
    <cfset variables.rowResult = variables.auditionService.getRowDetail(
        job_id = variables.jobId,
        row_id = variables.rowId,
        userid = variables.userid
    )>

    <cfif not variables.rowResult.success>
        <cfset variables.httpStatusCode = 500>
        <cfif variables.rowResult.code eq "NOT_FOUND">
            <cfset variables.httpStatusCode = 404>
        </cfif>
        <cfset returnError(variables.rowResult.code, variables.rowResult.message, variables.httpStatusCode)>
    </cfif>
    <cfset arrayAppend(variables.debug, "row_fetched")>
    <cflog file="import_auditions" text="[row] SUCCESS userid=#variables.userid# job_id=#variables.jobId# row_id=#variables.rowId# elapsed_ms=#getTickCount() - variables.startTick#">
    <cfset arrayAppend(variables.debug, "done")>

    <!--- Build success response --->
    <cfset variables.response.success = true>
    <cfset variables.response.message = "">
    <cfset variables.response.data = variables.rowResult.data>
    <cfset variables.response.data.debug = variables.debug>
    <cfset variables.response.data.elapsed_ms = getTickCount() - variables.startTick>

    <cfcatch type="any">
        <!--- Log row detail error (if service available) --->
        <cflog file="import_auditions" text="[row] ERROR userid=#variables.userid# job_id=#variables.jobId# row_id=#variables.rowId# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cfset arrayAppend(variables.debug, "exception")>
        <cftry>
            <cfif isObject(variables.auditionService) and variables.jobId gt 0>
                <cfset variables.auditionService.logEvent(
                    job_id = variables.jobId,
                    userid = variables.userid,
                    event_type = "row_detail_endpoint_error",
                    detail = { error: cfcatch.message, detail: cfcatch.detail, row_id: variables.rowId, debug: variables.debug }
                )>
            </cfif>
            <cfcatch type="any"><!--- Ignore logging errors ---></cfcatch>
        </cftry>

        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Row detail fetch failed: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 1 ? variables.debug[arrayLen(variables.debug) - 1] : "start">
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
