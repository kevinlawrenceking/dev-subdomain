<cfsilent>
<!---
    Contact Import V2 - Parse File Endpoint
    POST /ajax/import/parse.cfm

    Expects JSON body: { job_id: number, options: object }
    Returns: JSON with parse results
--->

<cfset response = {
    success: false,
    totalRows: 0,
    parsedRows: 0,
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

    <!--- Get and validate job --->
    <cfset importService = new services.ContactImportV2Service()>
    <cfset job = importService.getJob(requestData.job_id)>

    <cfif not job.found>
        <cfset response.message = "Job not found">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Verify ownership --->
    <cfif job.userid neq userid>
        <cfset response.message = "Access denied">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Parse the file --->
    <cfset parseResult = importService.parseFile(requestData.job_id)>

    <cfif not parseResult.success>
        <cfset response.message = parseResult.message>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Process rows (apply mapping, validation, duplicate detection) --->
    <cfset processResult = importService.processRows(requestData.job_id, userid)>

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.totalRows = parseResult.totalRows>
    <cfset response.parsedRows = parseResult.parsedRows>
    <cfset response.validRows = processResult.valid>
    <cfset response.problemRows = processResult.problem>
    <cfset response.dupeRows = processResult.dupe>
    <cfset response.message = "File parsed successfully">

    <cfcatch type="any">
        <cfset response.message = "Parse failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
