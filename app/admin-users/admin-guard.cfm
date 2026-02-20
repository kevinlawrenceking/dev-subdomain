<!---
    Admin Guard - Include at top of every admin-users page and AJAX endpoint.
    Verifies: (1) logged in, (2) admin role.
    For AJAX endpoints, set variables.isAjax = true before including this file
    to get JSON error responses instead of redirects.
--->
<cfif NOT structKeyExists(session, "userid")
      OR NOT isDefined("userRole")
      OR (userRole NEQ "Admin" AND userRole NEQ "Administrator")>

    <cfif isDefined("variables.isAjax") AND variables.isAjax>
        <cfheader statuscode="403">
        <cfcontent type="application/json; charset=utf-8" reset="true">
        <cfoutput>{"success":false,"message":"Admin access required","code":"FORBIDDEN"}</cfoutput>
        <cfabort>
    <cfelse>
        <cflocation url="/app/" addtoken="false">
    </cfif>

</cfif>
