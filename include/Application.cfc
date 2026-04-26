<cfcomponent extends="/app/Application">
  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="false" default="" />

    <cfscript>
      // Use datasource from parent Application.cfc
      application.datasourceName = application.dsn;
      application.dsn = application.dsn;
    </cfscript>

    <!--- PERF: Request-scoped service cache (matches app/Application.cfc) --->
    <cfset request.services = {} />
    <cfset request.svc = function(required string name) {
        if (!structKeyExists(request.services, arguments.name)) {
            request.services[arguments.name] = createObject("component", "services." & arguments.name);
        }
        return request.services[arguments.name];
    } />

    <!--- CSRF validation for POST requests from authenticated users --->
    <!--- Accept token from form field (regular forms) OR X-CSRF-Token header (AJAX) --->
    <cfif cgi.REQUEST_METHOD EQ "POST" AND structKeyExists(session, "csrfToken")>
      <cfset var submittedToken = "">
      <cfif structKeyExists(form, "csrfToken")>
        <cfset submittedToken = form.csrfToken>
      <cfelseif len(trim(cgi.HTTP_X_CSRF_TOKEN))>
        <cfset submittedToken = cgi.HTTP_X_CSRF_TOKEN>
      </cfif>
      <!--- Two-tier verify: direct session compare first (reliable even when ACF
            has rotated/evicted the token from its internal CSRF store), fall back
            to CF CSRF engine. Mirrors /app/Application.cfc:402-408 and
            /ajax/Application.cfc:111-119. --->
      <cfset var csrfValid = false>
      <cfif len(trim(submittedToken))>
        <cfif submittedToken EQ session.csrfToken>
          <cfset csrfValid = true>
        <cfelseif CSRFVerifyToken(submittedToken)>
          <cfset csrfValid = true>
        </cfif>
      </cfif>
      <cfif NOT csrfValid>
        <cflog file="tao_csrf" type="warning"
               text="CSRF form POST rejected: #cgi.SCRIPT_NAME# | userid=#structKeyExists(session,'userid') ? session.userid : 'none'#">
        <cfheader statuscode="403">
        <cfcontent type="text/html" reset="true">
        <cfoutput>
          <!DOCTYPE html><html><head><title>Access Denied</title></head>
          <body>
          <div style="font-family:Arial,sans-serif;text-align:center;padding:60px 20px;color:##333">
          <h2 style="font-size:22px">Security token missing or invalid</h2>
          <p style="font-size:15px;color:##666">Your form submission could not be verified. Please go back and try again.</p>
          <p><a href="javascript:history.back()" style="color:##2563eb">Go Back</a></p>
          </div>
          </body></html>
        </cfoutput>
        <cfabort>
      </cfif>
    </cfif>

    <cfreturn true />
  </cffunction>
</cfcomponent>