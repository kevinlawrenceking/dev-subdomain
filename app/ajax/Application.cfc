<cfcomponent output="false">
  <cfscript>
    this.name = "TAO"; // must exactly match the main app
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(11, 1, 0, 0);
    this.sessionTimeout = createTimeSpan(0, 9, 20, 0);
    this.setClientCookies = true;
    this.loginStorage = "session";
  </cfscript>

  <cffunction name="onRequestStart" returntype="boolean">
    <cfargument name="targetPage" required="true">
    <cfreturn true>
  </cffunction>

  <cffunction name="onRequest" returntype="void">
    <cfargument name="targetPage" required="true">
    <cfinclude template="#arguments.targetPage#">
  </cffunction>
</cfcomponent>
