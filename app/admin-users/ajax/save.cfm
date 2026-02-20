<cfsilent>
<!---
    Admin User Management - Create or Update User
    POST /app/admin-users/ajax/save.cfm

    Form Parameters:
    - userid (0 for create, >0 for update)
    - userFirstName (required)
    - userLastName (required)
    - userEmail (required)
    - userRole (optional, default "User")
    - userstatus (optional, default "Active")
    - password (required for create, optional for update)
    - IsBetaTester (0/1, optional)
    - isAudition (0/1, optional)
    - isAuditionModule (0/1, optional)

    Returns JSON: { success, message, data: { userid } }
--->

<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>

<cftry>
    <cfparam name="form.userid" default="0">
    <cfparam name="form.userFirstName" default="">
    <cfparam name="form.userLastName" default="">
    <cfparam name="form.userEmail" default="">
    <cfparam name="form.userRole" default="User">
    <cfparam name="form.userstatus" default="Active">
    <cfparam name="form.password" default="">
    <cfparam name="form.IsBetaTester" default="0">
    <cfparam name="form.isAudition" default="0">
    <cfparam name="form.isAuditionModule" default="0">

    <cfset variables.svc = new services.UserService()>
    <cfset variables.targetUserId = val(form.userid)>

    <cfif variables.targetUserId gt 0>
        <!--- UPDATE existing user --->
        <cfset variables.result = variables.svc.updateUser(
            userid = variables.targetUserId,
            userFirstName = form.userFirstName,
            userLastName = form.userLastName,
            userEmail = form.userEmail,
            userRole = form.userRole,
            userstatus = form.userstatus,
            IsBetaTester = val(form.IsBetaTester) ? true : false,
            isAudition = val(form.isAudition) ? true : false,
            isAuditionModule = val(form.isAuditionModule) ? true : false,
            newPassword = form.password
        )>

        <cfif variables.result.success>
            <cflog file="admin_users" text="[save] UPDATE userid=#variables.targetUserId# by admin=#session.userid#">
        </cfif>

        <cfset variables.response.success = variables.result.success>
        <cfset variables.response.message = variables.result.message>
        <cfset variables.response.data.userid = variables.targetUserId>

    <cfelse>
        <!--- CREATE new user --->
        <cfif not len(trim(form.password))>
            <cfset variables.response.message = "Password is required when creating a new user">
            <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>

        <cfset variables.result = variables.svc.createUser(
            userFirstName = form.userFirstName,
            userLastName = form.userLastName,
            userEmail = form.userEmail,
            userRole = form.userRole,
            password = form.password,
            userstatus = form.userstatus
        )>

        <cfif variables.result.success>
            <cflog file="admin_users" text="[save] CREATE userid=#variables.result.userid# by admin=#session.userid#">
        </cfif>

        <cfset variables.response.success = variables.result.success>
        <cfset variables.response.message = variables.result.message>
        <cfset variables.response.data.userid = variables.result.success ? variables.result.userid : 0>
    </cfif>

    <cfcatch type="any">
        <cfset variables.response.message = "Save failed: " & cfcatch.message>
        <cflog file="admin_users" text="[save] ERROR: #cfcatch.message# #cfcatch.detail#">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
