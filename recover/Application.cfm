<cfapplication name="TAO" sessionmanagement="true">
<cfscript>
    // Env routing - set dsn for recover pages
    host = ListFirst(cgi.server_name, ".");
    if (host EQ "app") {
        dsn = "abo";
    } else {
        dsn = "abod";
    }
</cfscript>
