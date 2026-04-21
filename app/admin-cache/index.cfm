<!---
Admin cache clear utility.
Flushes CF caches without restarting the CF server:
  1. Query cache (cfquery cachedwithin results)
  2. ehcache "object" and "template" regions
  3. Application scope (applicationStop -> onApplicationStart reruns next request)
  4. Trusted Template class cache (optional; requires CF Admin password)
Access: /app/admin-cache/
--->

<!--- Admin guard: DB lookup on session userid so this page is self-contained. --->
<cfif NOT structKeyExists(session, "userid")>
    <cflocation url="/app/" addtoken="false" />
</cfif>

<cfquery name="roleCheck" datasource="#application.dsn#" maxrows="1">
    SELECT userRole
    FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer" />
</cfquery>

<cfif roleCheck.recordCount EQ 0
      OR (roleCheck.userRole NEQ "Admin" AND roleCheck.userRole NEQ "Administrator")>
    <cflocation url="/app/" addtoken="false" />
</cfif>

<cfset results = []>
<cfset didRun = false>

<cfif cgi.REQUEST_METHOD EQ "POST">
    <cfset didRun = true>

    <!--- 1) Query cache --->
    <cftry>
        <cfobjectcache action="clear">
        <cfset arrayAppend(results, {step:"Query cache", status:"cleared", detail:"cfobjectcache action=clear"})>
        <cfcatch>
            <cfset arrayAppend(results, {step:"Query cache", status:"error", detail:cfcatch.message})>
        </cfcatch>
    </cftry>

    <!--- 2a) ehcache object region --->
    <cftry>
        <cfset cacheRemoveAll("object")>
        <cfset arrayAppend(results, {step:"ehcache: object region", status:"cleared", detail:"cacheRemoveAll(object)"})>
        <cfcatch>
            <cfset arrayAppend(results, {step:"ehcache: object region", status:"error", detail:cfcatch.message})>
        </cfcatch>
    </cftry>

    <!--- 2b) ehcache template region --->
    <cftry>
        <cfset cacheRemoveAll("template")>
        <cfset arrayAppend(results, {step:"ehcache: template region", status:"cleared", detail:"cacheRemoveAll(template)"})>
        <cfcatch>
            <cfset arrayAppend(results, {step:"ehcache: template region", status:"error", detail:cfcatch.message})>
        </cfcatch>
    </cftry>

    <!--- 3) Trusted Template class cache (optional) --->
    <cfif structKeyExists(form, "cfAdminPassword") AND len(trim(form.cfAdminPassword))>
        <cftry>
            <cfset adminApi = createObject("component", "CFIDE.adminapi.administrator")>
            <cfset adminApi.login(trim(form.cfAdminPassword))>
            <cfset cfRuntime = createObject("component", "CFIDE.adminapi.runtime")>
            <cfset cfRuntime.clearTrustedCache()>
            <cfset arrayAppend(results, {step:"Trusted Template Cache", status:"cleared", detail:"CFIDE.adminapi.runtime.clearTrustedCache()"})>
            <cfcatch>
                <cfset arrayAppend(results, {step:"Trusted Template Cache", status:"error", detail:cfcatch.message})>
            </cfcatch>
        </cftry>
    <cfelse>
        <cfset arrayAppend(results, {step:"Trusted Template Cache", status:"skipped", detail:"no CF Admin password supplied"})>
    </cfif>

    <cflog file="TAO_cache_clear" type="information"
           text="Admin cache clear by userid=#session.userid# | steps=#arrayLen(results)#" />

    <!--- 4) Application scope: do LAST so any application.* reads above still work --->
    <cftry>
        <cfset applicationStop()>
        <cfset arrayAppend(results, {step:"Application scope", status:"cleared", detail:"applicationStop(); onApplicationStart reruns on next request"})>
        <cfcatch>
            <cfset arrayAppend(results, {step:"Application scope", status:"error", detail:cfcatch.message})>
        </cfcatch>
    </cftry>
</cfif>

