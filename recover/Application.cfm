<!--- ALWAYS compute host before cfapplication to get host-specific scope --->
<cfset host = ListFirst(cgi.server_name, ".") />
<cfif host EQ "app">
    <cfset dsn = "abo" />
<cfelse>
    <cfset dsn = "abod" />
</cfif>

<cfapplication name="TAO_#host#" sessionmanagement="true">

<cfset application.dsn = dsn />
