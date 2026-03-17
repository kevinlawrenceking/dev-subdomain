<cfcomponent extends="/app/Application">
  <cffunction name="onRequestStart" returntype="void" output="false">
    <cfargument name="targetPage" type="string" required="false" default="" />
    <cfscript>
      // Use datasource from parent Application.cfc
      application.datasourceName = application.dsn;
      application.dsn = application.dsn;
    </cfscript>

    <!--- CSRF validation for POST requests from authenticated users --->
    <cfif cgi.REQUEST_METHOD EQ "POST" AND structKeyExists(session, "csrfToken")>
      <cfset var submittedToken = "">
      <cfif structKeyExists(form, "csrfToken")>
        <cfset submittedToken = form.csrfToken>
      </cfif>
      <cfif NOT len(trim(submittedToken)) OR NOT CSRFVerifyToken(submittedToken)>
        <cflog file="tao_csrf" type="warning"
               text="CSRF form POST rejected: #cgi.SCRIPT_NAME# | userid=#structKeyExists(session,'userid') ? session.userid : 'none'#">
        <cfheader statuscode="403">
        <cfcontent type="text/html" reset="true">
        <cfoutput>
          <!DOCTYPE html><html><head><title>Access Denied</title>
          <style>body{font-family:Arial,sans-serif;text-align:center;padding:60px 20px;color:##333}
          h2{font-size:22px}p{font-size:15px;color:##666}a{color:##2563eb}</style></head>
          <body><h2>Security token missing or invalid</h2>
          <p>Your form submission could not be verified. Please go back and try again.</p>
          <p><a href="javascript:history.back()">Go Back</a></p>
          </body></html>
        </cfoutput>
        <cfabort>
      </cfif>
    </cfif>
  </cffunction>
</cfcomponent>