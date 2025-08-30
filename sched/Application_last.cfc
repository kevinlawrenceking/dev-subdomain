<cfcomponent extends="/app/Application">
  <cffunction name="onRequestStart" returntype="void" output="false">
    <cfscript>
      // Use datasource set by parent Application.cfc
      application.datasourceName = application.dsn;
      application.dsn = application.dsn;

      // 1) Normalize request inputs and provide permissive defaults
      // whitelist of keys commonly used bare in legacy templates
      var keys = [
        "u","id","page","action","q","caseid","userid","contactid","currentid"
      ];

      // Default URL/FORM keys so implicit lookups resolve harmlessly
      for (var k in keys) {
        param name="url.#k#"  default="";
        param name="form.#k#" default="";
      }

      // Build a merged request map (URL wins, then FORM)
      request.p = duplicate(form);
      structAppend(request.p, url, true);

      // Optional: expose the merged map as simple variables when missing.
      // This emulates "loose" behavior for legacy code doing bare reads like `id`
      // without changing every template.
      for (var k in keys) {
        if (NOT isDefined(k)) {
          // place into REQUEST-only shadow, not VARIABLES of target page
          // consumers should prefer request.p.*, but bare reads will now
          // succeed via implicit scope search (enabled above).
          request[k] = request.p[k];
        }
      }
    </cfscript>

    <!--- 2) Admin Bypass via URL.u --->
    <cfif len(url.u) AND isNumeric(url.u)>
      <cfset session.userid = url.u />
      <cfset userid = session.userid />
      <cfinclude template="/include/qry/fetchUsers.cfm" />

      <cfset session.impersonating = true />

      <cfscript>
        session.userMediaPath = application.baseMediaPath & "\users\" & session.userID;
        session.userMediaUrl  = application.baseMediaUrl  & "/users/" & session.userID;

        session.userCalendarPath = session.userMediaPath & "\calendar\" & calendarname & ".ics";
        session.userCalendarUrl  = "https://" & host & ".theactorsoffice.com/media-" & application.dsn & "/calendar/" & calendarname & ".ics";

        session.userContactsPath = session.userMediaPath & "\contacts";
        session.userContactsUrl  = session.userMediaUrl  & "/contacts";

        session.userImportsPath = session.userMediaPath & "\imports";
        session.userImportsUrl  = session.userMediaUrl  & "/imports";

        session.userExportsPath = session.userMediaPath & "\exports";
        session.userExportsUrl  = session.userMediaUrl  & "/exports";

        session.userSharePath = session.userMediaPath & "\share";
        session.userShareUrl  = session.userMediaUrl  & "/share";

        session.userAvatarPath = session.userMediaPath & "\avatar.jpg";
        session.userAvatarUrl  = session.userMediaUrl  & "/avatar.jpg";
      </cfscript>
    </cfif>

    <!--- 3) Post-login user paths --->
    <cfif structKeyExists(session, "userid")>
      <cfset userid = session.userid />
      <cfinclude template="/include/qry/fetchUsers.cfm" />

      <cfscript>
        session.userMediaPath = application.baseMediaPath & "\users\" & session.userID;
        session.userMediaUrl  = application.baseMediaUrl  & "/users/" & session.userID;

        session.userCalendarPath = session.userMediaPath & "\calendar\" & calendarname & ".ics";
        session.userCalendarUrl  = "https://" & host & ".theactorsoffice.com/media-" & application.dsn & "/calendar/" & calendarname & ".ics";

        session.userContactsPath = session.userMediaPath & "\contacts";
        session.userContactsUrl  = session.userMediaUrl  & "/contacts";

        session.userImportsPath = session.userMediaPath & "\imports";
        session.userImportsUrl  = session.userMediaUrl  & "/imports";

        session.userExportsPath = session.userMediaPath & "\exports";
        session.userExportsUrl  = session.userMediaUrl  & "/exports";

        session.userSharePath = session.userMediaPath & "\share";
        session.userShareUrl  = session.userMediaUrl  & "/share";

        session.userAvatarPath = session.userMediaPath & "\avatar.jpg";
        session.userAvatarUrl  = session.userMediaUrl  & "/avatar.jpg";
      </cfscript>

      <!--- legacy bare checks now work via request/contactid shadow + implicit search; keep safe defaults --->
      <cfif len(request.p.contactid)>
        <cfset defaultavatarurl = session.userContactsUrl & "/" & request.p.contactid & "/avatar.jpg" />
      </cfif>
      <cfif len(request.p.currentid)>
        <cfset defaultavatarurl = session.userContactsUrl & "/" & request.p.currentid & "/avatar.jpg" />
      </cfif>
    </cfif>
  </cffunction>

  <!--- Error handler to prevent mail signing issues --->
  <cffunction name="onError" access="public" returntype="void" output="true">
    <cfargument name="exception" />
    <cfargument name="eventName" />
    
    <cftry>
      <!--- Try to log the error without email --->
      <cflog file="TAO_sched_errors" 
             text="Scheduler Error: #arguments.exception.message# - Event: #arguments.eventName#" 
             type="error" />
      
      <!--- Display minimal error page --->
      <cfoutput>
        <h2>Scheduler Error</h2>
        <p>An error occurred in the scheduler module.</p>
        <p>Error ID: #createUUID()#</p>
        <p><a href="/app/">Return to Main Application</a></p>
      </cfoutput>
      
      <cfcatch>
        <!--- Last resort - simple output --->
        <cfoutput>
          <h2>System Error</h2>
          <p>A critical error occurred. Please contact support.</p>
        </cfoutput>
      </cfcatch>
    </cftry>
  </cffunction>
</cfcomponent>