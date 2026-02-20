<cfsilent>
<!---
    Admin User Management - Toggle User Status
    POST /app/admin-users/ajax/toggle-status.cfm

    Form Parameters:
    - userid (required): Target user ID
    - newStatus (required): Target status (Active, Cancelled, Pending)

    Returns JSON: { success, message }
--->

<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>

<cftry>
    <cfparam name="form.userid" default="0">
    <cfparam name="form.newStatus" default="">

    <cfset variables.targetUserId = val(form.userid)>
    <cfif variables.targetUserId lte 0>
        <cfset variables.response.message = "Valid userid is required">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <cfif not len(trim(form.newStatus))>
        <cfset variables.response.message = "New status is required">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <cfset variables.svc = new services.UserService()>
    <cfset variables.result = variables.svc.toggleUserStatus(
        userid = variables.targetUserId,
        newStatus = form.newStatus
    )>

    <cfif variables.result.success>
        <cflog file="admin_users" text="[toggle-status] userid=#variables.targetUserId# newStatus=#form.newStatus# by admin=#session.userid#">
    </cfif>

    <cfset variables.response.success = variables.result.success>
    <cfset variables.response.message = variables.result.message>
    <cfset variables.response.data.userid = variables.targetUserId>
    <cfset variables.response.data.newStatus = form.newStatus>

    <cfcatch type="any">
        <cfset variables.response.message = "Status change failed: " & cfcatch.message>
        <cflog file="admin_users" text="[toggle-status] ERROR userid=#val(form.userid)#: #cfcatch.message# #cfcatch.detail#">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
