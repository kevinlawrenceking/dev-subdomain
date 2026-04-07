<cfcomponent output="false">

  <!--- 1) Compute host + env into LOCAL vars only (no application scope yet) --->
  <cfset host = ListFirst(cgi.server_name, ".") />
  <cfscript>
    if (host == "app") {
      envLabel = "PROD"; _dsn = "abo"; _schema = "actorsbusinessoffice"; _suffix = "_1.5";
    } else if (host == "uat") {
      envLabel = "UAT";  _dsn = "abod"; _schema = "new_development";     _suffix = "";
    } else {
      envLabel = "DEV";  _dsn = "abod"; _schema = "new_development";     _suffix = "";
    }

    // 2) Set this.name FIRST — ColdFusion resolves the application scope by
    //    this.name, so every application.* write below goes to the correct scope
    this.name = "TAO_" & envLabel;

    // 3) NOW populate the application scope (targeting the right scope)
    application.dsn                = _dsn;
    application.information_schema = _schema;
    application.suffix             = _suffix;
    application.dbug               = "Y";
  </cfscript>

  <!--- version --->
  <cfquery result="result" name="findit" datasource="#application.dsn#">
    SELECT verid
    FROM taoversions
    ORDER BY isactive DESC, verid DESC
    LIMIT 1
  </cfquery>
  <cfset application.rev = findit.verid />

  <cfscript>
    this.datasource = application.dsn;
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(11,1,0,0);
    this.sessionTimeout = createTimeSpan(0,9,20,0);
    this.loginStorage = "session";
    this.mappings["/app"] = expandPath(".");
    this.strictVariables = false;

    // Session cookie hardening
    this.sessioncookie.httponly = true;
    this.sessioncookie.secure = true;
    // Lax is required for OAuth callbacks (Google redirects back cross-site).
    // Safe because all POST requests already validate CSRF tokens.
    this.sessioncookie.samesite = "Lax";

    // Make CF act looser on variable resolution and avoid null pitfalls
    this.searchImplicitScopes = true;
    this.enableNullSupport = false;

    // Standardize for services and queryExecute
    application.datasource = this.datasource;

    // Central service registry
    if (NOT structKeyExists(application, "services")) {
      application.services = {
        auditionSubmitSiteUserService = new services.AuditionSubmitSiteUserService()
      };
      // TAO-SPEC-2026-005: Error management service
      try {
        application.services.errorService = new services.ErrorService(
          dsn = application.dsn,
          fromEmail = "support@theactorsoffice.com",
          toEmail = "kevinking7135@gmail.com",
          appName = this.name
        );
      } catch (any e) {
        // ErrorService init failed in pseudo-constructor — will retry in onApplicationStart
      }
    }

    // Media paths - detect environment based on dsn
    if (application.dsn == "abo") {
      // Production server
      application.baseMediaPath = "C:\\home\\theactorsoffice.com\\media-" & this.datasource;
    } else {
      // Development - use expandPath to get absolute path from app root
      // expandPath("/") gives the web root, which is the dev-subdomain folder
      application.baseMediaPath = expandPath("/media-" & this.datasource);
    }
    application.baseMediaUrl  = "/media-" & this.datasource;

    application.auditionimporttemplate = application.baseMediaUrl & "/auditionimporttemplates.xlsx";
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
    <cfscript>
      // Rebuild critical app-level values on reload
      application.datasource = this.datasource;
      application.services = {
        auditionSubmitSiteUserService = new services.AuditionSubmitSiteUserService()
      };

      // TAO-SPEC-2026-005: Error management service (application-scoped singleton)
      try {
        application.services.errorService = new services.ErrorService(
          dsn = application.dsn,
          fromEmail = "support@theactorsoffice.com",
          toEmail = "kevinking7135@gmail.com",
          appName = this.name
        );
      } catch (any e) {
        cflog(file="TAO_error_fallback", type="error",
              text="ErrorService init failed: " & e.message);
      }

      // External API credentials — read from server environment variables.
      // Use structKeyExists to safely handle missing env vars on any CF engine.
      var env = {};
      if (structKeyExists(server, "system") && structKeyExists(server.system, "environment")) {
        env = server.system.environment;
      }
      application.secrets = {
        googleOAuthClientId     = structKeyExists(env, "TAO_GOOGLE_OAUTH_CLIENT_ID")     ? env["TAO_GOOGLE_OAUTH_CLIENT_ID"]     : "",
        googleOAuthClientSecret = structKeyExists(env, "TAO_GOOGLE_OAUTH_CLIENT_SECRET") ? env["TAO_GOOGLE_OAUTH_CLIENT_SECRET"] : "",
        googleOAuthRedirectUri  = structKeyExists(env, "TAO_GOOGLE_OAUTH_REDIRECT_URI")  ? env["TAO_GOOGLE_OAUTH_REDIRECT_URI"]  : "https://app.theactorsoffice.com/oauth/oauth_callback.cfm",
        paykickstartAuthToken   = structKeyExists(env, "TAO_PAYKICKSTART_AUTH_TOKEN")    ? env["TAO_PAYKICKSTART_AUTH_TOKEN"]    : "",
        iconHorseApiKey         = structKeyExists(env, "TAO_ICONHORSE_API_KEY")          ? env["TAO_ICONHORSE_API_KEY"]          : ""
      };

      // Initialize feature flags with DB-driven values (cached)
      loadFeatureFlags();

      // PERF: Request-level timing instrumentation (kill switch: set false to disable)
      application.perfLogging = true;
    </cfscript>
    <cfreturn true />
  </cffunction>

  <!--- ============================================================
        FEATURE FLAGS - DB-driven rollout control
        ============================================================ --->

  <cffunction name="loadFeatureFlags" access="public" returntype="void" output="false"
              hint="Load feature flags from database into application scope with caching">
    <cfscript>
      // Initialize features struct if missing
      if (!structKeyExists(application, "features")) {
        application.features = {};
      }

      // Set cache TTL (60 seconds default)
      application.featureFlagCacheTTL = 60;

      try {
        // Load global flags from database
        var qFlags = queryExecute(
          "SELECT flag_key, is_enabled FROM feature_flags",
          {},
          { datasource: application.datasource }
        );

        // Reset all flags to false first (safe default)
        application.features.importV3Enabled = false;
        application.features.importV3AllowedUsers = [];

        // Apply loaded flags
        for (var row in qFlags) {
          if (row.flag_key eq "import_v3_enabled") {
            application.features.importV3Enabled = (row.is_enabled eq 1);
          }
        }

        // Load per-user allowlist for import_v3
        var qAllowed = queryExecute(
          "SELECT userid FROM feature_flag_users
           WHERE flag_key = 'import_v3_enabled' AND is_enabled = 1",
          {},
          { datasource: application.datasource }
        );
        application.features.importV3AllowedUsers = [];
        for (var row in qAllowed) {
          arrayAppend(application.features.importV3AllowedUsers, row.userid);
        }

        // Record cache timestamp
        application.featureFlagCacheTime = now();

      } catch (any e) {
        // On error, maintain safe defaults (features disabled)
        application.features.importV3Enabled = false;
        application.features.importV3AllowedUsers = [];
        application.featureFlagCacheTime = now();
      }
    </cfscript>
  </cffunction>

  <cffunction name="refreshFeatureFlagsIfStale" access="public" returntype="void" output="false"
              hint="Refresh feature flags if cache has expired">
    <cfscript>
      // Check if cache exists and is still valid
      if (!structKeyExists(application, "featureFlagCacheTime")
          || !structKeyExists(application, "featureFlagCacheTTL")
          || dateDiff("s", application.featureFlagCacheTime, now()) > application.featureFlagCacheTTL) {
        loadFeatureFlags();
      }
    </cfscript>
  </cffunction>

  <cffunction name="forceRefreshFeatureFlags" access="public" returntype="void" output="false"
              hint="Force immediate refresh of feature flags (admin action)">
    <cfscript>
      loadFeatureFlags();
    </cfscript>
  </cffunction>

  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true" />

    <!--- PERF: Capture timing at the very start of the request lifecycle --->
    <!--- MIGRATE: This logging pattern maps to structured logging in Go (zerolog/slog). --->
    <cfset request.perfStart = getTickCount() />
    <cfset request.perfPage = arguments.targetPage />
    <cfset request.perfQueryCount = 0 />

    <!--- PERF: Request-scoped service cache. Lazy — each CFC is instantiated once
          on first access, then reused for the rest of the request.
          MIGRATE: In Go, services are injected via constructor DI. --->
    <cfset request.services = {} />
    <cfset request.svc = function(required string name) {
        if (!structKeyExists(request.services, arguments.name)) {
            request.services[arguments.name] = createObject("component", "services." & arguments.name);
        }
        return request.services[arguments.name];
    } />

    <!--- Per-request datasource: immune to application-scope race conditions --->
    <cfset request.dsn = application.dsn />

    <!--- Refresh feature flags if cache expired (DB-driven rollout control) --->
    <cfscript>
      refreshFeatureFlagsIfStale();
    </cfscript>

    <!--- 1) Normalize request inputs and provide permissive defaults --->
    <cfscript>
      // whitelist of keys commonly used bare in legacy templates
      var keys = [
        "u","id","page","action","q","caseid","userid","contactid","currentid"
      ];

      // Default URL and FORM keys so implicit lookups resolve harmlessly
      for (var k in keys) {
        param name="url.#k#"  default="";
        param name="form.#k#" default="";
      }

      // Build a merged request map (URL wins, then FORM)
      request.p = duplicate(form);
      structAppend(request.p, url, true);

      // Optional: expose the merged map as simple variables when missing.
      // This emulates loose behavior for legacy code doing bare reads like id
      // without changing every template.
      for (var k in keys) {
        if (NOT isDefined(k)) {
          // place into REQUEST-only shadow, not VARIABLES of target page
          // consumers should prefer request.p.*, but bare reads will now
          // succeed via implicit scope search.
          request[k] = request.p[k];
        }
      }
    </cfscript>

    <!--- 2) Admin Bypass via URL.u --->
    <cfif len(url.u) AND isNumeric(url.u)>

      <!--- RULE 1: Authentication gate — reject unauthenticated ?u= --->
      <cfif NOT structKeyExists(session, "userid")>
        <cflocation url="/loginform.cfm" addToken="false" />
      </cfif>

      <!--- RULE 2: Self-match — normal login redirect, skip to post-login block --->
      <cfif url.u NEQ session.userid>

        <!--- RULE 3: Admin impersonation gate — verify requester is admin --->
        <cfquery name="adminCheck" datasource="#application.dsn#" maxrows="1">
          SELECT userRole
          FROM taousers
          WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer" />
        </cfquery>

        <cfif adminCheck.recordCount EQ 0
              OR (adminCheck.userRole NEQ "Admin" AND adminCheck.userRole NEQ "Administrator")>
          <cflocation url="/loginform.cfm?pwrong=Y" addToken="false" />
        </cfif>

        <!--- Admin confirmed — impersonate target user --->
        <cfset session.userid = url.u />
        <cfset userid = session.userid />
        <!--- PERF: Force a fresh DB load for the impersonated user --->
        <cfset session.bustUserCache = true />
        <cfinclude template="/include/qry/fetchUsers.cfm" />

        <cfset session.impersonating = true />

        <cfscript>
          session.userMediaPath = application.baseMediaPath & "\\users\\" & session.userID;
          session.userMediaUrl  = application.baseMediaUrl  & "/users/" & session.userID;

          session.userCalendarPath = session.userMediaPath & "\\calendar\\" & calendarname & ".ics";
          session.userCalendarUrl  = "https://" & host & ".theactorsoffice.com/media-" & application.dsn & "/calendar/" & calendarname & ".ics";

          session.userContactsPath = session.userMediaPath & "\\contacts";
          session.userContactsUrl  = session.userMediaUrl  & "/contacts";

          session.userImportsPath = session.userMediaPath & "\\imports";
          session.userImportsUrl  = session.userMediaUrl  & "/imports";

          session.userExportsPath = session.userMediaPath & "\\exports";
          session.userExportsUrl  = session.userMediaUrl  & "/exports";

          session.userSharePath = session.userMediaPath & "\\share";
          session.userShareUrl  = session.userMediaUrl  & "/share";

          session.userAvatarPath = session.userMediaPath & "\\avatar.jpg";
          session.userAvatarUrl  = session.userMediaUrl  & "/avatar.jpg";
        </cfscript>

      </cfif>
      <!--- Self-match (url.u == session.userid): no action, post-login block handles it --->

    </cfif>

    <!--- 3) Login gate (allow login pages) --->
    <cfif NOT structKeyExists(session, "userid")
          AND NOT ListFindNoCase(arguments.targetPage, "loginform.cfm,login2.cfm")
          AND NOT ListFindNoCase(CGI.SCRIPT_NAME, "/app/login2.cfm")>
      <cflocation url="/loginform.cfm" addToken="false" />
    </cfif>

    <!--- Generate CSRF token for session if not already present --->
    <cfif structKeyExists(session, "userid") AND NOT structKeyExists(session, "csrfToken")>
      <cfset session.csrfToken = CSRFGenerateToken() />
    </cfif>

    <!--- CSRF validation for POST requests from authenticated users --->
    <!--- Accept token from form field (regular forms) OR X-CSRF-Token header (AJAX) --->
    <cfif cgi.REQUEST_METHOD EQ "POST" AND structKeyExists(session, "csrfToken")>
      <cfset var submittedCsrf = "">
      <cfif structKeyExists(form, "csrfToken")>
        <cfset submittedCsrf = form.csrfToken>
      <cfelseif len(trim(cgi.HTTP_X_CSRF_TOKEN))>
        <cfset submittedCsrf = cgi.HTTP_X_CSRF_TOKEN>
      </cfif>
      <!--- Verify: try session comparison first (reliable), fall back to CF CSRF engine --->
      <cfset var csrfValid = false>
      <cfif len(trim(submittedCsrf))>
        <cfif submittedCsrf EQ session.csrfToken>
          <cfset csrfValid = true>
        <cfelseif CSRFVerifyToken(submittedCsrf)>
          <cfset csrfValid = true>
        </cfif>
      </cfif>
      <cfif NOT csrfValid>
        <cflog file="tao_csrf" type="warning"
               text="CSRF POST rejected: #cgi.SCRIPT_NAME# | userid=#structKeyExists(session,'userid') ? session.userid : 'none'# | hasToken=#len(trim(submittedCsrf)) GT 0#">
        <cfheader statuscode="403">
        <!--- Return JSON for AJAX requests so JS error handlers work properly --->
        <cfif len(trim(cgi.HTTP_X_REQUESTED_WITH)) OR len(trim(cgi.HTTP_X_CSRF_TOKEN))>
          <cfcontent type="application/json; charset=utf-8" reset="true">
          <cfoutput>{"success":false,"message":"Security token missing or invalid. Please reload the page and try again.","code":"CSRF_FAILED"}</cfoutput>
        <cfelse>
          <cfcontent type="text/html" reset="true">
          <cfoutput>
            <!DOCTYPE html><html><head><title>Access Denied</title></head>
            <body>
            <div style="font-family:Arial,sans-serif;text-align:center;padding:60px 20px;color:##333">
            <h2 style="font-size:22px">Security token missing or invalid</h2>
            <p style="font-size:15px;color:##666">Your form submission could not be verified. Please reload the page and try again.</p>
            <p><a href="javascript:history.back()" style="color:##2563eb">Go Back</a></p>
            </div>
            </body></html>
          </cfoutput>
        </cfif>
        <cfabort>
      </cfif>
    </cfif>

    <!--- 4) Post-login user paths --->
    <cfif structKeyExists(session, "userid")>
      <cfset userid = session.userid />
      <cfinclude template="/include/qry/fetchUsers.cfm" />

      <cfscript>
        session.userMediaPath = application.baseMediaPath & "\\users\\" & session.userID;
        session.userMediaUrl  = application.baseMediaUrl  & "/users/" & session.userID;

        session.userCalendarPath = session.userMediaPath & "\\calendar\\" & calendarname & ".ics";
        session.userCalendarUrl  = "https://" & host & ".theactorsoffice.com/media-" & application.dsn & "/calendar/" & calendarname & ".ics";

        session.userContactsPath = session.userMediaPath & "\\contacts";
        session.userContactsUrl  = session.userMediaUrl  & "/contacts";

        session.userImportsPath = session.userMediaPath & "\\imports";
        session.userImportsUrl  = session.userMediaUrl  & "/imports";

        session.userExportsPath = session.userMediaPath & "\\exports";
        session.userExportsUrl  = session.userMediaUrl  & "/exports";

        session.userSharePath = session.userMediaPath & "\\share";
        session.userShareUrl  = session.userMediaUrl  & "/share";

        session.userAvatarPath = session.userMediaPath & "\\avatar.jpg";
        session.userAvatarUrl  = session.userMediaUrl  & "/avatar.jpg";
      </cfscript>

      <!--- legacy bare checks now work via request shadows and implicit search --->
      <cfif len(request.p.contactid)>
        <cfset defaultavatarurl = session.userContactsUrl & "/" & request.p.contactid & "/avatar.jpg" />
      </cfif>
      <cfif len(request.p.currentid)>
        <cfset defaultavatarurl = session.userContactsUrl & "/" & request.p.currentid & "/avatar.jpg" />
      </cfif>

      <!--- P11: Setup wizard guard -- redirect Setup-status users to wizard
            Note: DB stores userstatus with trailing space ('setup ') so we trim before comparing.
            ColdFusion EQ is case-insensitive but trailing spaces are significant. --->
      <cfif structKeyExists(session, "userstatus")
            AND trim(session.userstatus) EQ "Setup"
            AND NOT findNoCase("/setup-wizard/", cgi.SCRIPT_NAME)
            AND NOT findNoCase("/ajax/", cgi.SCRIPT_NAME)
            AND NOT findNoCase("/login", cgi.SCRIPT_NAME)
            AND NOT findNoCase("/logout", cgi.SCRIPT_NAME)
            AND NOT REFindNoCase("\.(css|js|png|jpg|gif|svg|woff|woff2|ttf|ico)$", cgi.SCRIPT_NAME)>
        <cflocation url="/app/setup-wizard/" addtoken="false" />
      </cfif>

    </cfif>

    <cfreturn true />
  </cffunction>

  <cffunction name="onRequest" returntype="void" output="true">
    <cfargument name="targetPage" type="string" required="true" />
    <cfinclude template="#arguments.targetPage#" />
  </cffunction>

  <!--- PERF: Log request timing to TSV file for performance analysis --->
  <!--- MIGRATE: The perf-*.log TSV format maps to: { "timestamp", "user_id", "path", "elapsed_ms", "query_count", "query_string" } --->
  <cffunction name="onRequestEnd" returntype="void" output="false">
    <cfargument name="targetPage" type="string" required="true" />

    <cfif structKeyExists(application, "perfLogging") AND application.perfLogging
          AND structKeyExists(request, "perfStart")>

      <cfset var elapsed = getTickCount() - request.perfStart />
      <cfset var userid = structKeyExists(session, "userid") ? session.userid : 0 />
      <cfset var qcount = structKeyExists(request, "perfQueryCount") ? request.perfQueryCount : -1 />
      <cfset var logLine = dateTimeFormat(now(), "yyyy-MM-dd HH:nn:ss") & chr(9)
          & userid & chr(9)
          & request.perfPage & chr(9)
          & elapsed & chr(9)
          & qcount & chr(9)
          & cgi.QUERY_STRING />

      <cftry>
        <cfset var logDir = expandPath("/logs") />
        <cfif NOT directoryExists(logDir)>
          <cfset directoryCreate(logDir) />
        </cfif>
        <cffile action="append"
                file="#logDir#/perf-#dateFormat(now(), 'yyyy-MM-dd')#.log"
                output="#logLine#"
                addNewLine="true" />
      <cfcatch>
        <!--- Silently fail - logging must never break the request --->
      </cfcatch>
      </cftry>
    </cfif>
  </cffunction>

  <!--- TAO-SPEC-2026-005: Centralized error handler with ticket tracking --->
  <cffunction name="onError" access="public" returntype="void" output="true">
    <cfargument name="exception" />
    <cfargument name="eventName" />

    <cftry>
      <!--- Delegate to ErrorService --->
      <cfif structKeyExists(application, "services")
            AND structKeyExists(application.services, "errorService")
            AND isObject(application.services.errorService)>
        <cfset var result = application.services.errorService.handleError(
            arguments.exception, arguments.eventName, "app"
        ) />
      <cfelse>
        <!--- ErrorService not in application scope — instantiate inline --->
        <cfset var errorSvc = new services.ErrorService(
            dsn = application.dsn,
            fromEmail = "support@theactorsoffice.com",
            toEmail = "kevinking7135@gmail.com",
            appName = "TAO"
        ) />
        <cfset var result = errorSvc.handleError(
            arguments.exception, arguments.eventName, "app"
        ) />
      </cfif>

      <!--- Render response based on request type --->
      <cfif result.isAjax>
        <cfheader statuscode="500" />
        <cfcontent type="application/json; charset=utf-8" reset="true" />
        <cfoutput>{"success":false,"message":"#encodeForJavaScript(result.message)#","ticketId":"#encodeForJavaScript(result.ticketId)#","support":"support@theactorsoffice.com","reference":"Quote this ticket ID when contacting support."}</cfoutput>
      <cfelse>
        <cfheader statuscode="500" />
        <cfcontent type="text/html; charset=utf-8" reset="true" />
        <cfset request.errorTicketId = result.ticketId />
        <cfinclude template="/templates/error/error-friendly.cfm" />
      </cfif>

    <cfcatch>
      <!--- ABSOLUTE FALLBACK: ErrorService itself failed --->
      <cfset var fallbackTicketId = "ERR-" & Left(CreateUUID(), 8) />

      <!--- Log both the original error and the fallback failure --->
      <cftry>
        <cfset var origMsg = "" />
        <cfif structKeyExists(arguments, "exception") AND structKeyExists(arguments.exception, "message")>
          <cfset origMsg = Left(arguments.exception.message, 200) />
        </cfif>
        <cflog file="TAO_error_fallback" type="error"
               text="ErrorService failed: #cfcatch.message# | Original: #origMsg# | Ticket: #fallbackTicketId#" />
        <cfcatch></cfcatch>
      </cftry>

      <!--- Detect AJAX for fallback response --->
      <cfset var fallbackIsAjax = (
        findNoCase("xmlhttprequest", cgi.HTTP_X_REQUESTED_WITH) GT 0 OR
        findNoCase("/ajax/", cgi.SCRIPT_NAME) GT 0
      ) />

      <cfif fallbackIsAjax>
        <cfheader statuscode="500" />
        <cfcontent type="application/json; charset=utf-8" reset="true" />
        <cfoutput>{"success":false,"message":"An unexpected error occurred. Please try again or contact support.","ticketId":"#fallbackTicketId#","support":"support@theactorsoffice.com","reference":"Quote this ticket ID when contacting support."}</cfoutput>
      <cfelse>
        <cfheader statuscode="500" />
        <cfcontent type="text/html; charset=utf-8" reset="true" />
        <cftry>
          <cfset request.errorTicketId = fallbackTicketId />
          <cfinclude template="/templates/error/error-friendly.cfm" />
        <cfcatch>
          <!--- Last resort: hardcoded minimal HTML --->
          <cfoutput>
          <!DOCTYPE html>
          <html><head><title>Error</title></head>
          <body style="font-family:sans-serif;text-align:center;padding:60px 20px;color:##333">
          <h1 style="font-size:22px">Something went wrong</h1>
          <p>Our team has been notified. Your ticket ID is: <strong>#fallbackTicketId#</strong></p>
          <p><a href="/app/dashboard/" style="color:##406E8E">Return to Dashboard</a></p>
          <p style="font-size:13px;color:##999">Contact support@theactorsoffice.com if this persists.</p>
          </body></html>
          </cfoutput>
        </cfcatch>
        </cftry>
      </cfif>
    </cfcatch>
    </cftry>

    <cfabort />
  </cffunction>

</cfcomponent>
