<cfsilent>
<!---
    Admin User Management - Get User Details
    GET /app/admin-users/ajax/get.cfm

    URL Parameters:
    - userid (required): The user ID to fetch

    Returns JSON: { success, message, data: { user: {...} } }
--->

<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>

<cftry>
    <cfparam name="url.userid" default="0">

    <cfset variables.targetUserId = val(url.userid)>
    <cfif variables.targetUserId lte 0>
        <cfset variables.response.message = "Valid userid is required">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <cfset variables.svc = new services.UserService()>
    <cfset variables.userData = variables.svc.GetUserDetails(variables.targetUserId)>

    <!--- Check if user was found (GetUserDetails returns struct with keys from query, empty if not found) --->
    <cfif structIsEmpty(variables.userData) or (structKeyExists(variables.userData, "userid") and variables.userData.userid eq "")>
        <cfset variables.response.message = "User not found">
        <cfheader statuscode="404">
        <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Build safe user struct (exclude sensitive fields) --->
    <cfset variables.safeUser = {
        "userid": variables.userData.userid,
        "userFirstName": variables.userData.userFirstName,
        "userLastName": variables.userData.userLastName,
        "userEmail": variables.userData.userEmail,
        "userRole": variables.userData.userRole,
        "userstatus": variables.userData.userstatus,
        "recordname": variables.userData.recordname,
        "avatarname": variables.userData.avatarname,
        "customerid": variables.userData.customerid,
        "IsDeleted": variables.userData.IsDeleted,
        "IsBetaTester": variables.userData.IsBetaTester,
        "isSetup": variables.userData.isSetup,
        "isAudition": variables.userData.isAudition,
        "isAuditionModule": variables.userData.isAuditionModule
    }>

    <!--- Add optional fields if they exist --->
    <cfif structKeyExists(variables.userData, "tzname")>
        <cfset variables.safeUser.tzname = variables.userData.tzname>
    </cfif>
    <cfif structKeyExists(variables.userData, "dateformatExample")>
        <cfset variables.safeUser.dateformatExample = variables.userData.dateformatExample>
    </cfif>
    <cfif structKeyExists(variables.userData, "regionName")>
        <cfset variables.safeUser.regionName = variables.userData.regionName>
    </cfif>
    <cfif structKeyExists(variables.userData, "countryName")>
        <cfset variables.safeUser.countryName = variables.userData.countryName>
    </cfif>
    <cfif structKeyExists(variables.userData, "planName")>
        <cfset variables.safeUser.planName = variables.userData.planName>
    </cfif>
    <cfif structKeyExists(variables.userData, "BaseProductLabel")>
        <cfset variables.safeUser.productLabel = variables.userData.BaseProductLabel>
    </cfif>
    <cfif structKeyExists(variables.userData, "created_at")>
        <cfset variables.safeUser.created_at = variables.userData.created_at>
    </cfif>

    <!--- Check for ThriveCart data --->
    <cfif structKeyExists(variables.userData, "customerfirst") and len(variables.userData.customerfirst)>
        <cfset variables.safeUser.thrivecart = {
            "customerfirst": variables.userData.customerfirst,
            "customerlast": variables.userData.customerlast,
            "customeremail": variables.userData.customeremail,
            "status": structKeyExists(variables.userData, "STATUS") ? variables.userData.STATUS : ""
        }>
    </cfif>

    <cfset variables.response.success = true>
    <cfset variables.response.data.user = variables.safeUser>

    <cfcatch type="any">
        <cfset variables.response.message = "Failed to load user: " & cfcatch.message>
        <cflog file="admin_users" text="[get] ERROR userid=#val(url.userid)#: #cfcatch.message# #cfcatch.detail#">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
