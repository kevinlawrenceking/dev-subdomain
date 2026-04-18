<!---
TAO-SPEC-2026-005 Phase 2c: ErrorService rootCause smoke test
Throws three shaped exceptions so ErrorService.unwrapCauseChain runs against
each code path. Dev-only — refuses to run on the prod DSN.

Access: /app/admin-error-test/?mode=query  (default)
                                 ?mode=expression
                                 ?mode=nested

Each request produces one error_tickets row and one tickets row. Inspect with
/database/verification/2026-04-17_phase_2c_verification.sql.
--->

<!--- DSN gate: only run against new_development --->
<cfif NOT structKeyExists(application, "dsn") OR application.dsn NEQ "abod">
    <cfoutput><h1>Disabled</h1><p>This smoke-test page is only available on the dev DSN (abod). Current DSN: #structKeyExists(application,"dsn") ? application.dsn : "(unset)"#.</p></cfoutput>
    <cfabort />
</cfif>

<!--- Admin role check — same pattern as /app/admin-error-tickets/ --->
<cfif NOT isDefined("userRole") OR (userRole NEQ "Admin" AND userRole NEQ "Administrator")>
    <cflocation url="/app/dashboard_new/" addtoken="false" />
</cfif>

<cfparam name="url.mode" default="query" />
<cfset mode = lcase(trim(url.mode)) />

<cfif NOT listFindNoCase("query,expression,nested,index", mode)>
    <cfset mode = "index" />
</cfif>

<!--- Landing page — pick a mode --->
<cfif mode EQ "index">
    <!DOCTYPE html>
    <html>
    <head>
        <title>Error Capture Smoke Test | TAO Admin</title>
        <link href="/app/assets/css/bootstrap.css" rel="stylesheet" />
        <style>
            body { background: #f5f6fa; padding: 30px; font-family: sans-serif; }
            .card { background: #fff; border-radius: 8px; padding: 20px; max-width: 720px; margin: 0 auto; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
            h1 { margin-top: 0; }
            .mode { border: 1px solid #ddd; border-radius: 6px; padding: 15px; margin-bottom: 12px; }
            .mode a { font-weight: bold; }
            .muted { color: #666; font-size: 0.9rem; }
            .warn { background: #fff3cd; border-color: #ffeeba; color: #856404; padding: 10px; border-radius: 6px; margin-bottom: 20px; }
        </style>
    </head>
    <body>
        <div class="card">
            <h1>ErrorService rootCause smoke test</h1>
            <div class="warn">
                <strong>Dev only.</strong> Each link below throws a real uncaught exception.
                ErrorService will record one row in <code>error_tickets</code> and one row in <code>tickets</code>.
                Run the verification SQL after each click.
            </div>

            <div class="mode">
                <a href="?mode=query">mode=query</a>
                <div class="muted">Runs a cfquery against a non-existent column. Produces a rich rootCause with type, message, file, line from the JDBC driver.</div>
            </div>

            <div class="mode">
                <a href="?mode=expression">mode=expression</a>
                <div class="muted">References an undefined scope variable. Exercises the fallback path — rootCause may be thin or absent, so diag.rootCause* should be empty strings / 0.</div>
            </div>

            <div class="mode">
                <a href="?mode=nested">mode=nested</a>
                <div class="muted">Catches one exception, throws a new one with <code>object=cfcatch</code>. Forces unwrapCauseChain to walk at least one level; depth should be &gt;= 1.</div>
            </div>
        </div>
    </body>
    </html>
    <cfabort />
</cfif>

<!--- =============================================================== --->
<!--- MODE: query — SQL exception with rich rootCause                 --->
<!--- =============================================================== --->
<cfif mode EQ "query">
    <cflog file="TAO_error_smoketest" type="info"
           text="Smoke test mode=query initiated by userid=#(isDefined('session.userid') ? session.userid : 'unknown')#" />
    <cfquery datasource="#application.dsn#">
        SELECT this_column_does_not_exist_smoketest
        FROM taoversions
        LIMIT 1
    </cfquery>
</cfif>

<!--- =============================================================== --->
<!--- MODE: expression — undefined scope, thin or no rootCause        --->
<!--- =============================================================== --->
<cfif mode EQ "expression">
    <cflog file="TAO_error_smoketest" type="info"
           text="Smoke test mode=expression initiated by userid=#(isDefined('session.userid') ? session.userid : 'unknown')#" />
    <cfset forced = undefinedScope.undefinedKey.somethingElse />
</cfif>

<!--- =============================================================== --->
<!--- MODE: nested — catch + re-throw with object=cfcatch              --->
<!--- =============================================================== --->
<cfif mode EQ "nested">
    <cflog file="TAO_error_smoketest" type="info"
           text="Smoke test mode=nested initiated by userid=#(isDefined('session.userid') ? session.userid : 'unknown')#" />
    <cftry>
        <cfquery datasource="#application.dsn#">
            SELECT smoketest_inner_missing_col
            FROM taoversions
            LIMIT 1
        </cfquery>
        <cfcatch type="any">
            <cfthrow type="TAO.SmokeTest.Nested"
                     message="Outer wrapper for nested smoke test"
                     detail="See rootCause for the underlying JDBC failure"
                     object="#cfcatch#" />
        </cfcatch>
    </cftry>
</cfif>
