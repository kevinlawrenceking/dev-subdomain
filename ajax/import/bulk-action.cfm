<cfsilent>
<!---
    Contact Import V2 - Bulk Set Action Endpoint
    POST /ajax/import/bulk-action.cfm

    Expects JSON body: { job_id: number, row_ids: array, action: string }
    Actions: import_new, skip, update_existing
    Returns: JSON with success status
--->

<cfset response = {
    success: false,
    affected: 0,
    message: ""
}>

<cftry>
    <!--- Validate user session --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid)>
        <cfset response.message = "Authentication required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- Parse request body --->
    <cfset requestBody = toString(getHTTPRequestData().content)>
    <cfif not len(requestBody)>
        <cfset response.message = "Missing request body">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset requestData = deserializeJSON(requestBody)>

    <!--- Validate job_id --->
    <cfif not structKeyExists(requestData, "job_id") or not isNumeric(requestData.job_id)>
        <cfset response.message = "Missing or invalid job_id">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Validate row_ids --->
    <cfif not structKeyExists(requestData, "row_ids") or not isArray(requestData.row_ids)>
        <cfset response.message = "Missing or invalid row_ids array">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Validate action --->
    <cfset validActions = "import_new,skip,update_existing,ignore">
    <cfif not structKeyExists(requestData, "action") or not listFindNoCase(validActions, requestData.action)>
        <cfset response.message = "Invalid action. Must be one of: " & validActions>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Verify job ownership --->
    <cfset importService = new services.ContactImportV2Service()>
    <cfset job = importService.getJob(requestData.job_id)>

    <cfif not job.found>
        <cfset response.message = "Job not found">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfif job.userid neq userid>
        <cfset response.message = "Access denied">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Set bulk action --->
    <cfset importService.bulkSetAction(
        job_id = requestData.job_id,
        row_ids = requestData.row_ids,
        action = requestData.action
    )>

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.affected = arrayLen(requestData.row_ids)>
    <cfset response.message = "Action set for " & arrayLen(requestData.row_ids) & " rows">

    <cfcatch type="any">
        <cfset response.message = "Error: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
