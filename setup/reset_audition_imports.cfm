<cfsetting showdebugoutput="false">
<cfcontent type="text/html; charset=utf-8">
<!--- Reset all audition import staging data (test data cleanup) --->

<!--- Derive datasource from hostname (same logic as Application.cfc) --->
<cfset host = ListFirst(cgi.server_name, ".")>
<cfif host EQ "app">
  <h2>Blocked: this script only runs on dev.</h2>
  <cfabort>
</cfif>
<cfset dsn = "abod">

<h2>Audition Import Staging Data Reset</h2>

<!--- Show counts before --->
<cfquery name="counts" datasource="#dsn#">
  SELECT
    (SELECT COUNT(*) FROM import_auditions_jobs)        AS jobs,
    (SELECT COUNT(*) FROM import_auditions_columns)     AS columns_tbl,
    (SELECT COUNT(*) FROM import_auditions_rows)        AS rows_tbl,
    (SELECT COUNT(*) FROM import_auditions_facts)       AS facts,
    (SELECT COUNT(*) FROM import_auditions_row_results) AS row_results,
    (SELECT COUNT(*) FROM import_auditions_events)      AS events
</cfquery>

<cfoutput>
<h3>Before</h3>
<ul>
  <li>Jobs: #counts.jobs#</li>
  <li>Columns: #counts.columns_tbl#</li>
  <li>Rows: #counts.rows_tbl#</li>
  <li>Facts: #counts.facts#</li>
  <li>Row Results: #counts.row_results#</li>
  <li>Events: #counts.events#</li>
</ul>
</cfoutput>

<cfif counts.jobs EQ 0>
  <p><strong>Nothing to delete.</strong></p>
  <cfabort>
</cfif>

<!--- Truncate child tables first, then parent --->
<cftransaction>
  <cfquery datasource="#dsn#">DELETE FROM import_auditions_events</cfquery>
  <cfquery datasource="#dsn#">DELETE FROM import_auditions_row_results</cfquery>
  <cfquery datasource="#dsn#">DELETE FROM import_auditions_facts</cfquery>
  <cfquery datasource="#dsn#">DELETE FROM import_auditions_rows</cfquery>
  <cfquery datasource="#dsn#">DELETE FROM import_auditions_columns</cfquery>
  <cfquery datasource="#dsn#">DELETE FROM import_auditions_jobs</cfquery>
</cftransaction>

<!--- Verify --->
<cfquery name="after" datasource="#dsn#">
  SELECT
    (SELECT COUNT(*) FROM import_auditions_jobs)        AS jobs,
    (SELECT COUNT(*) FROM import_auditions_rows)        AS rows_tbl,
    (SELECT COUNT(*) FROM import_auditions_facts)       AS facts
</cfquery>

<cfoutput>
<h3>After</h3>
<p>Jobs: #after.jobs# | Rows: #after.rows_tbl# | Facts: #after.facts#</p>
</cfoutput>

<p><strong>Done.</strong> All import staging data has been deleted. You can now re-upload your files.</p>
