<cfsilent>
<!---
    Contact Import V3 - Finalize Update Endpoint
    POST /ajax/importv3/finalize_update.cfm

    Applies updates to existing contacts from rows marked with user_action=update_existing.
    Per-row transactions for isolation. Idempotent via row_results check.

    Chunk 9: Update-existing finalize

    Eligibility rules:
    - row.status = 'ready'
    - user_action = 'update_existing'
    - matched_contactid IS NOT NULL and > 0
    - Not already finalized with action_taken='updated'
    - matched_contactid must belong to session.userid

    Safe overwrite rules:
    - Blanks never overwrite existing values unless job.allow_blank_overwrite=1
    - Identical values (after normalization) are skipped

    Request Parameters:
    - job_id (required): The import job ID
    - csrf_token (required): CSRF protection token

    Response codes:
    - AUTH_REQUIRED: No session userid
    - CSRF_INVALID: Invalid or missing CSRF token
    - ACCESS_DENIED: Job or contact does not belong to user
    - NOT_FOUND: Job does not exist
    - MISSING_JOB_ID: job_id parameter missing
    - INVALID_STATE: Job not in allowed status
    - INTERNAL_ERROR: Finalize operation failed
--->

<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- B) CSRF: Generate token if not exists, then validate --->
    <cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>
    <cfparam name="form.csrf_token" default="">
    <cfif not len(form.csrf_token) or form.csrf_token neq session.csrf_token>
        <cfset response.code = "CSRF_INVALID">
        <cfset response.message = "Invalid or missing CSRF token">
        <cfheader statuscode="403">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- C) Validate job_id parameter --->
    <cfparam name="form.job_id" default="">
    <cfparam name="url.job_id" default="">
    <cfset jobId = val(url.job_id)>
    <cfif jobId eq 0>
        <cfset jobId = val(form.job_id)>
    </cfif>
    <cfif jobId lte 0>
        <cfset response.code = "MISSING_JOB_ID">
        <cfset response.message = "job_id is required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Initialize service --->
    <cfset v3Service = new services.ContactImportV3Service()>

    <!--- D) Verify job ownership and get current status --->
    <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
    <cfif not jobResult.success>
        <cfset response.code = jobResult.code>
        <cfset response.message = jobResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset job = jobResult.data.job>

    <!--- E) Validate job status - only allow finalize from these states --->
    <cfset ALLOWED_STATUSES = ["reviewing", "finalizing", "completed"]>
    <cfif not arrayFindNoCase(ALLOWED_STATUSES, job.status)>
        <cfset response.code = "INVALID_STATE">
        <cfset response.message = "Cannot finalize updates from status: " & job.status & ". Allowed: " & arrayToList(ALLOWED_STATUSES, ", ")>
        <cfset response.data = { current_status: job.status, allowed: ALLOWED_STATUSES }>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- F) Call finalize update service method --->
    <cfset finalizeResult = v3Service.finalizeUpdateJob(jobId, userid)>

    <cfif finalizeResult.success>
        <cfset response.success = true>
        <cfset response.message = finalizeResult.message>
        <cfset response.data = finalizeResult.data>
    <cfelse>
        <cfset response.code = finalizeResult.code>
        <cfset response.message = finalizeResult.message>
        <cfset response.data = finalizeResult.data>
    </cfif>

    <cfcatch type="any">
        <!--- Log finalize error --->
        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "finalize_update_endpoint_error",
                detail = { error: cfcatch.message, detail: cfcatch.detail }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>

        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "Finalize update failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
