<cfcomponent extends="/app/Application">
  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true">

    <!--- TAO-CAL-01d: initialize request.svc factory before any branch so that
          both localhost-bypass and auth-gated paths have services available.
          Inherited from /app/Application. --->
    <cfset initServiceFactory()>

    <!--- Allow localhost and same-server requests (ColdFusion scheduler) without auth --->
    <cfif CGI.REMOTE_ADDR EQ "127.0.0.1"
          OR CGI.REMOTE_ADDR EQ "::1"
          OR (len(trim(CGI.LOCAL_ADDR)) AND CGI.REMOTE_ADDR EQ CGI.LOCAL_ADDR)>
      <cfset application.datasourceName = application.dsn>
      <cfreturn true>
    </cfif>

    <!--- External requests require authenticated admin session --->
    <cfif NOT structKeyExists(session, "userid")>
      <cfheader statuscode="403">
      <cfabort>
    </cfif>

    <cfset application.datasourceName = application.dsn>
    <cfreturn true>
  </cffunction>
</cfcomponent>