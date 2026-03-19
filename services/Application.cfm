<!--- ALWAYS compute host and dsn -- never rely on stale application scope --->
<cfset host = ListFirst(cgi.server_name, ".") />
<cfif host EQ "app">
    <cfset envLabel = "PROD" />
    <cfset datasourceName = "abo" />
<cfelseif host EQ "uat">
    <cfset envLabel = "UAT" />
    <cfset datasourceName = "abod" />
<cfelse>
    <cfset envLabel = "DEV" />
    <cfset datasourceName = "abod" />
</cfif>

<!--- App name MUST be set before writing to application scope --->
<cfapplication
    name="TAO_#envLabel#"
    sessionmanagement="true"
    applicationtimeout="#createTimeSpan(1, 0, 0, 0)#"
    sessiontimeout="#createTimeSpan(0, 1, 0, 0)#"
    datasource="#datasourceName#"
    setclientcookies="true">

<cfscript>
    application.dsn = datasourceName;
    dsn = datasourceName;
</cfscript>


