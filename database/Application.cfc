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
    this.name = "TAO_" & host;
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 0, 30, 0);
    this.datasource = application.dsn;

    // Session cookie hardening
    this.sessioncookie.httponly = true;
    this.sessioncookie.secure = true;
    this.sessioncookie.samesite = "Strict";
    application.datasource = this.datasource;
  </cfscript>

  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true">
    <!--- Require authenticated session for all database admin pages --->
    <cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid)>
      <cflocation url="/loginform.cfm" addtoken="false">
    </cfif>

    <!--- Require admin role via direct DB lookup (do not rely on session.userrole) --->
    <cfquery name="qAdminCheck" datasource="#application.dsn#" maxrows="1">
      SELECT userRole
      FROM taousers
      WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfif qAdminCheck.recordCount EQ 0
          OR (qAdminCheck.userRole NEQ "Admin" AND qAdminCheck.userRole NEQ "Administrator")>
      <cfheader statuscode="403">
      <cfcontent type="text/plain" reset="true">
      <cfoutput>Access denied. Admin authorization required.</cfoutput>
      <cfabort>
    </cfif>

    <cfreturn true>
  </cffunction>
</cfcomponent>
