<cfsilent>
<!--- Diagnostic endpoint to check V3 table status --->
<cfset response = {
    "tables": {},
    "errors": [],
    "table_columns": {}
}>

<cfset tableList = "import_v3_jobs,import_v3_columns,import_v3_rows,import_v3_facts,import_v3_events">

<cfloop list="#tableList#" index="tableName">
    <cftry>
        <cfset qCheck = queryExecute(
            "SELECT COUNT(*) as cnt FROM #tableName#",
            {},
            { datasource: application.datasource }
        )>
        <cfset response.tables[tableName] = { "exists": true, "count": qCheck.cnt }>
        <cfcatch type="any">
            <cfset response.tables[tableName] = { "exists": false, "error": cfcatch.message }>
            <cfset arrayAppend(response.errors, tableName & ": " & cfcatch.message)>
        </cfcatch>
    </cftry>
</cfloop>

<!--- Also check specific job if provided --->
<cfparam name="url.job_id" default="0">
<cfif url.job_id gt 0>
    <cftry>
        <cfset qJob = queryExecute(
            "SELECT * FROM import_v3_jobs WHERE job_id = :job_id",
            { job_id: { value: url.job_id, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <cfif qJob.recordCount gt 0>
            <cfset response.job = {}>
            <cfloop list="#qJob.columnList#" index="col">
                <cfset response.job[col] = qJob[col][1]>
            </cfloop>
        <cfelse>
            <cfset response.job = "NOT FOUND">
        </cfif>
        <cfcatch type="any">
            <cfset response.job_error = cfcatch.message & " | " & cfcatch.detail>
        </cfcatch>
    </cftry>
</cfif>

<!--- Check table structure for ALL v3 tables --->
<cfloop list="#tableList#" index="tableName">
    <cftry>
        <cfset qCols = queryExecute(
            "SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :tbl ORDER BY ORDINAL_POSITION",
            { tbl: { value: tableName, cfsqltype: "cf_sql_varchar" } },
            { datasource: application.datasource }
        )>
        <cfset response.table_columns[tableName] = valueList(qCols.COLUMN_NAME)>
        <cfcatch type="any">
            <cfset response.table_columns[tableName] = "ERROR: " & cfcatch.message>
        </cfcatch>
    </cftry>
</cfloop>

<!--- Test the specific columns query that's failing --->
<cfif url.job_id gt 0>
    <cftry>
        <cfset qTestColumns = queryExecute(
            "SELECT
                c.column_id,
                c.source_column_index,
                c.source_column_name,
                c.mapped_field,
                c.is_custom_field,
                c.custom_field_id,
                c.confidence,
                c.user_confirmed,
                c.sample_values,
                c.intent,
                c.target_key,
                c.transform_json
            FROM import_v3_columns c
            WHERE c.job_id = :job_id
            ORDER BY c.source_column_index ASC",
            { job_id: { value: url.job_id, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <cfset response.columns_query_test = "OK - " & qTestColumns.recordCount & " columns found">
        <cfcatch type="any">
            <cfset response.columns_query_test = "FAILED: " & cfcatch.message & " | " & cfcatch.detail>
        </cfcatch>
    </cftry>
</cfif>

</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
