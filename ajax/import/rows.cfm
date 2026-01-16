<cfsilent>
<!---
    Contact Import V2 - Get Rows Endpoint
    GET /ajax/import/rows.cfm?job_id=123&status=problem&page=1&limit=50

    Returns: JSON with paginated rows
--->

<cfset response = {
    success: false,
    rows: [],
    total: 0,
    page: 1,
    pages: 0,
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

    <!--- Validate and set parameters --->
    <cfparam name="url.job_id" default="0">
    <cfparam name="url.row_id" default="0">
    <cfparam name="url.status" default="">
    <cfparam name="url.page" default="1">
    <cfparam name="url.limit" default="50">

    <cfif not isNumeric(url.job_id) or url.job_id eq 0>
        <cfset response.message = "Missing or invalid job_id">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Get job --->
    <cfset importService = new services.ContactImportV2Service()>
    <cfset job = importService.getJob(url.job_id)>

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

    <!--- Get rows --->
    <cfif isNumeric(url.row_id) and val(url.row_id) gt 0>
        <!--- Fetch specific row by row_id --->
        <cfset rowsResult = importService.getRows(
            job_id = url.job_id,
            row_id = val(url.row_id),
            page = 1,
            limit = 1
        )>
    <cfelse>
        <!--- Fetch paginated rows with optional status filter --->
        <cfset rowsResult = importService.getRows(
            job_id = url.job_id,
            status = url.status,
            page = val(url.page),
            limit = val(url.limit)
        )>
    </cfif>

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.rows = rowsResult.rows>
    <cfset response.total = rowsResult.total>
    <cfset response.page = rowsResult.page>
    <cfset response.pages = rowsResult.pages>

    <cfcatch type="any">
        <cfset response.message = "Error: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
