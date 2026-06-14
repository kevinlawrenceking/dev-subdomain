<!---
    PURPOSE: Run the per-user enum heal across ALL active users.
             Output is one row per user: name + total records added.
    AUTHOR:  Kevin King
    USAGE:   /setup/ensure_all_users.cfm           (HTML summary)
             /setup/ensure_all_users.cfm?json=1    (JSON summary)
    SECURITY: Admin only -- this provisions every user.
--->
<cfparam name="url.json" default="0">

<!--- Bulk run over every user can take a while; lift the request timeout. --->
<cfsetting requesttimeout="900">

<!--- Admin guard. Role is NOT in session (login only sets userid/userLoggedIn),
      so look it up in taousers.userRole -- same rule as app/admin-users/admin-guard.cfm. --->
<cfif not structKeyExists(session, "userid") or not val(session.userid)>
    <cflocation url="/app/" addtoken="false">
</cfif>
<cfquery name="qRole" datasource="#application.dsn#" maxrows="1">
    SELECT userRole FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
</cfquery>
<cfif not (qRole.recordCount AND (qRole.userRole EQ "Admin" OR qRole.userRole EQ "Administrator"))>
    <cflocation url="/app/" addtoken="false">
</cfif>

<!--- Active users (matches setup-verification.cfm) --->
<cfquery name="getAllUsers" datasource="#application.dsn#">
    SELECT userid,
           CONCAT(userfirstname, ' ', userlastname) AS fullname
    FROM taousers
    WHERE userstatus = 'Active'
    ORDER BY userlastname, userfirstname
</cfquery>

<cfset svc = new services.SetupProvisioningService()>
<cfset rows = []>
<cfset grandTotal = 0>

<cfloop query="getAllUsers">
    <cftry>
        <cfset r = svc.ensureUserRecords(getAllUsers.userid)>
        <cfset added = r.data.totalInserted>
        <cfset arrayAppend(rows, {
            userid   = getAllUsers.userid,
            fullname = getAllUsers.fullname,
            added    = added,
            complete = r.data.complete,
            issues   = arrayLen(r.data.issues),
            ok       = r.success
        })>
        <cfset grandTotal += added>
        <cfcatch type="any">
            <cfset arrayAppend(rows, {
                userid   = getAllUsers.userid,
                fullname = getAllUsers.fullname,
                added    = 0,
                complete = false,
                issues   = -1,
                ok       = false,
                error    = cfcatch.message
            })>
        </cfcatch>
    </cftry>
</cfloop>

<cfset summary = { totalUsers = arrayLen(rows), grandTotalAdded = grandTotal, users = rows }>

<!--- JSON mode --->
<cfif val(url.json) eq 1>
    <cfcontent type="application/json; charset=utf-8" reset="true">
    <cfoutput>#serializeJSON(summary)#</cfoutput>
    <cfabort>
</cfif>

<!--- HTML summary --->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ensure Records - All Users | TAO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        td.num { text-align:right; }
        .added-pos { color:#198754; font-weight:700; }
        .row-issue { background:#fff5f5; }
    </style>
</head>
<body>
<cfoutput>
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="h4 mb-0">Ensure User Records &mdash; All Active Users
            <small class="text-muted">(#application.dsn#)</small></h1>
        <a href="/app/admin-users/setup-verification.cfm" class="btn btn-outline-secondary btn-sm">Full Matrix</a>
    </div>

    <div class="alert alert-info">
        Processed <strong>#summary.totalUsers#</strong> user(s).
        Total records added this run: <strong>#summary.grandTotalAdded#</strong>.
    </div>

    <table class="table table-sm table-striped table-hover align-middle">
        <thead class="table-dark">
            <tr>
                <th>User</th>
                <th class="text-end">User ID</th>
                <th class="text-end">Records Added</th>
                <th>Result</th>
            </tr>
        </thead>
        <tbody>
            <cfloop array="#summary.users#" index="u">
                <tr <cfif not u.complete or not u.ok>class="row-issue"</cfif>>
                    <td>#encodeForHTML(u.fullname)#</td>
                    <td class="num">#u.userid#</td>
                    <td class="num"><cfif u.added GT 0><span class="added-pos">+#u.added#</span><cfelse>0</cfif></td>
                    <td>
                        <cfif not u.ok>
                            <span class="badge bg-danger">FAILED</span>
                            <cfif structKeyExists(u, "error")><small class="text-muted">#encodeForHTML(u.error)#</small></cfif>
                        <cfelseif u.complete>
                            <span class="badge bg-success">Complete</span>
                        <cfelse>
                            <span class="badge bg-warning text-dark">#u.issues# table(s) flagged</span>
                        </cfif>
                    </td>
                </tr>
            </cfloop>
        </tbody>
        <tfoot>
            <tr class="table-light">
                <th colspan="2" class="text-end">Grand total added:</th>
                <th class="num">#summary.grandTotalAdded#</th>
                <th></th>
            </tr>
        </tfoot>
    </table>

    <p class="text-muted small">Idempotent &mdash; re-running adds nothing when users are already fully provisioned.</p>
</div>
</cfoutput>
</body>
</html>
