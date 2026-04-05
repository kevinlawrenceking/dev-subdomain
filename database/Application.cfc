<cfcomponent output="false">
  <cfscript>
    host = ListFirst(cgi.server_name, ".");
    if (host == "app") {
      envLabel = "PROD"; _dsn = "abo"; _schema = "actorsbusinessoffice";
    } else if (host == "uat") {
      envLabel = "UAT";  _dsn = "abod"; _schema = "new_development";
    } else {
      envLabel = "DEV";  _dsn = "abod"; _schema = "new_development";
    }

    // Set this.name FIRST so application scope writes target the correct scope
    this.name = "TAO_" & envLabel;

    application.dsn = _dsn;
    application.information_schema = _schema;

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

  <!--- TAO-SPEC-2026-005: Centralized error handler for database admin context --->
  <cffunction name="onError" access="public" returntype="void" output="true">
    <cfargument name="exception" />
    <cfargument name="eventName" />

    <cfset var ticketId = "" />
    <cfset var isAjax = false />

    <cftry>
      <!--- Use shared ErrorService if available (same this.name = shared application scope) --->
      <cfif structKeyExists(application, "services")
            AND structKeyExists(application.services, "errorService")
            AND isObject(application.services.errorService)>
        <cfset var result = application.services.errorService.handleError(
            arguments.exception, arguments.eventName, "database"
        ) />
      <cfelse>
        <!--- Instantiate inline — cold-start or ErrorService not registered --->
        <cfset var errorSvc = new services.ErrorService(
            dsn = application.dsn,
            fromEmail = "support@theactorsoffice.com",
            toEmail = "kevinking7135@gmail.com",
            appName = "TAO"
        ) />
        <cfset var result = errorSvc.handleError(
            arguments.exception, arguments.eventName, "database"
        ) />
      </cfif>

      <cfset ticketId = result.ticketId />
      <cfset isAjax = result.isAjax />

    <cfcatch>
      <cfset ticketId = "ERR-" & Left(CreateUUID(), 8) />
      <cftry>
        <cflog file="TAO_error_fallback" type="error"
               text="DB context ErrorService failed: #cfcatch.message# | Ticket: #ticketId#" />
        <cfcatch></cfcatch>
      </cftry>
    </cfcatch>
    </cftry>

    <!--- Render response --->
    <cfif isAjax>
      <cfheader statuscode="500" />
      <cfcontent type="application/json; charset=utf-8" reset="true" />
      <cfoutput>{"success":false,"message":"An unexpected error occurred. Please try again or contact support.","ticketId":"#ticketId#","support":"support@theactorsoffice.com","reference":"Quote this ticket ID when contacting support."}</cfoutput>
    <cfelse>
      <cfheader statuscode="500" />
      <cfcontent type="text/html; charset=utf-8" reset="true" />
      <cftry>
        <cfset request.errorTicketId = ticketId />
        <cfinclude template="/templates/error/error-friendly.cfm" />
      <cfcatch>
        <cfoutput>
        <!DOCTYPE html>
        <html><head><title>Error</title></head>
        <body style="font-family:sans-serif;text-align:center;padding:60px 20px;color:##333">
        <h1 style="font-size:22px">Something went wrong</h1>
        <p>Our team has been notified. Your ticket ID is: <strong>#ticketId#</strong></p>
        <p><a href="/app/dashboard/" style="color:##406E8E">Return to Dashboard</a></p>
        <p style="font-size:13px;color:##999">Contact support@theactorsoffice.com if this persists.</p>
        </body></html>
        </cfoutput>
      </cfcatch>
      </cftry>
    </cfif>
    <cfabort />
  </cffunction>
</cfcomponent>
