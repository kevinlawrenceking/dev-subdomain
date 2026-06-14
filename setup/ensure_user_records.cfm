<!---
    PURPOSE: Diagnostic / repair endpoint for per-user enum tables.
             Takes a single userid, runs SetupProvisioningService.ensureUserRecords,
             and renders a master-vs-user matrix (or JSON with ?json=1).
    AUTHOR:  Kevin King
    USAGE:   /setup/ensure_user_records.cfm?userid=30          (HTML matrix)
             /setup/ensure_user_records.cfm?userid=30&json=1   (JSON result)
    SECURITY: Requires an authenticated session. Non-admins may only repair
              their own account; admins may repair any userid.
--->
<cfparam name="url.userid" default="0">
<cfparam name="url.json"   default="0">

<!--- Heal can touch many tables; give it effectively unlimited time. --->
<cfsetting requesttimeout="86400">

<!--- Auth guard --->
<cfif not structKeyExists(session, "userid") or not val(session.userid)>
    <cflocation url="/app/" addtoken="false">
</cfif>

<!--- Role is NOT in session (login only sets userid/userLoggedIn); look it up
      in taousers.userRole -- same rule as app/admin-users/admin-guard.cfm. --->
<cfquery name="qRole" datasource="#application.dsn#" maxrows="1">
    SELECT userRole FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
</cfquery>
<cfset isAdmin = qRole.recordCount and (qRole.userRole eq "Admin" or qRole.userRole eq "Administrator")>
<cfset targetUserid = val(url.userid)>

<!--- Non-admins can only heal themselves; default to self when unspecified --->
<cfif not isAdmin or targetUserid eq 0>
    <cfset targetUserid = val(session.userid)>
</cfif>

<cfset svc = new services.SetupProvisioningService()>
<cfset result = svc.ensureUserRecords(targetUserid)>

<!--- JSON mode --->
<cfif val(url.json) eq 1>
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<!--- HTML matrix --->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ensure User Records | TAO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .st-OK    { color:#198754; font-weight:600; }
        .st-SHORT { color:#fd7e14; font-weight:600; }
        .st-EMPTY { color:#dc3545; font-weight:700; }
        .st-ERROR { color:#fff; background:#dc3545; padding:0 .35rem; border-radius:.2rem; }
        td.num    { text-align:right; }
    </style>
</head>
<body>
<cfoutput>
<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="h4 mb-0">Ensure User Records &mdash; userid #result.data.userid#
            <small class="text-muted">(#result.data.dsn#)</small></h1>
        <a href="/app/admin-users/setup-verification.cfm" class="btn btn-outline-secondary btn-sm">Full Matrix</a>
    </div>

    <div class="alert <cfif result.success and result.data.complete>alert-success<cfelseif result.success>alert-warning<cfelse>alert-danger</cfif>">
        <strong>#encodeForHTML(result.message)#</strong>
    </div>

    <table class="table table-sm table-striped table-hover align-middle">
        <thead class="table-dark">
            <tr>
                <th>Table</th>
                <th>Description</th>
                <th class="text-end">Master</th>
                <th class="text-end">Before</th>
                <th class="text-end">Inserted</th>
                <th class="text-end">After</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <cfloop array="#result.data.matrix#" index="row">
                <tr>
                    <td><code>#row.table#</code></td>
                    <td>#row.description#</td>
                    <td class="num">#(row.master EQ -1 ? "ERR" : row.master)#</td>
                    <td class="num">#(row.before EQ -1 ? "ERR" : row.before)#</td>
                    <td class="num"><cfif row.inserted GT 0><strong>+#row.inserted#</strong><cfelse>0</cfif></td>
                    <td class="num">#(row.after EQ -1 ? "ERR" : row.after)#</td>
                    <td><span class="st-#row.status#">#row.status#</span></td>
                </tr>
            </cfloop>
        </tbody>
        <tfoot>
            <tr class="table-light">
                <th colspan="4" class="text-end">Total inserted this run:</th>
                <th class="num">#result.data.totalInserted#</th>
                <th colspan="2"></th>
            </tr>
        </tfoot>
    </table>

    <p class="text-muted small">
        Status key: <span class="st-OK">OK</span> populated &middot;
        <span class="st-SHORT">SHORT</span> fewer than master &middot;
        <span class="st-EMPTY">EMPTY</span> no records &middot;
        <span class="st-ERROR">ERROR</span> table/query failed.
        Re-run safely &mdash; inserts are idempotent.
    </p>
</div>
</cfoutput>
</body>
</html>
