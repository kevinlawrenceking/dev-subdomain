<cfsilent>
<!---
    Contact Import V3 - Fact Update Endpoint
    POST /ajax/importv3/fact_update.cfm
    
    Updates the edited_value for a single fact (cell value).
    NEVER modifies raw_value - that is immutable.
    
    Request Parameters (POST):
    - job_id (required): The import job ID
    - row_id (required): The row ID
    - column_id (required): The column ID
    - new_value (required): The new edited value (can be empty string to clear)
    
    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job, row, or fact does not exist
    - MISSING_PARAMS: Required parameters missing
    - UPDATE_FAILED: Database update failed
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
    <!--- Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- CSRF: Generate token if not exists, then validate --->
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

    <!--- Validate required parameters --->
    <cfparam name="form.job_id" default="">
    <cfparam name="form.row_id" default="">
    <cfparam name="form.column_id" default="">
    <cfparam name="form.new_value" default="">
    
    <cfset jobId = val(form.job_id)>
    <cfset rowId = val(form.row_id)>
    <cfset columnId = val(form.column_id)>
    <cfset newValue = form.new_value>
    
    <cfif jobId lte 0 or rowId lte 0 or columnId lte 0>
        <cfset response.code = "MISSING_PARAMS">
        <cfset response.message = "job_id, row_id, and column_id are required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Validate new_value was explicitly provided (allow empty string) --->
    <cfif not structKeyExists(form, "new_value")>
        <cfset response.code = "MISSING_PARAMS">
        <cfset response.message = "new_value is required">
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

    <!--- Call service method to update fact --->
    <cfset updateResult = v3Service.updateFact(
        jobId = jobId,
        rowId = rowId,
        columnId = columnId,
        newValue = newValue,
        userid = userid
    )>

    <cfif not updateResult.success>
        <cfset response.code = updateResult.code>
        <cfset response.message = updateResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = "Fact updated successfully">
    <cfset response.data = updateResult.data>

    <cfcatch type="any">
        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "fact_update_error",
                detail = { error: cfcatch.message, row_id: rowId, column_id: columnId }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>
        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "An error occurred: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