<cfparam name="session.csrfToken" default="">
<!DOCTYPE html>
<html>
<head>
    <title>Clear CF Caches | TAO Admin</title>
    <link href="/app/assets/css/bootstrap.css" rel="stylesheet" />
    <cfoutput><meta name="csrf-token" content="#session.csrfToken#"></cfoutput>
    <style>
        body { background:##f5f6fa; padding:30px; font-family: -apple-system, Segoe UI, sans-serif; }
        .card { background:##fff; border-radius:8px; padding:22px 26px; max-width:780px; margin:0 auto; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
        h1 { margin-top:0; font-size:22px; }
        .muted { color:##666; font-size:0.9rem; }
        .note { background:##eef5ff; border:1px solid ##c9dcf7; padding:10px 12px; border-radius:6px; margin:14px 0; font-size:0.92rem; }
        .warn { background:##fff3cd; border:1px solid ##ffeeba; color:##856404; padding:10px 12px; border-radius:6px; margin:14px 0; font-size:0.92rem; }
        table { width:100%; border-collapse:collapse; margin-top:14px; }
        th, td { padding:8px 10px; border-bottom:1px solid ##eee; text-align:left; font-size:0.92rem; vertical-align:top; }
        th { background:##fafbfd; }
        .s-cleared { color:##1a7f37; font-weight:600; }
        .s-skipped { color:##8a6d3b; }
        .s-error { color:##b42318; font-weight:600; }
        input[type=password] { width:100%; padding:8px; border:1px solid ##ccc; border-radius:4px; font-size:0.95rem; }
        button { background:##2563eb; color:##fff; border:0; padding:10px 18px; border-radius:6px; font-size:0.95rem; cursor:pointer; }
        button:hover { background:##1d4ed8; }
        code { background:##f3f4f6; padding:1px 5px; border-radius:3px; font-size:0.88em; }
    </style>
</head>
<body>
<div class="card">
    <h1>Clear ColdFusion Caches</h1>
    <p class="muted">Flushes cached state without restarting the CF server.</p>

    <cfif didRun>
        <h3 style="margin-top:20px;font-size:16px;">Result</h3>
        <table>
            <thead><tr><th>Step</th><th>Status</th><th>Detail</th></tr></thead>
            <tbody>
                <cfoutput>
                <cfloop array="#results#" index="r">
                    <tr>
                        <td>#htmlEditFormat(r.step)#</td>
                        <td class="s-#r.status#">#r.status#</td>
                        <td class="muted">#htmlEditFormat(r.detail)#</td>
                    </tr>
                </cfloop>
                </cfoutput>
            </tbody>
        </table>
        <p class="muted" style="margin-top:16px;">
            Application scope has been stopped. The next request to any TAO page reruns
            <code>onApplicationStart</code> and rebuilds <code>application.services</code>,
            feature flags, and secrets from scratch.
        </p>
    </cfif>

    <form method="POST" action="/app/admin-cache/" style="margin-top:20px;">
        <cfoutput><input type="hidden" name="csrfToken" value="#session.csrfToken#" /></cfoutput>

        <div class="note">
            <strong>What runs:</strong>
            <ol style="margin:6px 0 0 18px;padding:0;">
                <li>Query cache (<code>cfobjectcache</code>)</li>
                <li>ehcache <code>object</code> + <code>template</code> regions</li>
                <li>Trusted Template class cache (optional, only if password supplied)</li>
                <li>Application scope (<code>applicationStop()</code>)</li>
            </ol>
        </div>

        <div class="warn">
            <strong>Trusted Template Cache:</strong> only needed if CF Admin &rarr; Server Settings &rarr; Caching &rarr;
            "Trusted Cache" is <em>enabled</em>. On dev the cleaner fix is to uncheck that box so edits are picked up
            automatically — the "maximum number of cached templates" setting does not govern this. If Trusted Cache must
            stay on, paste your CF Admin password below.
        </div>

        <label for="cfAdminPassword" style="display:block;margin-top:12px;font-size:0.9rem;">CF Admin password (optional)</label>
        <input type="password" id="cfAdminPassword" name="cfAdminPassword" autocomplete="new-password" placeholder="leave blank to skip trusted cache" />

        <div style="margin-top:18px;">
            <button type="submit">Clear caches now</button>
        </div>
    </form>
</div>
</body>
</html>
