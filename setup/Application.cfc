<cfcomponent output="false">

<cfscript>
    // === Application Settings ===
    this.name = "Setup";                          
    this.sessionManagement = true;                
    this.applicationTimeout = createTimeSpan(1,0,0,0);  
    this.sessionTimeout     = createTimeSpan(0,0,30,0); 

    // Compiler settings
    this.searchImplicitScopes = true;   
    this.strictVariables = false;       

    // Get hostname (e.g., "app")
    host = ListFirst(cgi.server_name, ".");

    // Declare local dsn before assigning to this.datasource
    dsn = "";
    information_schema = "";
    suffix = "";

    if (host == "app") {
        dsn = "abo";
        information_schema = "actorsbusinessoffice";
        suffix = "_1.5";
    } else {
        dsn = "abod";
        information_schema = "new_development";
        suffix = "";
    }

    // Assign to this.datasource before using application scope
    this.datasource = dsn;

    // Now set application scope vars
    application.dsn = dsn;
    application.information_schema = information_schema;
    application.suffix = suffix;

    application.dbug = "N";
    application.baseMediaPath = "C:\home\theactorsoffice.com\media-" & this.datasource;
    application.baseMediaUrl = "/media-" & this.datasource;
    application.auditionimporttemplate = application.baseMediaUrl & "/auditionimporttemplates.xlsx";
    application.imagesPath = application.baseMediaPath & "\images";
    application.imagesUrl = application.baseMediaUrl & "/images";
</cfscript>


<!--- Application lifecycle events --->

<cffunction name="onApplicationStart" returntype="boolean" output="false">
    <cfreturn true>
</cffunction>

<cffunction name="onRequestStart" returntype="boolean" output="false">
    <cfargument name="targetPage" type="string" required="true">
    <cfreturn true>
</cffunction>

</cfcomponent>
