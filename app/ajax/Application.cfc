<cfcomponent output="false">
  <cfscript>
    this.name = "TAO"; // must exactly match the main app
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(11, 1, 0, 0);
    this.sessionTimeout = createTimeSpan(0, 9, 20, 0);
    this.setClientCookies = true;
    this.loginStorage = "session";

    // Session cookie hardening
    this.sessioncookie.httponly = true;
    this.sessioncookie.secure = true;
    this.sessioncookie.samesite = "Strict";
  </cfscript>

  <cffunction name="onRequestStart" returntype="boolean">
    <cfargument name="targetPage" required="true">
    <!--- Require authenticated session for all app AJAX endpoints --->
    <cfif NOT structKeyExists(session, "userid")>
      <cfheader statuscode="401">
      <cfcontent type="application/json" reset="true">
      <cfoutput>{"success":false,"message":"Authentication required"}</cfoutput>
      <cfabort>
    </cfif>
    <!--- CSRF validation — REQUIRED for state-changing requests --->
    <cfif CGI.REQUEST_METHOD EQ "POST" OR CGI.REQUEST_METHOD EQ "PUT" OR CGI.REQUEST_METHOD EQ "DELETE">
      <cfset var csrfHeader = "">
      <cfif structKeyExists(getHTTPRequestData().headers, "X-CSRF-Token")>
        <cfset csrfHeader = getHTTPRequestData().headers["X-CSRF-Token"]>
      </cfif>
      <cfif NOT len(csrfHeader) AND structKeyExists(form, "csrfToken")>
        <cfset csrfHeader = form.csrfToken>
      </cfif>
      <cfif NOT len(csrfHeader)>
        <cflog file="tao_csrf" type="warning" text="CSRF token missing: #cgi.SCRIPT_NAME# [#cgi.REQUEST_METHOD#] user=#session.userid#">
        <cfheader statuscode="403">
        <cfcontent type="application/json" reset="true">
        <cfoutput>{"success":false,"message":"CSRF token required"}</cfoutput>
        <cfabort>
      </cfif>
      <cfif NOT CSRFVerifyToken(csrfHeader)>
        <cflog file="tao_csrf" type="warning" text="CSRF token invalid: #cgi.SCRIPT_NAME# [#cgi.REQUEST_METHOD#] user=#session.userid#">
        <cfheader statuscode="403">
        <cfcontent type="application/json" reset="true">
        <cfoutput>{"success":false,"message":"Invalid CSRF token"}</cfoutput>
        <cfabort>
      </cfif>
    </cfif>

    <cfreturn true>
  </cffunction>

  <cffunction name="onRequest" returntype="void">
    <cfargument name="targetPage" required="true">
    <cfinclude template="#arguments.targetPage#">
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
      <cflog file="tao_errors" type="error" text="[APP-AJAX #cgi.SCRIPT_NAME#] #errDetail#">
    <cfcatch><cflog file="tao_errors" type="error" text="APP-AJAX onError logging failed: #cfcatch.message#"></cfcatch>
    </cftry>

    <!--- Return safe JSON — no internals exposed --->
    <cfheader statuscode="500">
    <cfcontent type="application/json" reset="true">
    <cfoutput>{"success":false,"message":"An unexpected error occurred. Please try again or contact support."}</cfoutput>
    <cfabort>
  </cffunction>
</cfcomponent>
