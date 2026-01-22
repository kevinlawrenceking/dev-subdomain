<cfsilent>
<!---
    Contact Import V3 - Rows List Endpoint
    GET /ajax/importv3/rows.cfm
    
    Returns paginated list of rows for a job with summary counts.
    
    Request Parameters:
    - job_id (required): The import job ID
    - status (optional): Filter by status - ready|problem|dupe|ignored|all (default: all)
    - page (optional): Page number (default: 1)
    - page_size (optional): Rows per page (default: 50, max: 200)
    
    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job does not exist
    - MISSING_PARAMS: job_id parameter missing
--->

<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<cftry>
    <!--- Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- Validate job_id parameter --->
    <cfparam name="url.job_id" default="">
    <cfset jobId = val(url.job_id)>
    <cfif jobId lte 0>
        <cfset response.code = "MISSING_PARAMS">
        <cfset response.message = "job_id is required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Parse optional parameters --->
    <cfparam name="url.status" default="all">
    <cfparam name="url.page" default="1">
    <cfparam name="url.page_size" default="50">
    
    <cfset statusFilter = lcase(trim(url.status))>
    <cfset page = max(1, val(url.page))>
    <cfset pageSize = min(200, max(1, val(url.page_size)))>

    <!--- Validate status filter --->
    <cfset validStatuses = ["ready", "problem", "dupe", "ignored", "all"]>
    <cfif not arrayFindNoCase(validStatuses, statusFilter)>
        <cfset statusFilter = "all">
    </cfif>

    <!--- Initialize V3 service --->
    <cfset v3Service = new services.ContactImportV3Service()>

    <!--- Verify job ownership --->
    <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
    <cfif not jobResult.success>
        <cfset response.code = jobResult.code>
        <cfset response.message = jobResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Call service method to get rows --->
    <cfset rowsResult = v3Service.getRows(
        jobId = jobId,
        userid = userid,
        statusFilter = statusFilter,
        page = page,
        pageSize = pageSize
    )>

    <cfif not rowsResult.success>
        <cfset response.code = rowsResult.code>
        <cfset response.message = rowsResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = "">
    <cfset response.data = rowsResult.data>

    <cfcatch type="any">
        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "rows_list_error",
                detail = { error: cfcatch.message }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>
        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "An error occurred: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
