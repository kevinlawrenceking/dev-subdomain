<cfsilent>
<!---
    Contact Import V3 - Row Action Endpoint
    POST /ajax/importv3/row_action.cfm
    
    Sets the user_action for a row (import_new, update_existing, or skip).
    
    Request Parameters (POST):
    - job_id (required): The import job ID
    - row_id (required): The row ID
    - user_action (required): import_new|update_existing|skip
    - matched_contactid (required if update_existing): Contact ID to update
    
    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job or row does not exist
    - MISSING_PARAMS: Required parameters missing
    - INVALID_ACTION: Invalid user_action value
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
    <cfparam name="form.user_action" default="">
    <cfparam name="form.matched_contactid" default="">
    
    <cfset jobId = val(form.job_id)>
    <cfset rowId = val(form.row_id)>
    <cfset userAction = lcase(trim(form.user_action))>
    <cfset matchedContactId = val(form.matched_contactid)>
    
    <cfif jobId lte 0 or rowId lte 0>
        <cfset response.code = "MISSING_PARAMS">
        <cfset response.message = "job_id and row_id are required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Validate user_action --->
    <cfset validActions = ["import_new", "update_existing", "skip"]>
    <cfif not len(userAction) or not arrayFindNoCase(validActions, userAction)>
        <cfset response.code = "INVALID_ACTION">
        <cfset response.message = "user_action must be one of: " & arrayToList(validActions, ", ")>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- If update_existing, require matched_contactid --->
    <cfif userAction eq "update_existing" and matchedContactId lte 0>
        <cfset response.code = "MISSING_PARAMS">
        <cfset response.message = "matched_contactid is required when user_action is update_existing">
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

    <!--- Call service method to set row action --->
    <cfset actionResult = v3Service.setRowAction(
        jobId = jobId,
        rowId = rowId,
        userAction = userAction,
        matchedContactId = matchedContactId,
        userid = userid
    )>

    <cfif not actionResult.success>
        <cfset response.code = actionResult.code>
        <cfset response.message = actionResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Build success response --->
    <cfset response.success = true>
    <cfset response.message = "Row action updated successfully">
    <cfset response.data = actionResult.data>

    <cfcatch type="any">
        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "row_action_error",
                detail = { error: cfcatch.message, row_id: rowId, user_action: userAction }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>
        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "An error occurred: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
