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

    <!--- Require authenticated session for all AJAX endpoints --->
    <cfif NOT structKeyExists(session, "userid")>
      <cfheader statuscode="401">
      <cfcontent type="application/json" reset="true">
      <cfoutput>{"success":false,"message":"Authentication required"}</cfoutput>
      <cfabort>
    </cfif>

    <cfset userid = session.userid>
    <cfset request.userid = session.userid>

    <!--- CSRF validation for state-changing requests --->
    <cfif CGI.REQUEST_METHOD EQ "POST" OR CGI.REQUEST_METHOD EQ "PUT" OR CGI.REQUEST_METHOD EQ "DELETE">
      <cfset var csrfHeader = "">
      <cfif structKeyExists(getHTTPRequestData().headers, "X-CSRF-Token")>
        <cfset csrfHeader = getHTTPRequestData().headers["X-CSRF-Token"]>
      </cfif>
      <cfif structKeyExists(form, "csrfToken")>
        <cfset csrfHeader = form.csrfToken>
      </cfif>
      <!--- Validate if token was provided --->
      <cfif len(csrfHeader) AND structKeyExists(session, "csrfToken")>
        <cfif NOT CSRFVerifyToken(csrfHeader)>
          <cfheader statuscode="403">
          <cfcontent type="application/json" reset="true">
          <cfoutput>{"success":false,"message":"Invalid CSRF token"}</cfoutput>
          <cfabort>
        </cfif>
      </cfif>
    </cfif>

    <cfreturn true>
  </cffunction>
</cfcomponent>
