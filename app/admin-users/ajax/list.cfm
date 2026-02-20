<cfsilent>
<!---
    Admin User List - AJAX Endpoint
    GET /app/admin-users/ajax/list.cfm

    URL Parameters:
    - search (optional): Search term for name/email/userid
    - status (optional): Filter by userstatus
    - role (optional): Filter by userRole
    - page (optional, default 1): Page number
    - pageSize (optional, default 25): Rows per page
    - sortCol (optional, default userid): Column to sort by
    - sortDir (optional, default DESC): Sort direction

    Returns JSON: { success, data: { users: [...], total, page, pageSize, totalPages }, filters: { statuses, roles } }
--->

<cfset variables.isAjax = true>
<cfinclude template="../admin-guard.cfm">

<cfset variables.response = { "success": false, "message": "", "data": {} }>

<cftry>
    <cfparam name="url.search" default="">
    <cfparam name="url.status" default="">
    <cfparam name="url.role" default="">
    <cfparam name="url.page" default="1">
    <cfparam name="url.pageSize" default="25">
    <cfparam name="url.sortCol" default="userid">
    <cfparam name="url.sortDir" default="DESC">

    <cfset variables.svc = new services.UserService()>

    <!--- Get user list --->
    <cfset variables.result = variables.svc.listUsers(
        search = url.search,
        status = url.status,
        role = url.role,
        page = val(url.page) gt 0 ? val(url.page) : 1,
        pageSize = val(url.pageSize) gt 0 ? val(url.pageSize) : 25,
        sortCol = url.sortCol,
        sortDir = url.sortDir
    )>

    <!--- Convert query to array of structs --->
    <cfset variables.usersArr = []>
    <cfloop query="variables.result.users">
        <cfset arrayAppend(variables.usersArr, {
            "userid": variables.result.users.userid,
            "userFirstName": variables.result.users.userFirstName,
            "userLastName": variables.result.users.userLastName,
            "userEmail": variables.result.users.userEmail,
            "userRole": variables.result.users.userRole,
            "userstatus": variables.result.users.userstatus,
            "recordname": variables.result.users.recordname,
            "IsDeleted": variables.result.users.IsDeleted,
            "IsBetaTester": variables.result.users.IsBetaTester,
            "isSetup": variables.result.users.isSetup,
            "customerid": variables.result.users.customerid,
            "avatarname": variables.result.users.avatarname,
            "isAudition": variables.result.users.isAudition,
            "isAuditionModule": variables.result.users.isAuditionModule
        })>
    </cfloop>

    <!--- Get filter options --->
    <cfset variables.qStatuses = variables.svc.getUserStatuses()>
    <cfset variables.qRoles = variables.svc.getUserRoles()>

    <cfset variables.statusList = []>
    <cfloop query="variables.qStatuses">
        <cfset arrayAppend(variables.statusList, variables.qStatuses.userstatus)>
    </cfloop>

    <cfset variables.roleList = []>
    <cfloop query="variables.qRoles">
        <cfset arrayAppend(variables.roleList, variables.qRoles.userRole)>
    </cfloop>

    <cfset variables.totalPages = ceiling(variables.result.total / variables.result.pageSize)>
    <cfif variables.totalPages lt 1><cfset variables.totalPages = 1></cfif>

    <cfset variables.response.success = true>
    <cfset variables.response.data = {
        "users": variables.usersArr,
        "total": variables.result.total,
        "page": variables.result.page,
        "pageSize": variables.result.pageSize,
        "totalPages": variables.totalPages
    }>
    <cfset variables.response.filters = {
        "statuses": variables.statusList,
        "roles": variables.roleList
    }>

    <cfcatch type="any">
        <cfset variables.response.message = "Failed to load users: " & cfcatch.message>
        <cflog file="admin_users" text="[list] ERROR: #cfcatch.message# #cfcatch.detail#">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
