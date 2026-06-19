<!---
    PURPOSE: Run the per-user enum heal across ALL active users.
             Output is one row per user: name + total records added.
    AUTHOR:  Kevin King
    USAGE:   /setup/ensure_all_users.cfm              (HTML summary; skips already-complete users)
             /setup/ensure_all_users.cfm?json=1       (JSON summary)
             /setup/ensure_all_users.cfm?force=1      (heal EVERY user, even complete ones)
    SECURITY: Admin only -- this provisions every user.
    NOTE:    By default already-complete users are skipped after a cheap count
             check, so a re-run after a timeout finishes the remaining users fast.
--->
<cfparam name="url.json"  default="0">
<cfparam name="url.force" default="0">
<!--- Optional batch cap. ?limit=N processes only the first N active users
      (by name). On a normal run already-complete users are skipped cheaply,
      so re-running drains the rest; use ?limit for a bounded test run or to
      chunk a large cold backlog and avoid the request timeout seen in prod. --->
<cfparam name="url.limit" default="0">

<cfset skipComplete = (val(url.force) NEQ 1)>
<cfset batchLimit   = max(0, int(val(url.limit)))>

<!--- Bulk run over every user can take a while; lift the request timeout. --->
<cfsetting requesttimeout="86400">

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

<!--- Defaults so the output blocks below are always safe, even if we never
      acquire the lock (a heal is already running). --->
<cfset rows = []>
<cfset grandTotal = 0>
<cfset skippedCount = 0>
<cfset gotLock = false>

<!--- ANTI-OVERLAP LOCK. This provisions every active user and can run long;
      two admins (or a re-fired run) healing the same users at once duplicates
      work and races on inserts. An exclusive named lock with a short acquire
      timeout makes the second caller bow out immediately. --->
<cflock name="setup_ensure_all_users" type="exclusive" timeout="3" throwontimeout="false">
<cfset gotLock = true>

<!--- Active users (matches setup-verification.cfm) --->
<cfquery name="getAllUsers" datasource="#application.dsn#">
    SELECT userid,
           CONCAT(userfirstname, ' ', userlastname) AS fullname
    FROM taousers
    WHERE userstatus = 'Active'
    ORDER BY userlastname, userfirstname
    <cfif batchLimit GT 0>
        LIMIT <cfqueryparam value="#batchLimit#" cfsqltype="cf_sql_integer">
    </cfif>
</cfquery>

<cfset svc = new services.SetupProvisioningService()>

<cfloop query="getAllUsers">
    <cftry>
        <cfset r = svc.ensureUserRecords(getAllUsers.userid, skipComplete)>
        <cfset added = r.data.totalInserted>
        <cfset wasSkipped = structKeyExists(r.data, "skipped") AND r.data.skipped>
        <cfif wasSkipped><cfset skippedCount++></cfif>
        <cfset arrayAppend(rows, {
            userid   = getAllUsers.userid,
            fullname = getAllUsers.fullname,
            added    = added,
            complete = r.data.complete,
            issues   = arrayLen(r.data.issues),
            ok       = r.success,
            skipped  = wasSkipped
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
                skipped  = false,
                error    = cfcatch.message
            })>
        </cfcatch>
    </cftry>
</cfloop>

</cflock><!--- release anti-overlap lock --->

<!--- Overlap: another heal already holds the lock. Report it instead of
      running a second concurrent pass. --->
<cfif NOT gotLock>
    <cflog file="setup_ensure_all_users" type="warning"
           text="SKIPPED ensure_all_users -- another run is already in progress.">
    <cfif val(url.json) eq 1>
        <cfcontent type="application/json; charset=utf-8" reset="true">
        <cfoutput>{"success":false,"status":"skipped","reason":"overlap","message":"Another ensure-all-users run is already in progress."}</cfoutput>
    <cfelse>
        <cfcontent type="text/html; charset=utf-8" reset="true">
        <cfoutput><!DOCTYPE html><html><head><meta charset="utf-8"><title>Run in progress</title></head><body style="font-family:sans-serif;padding:40px"><h1 style="font-size:20px">Another run is already in progress</h1><p>An ensure-all-users heal is currently running. Please wait for it to finish, then refresh.</p></body></html></cfoutput>
    </cfif>
    <cfabort>
</cfif>

<cfset summary = {
    totalUsers      = arrayLen(rows),
    grandTotalAdded = grandTotal,
    skippedComplete = skippedCount,
    healed          = arrayLen(rows) - skippedCount,
    batchLimit      = batchLimit,
    users           = rows
}>

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
        Processed <strong>#summary.totalUsers#</strong> user(s):
        <strong>#summary.healed#</strong> healed,
        <strong>#summary.skippedComplete#</strong> already complete (skipped).
        Total records added this run: <strong>#summary.grandTotalAdded#</strong>.
        <cfif val(url.force) EQ 1><span class="badge bg-dark">force mode: healed all</span></cfif>
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
                        <cfelseif u.skipped>
                            <span class="badge bg-secondary">Skipped (already complete)</span>
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
