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
        if (NOT structKeyExists(application, "dsn")) {
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
        application.imagesPath = application.baseMediaPath & "\\images";
        application.imagesUrl = application.baseMediaUrl & "/images";
    </cfscript>
</cffunction>

</cfcomponent>
