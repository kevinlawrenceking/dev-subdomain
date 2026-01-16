<cfsilent>
<!---
    Contact Import V2 - Job Status Endpoint
    GET /ajax/import/status.cfm?job_id=123

    Returns: JSON with job status and counts
--->

<cfset response = {
    success: false,
    job: {},
    stats: {},
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

    <!--- Validate job_id --->
    <cfparam name="url.job_id" default="0">
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

    <!--- Get detailed stats --->
    <cfset stats = importService.getJobStats(url.job_id)>

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.job = {
        job_id: job.job_id,
        filename: job.source_filename,
        file_type: job.file_type,
        status: job.status,
        created_at: dateTimeFormat(job.created_at, "yyyy-mm-dd HH:nn:ss"),
        total_rows: job.total_rows,
        parsed_rows: job.parsed_rows,
        valid_rows: job.valid_rows,
        problem_rows: job.problem_rows,
        dupe_rows: job.dupe_rows,
        imported_rows: job.imported_rows
    }>
    <cfset response.stats = stats>

    <cfcatch type="any">
        <cfset response.message = "Error: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
