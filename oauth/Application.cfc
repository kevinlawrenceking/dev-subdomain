<cfcomponent output="false">
<!---
    PURPOSE: Minimal Application.cfc for /oauth/ directory.
    Shares the TAO application name so session and application scopes
    are accessible during the OAuth callback from Google.
--->

  <cfset host = ListFirst(cgi.server_name, ".") />

  <!--- env routing (must match /app/Application.cfc) --->
  <cfif host EQ "app">
    <cfset application.dsn = "abo" />
  <cfelse>
    <cfset application.dsn = "abod" />
  </cfif>

  <cfscript>
    // Must match /app/Application.cfc to share session/application scope
    this.name = "TAO";
    this.datasource = application.dsn;
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(11,1,0,0);
    this.sessionTimeout = createTimeSpan(0,9,20,0);
    this.loginStorage = "session";

    // Cookie settings (must match /app/ to share session cookie)
    this.sessioncookie.httponly = true;
    this.sessioncookie.secure = true;
    this.sessioncookie.samesite = "Lax";
  </cfscript>

  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true" />

    <!--- Ensure application.secrets is initialized.
          Normally set by /app/Application.cfc onApplicationStart.
          If the app hasn't started yet (unlikely but possible),
          initialize secrets here as a fallback. --->
    <cfif NOT structKeyExists(application, "secrets")>
      <cfscript>
        var env = {};
        if (structKeyExists(server, "system") && structKeyExists(server.system, "environment")) {
          env = server.system.environment;
        }
        application.secrets = {
          googleOAuthClientId     = structKeyExists(env, "TAO_GOOGLE_OAUTH_CLIENT_ID")     ? env["TAO_GOOGLE_OAUTH_CLIENT_ID"]     : "",
          googleOAuthClientSecret = structKeyExists(env, "TAO_GOOGLE_OAUTH_CLIENT_SECRET") ? env["TAO_GOOGLE_OAUTH_CLIENT_SECRET"] : "",
          googleOAuthRedirectUri  = structKeyExists(env, "TAO_GOOGLE_OAUTH_REDIRECT_URI")  ? env["TAO_GOOGLE_OAUTH_REDIRECT_URI"]  : "https://app.theactorsoffice.com/oauth/oauth_callback.cfm"
        };
      </cfscript>
    </cfif>

    <cfreturn true />
  </cffunction>

  <cffunction name="onRequest" returntype="void" output="true">
    <cfargument name="targetPage" type="string" required="true" />
    <cfinclude template="#arguments.targetPage#" />
  </cffunction>

</cfcomponent>
