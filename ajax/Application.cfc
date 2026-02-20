<cfcomponent output="false">
  <cfscript>
    this.name = "TAO"; // must match main app to share sessions
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(11, 1, 0, 0);
    this.sessionTimeout = createTimeSpan(0, 9, 20, 0);
    this.setClientCookies = true;
    this.loginStorage = "session";

    // Preserve struct key case in serializeJSON so JS receives
    // lowercase keys like "column_id" instead of "COLUMN_ID"
    this.serialization.preserveCaseForStructKey = true;

    // Inherit datasource settings from main app
    host = ListFirst(cgi.server_name, ".");
    if (host EQ "app") {
      application.dsn = "abo";
    } else {
      application.dsn = "abod";
    }
    this.datasource = application.dsn;
    application.datasource = this.datasource;
  </cfscript>

  <cffunction name="onRequestStart" returntype="boolean">
    <cfargument name="targetPage" required="true">

    <!--- Force correct datasource based on current host --->
    <cfset var host = ListFirst(cgi.server_name, ".")>
    <cfif host EQ "app">
      <cfset application.datasource = "abo">
    <cfelse>
      <cfset application.datasource = "abod">
    </cfif>

    <!--- Set userid from session if available --->
    <cfif structKeyExists(session, "userid")>
      <cfset userid = session.userid>
      <cfset request.userid = session.userid>
    </cfif>

    <cfreturn true>
  </cffunction>
</cfcomponent>
