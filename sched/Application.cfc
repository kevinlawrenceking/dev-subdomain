<cfcomponent extends="/app/Application">
  <cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true">

    <!--- Allow localhost (ColdFusion scheduler) without auth --->
    <cfif CGI.REMOTE_ADDR EQ "127.0.0.1" OR CGI.REMOTE_ADDR EQ "::1">
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