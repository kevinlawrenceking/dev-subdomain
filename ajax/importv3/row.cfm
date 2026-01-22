<cfsilent>
<!---
    Contact Import V3 - Single Row Detail Endpoint
    GET /ajax/importv3/row.cfm
    
    Returns detailed information for a single row including all column facts.
    
    Request Parameters:
    - job_id (required): The import job ID
    - row_id (required): The row ID
    
    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job or row does not exist
    - MISSING_PARAMS: Required parameters missing
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

    <!--- Validate required parameters --->
    <cfparam name="url.job_id" default="">
    <cfparam name="url.row_id" default="">
    
    <cfset jobId = val(url.job_id)>
    <cfset rowId = val(url.row_id)>
    
    <cfif jobId lte 0 or rowId lte 0>
        <cfset response.code = "MISSING_PARAMS">
        <cfset response.message = "job_id and row_id are required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
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

    <!--- Call service method to get row detail --->
    <cfset rowResult = v3Service.getRowDetail(
        jobId = jobId,
        rowId = rowId,
        userid = userid
    )>

    <cfif not rowResult.success>
        <cfset response.code = rowResult.code>
        <cfset response.message = rowResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = "">
    <cfset response.data = rowResult.data>

    <cfcatch type="any">
        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "row_detail_error",
                detail = { error: cfcatch.message, row_id: rowId }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>
        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "An error occurred: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
