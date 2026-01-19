<cfsilent>
<!---
    Contact Import V3 - Preview Update Endpoint
    GET /ajax/importv3/preview_update.cfm

    Generates a preview of what changes will be made when finalizing update_existing rows.
    Shows field-level diffs with old/new values and actions (set, add, skip_blank, skip_same).

    Chunk 9: Update-existing finalize preview

    Request Parameters:
    - job_id (required): The import job ID
    - row_id (optional): Single row ID to preview (omit for all eligible rows)

    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job does not exist
    - MISSING_JOB_ID: job_id parameter missing
    - INTERNAL_ERROR: Preview generation failed
--->

<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>
<!--- Feature flag check --->
<cfif NOT structKeyExists(application, "features") 
    OR NOT structKeyExists(application.features, "importV3Enabled")
    OR NOT application.features.importV3Enabled>
    <cfcontent type="application/json" reset="true">
    <cfoutput>#serializeJSON({
        success: false,
        code: "FEATURE_DISABLED",
        message: "Contact Import V3 is not enabled"
    })#</cfoutput>
    <cfabort>
</cfif>


<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- B) Validate job_id parameter --->
    <cfparam name="url.job_id" default="">
    <cfparam name="form.job_id" default="">
    <cfset jobId = val(url.job_id)>
    <cfif jobId eq 0>
        <cfset jobId = val(form.job_id)>
    </cfif>
    <cfif jobId lte 0>
        <cfset response.code = "MISSING_JOB_ID">
        <cfset response.message = "job_id is required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- C) Optional row_id parameter --->
    <cfparam name="url.row_id" default="0">
    <cfparam name="form.row_id" default="0">
    <cfset rowId = val(url.row_id)>
    <cfif rowId eq 0>
        <cfset rowId = val(form.row_id)>
    </cfif>

    <!--- D) Initialize service --->
    <cfset v3Service = new services.ContactImportV3Service()>

    <!--- E) Verify job ownership --->
    <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
    <cfif not jobResult.success>
        <cfset response.code = jobResult.code>
        <cfset response.message = jobResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- F) Call preview service method --->
    <cfset previewResult = v3Service.previewUpdateJob(jobId, userid, rowId)>

    <cfif previewResult.success>
        <cfset response.success = true>
        <cfset response.message = previewResult.message>
        <cfset response.data = previewResult.data>
    <cfelse>
        <cfset response.code = previewResult.code>
        <cfset response.message = previewResult.message>
        <cfset response.data = previewResult.data>
    </cfif>

    <cfcatch type="any">
        <!--- Log preview error --->
        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "preview_update_endpoint_error",
                detail = { error: cfcatch.message, detail: cfcatch.detail }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>

        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "Preview failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
