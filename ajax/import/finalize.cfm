<cfsilent>
<!---
    Contact Import V2 - Finalize Import Endpoint
    POST /ajax/import/finalize.cfm

    Expects JSON body: { job_id: number }
    Returns: JSON with import results
--->

<cfset response = {
    success: false,
    imported: 0,
    skipped: 0,
    failed: 0,
    contacts: [],
    errors: [],
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

    <!--- Validate job_id --->
    <cfif not structKeyExists(requestData, "job_id") or not isNumeric(requestData.job_id)>
        <cfset response.message = "Missing or invalid job_id">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Get and verify job --->
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

    <!--- Acquire atomic import lock (prevents concurrent double-finalize) --->
    <cfset lockResult = importService.tryAcquireImportLock(requestData.job_id)>

    <cfif not lockResult.acquired>
        <!--- Lock not acquired - return appropriate message --->
        <cfset response.message = lockResult.message>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Lock acquired (status is now 'importing') - validate job is ready --->
    <cfset validation = importService.validateForImport(requestData.job_id)>

    <cfif not validation.can_import>
        <!--- Release lock by resetting status to 'reviewing' --->
        <cfset importService.updateJobStatus(requestData.job_id, "reviewing")>
        <cfset response.message = "Cannot import: " & arrayToList(validation.issues, "; ")>
        <cfset response.errors = validation.issues>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Execute import (lock held, status is 'importing') --->
    <cfset importResult = importService.executeImport(requestData.job_id, userid)>

    <!--- Return result --->
    <cfset response.success = importResult.success>
    <cfset response.imported = importResult.imported>
    <cfset response.skipped = importResult.skipped>
    <cfset response.failed = importResult.failed>
    <cfset response.contacts = importResult.contacts>
    <cfset response.errors = importResult.errors>

    <cfif importResult.success>
        <cfset response.message = "Import completed. " & importResult.imported & " contacts imported.">
    <cfelse>
        <cfset response.message = "Import completed with errors. " & importResult.imported & " imported, " & importResult.failed & " failed.">
    </cfif>

    <cfcatch type="any">
        <cfset response.message = "Error: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
