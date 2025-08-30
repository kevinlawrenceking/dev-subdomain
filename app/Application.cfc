
<cfcomponent output="false">

  <!--- host shortcut --->
  <cfset host = ListFirst(cgi.server_name, ".") />

  <!--- app flags --->
  <cfset application.dbug = "Y" />

  <!--- env routing --->
  <cfif host EQ "app">
    <cfset application.dsn = "abo" />
    <cfset application.information_schema = "actorsbusinessoffice" />
    <cfset application.suffix = "_1.5" />
  <cfelse>
    <cfset application.dsn = "abod" />
    <cfset application.information_schema = "new_development" />
    <cfset application.suffix = "" />
  </cfif>

  <!--- version --->
  <cfquery result="result" name="findit" datasource="#application.dsn#">
    SELECT verid
    FROM taoversions
    ORDER BY isactive DESC, verid DESC
    LIMIT 1
  </cfquery>
  <cfset application.rev = findit.verid />

  <cfscript>
    // Core application settings
    this.name = "TAO";
    this.datasource = application.dsn;
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(11,1,0,0);
    this.sessionTimeout = createTimeSpan(0,9,20,0);
    this.loginStorage = "session";
    this.mappings["/app"] = expandPath(".");
    this.strictVariables = false;

    // Make CF act “looser” on variable resolution and avoid null pitfalls
    this.searchImplicitScopes = true;   // ACF: re-enable implicit scope searching
    this.enableNullSupport = false;     // ACF: legacy truthy/falsy behavior

    // Media paths
    application.baseMediaPath = "C:\home\theactorsoffice.com\media-" & this.datasource;
    application.baseMediaUrl  = "/media-" & this.datasource;

    application.auditionimporttemplate = application.baseMediaUrl & "/auditionimporttemplates.xlsx";
    application.imagesPath = application.baseMediaPath & "\images";
    application.imagesUrl = application.baseMediaUrl & "/images";

    application.datesPath = application.imagesPath & "\dates";
    application.datesUrl  = application.imagesUrl & "/dates";

    application.defaultsPath = application.imagesPath & "\defaults";
    application.defaultsUrl  = application.imagesUrl & "/defaults";

    application.defaultAvatarUrl  = application.defaultsUrl  & "/avatar.jpg";
    application.defaultAvatarPath = application.defaultsPath & "\avatar.jpg";

    application.emailImagesPath = application.imagesPath & "\email";
    application.emailImagesUrl  = application.imagesUrl  & "/email";

    application.filetypesPath = application.imagesPath & "\filetypes";
    application.filetypesUrl  = application.imagesUrl  & "/filetypes";

    application.retinaIconsPath = application.imagesPath & "\retina-circular-icons";
    application.retinaIconsUrl  = application.imagesUrl  & "/retina-circular-icons";

    application.retinaIcons14Path = application.retinaIconsPath & "\14";
    application.retinaIcons14Url  = application.retinaIconsUrl  & "/14";

    application.retinaIcons32Path = application.retinaIconsPath & "\32";
    application.retinaIcons32Url  = application.retinaIconsUrl  & "/32";
  </cfscript>

  <!--- Utility: user-facing date formatter that tolerates nulls/missing --->
  <cffunction name="formatDate" access="public" returntype="string" output="false">
    <cfargument name="dateValue" required="false" />
    <cfset var dateFormatToUse = "mm/dd/yyyy" />
    <cfif structKeyExists(session, "dateformatExample")>
      <cfset dateFormatToUse = session.dateformatExample />
    </cfif>
    <cfif NOT structKeyExists(arguments, "dateValue") OR isNull(arguments.dateValue) OR NOT isDate(arguments.dateValue)>
      <cfreturn "" />
    </cfif>
    <cfreturn dateFormat(arguments.dateValue, dateFormatToUse) />
  </cffunction>

  <cffunction name="onApplicationStart" returntype="boolean" output="false">
    <cfreturn true />
  </cffunction>

  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true" />

    <!--- 1) Normalize request inputs and provide permissive defaults --->
    <cfscript>
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
      // This emulates “loose” behavior for legacy code doing bare reads like `id`
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

    <!--- 3) Login gate (allow login pages) --->
    <cfif NOT structKeyExists(session, "userid")
          AND NOT ListFindNoCase(arguments.targetPage, "loginform.cfm,login2.cfm")
          AND NOT ListFindNoCase(CGI.SCRIPT_NAME, "/app/login2.cfm")>
      <cflocation url="/loginform.cfm" addToken="false" />
    </cfif>

    <!--- 4) Post-login user paths --->
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

    <cfreturn true />
  </cffunction>

  <cffunction name="onRequest" returntype="void" output="true">
    <cfargument name="targetPage" type="string" required="true" />
    <cfinclude template="#arguments.targetPage#" />
  </cffunction>

  <!--- simple debug trap during triage; remove when stable --->
  <cffunction name="onError" access="public" returntype="void" output="true">
    <cfargument name="exception" />
    <cfargument name="eventName" />
    <cfdump var="#arguments.exception#" label="CF Error" top="2" />
    <cfabort />
  </cffunction>

</cfcomponent>
 