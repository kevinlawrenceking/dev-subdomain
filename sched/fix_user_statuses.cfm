<!---
    fix_user_statuses.cfm
    Scheduled task: Reactivate users whose ThriveCart payment is completed
    but TAO account status is not active.

    Previously ran on every login page load. Moved here for performance.
--->
<cfif NOT structKeyExists(application, "dsn")>
    <cfset dsn = listFirst(cgi.server_name, ".") EQ "app" ? "abo" : "abod" />
<cfelse>
    <cfset dsn = application.dsn />
</cfif>

<cfquery name="fix" datasource="#dsn#">
    SELECT u.userID
    FROM taousers u
    INNER JOIN thrivecart t ON t.id = u.customerid
    INNER JOIN userstatuses us ON us.userstatus = u.userstatus
    WHERE t.status = 'Completed' AND u.userstatus <> 'active'
</cfquery>

<cfloop query="fix">
    <cfquery datasource="#dsn#">
        UPDATE taousers_tbl
        SET userstatus = 'active'
        WHERE userid = <cfqueryparam value="#fix.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cfloop>

<cfoutput>Fixed #fix.recordcount# user status(es) at #dateFormat(now(), 'yyyy-mm-dd')# #timeFormat(now(), 'HH:mm:ss')#</cfoutput>
