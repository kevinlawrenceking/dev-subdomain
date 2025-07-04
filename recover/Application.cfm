<cfscript>
    // Get the first part of the server name (subdomain)
    host = ListFirst(cgi.server_name, ".");

    // Determine the datasource based on the host
    if (host == "app" || host == "uat") {
        datasourceName = "abo";
        dsn = "abo";
    } else {
        datasourceName = "abod";
        dsn = "abod";
    }
</cfscript>
