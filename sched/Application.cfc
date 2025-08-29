<cfcomponent extends="/app/Application">
  <!--- 
      PURPOSE: Minimal Application component for scheduled tasks
      AUTHOR: Kevin King
      DATE: 2025-08-29
      DESCRIPTION: Basic app for automated tasks - no login required
  --->

  <cffunction name="onRequestStart" returntype="void" output="false">
    <cfscript>
      // Use datasource set by parent Application.cfc
      application.datasourceName = application.dsn;
      application.dsn = application.dsn;

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
  </cffunction>

  <!--- Error handler for scheduled tasks --->
  <cffunction name="onError" access="public" returntype="void" output="true">
    <cfargument name="exception" />
    <cfargument name="eventName" />
    
    <cftry>
      <!--- Log the error without email --->
      <cflog file="TAO_sched_errors" 
             text="Scheduler Error: #arguments.exception.message# - Event: #arguments.eventName# - Page: #cgi.script_name#" 
             type="error" />
      
      <!--- Simple error output for scheduled tasks --->
      <cfoutput>
        <h2>Scheduled Task Error</h2>
        <p>Task: #cgi.script_name#</p>
        <p>Error: #arguments.exception.message#</p>
        <p>Time: #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")#</p>
      </cfoutput>
      
      <cfcatch>
        <!--- Last resort --->
        <cfoutput>ERROR: #arguments.exception.message#</cfoutput>
      </cfcatch>
    </cftry>
  </cffunction>
</cfcomponent>