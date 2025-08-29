<cfcomponent output="false">
  <!--- 
      PURPOSE: Standalone Application component for scheduled tasks
      AUTHOR: Kevin King
      DATE: 2025-08-29
      DESCRIPTION: Independent app for automated tasks - no dependencies on main app
  --->

  <!--- Environment detection --->
  <cfset host = ListFirst(cgi.server_name, ".") />

  <!--- Database configuration - Set in application scope immediately --->
  <cfif host EQ "app">
    <cfset application.dsn = "abo" />
    <cfset application.information_schema = "actorsbusinessoffice" />
    <cfset application.suffix = "_1.5" />
  <cfelse>
    <cfset application.dsn = "abod" />
    <cfset application.information_schema = "new_development" />
    <cfset application.suffix = "" />
  </cfif>

  <cfscript>
    // Basic application settings for scheduler
    this.name = "TAO_Scheduler";
    this.datasource = application.dsn;  // Use the DSN we just set
    this.sessionManagement = false;  // No sessions needed for scheduled tasks
    this.applicationTimeout = createTimeSpan(0, 0, 30, 0);  // 30 minutes
    
    // Looser variable handling for legacy compatibility
    this.searchImplicitScopes = true;
    this.enableNullSupport = false;
    this.strictVariables = false;
    
    // Mail settings for Hostek VPS
    this.smtpServerSettings = {
      server = "127.0.0.1",
      port = 25,

      useSSL = false,
      useTLS = false,
      sign = false,
      encrypt = false
    };
    
    // Basic mappings
    this.mappings["/include"] = expandPath("../include");
    this.mappings["/services"] = expandPath("../services");
  </cfscript>

  <cffunction name="onApplicationStart" returntype="boolean" output="false">
    <cftry>
      <!--- Ensure DSN is set --->
      <cfif not structKeyExists(application, "dsn") or not len(application.dsn)>
        <cfif host EQ "app">
          <cfset application.dsn = "abo" />
          <cfset application.information_schema = "actorsbusinessoffice" />
          <cfset application.suffix = "_1.5" />
        <cfelse>
          <cfset application.dsn = "abod" />
          <cfset application.information_schema = "new_development" />
          <cfset application.suffix = "" />
        </cfif>
      </cfif>
      
      <!--- Try to get version, but don't fail if database is unavailable --->
      <cfquery result="result" name="findit" datasource="#application.dsn#" timeout="5">
        SELECT verid
        FROM taoversions
        ORDER BY isactive DESC, verid DESC
        LIMIT 1
      </cfquery>
      <cfset application.rev = findit.verid />
      
      <cfcatch>
        <cfset application.rev = "1.0" />
        <cflog file="TAO_sched_init_errors" 
               text="Could not get version from database: #cfcatch.message#" 
               type="warning" />
      </cfcatch>
    </cftry>
    
    <cfreturn true />
  </cffunction>

  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true" />
    
    <cftry>
      <cfscript>
        // Ensure application scope has DSN (force initialization if needed)
        if (not structKeyExists(application, "dsn") or not len(application.dsn)) {
          if (host EQ "app") {
            application.dsn = "abo";
            application.information_schema = "actorsbusinessoffice";
            application.suffix = "_1.5";
          } else {
            application.dsn = "abod";
            application.information_schema = "new_development";
            application.suffix = "";
          }
        }
        
        // Ensure other application variables exist
        if (not structKeyExists(application, "rev")) {
          application.rev = "1.0";
        }
        
        // Basic parameter normalization for scheduled tasks
        var taskKeys = ["task", "id", "action", "userid", "debug"];

        // Default URL/FORM keys so scripts don't break on undefined variables
        for (var k in taskKeys) {
          param name="url.#k#" default="";
          param name="form.#k#" default="";
        }

        // Build a merged request map (URL wins, then FORM)
        request.p = duplicate(form);
        structAppend(request.p, url, true);

        // Expose variables for legacy template compatibility
        for (var k in taskKeys) {
          if (NOT isDefined(k)) {
            request[k] = request.p[k];
          }
        }
      </cfscript>
      
      <cfcatch>
        <cflog file="TAO_sched_init_errors" 
               text="Scheduler Initialization Error: #cfcatch.message# - Detail: #cfcatch.detail#" 
               type="error" />
        <cfreturn false />
      </cfcatch>
    </cftry>
    
    <cfreturn true />
  </cffunction>

  <!--- Enhanced error handler for better debugging --->
  <cffunction name="onError" access="public" returntype="void" output="true">
    <cfargument name="exception" />
    <cfargument name="eventName" />
    
    <cftry>
      <!--- Log detailed error information --->
      <cflog file="TAO_sched_errors" 
             text="Scheduler Error - Event: #arguments.eventName# - Page: #cgi.script_name# - Message: #arguments.exception.message# - Detail: #arguments.exception.detail# - Type: #arguments.exception.type#" 
             type="error" />
      
      <!--- Detailed error output for debugging --->
      <cfoutput>
        <h2>Scheduled Task Error</h2>
        <p><strong>Task:</strong> #cgi.script_name#</p>
        <p><strong>Event:</strong> #arguments.eventName#</p>
        <p><strong>Error:</strong> #arguments.exception.message#</p>
        <p><strong>Detail:</strong> #arguments.exception.detail#</p>
        <p><strong>Type:</strong> #arguments.exception.type#</p>
        <p><strong>Time:</strong> #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")#</p>
        
        <cfif structKeyExists(arguments.exception, "stackTrace")>
          <h3>Stack Trace:</h3>
          <pre>#arguments.exception.stackTrace#</pre>
        </cfif>
        
        <cfif structKeyExists(arguments.exception, "tagContext") and isArray(arguments.exception.tagContext)>
          <h3>Tag Context:</h3>
          <cfloop array="#arguments.exception.tagContext#" index="context">
            <p><strong>File:</strong> #context.template# (Line: #context.line#)</p>
          </cfloop>
        </cfif>
      </cfoutput>
      
      <cfcatch>
        <!--- Last resort --->
        <cfoutput>
          <h2>Critical Error</h2>
          <p>ERROR: #arguments.exception.message#</p>
          <p>INNER ERROR: #cfcatch.message#</p>
        </cfoutput>
      </cfcatch>
    </cftry>
  </cffunction>
</cfcomponent>