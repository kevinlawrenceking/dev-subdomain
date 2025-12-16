<cfsilent>
<!---
    Contact Import V2 - Update Row Endpoint
    POST /ajax/import/update-row.cfm

    Expects JSON body: { row_id: number, data: object }
    Returns: JSON with new status and validation
--->

<cfset response = {
    success: false,
    new_status: "",
    validation: {},
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

    <!--- Validate data --->
    <cfif not structKeyExists(requestData, "data") or not isStruct(requestData.data)>
        <cfset response.message = "Missing or invalid data">
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

    <!--- Update row --->
    <cfset importService = new services.ContactImportV2Service()>
    <cfset updateResult = importService.updateRow(
        row_id = requestData.row_id,
        data = requestData.data,
        userid = userid
    )>

    <cfif not updateResult.success>
        <cfset response.message = updateResult.message>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.new_status = updateResult.new_status>
    <cfset response.validation = updateResult.validation>

    <cfcatch type="any">
        <cfset response.message = "Error: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
