<cfsilent>
<!--- V3 Migration Verification Script --->
<!--- Usage: /database/verify-v3-migration.cfm?run=yes --->
<!--- Smoke test: /database/verify-v3-migration.cfm?run=yes&smoke=yes --->
</cfsilent>
<cfset response = {
    success: false,
    message: "",
    tables: {},
    smoke_test: {ran: false, results: []},
    errors: []
}>
<cftry>
<cfif not structKeyExists(url, "run") or url.run neq "yes">
    <cfset response.message = "Add ?run=yes to verify V3 migration. Add &smoke=yes to run smoke tests.">
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<cfset schema = application.information_schema>
<cfset runSmoke = structKeyExists(url, "smoke") and url.smoke eq "yes">
<cfset expectedTables = [
    "import_v3_jobs",
    "import_v3_columns",
    "import_v3_rows",
    "import_v3_facts",
    "import_v3_row_results",
    "import_v3_events",
    "contact_custom_fields"
]>

<!--- ============================================================
     STEP 1: Check all tables exist
     ============================================================ --->
<cfquery name="qTables">
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#schema#">
      AND (table_name LIKE 'import_v3%' OR table_name = 'contact_custom_fields')
    ORDER BY table_name
</cfquery>

<cfset foundTables = []>
<cfloop query="qTables">
    <cfset arrayAppend(foundTables, qTables.table_name)>
</cfloop>

<cfset missingTables = []>
<cfloop array="#expectedTables#" index="t">
    <cfif not arrayFindNoCase(foundTables, t)>
        <cfset arrayAppend(missingTables, t)>
    </cfif>
</cfloop>

<cfif arrayLen(missingTables) gt 0>
    <cfset response.message = "FAIL: Missing tables: " & arrayToList(missingTables)>
    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<!--- ============================================================
     STEP 2: SHOW CREATE TABLE for each table
     ============================================================ --->
<cfloop array="#expectedTables#" index="tableName">
    <cfquery name="qCreate">
        SHOW CREATE TABLE #schema#.#tableName#
    </cfquery>
    <cfset response.tables[tableName] = {
        exists: true,
        create_statement: qCreate["Create Table"][1]
    }>

    <!--- Also get index info --->
    <cfquery name="qIndexes">
        SHOW INDEX FROM #schema#.#tableName#
    </cfquery>
    <cfset indexList = []>
    <cfloop query="qIndexes">
        <cfset arrayAppend(indexList, {
            name: qIndexes.Key_name,
            column: qIndexes.Column_name,
            unique: (qIndexes.Non_unique eq 0)
        })>
    </cfloop>
    <cfset response.tables[tableName].indexes = indexList>
</cfloop>

<!--- ============================================================
     STEP 3: Smoke tests (if requested)
     ============================================================ --->
<cfif runSmoke>
    <cfset response.smoke_test.ran = true>
    <cftransaction>
        <cftry>
            <!--- Insert a dummy job --->
            <cfquery name="qInsertJob" result="jobResult">
                INSERT INTO import_v3_jobs (userid, source_filename, file_type, file_hash, status)
                VALUES (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="99999">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="smoke_test.csv">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="csv">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="smoke_test_hash_#createUUID()#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="pending">
                )
            </cfquery>
            <cfset testJobId = jobResult.generatedKey>
            <cfset arrayAppend(response.smoke_test.results, "Inserted job: job_id=#testJobId#")>

            <!--- Insert a column --->
            <cfquery name="qInsertCol" result="colResult">
                INSERT INTO import_v3_columns (job_id, source_column_index, source_column_name, mapped_field)
                VALUES (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#testJobId#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="0">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="First Name">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="firstName">
                )
            </cfquery>
            <cfset testColId = colResult.generatedKey>
            <cfset arrayAppend(response.smoke_test.results, "Inserted column: column_id=#testColId#")>

            <!--- Insert a row --->
            <cfquery name="qInsertRow" result="rowResult">
                INSERT INTO import_v3_rows (job_id, row_num, raw_json, status)
                VALUES (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#testJobId#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="1">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value='{"0":"John"}'>,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="pending">
                )
            </cfquery>
            <cfset testRowId = rowResult.generatedKey>
            <cfset arrayAppend(response.smoke_test.results, "Inserted row: row_id=#testRowId#")>

            <!--- Insert a fact --->
            <cfquery name="qInsertFact" result="factResult">
                INSERT INTO import_v3_facts (row_id, column_id, field_name, raw_value, normalized_value, is_valid)
                VALUES (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#testRowId#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#testColId#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="firstName">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="John">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="John">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="1">
                )
            </cfquery>
            <cfset testFactId = factResult.generatedKey>
            <cfset arrayAppend(response.smoke_test.results, "Inserted fact: fact_id=#testFactId#")>

            <!--- Insert an event --->
            <cfquery name="qInsertEvent" result="eventResult">
                INSERT INTO import_v3_events (job_id, event_type, event_detail, userid)
                VALUES (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#testJobId#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="smoke_test">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value='{"test":true}'>,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="99999">
                )
            </cfquery>
            <cfset arrayAppend(response.smoke_test.results, "Inserted event: event_id=#eventResult.generatedKey#")>

            <!--- Insert a custom field --->
            <cfquery name="qInsertField" result="fieldResult">
                INSERT INTO contact_custom_fields (userid, field_key, field_label, field_type)
                VALUES (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="99999">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="smoke_test_field_#createUUID()#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="Smoke Test Field">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="text">
                )
            </cfquery>
            <cfset testFieldId = fieldResult.generatedKey>
            <cfset arrayAppend(response.smoke_test.results, "Inserted custom field: field_id=#testFieldId#")>

            <!--- Verify join works --->
            <cfquery name="qJoinTest">
                SELECT
                    j.job_id,
                    j.source_filename,
                    c.column_id,
                    c.mapped_field,
                    r.row_id,
                    r.row_num,
                    f.fact_id,
                    f.normalized_value
                FROM import_v3_jobs j
                INNER JOIN import_v3_columns c ON c.job_id = j.job_id
                INNER JOIN import_v3_rows r ON r.job_id = j.job_id
                INNER JOIN import_v3_facts f ON f.row_id = r.row_id AND f.column_id = c.column_id
                WHERE j.job_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#testJobId#">
            </cfquery>
            <cfif qJoinTest.recordCount eq 1>
                <cfset arrayAppend(response.smoke_test.results, "JOIN test PASSED: Retrieved linked data")>
            <cfelse>
                <cfset arrayAppend(response.smoke_test.results, "JOIN test FAILED: Expected 1 row, got #qJoinTest.recordCount#")>
            </cfif>

            <!--- Rollback to not leave test data --->
            <cftransaction action="rollback" />
            <cfset arrayAppend(response.smoke_test.results, "Transaction rolled back (no test data remains)")>

        <cfcatch type="any">
            <cftransaction action="rollback" />
            <cfset arrayAppend(response.errors, "Smoke test error: " & cfcatch.message)>
        </cfcatch>
        </cftry>
    </cftransaction>
</cfif>

<!--- ============================================================
     SUMMARY
     ============================================================ --->
<cfset response.success = true>
<cfset response.message = "V3 migration verified: #arrayLen(expectedTables)# tables found">
<cfif runSmoke and arrayLen(response.errors) eq 0>
    <cfset response.message = response.message & ". Smoke tests PASSED.">
</cfif>

<cfcatch type="any">
    <cfset response.message = "Verification error: " & cfcatch.message>
    <cfif len(cfcatch.detail)>
        <cfset response.message = response.message & " | " & cfcatch.detail>
    </cfif>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
