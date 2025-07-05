<cfcomponent extends="/app/Application">
  <cffunction name="onRequestStart" returntype="void" output="false">
        <cfscript>
            // Use datasource from parent Application.cfc
            application.datasourceName = application.dsn;
            application.dsn = application.dsn;
        </cfscript>
    </cffunction>

    </cfcomponent>