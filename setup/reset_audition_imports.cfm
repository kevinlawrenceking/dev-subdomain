<cfsetting showdebugoutput="false">
<cfcontent type="text/html; charset=utf-8">
<!--- Reset all audition import staging data (test data cleanup) --->

 
<cfset host = ListFirst(cgi.server_name, ".")>
<cfif host EQ "app">
  <h2>Blocked: this script only runs on dev.</h2>
  <cfabort>
</cfif>
<cfset dsn = "abod">

<cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid) OR session.userid LTE 0>
    <h2>Authentication required.</h2>
    <cfabort>
</cfif>
<cfif NOT isDefined("session.isAdmin") OR session.isAdmin NEQ true>
    <h2>Admin access required.</h2>
    <cfabort>
</cfif>

<h2>Audition Import Staging Data Reset</h2>

<!--- Fix missing updated_at column on import_auditions_columns (other staging tables have it) --->
<cfquery name="checkCol" datasource="#dsn#">
  SELECT COUNT(*) AS has_col
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'new_development'
    AND TABLE_NAME = 'import_auditions_columns'
    AND COLUMN_NAME = 'updated_at'
</cfquery>
<cfif checkCol.has_col EQ 0>
  <cfquery datasource="#dsn#">
    ALTER TABLE import_auditions_columns
      ADD COLUMN created_at DATETIME DEFAULT NOW(),
      ADD COLUMN updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
  </cfquery>
  <p><strong>Schema fix applied:</strong> added created_at and updated_at to import_auditions_columns.</p>
</cfif>

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
