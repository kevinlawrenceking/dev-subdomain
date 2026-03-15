<!---
    Database Admin Guard
    Include at top of every /database/ utility page.
    Requires: (1) active session, (2) admin role via direct DB lookup.
    Fails closed - redirects to login if session missing, aborts with 403 if not admin.
--->
<cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid)>
    <cflocation url="/loginform.cfm" addtoken="false">
</cfif>

<!--- Direct DB lookup for role - do not rely on session.userrole --->
<cfquery name="qAdminCheck" datasource="#application.dsn#" maxrows="1">
    SELECT userRole
    FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif qAdminCheck.recordCount EQ 0
      OR (qAdminCheck.userRole NEQ "Admin" AND qAdminCheck.userRole NEQ "Administrator")>
    <cfheader statuscode="403">
    <cfoutput>Access denied. Admin authorization required.</cfoutput>
    <cfabort>
</cfif>
