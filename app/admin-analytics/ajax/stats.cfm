<!---
    TAO-ADMIN-ANALYTICS-01 -- Admin Activity Analytics data endpoint (read-only JSON).
    Admin-gated on its own; pg_comps governs page nav only, NOT this endpoint.
    GET app/admin-analytics/ajax/stats.cfm?range=30d|90d|12m|all
    // MIGRATE: maps to a Go handler behind RequireAdmin middleware.
--->
<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<!--- 1) Authn (parent app/Application.cfc redirects anonymous page loads; AJAX returns JSON). --->
<cfif NOT structKeyExists(session, "userid")>
    <cfheader statuscode="401">
    <cfoutput>#serializeJSON({ "success": false, "message": "Authentication required." })#</cfoutput>
    <cfabort>
</cfif>

<!--- 2) Authz: admin only. AJAX context has no fetchUsers, so query the role directly. --->
<cfquery name="qAdmin" datasource="#application.dsn#" maxrows="1">
    SELECT userRole FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
</cfquery>
<cfif qAdmin.recordCount EQ 0
      OR (qAdmin.userRole NEQ "Admin" AND qAdmin.userRole NEQ "Administrator")>
    <cfheader statuscode="403">
    <cfoutput>#serializeJSON({ "success": false, "message": "Administrator access required." })#</cfoutput>
    <cfabort>
</cfif>

<!--- 3) Whitelist the only input. --->
<cfparam name="url.range" default="90d">
<cfif NOT ListFindNoCase("30d,90d,12m,all", url.range)>
    <cfheader statuscode="400">
    <cfoutput>#serializeJSON({ "success": false, "message": "Invalid range." })#</cfoutput>
    <cfabort>
</cfif>

<!--- 4) Build read-only payload. Service obtained by direct instantiation (mirrors app/admin-users/ajax/*). --->
<cftry>
    <cfset svc = createObject("component", "services.AnalyticsService").init()>
    <cfset rng = svc.resolveRange(url.range)>
    <cfset payload = {
        "range":  rng.publicView,
        "totals": svc.getTotals(rng.from, rng.toExcl, rng.isAll),
        "series": svc.getActivitySeries(rng.from, rng.toExcl, rng.isAll),
        "meta": {
            "generatedAt": dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss"),
            "remindersTrendCaveat": "Trend reflects reminders with a recorded completion date."
        }
    }>
    <cfoutput>#serializeJSON({ "success": true, "message": "", "data": payload })#</cfoutput>
<cfcatch type="any">
    <cflog file="TAO_analytics" type="error"
           text="stats.cfm failed | user=#structKeyExists(session,'userid') ? session.userid : 0# | #cfcatch.message#">
    <cfheader statuscode="500">
    <cfoutput>#serializeJSON({ "success": false, "message": "Unable to load analytics. Please try again." })#</cfoutput>
</cfcatch>
</cftry>
