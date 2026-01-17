<cfcomponent output="false">
  <!--- Inherit settings from parent /app Application.cfc --->
  <cfset host = ListFirst(cgi.server_name, ".") />

  <cfif host EQ "app">
    <cfset application.dsn = "abo" />
    <cfset application.information_schema = "actorsbusinessoffice" />
  <cfelse>
    <cfset application.dsn = "abod" />
    <cfset application.information_schema = "new_development" />
  </cfif>

  <cfscript>
    this.name = "TAO";
    this.datasource = application.dsn;
    application.datasource = this.datasource;
  </cfscript>
</cfcomponent>
