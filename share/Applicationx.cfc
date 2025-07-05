<cfcomponent extends="/app/Application">
    <!--- This Application.cfc acts as a proxy to the main Application.cfc in /app --->

  <cffunction name="onRequestStart" returntype="void" output="false">
        <cfscript>
            // Use datasource configured in Application.cfc
            this.datasource = application.dsn;
            application.datasourceName = application.dsn;
            application.dsn = application.dsn;
            application.baseMediaPath = "C:\home\theactorsoffice.com\media-" & this.datasource;
            application.baseMediaUrl = "/media-" & this.datasource;
        </cfscript>
    </cffunction>

    </cfcomponent>