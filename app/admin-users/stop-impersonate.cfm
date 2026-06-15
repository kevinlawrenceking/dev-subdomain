<!---
    Stop Impersonation -- restore the original admin session.

    Reachable only while impersonating (session.impersonating + session.adminUserid).
    Intentionally does NOT include admin-guard.cfm: during impersonation the active
    session.userid is the impersonated (non-admin) user, so the guard would block it.
    The session.impersonating flag is itself the gate -- it can only have been set by
    the admin-verified ?u= path in Application.cfc, and session.adminUserid records
    who that verified admin was. Restoring it simply returns the session to that admin.

    GET is safe here: the action only ever restores the caller's own admin id, so it
    needs no CSRF token (and CSRF validation in Application.cfc applies to POST only).
--->
<cfif structKeyExists(session, "impersonating") AND session.impersonating
      AND structKeyExists(session, "adminUserid") AND val(session.adminUserid) GT 0>

    <cflog file="tao_impersonation" type="information"
           text="impersonation end: admin=#session.adminUserid# stopped viewing user=#session.userid#">

    <cfset session.userid = val(session.adminUserid) />
    <!--- Force a fresh DB load so post-login block in Application.cfc rehydrates the admin. --->
    <cfset session.bustUserCache = true />
    <cfset structDelete(session, "impersonating") />
    <cfset structDelete(session, "adminUserid") />

    <cflocation url="/app/admin-users/" addtoken="false" />
<cfelse>
    <!--- Not impersonating -- nothing to restore; send home. --->
    <cflocation url="/app/" addtoken="false" />
</cfif>
