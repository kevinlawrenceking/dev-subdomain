<cfsilent>
<!---
    Contact Import V2 - Set Row Action Endpoint
    POST /ajax/import/row-action.cfm

    Expects JSON body: { row_id: number, action: string }
    Actions: import_new, skip, update_existing
    Returns: JSON with success status
--->

<cfset response = {
    success: false,
    message: ""
}>

<cftry>
    <!--- Validate user session --->
    <cfif not isDefined("userid") or not isNumeric(userid)>
        <cfset response.message = "Authentication required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Parse request body --->
    <cfset requestBody = toString(getHTTPRequestData().content)>
    <cfif not len(requestBody)>
        <cfset response.message = "Missing request body">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset requestData = deserializeJSON(requestBody)>

    <!--- Validate row_id --->
    <cfif not structKeyExists(requestData, "row_id") or not isNumeric(requestData.row_id)>
        <cfset response.message = "Missing or invalid row_id">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Validate action --->
    <cfset validActions = "import_new,skip,update_existing">
    <cfif not structKeyExists(requestData, "action") or not listFindNoCase(validActions, requestData.action)>
        <cfset response.message = "Invalid action. Must be one of: " & validActions>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Get row's job and verify ownership --->
    <cfquery name="qRow">
        SELECT r.job_id, j.userid
        FROM import_job_rows r
        INNER JOIN import_jobs j ON j.job_id = r.job_id
        WHERE r.row_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData.row_id#">
    </cfquery>

    <cfif qRow.recordCount eq 0>
        <cfset response.message = "Row not found">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfif qRow.userid neq userid>
        <cfset response.message = "Access denied">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Set row action --->
    <cfset importService = new services.ContactImportV2Service()>
    <cfset importService.setRowAction(requestData.row_id, requestData.action)>

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.message = "Action set successfully">

    <cfcatch type="any">
        <cfset response.message = "Error: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
