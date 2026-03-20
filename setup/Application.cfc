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

    // Assign to this.datasource before using application scope
    this.datasource = dsn;

    // Now set application scope vars (only if not already set by main app)
    if (NOT structKeyExists(application, "dsn")) {
        application.dsn = dsn;
        application.information_schema = information_schema;
        application.suffix = suffix;
        application.dbug = "N";
        if (dsn == "abo") {
            application.baseMediaPath = "C:\\home\\theactorsoffice.com\\media-" & dsn;
        } else {
            application.baseMediaPath = expandPath("/media-" & dsn);
        }
        application.baseMediaUrl = "/media-" & dsn;
        application.auditionimporttemplate = application.baseMediaUrl & "/auditionimporttemplates.xlsx";
        application.imagesPath = application.baseMediaPath & "\\images";
        application.imagesUrl = application.baseMediaUrl & "/images";
    }
</cfscript>


<!--- Application lifecycle events --->

<cffunction name="onApplicationStart" returntype="boolean" output="false">
    <cfreturn true>
</cffunction>

<cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true">
    <!--- Setup pages are accessed two ways:
          1. New users via UUID link from welcome email (no session)
          2. Authenticated users who land here by accident (redirect to dashboard)
          The old code returned 403 for unauthenticated users, which broke
          BOTH cases when the session scope was separate. Now that we share
          the TAO session, authenticated users pass through. Unauthenticated
          users are allowed through to setup pages (UUID validation in index.cfm
          handles access control and redirects invalid UUIDs to dashboard). --->
    <cfset request.dsn = application.dsn />
    <cfreturn true>
</cffunction>

</cfcomponent>
