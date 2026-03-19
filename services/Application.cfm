<!--- ALWAYS compute host and dsn -- never rely on stale application scope --->
<cfset host = ListFirst(cgi.server_name, ".") />
<cfif host EQ "app">
    <cfset datasourceName = "abo" />
<cfelse>
    <cfset datasourceName = "abod" />
</cfif>

<cfapplication
    name="TAO_#host#"
    sessionmanagement="true"
    applicationtimeout="#createTimeSpan(1, 0, 0, 0)#"
    sessiontimeout="#createTimeSpan(0, 1, 0, 0)#"
    datasource="#datasourceName#"
    setclientcookies="true">

<cfscript>
    application.dsn = datasourceName;
    dsn = datasourceName;
</cfscript>


