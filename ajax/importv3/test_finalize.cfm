<cfparam name="url.job_id" default="30">
<cfset jobId = val(url.job_id)>
<cfoutput>
<h2>Test Finalize - Job #jobId#</h2>
<hr>

<!--- Step 1: Auth check --->
<h3>Step 1: Session Check</h3>
<cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid) OR session.userid LTE 0>
    <p style="color:red;font-weight:bold">FAIL: No session.userid. You must be logged in.</p>
    <cfabort>
</cfif>
<p style="color:green">OK: session.userid = #session.userid#</p>

<!--- Step 2: Datasource check --->
<h3>Step 2: Datasource</h3>
<p>application.datasource = #application.datasource#</p>

<!--- Step 3: Check job exists --->
<h3>Step 3: Job Lookup</h3>
<cfset qJob = queryExecute(
    "SELECT job_id, userid, status, total_rows, imported_rows FROM import_v3_jobs WHERE job_id = :jid",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfif qJob.recordCount EQ 0>
    <p style="color:red;font-weight:bold">FAIL: Job #jobId# not found</p>
    <cfabort>
</cfif>
<p style="color:green">OK: Job found. Status=<strong>#qJob.status#</strong>, total_rows=#qJob.total_rows#, imported_rows=#qJob.imported_rows#</p>

<!--- Step 3b: If stuck in finalizing, reset to reviewing --->
<cfif qJob.status EQ "finalizing">
    <p style="color:orange">Job is stuck in 'finalizing'. Resetting to 'reviewing'...</p>
    <cfset queryExecute(
        "UPDATE import_v3_jobs SET status = 'reviewing', updated_at = NOW() WHERE job_id = :jid",
        { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <p style="color:green">Reset done.</p>
</cfif>

<!--- Step 4: Row status breakdown --->
<h3>Step 4: Row Status Breakdown</h3>
<cfset qAllRows = queryExecute(
    "SELECT status, COUNT(*) as cnt FROM import_v3_rows WHERE job_id = :jid GROUP BY status ORDER BY cnt DESC",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<table border="1" cellpadding="5">
    <tr><th>Status</th><th>Count</th></tr>
    <cfloop query="qAllRows">
        <tr><td>#qAllRows.status#</td><td>#qAllRows.cnt#</td></tr>
    </cfloop>
</table>

<!--- Step 5: Show failed row errors --->
<h3>Step 5: Failed Row Details</h3>
<cfset qFailed = queryExecute(
    "SELECT row_id, row_num, status, import_error, created_contactid
     FROM import_v3_rows
     WHERE job_id = :jid AND status = 'failed'
     ORDER BY row_num ASC
     LIMIT 10",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfif qFailed.recordCount GT 0>
    <p style="color:orange">#qFailed.recordCount# failed rows found. Errors:</p>
    <table border="1" cellpadding="5" style="max-width:100%">
        <tr><th>row_id</th><th>row_num</th><th>created_contactid</th><th>import_error</th></tr>
        <cfloop query="qFailed">
            <tr>
                <td>#qFailed.row_id#</td>
                <td>#qFailed.row_num#</td>
                <td>#qFailed.created_contactid#</td>
                <td style="color:red;max-width:600px;word-wrap:break-word">#htmlEditFormat(left(qFailed.import_error, 500))#</td>
            </tr>
        </cfloop>
    </table>
<cfelse>
    <p style="color:green">No failed rows.</p>
</cfif>

<!--- Step 5b: Show row_results errors --->
<h3>Step 5b: Row Results Table</h3>
<cfset qResults = queryExecute(
    "SELECT result_id, row_id, action_taken, contactid, error_code, error_message
     FROM import_v3_row_results
     WHERE job_id = :jid
     ORDER BY result_id DESC
     LIMIT 10",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfif qResults.recordCount GT 0>
    <table border="1" cellpadding="5" style="max-width:100%">
        <tr><th>result_id</th><th>row_id</th><th>action_taken</th><th>contactid</th><th>error_code</th><th>error_message</th></tr>
        <cfloop query="qResults">
            <tr>
                <td>#qResults.result_id#</td>
                <td>#qResults.row_id#</td>
                <td>#qResults.action_taken#</td>
                <td>#qResults.contactid#</td>
                <td style="color:red">#qResults.error_code#</td>
                <td style="max-width:400px;word-wrap:break-word">#htmlEditFormat(left(qResults.error_message, 300))#</td>
            </tr>
        </cfloop>
    </table>
<cfelse>
    <p style="color:gray">No row results yet.</p>
</cfif>

<!--- Step 6: Check facts for first row --->
<h3>Step 6: Facts for First Row</h3>
<cfset qFirstRow = queryExecute(
    "SELECT row_id, row_num FROM import_v3_rows WHERE job_id = :jid ORDER BY row_num ASC LIMIT 1",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfif qFirstRow.recordCount GT 0>
    <cfset firstRowId = qFirstRow.row_id>
    <p>First row: row_id=#firstRowId# row_num=#qFirstRow.row_num#</p>
    <cfset qFacts = queryExecute(
        "SELECT f.fact_id, f.field_name, f.raw_value, f.normalized_value, f.is_valid, f.validation_code
         FROM import_v3_facts f
         WHERE f.row_id = :rid
         ORDER BY f.field_name",
        { rid: { value: firstRowId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <p>Total facts: #qFacts.recordCount# (valid: <cfset validCount = 0><cfloop query="qFacts"><cfif qFacts.is_valid AND len(trim(qFacts.normalized_value))><cfset validCount++></cfif></cfloop>#validCount#)</p>
    <table border="1" cellpadding="5">
        <tr><th>fact_id</th><th>field_name</th><th>raw_value</th><th>normalized_value</th><th>is_valid</th><th>validation_code</th></tr>
        <cfloop query="qFacts">
            <tr style="background:<cfif NOT qFacts.is_valid>##ffcccc<cfelse>##ccffcc</cfif>">
                <td>#qFacts.fact_id#</td>
                <td>#qFacts.field_name#</td>
                <td>#htmlEditFormat(left(qFacts.raw_value, 80))#</td>
                <td>#htmlEditFormat(left(qFacts.normalized_value, 80))#</td>
                <td>#qFacts.is_valid#</td>
                <td>#qFacts.validation_code#</td>
            </tr>
        </cfloop>
    </table>
<cfelse>
    <p style="color:red">No rows found at all.</p>
</cfif>

<!--- Step 7: Check contactdetails table columns --->
<h3>Step 7: contactdetails Table Check</h3>
<cfset qCols = queryExecute(
    "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_KEY
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactdetails'
     ORDER BY ORDINAL_POSITION",
    {},
    { datasource: application.datasource }
)>
<cfif qCols.recordCount EQ 0>
    <p style="color:red;font-weight:bold">FAIL: 'contactdetails' table does not exist!</p>
<cfelse>
    <p style="color:green">OK: contactdetails has #qCols.recordCount# columns.</p>
    <p>Columns: <cfset colList = ""><cfloop query="qCols"><cfset colList = listAppend(colList, qCols.COLUMN_NAME)></cfloop>#colList#</p>
    <!--- Check specific columns we need --->
    <cfset needed = "contactid,userid,contactFullName,contactBirthday,user_yn,IsDeleted">
    <cfloop list="#needed#" index="col">
        <cfset found = false>
        <cfloop query="qCols">
            <cfif qCols.COLUMN_NAME EQ col><cfset found = true></cfif>
        </cfloop>
        <cfif found>
            <span style="color:green">[#col#: OK]</span>
        <cfelse>
            <span style="color:red;font-weight:bold">[#col#: MISSING!]</span>
        </cfif>
    </cfloop>
</cfif>

<!--- Step 8: Instantiate service --->
<h3>Step 8: Instantiate ContactImportV3Service</h3>
<cfflush>
<cfset v3Service = new services.ContactImportV3Service()>
<p style="color:green">OK: Service instantiated successfully</p>

<!--- Step 9: Try processing just ONE row manually (no service, raw queries) --->
<h3>Step 9: Manual Single Row Test (row_id=#firstRowId#)</h3>
<cfflush>

<!--- Reset this one row to ready --->
<cfset queryExecute(
    "UPDATE import_v3_rows SET status = 'ready', import_error = NULL WHERE row_id = :rid",
    { rid: { value: firstRowId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<p>Reset row #firstRowId# to 'ready'</p>

<!--- Get valid facts --->
<cfset qValidFacts = queryExecute(
    "SELECT f.field_name, f.normalized_value
     FROM import_v3_facts f
     WHERE f.row_id = :rid AND f.is_valid = 1 AND f.normalized_value IS NOT NULL AND f.normalized_value != ''",
    { rid: { value: firstRowId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<p>Valid facts for row: #qValidFacts.recordCount#</p>

<cfif qValidFacts.recordCount GT 0>
    <!--- Build name from facts --->
    <cfset firstName = "">
    <cfset lastName = "">
    <cfset fullName = "">
    <cfloop query="qValidFacts">
        <cfif qValidFacts.field_name EQ "firstName" OR qValidFacts.field_name EQ "first_name">
            <cfset firstName = qValidFacts.normalized_value>
        <cfelseif qValidFacts.field_name EQ "lastName" OR qValidFacts.field_name EQ "last_name">
            <cfset lastName = qValidFacts.normalized_value>
        <cfelseif qValidFacts.field_name EQ "contactFullName" OR qValidFacts.field_name EQ "full_name" OR qValidFacts.field_name EQ "contact_full_name">
            <cfset fullName = qValidFacts.normalized_value>
        </cfif>
    </cfloop>
    <cfif NOT len(fullName) AND (len(firstName) OR len(lastName))>
        <cfset fullName = trim(firstName & " " & lastName)>
    </cfif>
    <p>Resolved name: "<strong>#htmlEditFormat(fullName)#</strong>" (firstName="#htmlEditFormat(firstName)#" lastName="#htmlEditFormat(lastName)#")</p>

    <cfif len(fullName)>
        <!--- Try the actual INSERT --->
        <p>Attempting INSERT into contactdetails...</p>
        <cfset qInsertResult = {}>
        <cfset queryExecute(
            "INSERT INTO contactdetails_tbl (userid, contactFullName, contactBirthday, user_yn, IsDeleted)
             VALUES (:userid, :name, NULL, 'Y', 0)",
            {
                userid: { value: session.userid, cfsqltype: "cf_sql_integer" },
                name: { value: fullName, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: application.datasource, result: "qInsertResult" }
        )>
        <p style="color:green;font-weight:bold">INSERT SUCCEEDED! generatedKey = #qInsertResult.generatedKey#</p>

        <!--- Clean up: delete the test contact --->
        <cfset queryExecute(
            "DELETE FROM contactdetails_tbl WHERE contactid = :cid",
            { cid: { value: qInsertResult.generatedKey, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <p style="color:gray">(Test contact deleted)</p>
    <cfelse>
        <p style="color:red">Cannot test INSERT - no name resolved from facts</p>
    </cfif>
<cfelse>
    <p style="color:red">No valid facts - cannot test INSERT</p>
</cfif>

<!--- Step 10: Reset row back to failed, then call full finalizeJob --->
<h3>Step 10: Full finalizeJob() Call</h3>
<p>Resetting all failed rows (with no contactid) back to ready for retry...</p>
<cfset queryExecute(
    "UPDATE import_v3_rows SET status = 'ready', import_error = NULL, updated_at = NOW()
     WHERE job_id = :jid AND status = 'failed' AND created_contactid IS NULL",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfflush>

<p>Calling v3Service.finalizeJob(#jobId#, #session.userid#)...</p>
<cfflush>
<cfset startTick = getTickCount()>
<cfset result = v3Service.finalizeJob(jobId, session.userid)>
<cfset elapsed = getTickCount() - startTick>

<h3>Result (elapsed: #elapsed#ms)</h3>
<p>success: <strong style="color:#result.success ? 'green' : 'red'#">#result.success#</strong></p>
<cfif structKeyExists(result, "code")><p>code: #result.code#</p></cfif>
<p>message: #result.message#</p>

<h4>Full Result Dump:</h4>
<cfdump var="#result#" label="finalizeJob result" expand="true">

<!--- Step 11: Post-finalize status --->
<h3>Step 11: Post-Finalize Status</h3>
<cfset qJobAfter = queryExecute(
    "SELECT status, imported_rows, updated_rows, skipped_rows FROM import_v3_jobs WHERE job_id = :jid",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<p>Status: <strong>#qJobAfter.status#</strong> | imported=#qJobAfter.imported_rows# updated=#qJobAfter.updated_rows# skipped=#qJobAfter.skipped_rows#</p>

<!--- Final row status check --->
<cfset qFinalRows = queryExecute(
    "SELECT status, COUNT(*) as cnt FROM import_v3_rows WHERE job_id = :jid GROUP BY status ORDER BY cnt DESC",
    { jid: { value: jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<table border="1" cellpadding="5">
    <tr><th>Status</th><th>Count</th></tr>
    <cfloop query="qFinalRows">
        <tr><td>#qFinalRows.status#</td><td>#qFinalRows.cnt#</td></tr>
    </cfloop>
</table>

<hr>
<p style="color:gray">Test complete. Delete this file when done.</p>
</cfoutput>
