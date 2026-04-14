<!--- 
    TAO Database Diagnostics Script
    Date: 2026-04-14
    Purpose: Table/View checks, index audit, row counts, and column defaults
    Location: /database/diag-table-index-audit.cfm
    Auth: Requires admin session (handled by Application.cfc)
--->
<cfinclude template="/database/admin-guard.cfm">
<cfset dsn = application.dsn>
<cfset schema = "new_development">
<cfif application.dsn EQ "abo"><cfset schema = "actorsbusinessoffice"></cfif>

<cfoutput>
<html>
<head><title>TAO DB Diagnostics</title>
<style>
body{font-family:monospace;background:##1a1a1a;color:##00ff00;padding:20px;max-width:1400px;margin:0 auto}
h1,h2{border-bottom:1px solid ##00ff00;padding-bottom:8px}
table{border-collapse:collapse;width:100%;margin:10px 0}
th,td{border:1px solid ##00ff00;padding:6px 10px;text-align:left}
th{background:##003300}
.section{border:1px solid ##00ff00;padding:15px;margin:15px 0;border-radius:4px}
.warn{color:##ffff44}
.err{color:##ff4444}
.ok{color:##44ff44}
pre{background:##000;padding:10px;overflow-x:auto;border-radius:4px;white-space:pre-wrap}
</style>
</head>
<body>
<h1>TAO Database Diagnostics</h1>
<p>Schema: #schema# | DSN: #dsn# | Run: #dateFormat(now(),"yyyy-mm-dd")# #timeFormat(now(),"HH:mm:ss")#</p>

<!--- TASK 1: Table vs View checks --->
<div class="section">
<h2>Task 1: Table vs View Checks</h2>
<cfquery name="q1" datasource="#dsn#">
    SELECT TABLE_NAME, TABLE_TYPE 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA = <cfqueryparam value="#schema#" cfsqltype="cf_sql_varchar">
    AND TABLE_NAME IN (
        'notifications','notifications_tbl',
        'contactdetails','contactdetails_tbl',
        'funotifications','funotifications_tbl',
        'events','events_tbl',
        'fusystemusers','fusystemusers_tbl',
        'eventcontactsxref','eventcontactsxref_tbl',
        'contactitems','contactitems_tbl',
        'actionusers','actionusers_tbl'
    )
    ORDER BY TABLE_NAME
</cfquery>
<table>
<tr><th>TABLE_NAME</th><th>TABLE_TYPE</th></tr>
<cfloop query="q1">
<tr><td>#q1.TABLE_NAME#</td><td>#q1.TABLE_TYPE#</td></tr>
</cfloop>
</table>
</div>

<!--- TASK 2: Index checks --->
<div class="section">
<h2>Task 2: Index Audit</h2>
<cfset indexTables = "funotifications_tbl,events_tbl,eventcontactsxref_tbl,contactitems_tbl,fusystemusers_tbl,actionusers_tbl">
<cfloop list="#indexTables#" index="tblName">
<h3>Indexes on: #tblName#</h3>
<cftry>
<cfquery name="qIdx" datasource="#dsn#">
    SELECT INDEX_NAME,
           GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS idx_columns,
           INDEX_TYPE,
           CASE NON_UNIQUE WHEN 0 THEN 'UNIQUE' ELSE 'NON-UNIQUE' END AS uniqueness
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = <cfqueryparam value="#schema#" cfsqltype="cf_sql_varchar">
      AND TABLE_NAME = <cfqueryparam value="#tblName#" cfsqltype="cf_sql_varchar">
    GROUP BY INDEX_NAME, INDEX_TYPE, NON_UNIQUE
    ORDER BY INDEX_NAME
</cfquery>
<cfif qIdx.recordCount GT 0>
<table>
<tr><th>INDEX_NAME</th><th>COLUMNS</th><th>TYPE</th><th>UNIQUENESS</th></tr>
<cfloop query="qIdx">
<tr><td>#qIdx.INDEX_NAME#</td><td>#qIdx.idx_columns#</td><td>#qIdx.INDEX_TYPE#</td><td>#qIdx.uniqueness#</td></tr>
</cfloop>
</table>
<cfelse>
<p class="warn">No indexes found for #tblName#</p>
</cfif>
<cfcatch><p class="err">Error querying indexes for #tblName#: #cfcatch.message#</p></cfcatch>
</cftry>
</cfloop>
</div>

<!--- TASK 3: Row counts --->
<div class="section">
<h2>Task 3: Row Counts</h2>

<h3>3a: Pending events (Active + eventstop before today)</h3>
<cftry>
<cfquery name="q3a" datasource="#dsn#">
    SELECT COUNT(*) AS pending_events
    FROM events e INNER JOIN taousers u ON e.userid = u.userid
    WHERE e.eventstatus = 'Active' AND e.eventstop < CURDATE()
</cfquery>
<p>Pending events: <strong>#q3a.pending_events#</strong></p>
<cfcatch><p class="err">Error: #cfcatch.message#</p></cfcatch>
</cftry>

<h3>3b: Follow-up contacts across pending events</h3>
<cftry>
<cfquery name="q3b" datasource="#dsn#">
    SELECT COUNT(DISTINCT x.contactid) AS total_contacts
    FROM eventcontactsxref x INNER JOIN events e ON e.eventid = x.eventid
    WHERE e.eventstatus = 'Active' AND e.eventstop < CURDATE()
</cfquery>
<p>Distinct contacts: <strong>#q3b.total_contacts#</strong></p>
<cfcatch><p class="err">Error: #cfcatch.message#</p></cfcatch>
</cftry>

<h3>3c: Notification status drift</h3>
<cftry>
<cfquery name="q3c1" datasource="#dsn#">
    SELECT COUNT(*) AS cnt FROM funotifications 
    WHERE notstartdate > CURDATE() AND notstatus <> 'Future'
</cfquery>
<cfquery name="q3c2" datasource="#dsn#">
    SELECT COUNT(*) AS cnt FROM funotifications 
    WHERE notstartdate < CURDATE() AND notstatus = 'Future'
</cfquery>
<p>Should be Future (notstartdate after today but notstatus is not Future): <strong>#q3c1.cnt#</strong></p>
<p>Should be Active (notstartdate before today but notstatus is still Future): <strong>#q3c2.cnt#</strong></p>
<cfcatch><p class="err">Error: #cfcatch.message#</p></cfcatch>
</cftry>

<h3>3d: Cancelled users pending soft-delete</h3>
<cftry>
<cfquery name="q3d" datasource="#dsn#">
    SELECT COUNT(*) AS cancelled_pending FROM taousers u
    INNER JOIN thrivecart t ON u.customerid = t.id
    WHERE u.userstatus = 'cancelled' AND t.canceldate < SYSDATE()
</cfquery>
<p>Cancelled pending soft-delete: <strong>#q3d.cancelled_pending#</strong></p>
<cfcatch><p class="err">Error: #cfcatch.message#</p></cfcatch>
</cftry>
</div>

<!--- TASK 4: notstatus default --->
<div class="section">
<h2>Task 4: funotifications notstatus Column Default</h2>
<cftry>
<cfquery name="q4" datasource="#dsn#">
    SHOW COLUMNS FROM funotifications_tbl LIKE 'notstatus'
</cfquery>
<cfif q4.recordCount GT 0>
<table>
<tr><th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th><th>Extra</th></tr>
<tr>
<td>#q4.Field#</td>
<td>#q4.Type#</td>
<td>#q4.Null#</td>
<td>#q4.Key#</td>
<td>#q4.Default#</td>
<td>#q4.Extra#</td>
</tr>
</table>
<cfelse>
<p class="warn">Column notstatus not found in funotifications_tbl</p>
</cfif>
<cfcatch><p class="err">Error: #cfcatch.message#</p></cfcatch>
</cftry>
</div>

<!--- BONUS: Table sizes --->
<div class="section">
<h2>Bonus: Table Row Counts (core tables)</h2>
<cftry>
<cfquery name="qCounts" datasource="#dsn#">
    SELECT TABLE_NAME, TABLE_ROWS, DATA_LENGTH, INDEX_LENGTH
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = <cfqueryparam value="#schema#" cfsqltype="cf_sql_varchar">
    AND TABLE_NAME IN (
        'funotifications_tbl','fusystemusers_tbl','contactdetails_tbl',
        'contactitems_tbl','events_tbl','eventcontactsxref_tbl',
        'actionusers_tbl','taousers_tbl','notifications','fuactions','fusystems'
    )
    ORDER BY TABLE_ROWS DESC
</cfquery>
<table>
<tr><th>TABLE</th><th>EST ROWS</th><th>DATA (KB)</th><th>INDEX (KB)</th></tr>
<cfloop query="qCounts">
<tr>
<td>#qCounts.TABLE_NAME#</td>
<td>#numberFormat(qCounts.TABLE_ROWS)#</td>
<td>#numberFormat(qCounts.DATA_LENGTH / 1024, "0")#</td>
<td>#numberFormat(qCounts.INDEX_LENGTH / 1024, "0")#</td>
</tr>
</cfloop>
</table>
<cfcatch><p class="err">Error: #cfcatch.message#</p></cfcatch>
</cftry>
</div>

<p style="color:##666;margin-top:30px;">End of diagnostics.</p>
</body>
</html>
</cfoutput>
