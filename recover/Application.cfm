<!--- ALWAYS compute host before cfapplication to get host-specific scope --->
<cfset host = ListFirst(cgi.server_name, ".") />
<cfif host EQ "app">
    <cfset envLabel = "PROD" />
    <cfset dsn = "abo" />
<cfelseif host EQ "uat">
    <cfset envLabel = "UAT" />
    <cfset dsn = "abod" />
<cfelse>
    <cfset envLabel = "DEV" />
    <cfset dsn = "abod" />
</cfif>

<cfapplication name="TAO_#envLabel#" sessionmanagement="true">

<cfset application.dsn = dsn />
