<!---
    Restore the admin's real session after impersonation.
    session.impersonatorUserid is stashed by Application.cfc when url.u impersonation succeeds.
--->
<cfif structKeyExists(session, "impersonatorUserid") AND val(session.impersonatorUserid) GT 0>
    <cfset session.userid = val(session.impersonatorUserid) />
    <cfset structDelete(session, "impersonatorUserid") />
    <cfset structDelete(session, "impersonating") />
    <cfset session.bustUserCache = true />
    <cflocation url="/app/admin-users/" addtoken="false" />
<cfelse>
    <cflocation url="/app/" addtoken="false" />
</cfif>
