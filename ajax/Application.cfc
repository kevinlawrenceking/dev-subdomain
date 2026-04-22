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

    <!--- Ensure baseMediaPath exists (cold-start safety) --->
    <cfif NOT structKeyExists(application, "baseMediaPath")>
      <cfif application.datasource EQ "abo">
        <cfset application.baseMediaPath = "C:\home\theactorsoffice.com\media-abo">
      <cfelse>
        <cfset application.baseMediaPath = expandPath("/media-" & application.datasource)>
      </cfif>
      <cfset application.baseMediaUrl = "/media-" & application.datasource>
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

    <!--- PERF: Request-scoped service cache (matches app/Application.cfc) --->
    <cfset request.services = {} />
    <cfset request.svc = function(required string name) {
        if (!structKeyExists(request.services, arguments.name)) {
            request.services[arguments.name] = createObject("component", "services." & arguments.name);
        }
        return request.services[arguments.name];
    } />

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

        <!--- Verify: direct session comparison first (reliable even when ACF
              has rotated/evicted the token from its internal CSRF store),
              fall back to CF CSRF engine. Mirrors /app/Application.cfc line 404. --->
        <cfset var csrfValid = false>
        <cfif structKeyExists(session, "csrfToken") AND csrfHeader EQ session.csrfToken>
          <cfset csrfValid = true>
        <cfelseif CSRFVerifyToken(csrfHeader)>
          <cfset csrfValid = true>
        </cfif>
        <cfif NOT csrfValid>
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

  <!--- TAO-SPEC-2026-005: Centralized error handler — always returns JSON --->
  <cffunction name="onError" access="public" returntype="void" output="true">
    <cfargument name="exception" />
    <cfargument name="eventName" />

    <cfset var ticketId = "" />

    <cftry>
      <!--- Delegate to ErrorService (shared application scope via matching this.name) --->
      <cfif structKeyExists(application, "services")
            AND structKeyExists(application.services, "errorService")
            AND isObject(application.services.errorService)>
        <cfset var result = application.services.errorService.handleError(
            arguments.exception, arguments.eventName, "ajax"
        ) />
        <cfset ticketId = result.ticketId />
      <cfelse>
        <!--- ErrorService not available — instantiate inline --->
        <cfset var errorSvc = new services.ErrorService(
            dsn = application.datasource,
            fromEmail = "support@theactorsoffice.com",
            toEmail = "kevinking7135@gmail.com",
            appName = "TAO"
        ) />
        <cfset var result = errorSvc.handleError(
            arguments.exception, arguments.eventName, "ajax"
        ) />
        <cfset ticketId = result.ticketId />
      </cfif>

    <cfcatch>
      <!--- Fallback: generate ticket ID locally --->
      <cfset ticketId = "ERR-" & Left(CreateUUID(), 8) />
      <cftry>
        <cflog file="TAO_error_fallback" type="error"
               text="AJAX ErrorService failed: #cfcatch.message# | Ticket: #ticketId#" />
        <cfcatch></cfcatch>
      </cftry>
    </cfcatch>
    </cftry>

    <!--- Always return JSON — never HTML --->
    <cfheader statuscode="500" />
    <cfcontent type="application/json; charset=utf-8" reset="true" />
    <cfoutput>{"success":false,"message":"An unexpected error occurred. Please try again or contact support.","ticketId":"#ticketId#","support":"support@theactorsoffice.com","reference":"Quote this ticket ID when contacting support."}</cfoutput>
    <cfabort />
  </cffunction>
</cfcomponent>
