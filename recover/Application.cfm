<cfscript>
    // Env routing - set dsn as a Variables-scope variable
    // available to index.cfm and setup2.cfm in the same request
    host = ListFirst(cgi.server_name, ".");
    if (host EQ "app") {
        dsn = "abo";
    } else {
        dsn = "abod";
    }
</cfscript>
