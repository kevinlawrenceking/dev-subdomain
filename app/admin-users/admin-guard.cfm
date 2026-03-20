<!---
    Admin Guard - Include at top of every admin-users page and AJAX endpoint.
    Verifies: (1) logged in, (2) admin role.
    For AJAX endpoints, set variables.isAjax = true before including this file
    to get JSON error responses instead of redirects.
--->
<cfset variables._guardIsAdmin = false>
<cfif structKeyExists(session, "userid")>
    <!--- userRole may already be in scope from fetchUsers.cfm (page context).
          For AJAX endpoints it won't be, so fall back to a DB lookup. --->
    <cfif isDefined("userRole") AND (userRole EQ "Admin" OR userRole EQ "Administrator")>
        <cfset variables._guardIsAdmin = true>
    <cfelse>
        <cfquery name="_guardRoleCheck" datasource="#application.dsn#" maxrows="1">
            SELECT userRole
            FROM taousers
            WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer" />
        </cfquery>
        <cfif _guardRoleCheck.recordCount GT 0
              AND (_guardRoleCheck.userRole EQ "Admin" OR _guardRoleCheck.userRole EQ "Administrator")>
            <cfset variables._guardIsAdmin = true>
        </cfif>
    </cfif>
</cfif>

<cfif NOT variables._guardIsAdmin>

    <cfif isDefined("variables.isAjax") AND variables.isAjax>
        <cfheader statuscode="403">
        <cfcontent type="application/json; charset=utf-8" reset="true">
        <cfoutput>{"success":false,"message":"Admin access required","code":"FORBIDDEN"}</cfoutput>
        <cfabort>
    <cfelse>
        <cflocation url="/app/" addtoken="false">
    </cfif>

</cfif>
