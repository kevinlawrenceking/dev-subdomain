<cfcomponent output="false">
  <cfscript>
    // Compute env into locals, then set this.name BEFORE any application.* writes
    host = ListFirst(cgi.server_name, ".");
    if (host == "app") {
      envLabel = "PROD"; _dsn = "abo";
    } else if (host == "uat") {
      envLabel = "UAT";  _dsn = "abod";
    } else {
      envLabel = "DEV";  _dsn = "abod";
    }

    // this.name MUST be set first — determines which application scope is used
    this.name = "TAO_" & envLabel;

    application.dsn = _dsn;
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(11, 1, 0, 0);
    this.sessionTimeout = createTimeSpan(0, 9, 20, 0);
    this.setClientCookies = true;
    this.loginStorage = "session";

    // Session cookie hardening
    this.sessioncookie.httponly = true;
    this.sessioncookie.secure = true;
    this.sessioncookie.samesite = "Lax";

    // Preserve struct key case in serializeJSON so JS receives
    // lowercase keys like "column_id" instead of "COLUMN_ID"
    this.serialization.preserveCaseForStructKey = true;

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

    <!--- Require authenticated session for all AJAX endpoints --->
    <cfif NOT structKeyExists(session, "userid")>
      <cfheader statuscode="401">
      <cfcontent type="application/json" reset="true">
      <cfoutput>{"success":false,"message":"Authentication required"}</cfoutput>
      <cfabort>
    </cfif>

    <!--- Per-request datasource: immune to application-scope race conditions --->
    <cfset request.dsn = application.datasource>

    <cfset userid = session.userid>
    <cfset request.userid = session.userid>

    <!--- CSRF validation — REQUIRED for state-changing requests --->
    <cfif CGI.REQUEST_METHOD EQ "POST" OR CGI.REQUEST_METHOD EQ "PUT" OR CGI.REQUEST_METHOD EQ "DELETE">

      <!--- Endpoints with their own CSRF validation (separate token system) — skip framework check --->
      <cfset var selfCsrfPaths = "/ajax/importv3/,/ajax/import-auditions/">
      <cfset var skipFrameworkCsrf = false>
      <cfloop list="#selfCsrfPaths#" index="csrfPath">
        <cfif findNoCase(csrfPath, cgi.SCRIPT_NAME)>
          <cfset skipFrameworkCsrf = true>
          <cfbreak>
        </cfif>
      </cfloop>

      <cfif NOT skipFrameworkCsrf>
        <cfset var csrfHeader = "">
        <cfif structKeyExists(getHTTPRequestData().headers, "X-CSRF-Token")>
          <cfset csrfHeader = getHTTPRequestData().headers["X-CSRF-Token"]>
        </cfif>
        <cfif NOT len(csrfHeader) AND structKeyExists(form, "csrfToken")>
          <cfset csrfHeader = form.csrfToken>
        </cfif>

        <!--- Reject if no token provided --->
        <cfif NOT len(csrfHeader)>
          <cflog file="tao_csrf" type="warning" text="CSRF token missing: #cgi.SCRIPT_NAME# [#cgi.REQUEST_METHOD#] user=#session.userid#">
          <cfheader statuscode="403">
          <cfcontent type="application/json" reset="true">
          <cfoutput>{"success":false,"message":"CSRF token required"}</cfoutput>
          <cfabort>
        </cfif>

        <!--- Reject if token invalid --->
        <cfif NOT CSRFVerifyToken(csrfHeader)>
          <cflog file="tao_csrf" type="warning" text="CSRF token invalid: #cgi.SCRIPT_NAME# [#cgi.REQUEST_METHOD#] user=#session.userid#">
          <cfheader statuscode="403">
          <cfcontent type="application/json" reset="true">
          <cfoutput>{"success":false,"message":"Invalid CSRF token"}</cfoutput>
          <cfabort>
        </cfif>
      </cfif>
    </cfif>

    <cfreturn true>
  </cffunction>

  <!--- Error handler: log full details, return safe JSON to client --->
  <cffunction name="onError" access="public" returntype="void" output="true">
    <cfargument name="exception" />
    <cfargument name="eventName" />

    <!--- Log full error server-side --->
    <cftry>
      <cfset var errDetail = arguments.exception.message>
      <cfif structKeyExists(arguments.exception, "detail") AND len(arguments.exception.detail)>
        <cfset errDetail = errDetail & " | " & arguments.exception.detail>
      </cfif>
      <cfif structKeyExists(arguments.exception, "tagContext") AND isArray(arguments.exception.tagContext) AND arrayLen(arguments.exception.tagContext)>
        <cfset errDetail = errDetail & " | " & arguments.exception.tagContext[1].template & ":" & arguments.exception.tagContext[1].line>
      </cfif>
      <cfif structKeyExists(arguments.exception, "sql")>
        <cfset errDetail = errDetail & " | SQL: " & left(arguments.exception.sql, 500)>
      </cfif>
      <cflog file="tao_errors" type="error" text="[AJAX #cgi.SCRIPT_NAME#] #errDetail#">
    <cfcatch><cflog file="tao_errors" type="error" text="AJAX onError logging failed: #cfcatch.message#"></cfcatch>
    </cftry>

    <!--- Return safe JSON — no internals exposed --->
    <cfheader statuscode="500">
    <cfcontent type="application/json" reset="true">
    <cfoutput>{"success":false,"message":"An unexpected error occurred. Please try again or contact support."}</cfoutput>
    <cfabort>
  </cffunction>
</cfcomponent>
