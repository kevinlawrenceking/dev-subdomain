<cfcomponent output="false" hint="TAO-SPEC-2026-005: Centralized error management service. Application-scoped singleton.">

  <!--- ==================== CONSTRUCTOR ==================== --->

  <cffunction name="init" access="public" returntype="ErrorService" output="false"
              hint="Store config in variables scope (immutable after init). Returns this.">
    <cfargument name="dsn" type="string" required="true" />
    <cfargument name="fromEmail" type="string" required="true" />
    <cfargument name="toEmail" type="string" required="true" />
    <cfargument name="bccEmail" type="string" required="false" default="" />
    <cfargument name="ccEmail" type="string" required="false" default="" />
    <cfargument name="appName" type="string" required="false" default="TAO" />

    <cfset variables.dsn = arguments.dsn />
    <cfset variables.fromEmail = arguments.fromEmail />
    <cfset variables.toEmail = arguments.toEmail />
    <cfset variables.bccEmail = arguments.bccEmail />
    <cfset variables.ccEmail = arguments.ccEmail />
    <cfset variables.appName = arguments.appName />

    <cfreturn this />
  </cffunction>

  <!--- ==================== PUBLIC METHODS ==================== --->

  <cffunction name="handleError" access="public" returntype="struct" output="false"
              hint="Single entry point. Generates ticket, persists, emails, returns {ticketId, message, isAjax}.">
    <cfargument name="exception" required="true" />
    <cfargument name="eventName" type="string" required="false" default="" />
    <cfargument name="cfContext" type="string" required="false" default="app" />

    <cfscript>
      var ticketId = generateTicketId();
      var isAjax = isAjaxRequest();
      var safeMessage = "An unexpected error occurred. Please try again or contact support.";

      // Build full diagnostics
      var diagnostics = buildDiagnostics(arguments.exception, arguments.eventName, arguments.cfContext);
      diagnostics.ticketId = ticketId;

      // Persist to database (try/catch inside)
      var dbSuccess = persistTicket(diagnostics);

      // Create support ticket in tickets table
      createSupportTicket(diagnostics);

      // Send email notification (try/catch inside)
      var emailSuccess = sendErrorEmail(diagnostics);

      // Update email_sent flag if both DB and email succeeded
      if (dbSuccess AND emailSuccess) {
        try {
          queryExecute(
            "UPDATE error_tickets SET email_sent = 1 WHERE ticket_id = :tid",
            { tid = { value = ticketId, cfsqltype = "cf_sql_varchar" } },
            { datasource = variables.dsn }
          );
          if (structKeyExists(request, "perfSvcQueryCount")) request.perfSvcQueryCount++;
        } catch (any e) {
          cflog(file = "TAO_error_fallback", type = "warning",
                text = "Failed to update email_sent for " & ticketId & ": " & e.message);
        }
      }

      return {
        ticketId = ticketId,
        message = safeMessage,
        isAjax = isAjax
      };
    </cfscript>
  </cffunction>

  <!--- ==================== PRIVATE METHODS ==================== --->

  <cffunction name="generateTicketId" access="private" returntype="string" output="false">
    <cfreturn "ERR-" & Left(CreateUUID(), 8) />
  </cffunction>

  <cffunction name="unwrapCauseChain" access="private" returntype="struct" output="false"
              hint="Walks exception.rootCause / exception.cause chain up to depthCap. Returns { root, chain, chainCount, truncated }. Never throws.">
    <cfargument name="exception" required="true" />
    <cfargument name="depthCap" type="numeric" required="false" default="5" />

    <cfscript>
      var emptyRoot = { type = "", message = "", detail = "", file = "", line = 0 };
      var result = { root = emptyRoot, chain = [], chainCount = 0, truncated = false };

      try {
        if (NOT isStruct(arguments.exception)) {
          return result;
        }

        // Seed: pick first real cause off the outer exception.
        var current = "";
        if (structKeyExists(arguments.exception, "rootCause")
            AND isStruct(arguments.exception.rootCause)) {
          current = arguments.exception.rootCause;
        } else if (structKeyExists(arguments.exception, "cause")
                   AND isStruct(arguments.exception.cause)) {
          current = arguments.exception.cause;
        } else {
          return result;
        }

        // Referential-identity cycle guard via System.identityHashCode.
        var sys = createObject("java", "java.lang.System");
        var visited = [];
        var depth = 0;
        var deepest = emptyRoot;

        while (isStruct(current) AND depth LT arguments.depthCap) {
          var hash = sys.identityHashCode(current);
          if (arrayContains(visited, hash)) {
            break;
          }
          arrayAppend(visited, hash);

          var frame = {
            depth   = depth,
            type    = structKeyExists(current, "type")    ? toString(current.type)    : "",
            message = structKeyExists(current, "message") ? Left(toString(current.message), 2000) : "",
            detail  = structKeyExists(current, "detail")  ? Left(toString(current.detail),  2000) : "",
            file    = "",
            line    = 0
          };

          if (structKeyExists(current, "tagContext")
              AND isArray(current.tagContext)
              AND arrayLen(current.tagContext) GTE 1
              AND isStruct(current.tagContext[1])) {
            var tc = current.tagContext[1];
            if (structKeyExists(tc, "template")) {
              frame.file = Left(toString(tc.template), 500);
            }
            if (structKeyExists(tc, "line") AND isNumeric(tc.line)) {
              frame.line = val(tc.line);
            }
          }

          arrayAppend(result.chain, frame);
          deepest = {
            type    = frame.type,
            message = frame.message,
            detail  = frame.detail,
            file    = frame.file,
            line    = frame.line
          };
          depth = depth + 1;

          // Descend: prefer rootCause, then cause, else stop.
          if (structKeyExists(current, "rootCause")
              AND isStruct(current.rootCause)) {
            current = current.rootCause;
          } else if (structKeyExists(current, "cause")
                     AND isStruct(current.cause)) {
            current = current.cause;
          } else {
            current = "";
          }
        }

        result.chainCount = arrayLen(result.chain);
        result.truncated  = (depth GTE arguments.depthCap AND isStruct(current));
        result.root       = deepest;
        return result;

      } catch (any e) {
        cflog(file = "TAO_error_fallback", type = "warning",
              text = "unwrapCauseChain failed: " & e.message);
        return { root = { type = "", message = "", detail = "", file = "", line = 0 },
                 chain = [], chainCount = 0, truncated = false };
      }
    </cfscript>
  </cffunction>

  <cffunction name="buildDiagnostics" access="private" returntype="struct" output="false"
              hint="Assembles full diagnostic struct from exception, CGI, session, server scopes.">
    <cfargument name="exception" required="true" />
    <cfargument name="eventName" type="string" required="true" />
    <cfargument name="cfContext" type="string" required="true" />

    <cfscript>
      var diag = {};

      // Error details
      diag.errorType = structKeyExists(arguments.exception, "type") ? arguments.exception.type : "";
      diag.errorMessage = structKeyExists(arguments.exception, "message") ? Left(arguments.exception.message, 2000) : "";
      diag.errorDetail = structKeyExists(arguments.exception, "detail") ? Left(arguments.exception.detail, 2000) : "";

      // Stack trace
      diag.stackTrace = structKeyExists(arguments.exception, "stackTrace") ? arguments.exception.stackTrace : "";

      // Tag context (serialize to JSON)
      diag.tagContext = "";
      if (structKeyExists(arguments.exception, "tagContext") AND isArray(arguments.exception.tagContext)) {
        try {
          diag.tagContext = serializeJSON(arguments.exception.tagContext);
        } catch (any e) {
          diag.tagContext = "Error serializing tagContext: " & e.message;
        }
      }

      // SQL (sanitized — strip literals, preserve structure)
      diag.sqlStatement = "";
      if (structKeyExists(arguments.exception, "sql") AND len(trim(arguments.exception.sql))) {
        diag.sqlStatement = sanitizeSql(arguments.exception.sql);
      }

      // Root cause chain (TAO-SPEC-2026-005 Phase 2). Unwrap is best-effort;
      // helper swallows its own errors so capture never breaks capture.
      var causeData = unwrapCauseChain(arguments.exception);
      diag.rootCauseType    = causeData.root.type;
      diag.rootCauseMessage = causeData.root.message;
      diag.rootCauseDetail  = causeData.root.detail;
      diag.rootCauseFile    = causeData.root.file;
      diag.rootCauseLine    = causeData.root.line;
      diag.causeChain       = "";
      if (causeData.chainCount GT 0) {
        try {
          diag.causeChain = serializeJSON(causeData.chain);
        } catch (any e) {
          diag.causeChain = "Error serializing cause chain: " & e.message;
        }
      }
      diag.causeChainCount  = causeData.chainCount;
      diag.causeTruncated   = causeData.truncated;

      // Request context from CGI scope
      diag.scriptName = cgi.SCRIPT_NAME;
      diag.queryString = cgi.QUERY_STRING;
      diag.httpMethod = cgi.REQUEST_METHOD;
      diag.httpReferer = cgi.HTTP_REFERER;
      diag.remoteIp = cgi.REMOTE_ADDR;
      diag.userAgent = cgi.HTTP_USER_AGENT;
      diag.serverName = cgi.SERVER_NAME;

      // Form data (sensitive values redacted)
      diag.formData = redactFormScope();

      // User context (safe session reads — returns "" if session unavailable)
      diag.userId = safeSessionRead("userid");
      diag.userEmail = safeSessionRead("email");
      diag.userName = "";

      // Look up name/email from taousers if we have a userId
      if (len(diag.userId) AND isNumeric(diag.userId)) {
        var userInfo = lookupUser(val(diag.userId));
        diag.userName = userInfo.userName;
        if (NOT len(diag.userEmail)) {
          diag.userEmail = userInfo.userEmail;
        }
      }

      // CF and environment context
      diag.cfContext = arguments.cfContext;
      diag.eventName = arguments.eventName;
      diag.environment = variables.appName;

      diag.cfEngine = "";
      try {
        diag.cfEngine = server.coldfusion.productname & " " & server.coldfusion.productversion;
      } catch (any e) {
        diag.cfEngine = "Unknown";
      }

      // Raw exception reference for email template (tag context table, etc.)
      diag.exception = arguments.exception;

      return diag;
    </cfscript>
  </cffunction>

  <cffunction name="sanitizeSql" access="private" returntype="string" output="false"
              hint="Strips quoted string literals and numeric literals, replaces with ? placeholders.">
    <cfargument name="rawSql" type="string" required="true" />
    <cfscript>
      var result = arguments.rawSql;
      // Replace single-quoted string literals: 'anything' -> ?
      result = reReplace(result, "'[^']*'", "?", "ALL");
      // Replace standalone numeric literals
      result = reReplace(result, "\b\d+\.?\d*\b", "?", "ALL");
      return Left(result, 2000);
    </cfscript>
  </cffunction>

  <cffunction name="persistTicket" access="private" returntype="boolean" output="false"
              hint="INSERT into error_tickets. Returns true on success. Fallback: cflog.">
    <cfargument name="diagnostics" type="struct" required="true" />

    <cftry>
      <cfquery datasource="#variables.dsn#">
        INSERT INTO error_tickets (
          ticket_id, error_type, error_message, error_detail,
          root_cause_type, root_cause_message, root_cause_detail,
          root_cause_file, root_cause_line, cause_chain,
          stack_trace, tag_context, sql_statement,
          script_name, query_string, http_method, http_referer,
          remote_ip, user_agent, form_data,
          user_id, user_name, user_email,
          cf_context, event_name, environment, cf_engine, server_name,
          email_sent
        ) VALUES (
          <cfqueryparam value="#arguments.diagnostics.ticketId#" cfsqltype="cf_sql_varchar" />,
          <cfqueryparam value="#arguments.diagnostics.errorType#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.errorType)#" />,
          <cfqueryparam value="#arguments.diagnostics.errorMessage#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.errorMessage)#" />,
          <cfqueryparam value="#arguments.diagnostics.errorDetail#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.errorDetail)#" />,
          <cfqueryparam value="#arguments.diagnostics.rootCauseType#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.rootCauseType)#" />,
          <cfqueryparam value="#arguments.diagnostics.rootCauseMessage#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.rootCauseMessage)#" />,
          <cfqueryparam value="#arguments.diagnostics.rootCauseDetail#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.rootCauseDetail)#" />,
          <cfqueryparam value="#arguments.diagnostics.rootCauseFile#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.rootCauseFile)#" />,
          <cfqueryparam value="#arguments.diagnostics.rootCauseLine#" cfsqltype="cf_sql_integer" null="#(NOT isNumeric(arguments.diagnostics.rootCauseLine)) OR (val(arguments.diagnostics.rootCauseLine) EQ 0)#" />,
          <cfqueryparam value="#arguments.diagnostics.causeChain#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.causeChain)#" />,
          <cfqueryparam value="#arguments.diagnostics.stackTrace#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.stackTrace)#" />,
          <cfqueryparam value="#arguments.diagnostics.tagContext#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.tagContext)#" />,
          <cfqueryparam value="#arguments.diagnostics.sqlStatement#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.sqlStatement)#" />,
          <cfqueryparam value="#arguments.diagnostics.scriptName#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.scriptName)#" />,
          <cfqueryparam value="#arguments.diagnostics.queryString#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.queryString)#" />,
          <cfqueryparam value="#arguments.diagnostics.httpMethod#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.httpMethod)#" />,
          <cfqueryparam value="#arguments.diagnostics.httpReferer#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.httpReferer)#" />,
          <cfqueryparam value="#arguments.diagnostics.remoteIp#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.remoteIp)#" />,
          <cfqueryparam value="#arguments.diagnostics.userAgent#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.userAgent)#" />,
          <cfqueryparam value="#arguments.diagnostics.formData#" cfsqltype="cf_sql_longvarchar" null="#NOT len(arguments.diagnostics.formData)#" />,
          <cfqueryparam value="#arguments.diagnostics.userId#" cfsqltype="cf_sql_integer" null="#NOT len(arguments.diagnostics.userId) OR NOT isNumeric(arguments.diagnostics.userId)#" />,
          <cfqueryparam value="#arguments.diagnostics.userName#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.userName)#" />,
          <cfqueryparam value="#arguments.diagnostics.userEmail#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.userEmail)#" />,
          <cfqueryparam value="#arguments.diagnostics.cfContext#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.cfContext)#" />,
          <cfqueryparam value="#arguments.diagnostics.eventName#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.eventName)#" />,
          <cfqueryparam value="#arguments.diagnostics.environment#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.environment)#" />,
          <cfqueryparam value="#arguments.diagnostics.cfEngine#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.cfEngine)#" />,
          <cfqueryparam value="#arguments.diagnostics.serverName#" cfsqltype="cf_sql_varchar" null="#NOT len(arguments.diagnostics.serverName)#" />,
          <cfqueryparam value="0" cfsqltype="cf_sql_tinyint" />
        )
      </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

      <cflog file="TAO_error_tickets" type="error"
             text="Ticket #arguments.diagnostics.ticketId# persisted | #arguments.diagnostics.scriptName# | #Left(arguments.diagnostics.errorMessage, 200)#" />

      <cfreturn true />

      <cfcatch>
        <cflog file="TAO_error_fallback" type="error"
               text="DB persist failed for #arguments.diagnostics.ticketId#: #cfcatch.message# | Original: #Left(arguments.diagnostics.errorMessage, 200)#" />

        <!--- Log full diagnostics to file since DB is unavailable --->
        <cftry>
          <cflog file="TAO_error_fallback" type="error"
                 text="FULL: #arguments.diagnostics.ticketId# | Type=#arguments.diagnostics.errorType# | Script=#arguments.diagnostics.scriptName# | User=#arguments.diagnostics.userId# | #Left(arguments.diagnostics.errorMessage, 500)#" />
          <cfcatch></cfcatch>
        </cftry>

        <cfreturn false />
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="createSupportTicket" access="private" returntype="void" output="false"
              hint="INSERT into tickets table so the error appears in the TAO support ticket system.">
    <cfargument name="diagnostics" type="struct" required="true" />

    <cftry>
      <cfset var ticketName = arguments.diagnostics.ticketId & " - "
          & (len(arguments.diagnostics.rootCauseMessage)
                ? ((len(arguments.diagnostics.rootCauseType) ? arguments.diagnostics.rootCauseType & ": " : "")
                    & Left(arguments.diagnostics.rootCauseMessage, 200))
                : Left(arguments.diagnostics.errorMessage, 200)) />
      <cfset var ticketDetails = "Error Ticket: " & arguments.diagnostics.ticketId />
      <cfif len(arguments.diagnostics.rootCauseMessage)>
        <cfset ticketDetails = ticketDetails
            & chr(10) & "Root Cause Type: "    & arguments.diagnostics.rootCauseType
            & chr(10) & "Root Cause Message: " & Left(arguments.diagnostics.rootCauseMessage, 1000)
            & chr(10) & "Root Cause Detail: "  & Left(arguments.diagnostics.rootCauseDetail, 500)
            & chr(10) & "Root Cause File: "    & arguments.diagnostics.rootCauseFile
            & chr(10) & "Root Cause Line: "    & arguments.diagnostics.rootCauseLine
            & chr(10) & "--- Outer Exception ---" />
      </cfif>
      <cfset ticketDetails = ticketDetails
          & chr(10) & "Type: " & arguments.diagnostics.errorType
          & chr(10) & "Script: " & arguments.diagnostics.scriptName
          & chr(10) & "Query String: " & Left(arguments.diagnostics.queryString, 500)
          & chr(10) & "Message: " & Left(arguments.diagnostics.errorMessage, 1000)
          & chr(10) & "Detail: " & Left(arguments.diagnostics.errorDetail, 500) />
      <cfset var ticketUserId = (len(arguments.diagnostics.userId) AND isNumeric(arguments.diagnostics.userId)) ? val(arguments.diagnostics.userId) : 0 />

      <!---
        Resolve FK values inline so /app/admin-support-details/ INNER JOINs
        on pgpages / taousers_tbl succeed. Without this the ticket lands with
        pgid=0 / userid=0 and the details page throws (ERR-xxxxxxxx loop).
        pgid: prefer the admin-error-tickets page; fall back to any page.
        verid: latest active version (same query Application.cfc uses).
        userid: session user if it resolves; else the lowest userid in taousers_tbl.
      --->
      <cfquery datasource="#variables.dsn#">
        INSERT INTO tickets (
          pgid, verid, ticketName, ticketdetails, tickettype, userid, ticketactive, ticketstring
        )
        SELECT
          COALESCE(
            (SELECT pgid FROM pgpages WHERE pgDir = <cfqueryparam value="admin-error-tickets" cfsqltype="cf_sql_varchar" /> ORDER BY pgid LIMIT 1),
            (SELECT pgid FROM pgpages ORDER BY pgid LIMIT 1)
          ),
          (SELECT verid FROM taoversions ORDER BY isactive DESC, verid DESC LIMIT 1),
          <cfqueryparam value="#Left(ticketName, 255)#" cfsqltype="cf_sql_varchar" />,
          <cfqueryparam value="#ticketDetails#" cfsqltype="cf_sql_longvarchar" />,
          <cfqueryparam value="Error" cfsqltype="cf_sql_varchar" />,
          COALESCE(
            (SELECT userid FROM taousers_tbl WHERE userid = <cfqueryparam value="#ticketUserId#" cfsqltype="cf_sql_integer" /> LIMIT 1),
            (SELECT userid FROM taousers_tbl ORDER BY userid LIMIT 1)
          ),
          <cfqueryparam value="Y" cfsqltype="cf_sql_varchar" />,
          <cfqueryparam value="#Left(arguments.diagnostics.scriptName & '?' & arguments.diagnostics.queryString, 500)#" cfsqltype="cf_sql_varchar" />
      </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

      <cflog file="TAO_error_tickets" type="info"
             text="Support ticket created for #arguments.diagnostics.ticketId#" />

      <cfcatch>
        <cflog file="TAO_error_fallback" type="warning"
               text="Failed to create support ticket for #arguments.diagnostics.ticketId#: #cfcatch.message#" />
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="sendErrorEmail" access="private" returntype="boolean" output="false"
              hint="Renders email template via cfsavecontent, sends via cfmail. Returns true on success.">
    <cfargument name="diagnostics" type="struct" required="true" />

    <cftry>
      <!--- Determine subject prefix and recipient override based on environment --->
      <cfset var subjectPrefix = "[TAO Error]" />
      <cfset var effectiveToEmail = variables.toEmail />
      <cfif NOT findNoCase("app", cgi.SERVER_NAME)>
        <cfset subjectPrefix = "[DEV] [TAO Error]" />
        <!--- Override recipient to developer on non-prod — prevent support inbox noise --->
        <cfset effectiveToEmail = len(variables.bccEmail) ? variables.bccEmail : variables.toEmail />
      </cfif>

      <!--- Build subject line: [TAO Error] ERR-xxxxxxxx -- Type: First 80 chars of message --->
      <cfset var errorTypeLabel = "" />
      <cfif len(arguments.diagnostics.errorType)>
        <cfset errorTypeLabel = arguments.diagnostics.errorType & ": " />
      </cfif>
      <cfset var emailSubject = subjectPrefix & " " & arguments.diagnostics.ticketId
          & " " & chr(8212) & " " & errorTypeLabel & Left(arguments.diagnostics.errorMessage, 80) />

      <!--- Make diagnostics available to template via request scope (thread-safe) --->
      <cfset request._errorDiagnostics = arguments.diagnostics />

      <!--- Render email body from template --->
      <cfsavecontent variable="local.emailBody">
        <cfinclude template="/templates/email/error-ticket.cfm" />
      </cfsavecontent>

      <!--- Clean up request scope --->
      <cfset structDelete(request, "_errorDiagnostics") />

      <!--- Send --->
      <cfmail to="#effectiveToEmail#"
              from="#variables.fromEmail#"
              cc="#variables.ccEmail#"
              bcc="#variables.bccEmail#"
              subject="#emailSubject#"
              type="html"
              usessl="true"
              usetls="true">#local.emailBody#</cfmail>

      <cflog file="TAO_error_tickets" type="info"
             text="Email sent for #arguments.diagnostics.ticketId# to #effectiveToEmail#" />

      <cfreturn true />

      <cfcatch>
        <cflog file="TAO_error_email_fail" type="error"
               text="Email failed for #arguments.diagnostics.ticketId#: #cfcatch.message#" />
        <cfreturn false />
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="isAjaxRequest" access="private" returntype="boolean" output="false"
              hint="Detects AJAX requests via headers, content type, and URL path.">
    <cfscript>
      // X-Requested-With header (jQuery and most AJAX libraries)
      if (structKeyExists(cgi, "HTTP_X_REQUESTED_WITH")
          AND lcase(cgi.HTTP_X_REQUESTED_WITH) eq "xmlhttprequest") {
        return true;
      }
      // Content-Type indicates JSON payload
      if (structKeyExists(cgi, "CONTENT_TYPE")
          AND findNoCase("application/json", cgi.CONTENT_TYPE)) {
        return true;
      }
      // Request path under /ajax/
      if (findNoCase("/ajax/", cgi.SCRIPT_NAME)) {
        return true;
      }
      // Accept header requests JSON response
      if (structKeyExists(cgi, "HTTP_ACCEPT")
          AND findNoCase("application/json", cgi.HTTP_ACCEPT)) {
        return true;
      }
      return false;
    </cfscript>
  </cffunction>

  <cffunction name="redactFormScope" access="private" returntype="string" output="false"
              hint="Serializes FORM scope with sensitive keys redacted.">
    <cfscript>
      var redacted = {};
      var sensitivePattern = "(?i)(password|passwd|pwd|token|csrf|secret|creditcard|cc_|ssn|apikey)";

      try {
        for (var key in form) {
          if (reFindNoCase(sensitivePattern, key)) {
            redacted[key] = "[REDACTED]";
          } else {
            redacted[key] = Left(form[key], 500);
          }
        }
        return serializeJSON(redacted);
      } catch (any e) {
        return "Error reading form scope";
      }
    </cfscript>
  </cffunction>

  <cffunction name="lookupUser" access="private" returntype="struct" output="false"
              hint="Queries taousers for name and email by userId. Returns struct with userName, userEmail.">
    <cfargument name="userId" type="numeric" required="true" />
    <cfset var result = { userName = "", userEmail = "" } />
    <cftry>
      <cfquery name="local.qUser" datasource="#variables.dsn#" maxrows="1">
        SELECT userFirstName, userLastName, userEmail
        FROM taousers
        WHERE userID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer" />
      </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
      <cfif local.qUser.recordCount>
        <cfset result.userName = trim(local.qUser.userFirstName & " " & local.qUser.userLastName) />
        <cfset result.userEmail = local.qUser.userEmail />
      </cfif>
      <cfcatch>
        <cflog file="TAO_error_fallback" type="warning"
               text="lookupUser failed for userId #arguments.userId#: #cfcatch.message#" />
      </cfcatch>
    </cftry>
    <cfreturn result />
  </cffunction>

  <cffunction name="safeSessionRead" access="private" returntype="string" output="false"
              hint="Safely reads a session key. Returns empty string on any failure.">
    <cfargument name="key" type="string" required="true" />
    <cftry>
      <cfif structKeyExists(session, arguments.key)>
        <cfreturn toString(session[arguments.key]) />
      </cfif>
      <cfreturn "" />
      <cfcatch>
        <cfreturn "" />
      </cfcatch>
    </cftry>
  </cffunction>

</cfcomponent>
