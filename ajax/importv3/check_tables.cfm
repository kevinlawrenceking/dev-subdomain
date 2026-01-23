<cfsilent>
<!--- Diagnostic endpoint to check V3 table status --->
<cfset response = {
    "tables": {},
    "errors": []
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

<!--- Check table structure --->
<cftry>
    <cfset qCols = queryExecute(
        "SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'import_v3_jobs' ORDER BY ORDINAL_POSITION",
        {},
        { datasource: application.datasource }
    )>
    <cfset response.import_v3_jobs_columns = valueList(qCols.COLUMN_NAME)>
    <cfcatch type="any">
        <cfset response.columns_error = cfcatch.message>
    </cfcatch>
</cftry>

</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
