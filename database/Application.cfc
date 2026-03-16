<cfcomponent output="false">
  <!--- Inherit settings from parent /app Application.cfc --->
  <cfset host = ListFirst(cgi.server_name, ".") />

  <cfif host EQ "app">
    <cfset application.dsn = "abo" />
    <cfset application.information_schema = "actorsbusinessoffice" />
  <cfelse>
    <cfset application.dsn = "abod" />
    <cfset application.information_schema = "new_development" />
  </cfif>

  <cfscript>
    this.name = "TAO";
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 0, 30, 0);
    this.datasource = application.dsn;
    application.datasource = this.datasource;
  </cfscript>

  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true">
    <!--- Require authenticated session for all database admin pages --->
    <cfif NOT structKeyExists(session, "userid")>
      <cfheader statuscode="403">
      <cfabort>
    </cfif>
    <cfreturn true>
  </cffunction>
</cfcomponent>
