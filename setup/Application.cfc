<cfcomponent output="false">

<cfscript>
    // Get hostname first so app name is host-specific
    host = ListFirst(cgi.server_name, ".");
    if (host == "app") { envLabel = "PROD"; }
    else if (host == "uat") { envLabel = "UAT"; }
    else { envLabel = "DEV"; }

    // FIX (#1615/#1646): Use the SAME application name as /app/Application.cfc
    // so that /setup/ shares the main TAO session scope. Previously this was
    // "Setup_" & envLabel which created a separate session, causing authenticated
    // users to appear unauthenticated when hitting /setup/ URLs.
    this.name = "TAO_" & envLabel;
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(1,0,0,0);
    this.sessionTimeout     = createTimeSpan(0,0,30,0);

    // Session cookie hardening — match main app settings
    this.sessioncookie.httponly = true;
    this.sessioncookie.secure = true;
    // Lax to match main app (Strict blocks cross-site email link clicks)
    this.sessioncookie.samesite = "Lax";

    // Compiler settings
    this.searchImplicitScopes = true;
    this.strictVariables = false;

    // Declare local dsn before assigning to this.datasource
    dsn = "";
    information_schema = "";
    suffix = "";

    if (host == "app") {
        dsn = "abo";
        information_schema = "actorsbusinessoffice";
        suffix = "_1.5";
    } else {
        dsn = "abod";
        information_schema = "new_development";
        suffix = "";
    }

    // Assign to this.datasource so cfquery tags without datasource= work
    this.datasource = dsn;

    // Store for onRequestStart to use (avoid pseudo-constructor application scope access)
    variables._dsn = dsn;
    variables._schema = information_schema;
    variables._suffix = suffix;
</cfscript>


<!--- Application lifecycle events --->

<cffunction name="onApplicationStart" returntype="boolean" output="false">
    <cfscript>
        // Initialize application scope (guaranteed available here)
        ensureAppVars();
    </cfscript>
    <cfreturn true>
</cffunction>

<cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true">
    <!--- Setup pages are accessed two ways:
          1. New users via UUID link from welcome email (no session)
          2. Authenticated users who land here by accident (redirect to dashboard)
          UUID validation in index.cfm handles access control. --->
    <cfscript>
        // Ensure application scope vars exist (cold-start / race-condition safety)
        // Check imagesPath, not baseMediaPath or dsn -- imagesPath is derived last
        // and is the var setup pages actually read (user_setup_core.cfm). A partial
        // reinit can leave baseMediaPath present while imagesPath is absent, which
        // would skip healing and crash on application.imagesPath.
        if (NOT structKeyExists(application, "imagesPath")) {
            ensureAppVars();
        }
        request.dsn = application.dsn;
    </cfscript>
    <cfreturn true>
</cffunction>

<cffunction name="ensureAppVars" access="private" returntype="void" output="false"
            hint="Populate application-scope vars needed by setup pages">
    <cfscript>
        application.dsn = variables._dsn;
        application.datasource = variables._dsn;
        application.information_schema = variables._schema;
        application.suffix = variables._suffix;
        application.dbug = "N";
        if (variables._dsn == "abo") {
            application.baseMediaPath = "C:\\home\\theactorsoffice.com\\media-" & variables._dsn;
        } else {
            application.baseMediaPath = expandPath("/media-" & variables._dsn);
        }
        application.baseMediaUrl = "/media-" & variables._dsn;
        application.auditionimporttemplate = application.baseMediaUrl & "/auditionimporttemplates.xlsx";

        // Keep this full set in sync with /app/Application.cfc -- /setup shares the
        // same application scope (this.name = "TAO_<env>"), so any path var a setup
        // page reads must be defined here too, or it crashes when /setup initializes
        // the scope first.
        application.imagesPath = application.baseMediaPath & "\\images";
        application.imagesUrl  = application.baseMediaUrl  & "/images";

        application.datesPath = application.imagesPath & "\\dates";
        application.datesUrl  = application.imagesUrl  & "/dates";

        application.defaultsPath = application.imagesPath & "\\defaults";
        application.defaultsUrl  = application.imagesUrl  & "/defaults";

        application.defaultAvatarUrl  = application.defaultsUrl  & "/avatar.jpg";
        application.defaultAvatarPath = application.defaultsPath & "\\avatar.jpg";

        application.emailImagesPath = application.imagesPath & "\\email";
        application.emailImagesUrl  = application.imagesUrl  & "/email";

        application.filetypesPath = application.imagesPath & "\\filetypes";
        application.filetypesUrl  = application.imagesUrl  & "/filetypes";

        application.retinaIconsPath = application.imagesPath & "\\retina-circular-icons";
        application.retinaIconsUrl  = application.imagesUrl  & "/retina-circular-icons";

        application.retinaIcons14Path = application.retinaIconsPath & "\\14";
        application.retinaIcons14Url  = application.retinaIconsUrl  & "/14";

        application.retinaIcons32Path = application.retinaIconsPath & "\\32";
        application.retinaIcons32Url  = application.retinaIconsUrl  & "/32";
    </cfscript>
</cffunction>

<!--- TAO-SPEC-2026-005: Centralized error handler for setup context --->
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
            arguments.exception, arguments.eventName, "setup"
        ) />
      <cfelse>
        <!--- Instantiate inline — setup may be first context hit (cold start) --->
        <cfset var errorSvc = new services.ErrorService(
            dsn = application.dsn,
            fromEmail = "support@theactorsoffice.com",
            toEmail = "kevinking7135@gmail.com",
            appName = "TAO"
        ) />
        <cfset var result = errorSvc.handleError(
            arguments.exception, arguments.eventName, "setup"
        ) />
      </cfif>

      <cfset ticketId = result.ticketId />
      <cfset isAjax = result.isAjax />

    <cfcatch>
      <cfset ticketId = "ERR-" & Left(CreateUUID(), 8) />
      <cftry>
        <cflog file="TAO_error_fallback" type="error"
               text="Setup context ErrorService failed: #cfcatch.message# | Ticket: #ticketId#" />
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
