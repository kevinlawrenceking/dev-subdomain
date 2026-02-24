<!---
    TEST FINALIZE - Direct browser execution
    Hit this URL directly: /ajax/importv3/test_finalize.cfm?job_id=30

    No CSRF, no AJAX, no try/catch swallowing errors.
    Raw ColdFusion errors will display on screen.

    DELETE THIS FILE after debugging.
--->
<cfparam name="url.job_id" default="30">
<cfset jobId = val(url.job_id)>

<h2>Test Finalize - Job #jobId#</h2>
<hr>

<!--- Step 1: Auth check --->
<h3>Step 1: Session Check</h3>
<cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid) OR session.userid LTE 0>
    <p style="color:red;font-weight:bold">FAIL: No session.userid. You must be logged in.</p>
    <cfabort>
</cfif>
<p style="color:green">OK: session.userid = <cfoutput>#session.userid#</cfoutput></p>

<!--- Step 2: Datasource check --->
<h3>Step 2: Datasource</h3>
<p>application.datasource = <cfoutput>#application.datasource#</cfoutput></p>

<!--- Step 3: Check job exists --->
<h3>Step 3: Job Lookup</h3>
<cfset qJob = queryExecute(
    "SELECT job_id, userid, status, total_rows, imported_rows FROM import_v3_jobs WHERE job_id = :jid",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfif qJob.recordCount EQ 0>
    <p style="color:red;font-weight:bold">FAIL: Job #<cfoutput>#jobId#</cfoutput># not found</p>
    <cfabort>
</cfif>
<cfoutput>
<p style="color:green">OK: Job found. Status=<strong>#qJob.status#</strong>, total_rows=#qJob.total_rows#, imported_rows=#qJob.imported_rows#</p>
</cfoutput>

<!--- Step 3b: If stuck in finalizing, reset to reviewing --->
<cfif qJob.status EQ "finalizing">
    <p style="color:orange">Job is stuck in 'finalizing'. Resetting to 'reviewing'...</p>
    <cfset queryExecute(
        "UPDATE import_v3_jobs SET status = 'reviewing', updated_at = NOW() WHERE job_id = :jid",
        { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <p style="color:green">Reset done. Continuing...</p>
</cfif>

<!--- Step 4: Check eligible rows --->
<h3>Step 4: Eligible Rows</h3>
<cfset qEligible = queryExecute(
    "SELECT r.row_id, r.row_num, r.status, r.user_action, r.created_contactid
     FROM import_v3_rows r
     WHERE r.job_id = :jid
       AND (r.status = 'ready' OR (r.status = 'dupe' AND r.user_action = 'import_new'))
     ORDER BY r.row_num ASC",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfoutput><p>Eligible rows: <strong>#qEligible.recordCount#</strong></p></cfoutput>
<cfif qEligible.recordCount EQ 0>
    <p style="color:red">No rows eligible. Check row statuses:</p>
    <cfset qAllRows = queryExecute(
        "SELECT status, COUNT(*) as cnt FROM import_v3_rows WHERE job_id = :jid GROUP BY status",
        { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <table border="1" cellpadding="5">
        <tr><th>Status</th><th>Count</th></tr>
        <cfloop query="qAllRows">
            <cfoutput><tr><td>#qAllRows.status#</td><td>#qAllRows.cnt#</td></tr></cfoutput>
        </cfloop>
    </table>
    <cfabort>
</cfif>

<!--- Show first few eligible rows --->
<table border="1" cellpadding="5">
    <tr><th>row_id</th><th>row_num</th><th>status</th><th>user_action</th><th>created_contactid</th></tr>
    <cfloop query="qEligible" endrow="5">
        <cfoutput><tr><td>#qEligible.row_id#</td><td>#qEligible.row_num#</td><td>#qEligible.status#</td><td>#qEligible.user_action#</td><td>#qEligible.created_contactid#</td></tr></cfoutput>
    </cfloop>
</table>

<!--- Step 5: Check facts for first eligible row --->
<h3>Step 5: Facts for First Row (row_id=<cfoutput>#qEligible.row_id[1]#</cfoutput>)</h3>
<cfset firstRowId = qEligible.row_id[1]>
<cfset qFacts = queryExecute(
    "SELECT f.fact_id, f.field_name, f.normalized_value, f.is_valid
     FROM import_v3_facts f
     WHERE f.row_id = :rid AND f.is_valid = 1 AND f.normalized_value IS NOT NULL AND f.normalized_value != ''",
    { rid: { value: firstRowId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfoutput><p>Valid facts: <strong>#qFacts.recordCount#</strong></p></cfoutput>
<table border="1" cellpadding="5">
    <tr><th>fact_id</th><th>field_name</th><th>normalized_value</th></tr>
    <cfloop query="qFacts">
        <cfoutput><tr><td>#qFacts.fact_id#</td><td>#qFacts.field_name#</td><td>#left(qFacts.normalized_value, 50)#</td></tr></cfoutput>
    </cfloop>
</table>

<!--- Step 6: Instantiate service (THIS is where compile errors show) --->
<h3>Step 6: Instantiate ContactImportV3Service</h3>
<cfflush>
<cfset v3Service = new services.ContactImportV3Service()>
<p style="color:green">OK: Service instantiated successfully</p>

<!--- Step 7: Call finalizeJob (NO try/catch - raw errors show) --->
<h3>Step 7: Calling finalizeJob(#<cfoutput>#jobId#</cfoutput>, #<cfoutput>#session.userid#</cfoutput>)</h3>
<cfflush>
<cfset startTick = getTickCount()>
<cfset result = v3Service.finalizeJob(jobId, session.userid)>
<cfset elapsed = getTickCount() - startTick>

<!--- Step 8: Show result --->
<h3>Step 8: Result (elapsed: <cfoutput>#elapsed#</cfoutput>ms)</h3>
<cfoutput>
<p>success: <strong style="color:#result.success ? 'green' : 'red'#">#result.success#</strong></p>
<cfif structKeyExists(result, "code")><p>code: #result.code#</p></cfif>
<p>message: #result.message#</p>
</cfoutput>

<h4>Full Result Dump:</h4>
<cfdump var="#result#" label="finalizeJob result" expand="true">

<!--- Step 9: Verify job status after --->
<h3>Step 9: Job Status After Finalize</h3>
<cfset qJobAfter = queryExecute(
    "SELECT status, imported_rows, updated_rows, skipped_rows FROM import_v3_jobs WHERE job_id = :jid",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfoutput>
<p>Status: <strong>#qJobAfter.status#</strong> | imported=#qJobAfter.imported_rows# updated=#qJobAfter.updated_rows# skipped=#qJobAfter.skipped_rows#</p>
</cfoutput>

<hr>
<p style="color:gray">Test complete. Delete this file when done.</p>
