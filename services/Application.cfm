<cfscript>
    // Use datasource from parent Application.cfc
    datasourceName = application.dsn;
    dsn = application.dsn;
</cfscript>

<cfapplication 
    name="TAO" 
    sessionmanagement="true" 
    applicationtimeout="#createTimeSpan(1, 0, 0, 0)#" 
    sessiontimeout="#createTimeSpan(0, 1, 0, 0)#" 
    datasource="#datasourceName#"
    setclientcookies="true">


