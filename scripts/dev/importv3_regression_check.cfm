<cfsilent>
<!---
    Import V3 - Field Name Convention Regression Check (Dev / Admin only)

    Usage: /scripts/dev/importv3_regression_check.cfm?job_id=123
           /scripts/dev/importv3_regression_check.cfm?job_id=123&format=json

    Reports counts of camelCase vs snake_case field_name values in
    import_v3_facts for the 4 canonical name/type fields.

    Does NOT create or modify any DB records.
--->

<!--- Admin guard --->
<cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
    <cfheader statuscode="401">
    <cfoutput>Authentication required</cfoutput><cfabort>
</cfif>
<cfif not isDefined("session.isAdmin") or session.isAdmin neq true>
    <cfheader statuscode="403">
    <cfoutput>Administrator access required</cfoutput><cfabort>
</cfif>

<!--- Read job_id --->
<cfparam name="url.job_id" default="">
<cfparam name="url.format" default="html">

<cfif not isNumeric(url.job_id) or val(url.job_id) lte 0>
    <cfoutput>Usage: ?job_id=123 [&format=json]</cfoutput><cfabort>
</cfif>
<cfset variables.jobId = val(url.job_id)>

<!--- Verify job exists --->
<cfset variables.qJob = queryExecute(
    "SELECT job_id, status, source_filename FROM import_v3_jobs WHERE job_id = :job_id",
    { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
    { datasource: application.datasource }
)>
<cfif variables.qJob.recordCount eq 0>
    <cfoutput>Job #variables.jobId# not found</cfoutput><cfabort>
</cfif>

<!--- Define the 4 key pairs --->
<cfset variables.pairs = [
    { "snake": "first_name",   "camel": "firstName" },
    { "snake": "last_name",    "camel": "lastName" },
    { "snake": "full_name",    "camel": "contactFullName" },
    { "snake": "contact_type", "camel": "contactType" }
]>

<!--- Query counts for each field_name variant --->
<cfset variables.allFieldNames = "">
<cfloop array="#variables.pairs#" index="variables.p">
    <cfset variables.allFieldNames = listAppend(variables.allFieldNames, variables.p.snake)>
    <cfset variables.allFieldNames = listAppend(variables.allFieldNames, variables.p.camel)>
</cfloop>

<cfset variables.qCounts = queryExecute(
    "SELECT f.field_name, COUNT(*) as cnt
     FROM import_v3_facts f
     INNER JOIN import_v3_rows r ON f.row_id = r.row_id
     WHERE r.job_id = :job_id
       AND f.field_name IN (:field_list)
     GROUP BY f.field_name
     ORDER BY f.field_name",
    {
        job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
        field_list: { value: variables.allFieldNames, cfsqltype: "cf_sql_varchar", list: true }
    },
    { datasource: application.datasource }
)>

<!--- Build result --->
<cfset variables.countMap = {}>
<cfloop query="variables.qCounts">
    <cfset variables.countMap[variables.qCounts.field_name] = variables.qCounts.cnt>
</cfloop>

<cfset variables.totalSnake = 0>
<cfset variables.totalCamel = 0>
<cfset variables.results = []>

<cfloop array="#variables.pairs#" index="variables.p">
    <cfset variables.snakeCount = structKeyExists(variables.countMap, variables.p.snake) ? variables.countMap[variables.p.snake] : 0>
    <cfset variables.camelCount = structKeyExists(variables.countMap, variables.p.camel) ? variables.countMap[variables.p.camel] : 0>
    <cfset variables.totalSnake += variables.snakeCount>
    <cfset variables.totalCamel += variables.camelCount>
    <cfset arrayAppend(variables.results, {
        "snake_key": variables.p.snake,
        "camel_key": variables.p.camel,
        "snake_count": variables.snakeCount,
        "camel_count": variables.camelCount,
        "status": variables.snakeCount eq 0 ? "OK" : "NEEDS_NORMALIZE"
    })>
</cfloop>

<cfset variables.report = {
    "job_id": variables.jobId,
    "job_status": variables.qJob.status,
    "source_filename": variables.qJob.source_filename,
    "total_snake_case": variables.totalSnake,
    "total_camel_case": variables.totalCamel,
    "overall_status": variables.totalSnake eq 0 ? "CLEAN" : "HAS_LEGACY_SNAKE_CASE",
    "fields": variables.results
}>
</cfsilent>

<cfif url.format eq "json">
    <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.report)#</cfoutput>
<cfelse>
    <cfcontent type="text/html; charset=utf-8" reset="true">
    <cfoutput>
    <html><head><title>Import V3 Field Name Regression Check - Job ##variables.jobId#</title>
    <style>body{font-family:monospace;margin:20px}table{border-collapse:collapse;margin:10px 0}td,th{border:1px solid ##ccc;padding:6px 12px;text-align:left}.ok{color:green}.warn{color:red}h2{margin-top:20px}</style>
    </head><body>
    <h1>Import V3 Field Name Regression Check</h1>
    <p><strong>Job:</strong> #variables.jobId# | <strong>Status:</strong> #variables.qJob.status# | <strong>File:</strong> #variables.qJob.source_filename#</p>
    <p><strong>Overall:</strong> <span class="#variables.report.overall_status eq 'CLEAN' ? 'ok' : 'warn'#">#variables.report.overall_status#</span></p>
    <p>Total camelCase: #variables.totalCamel# | Total snake_case: #variables.totalSnake#</p>

    <h2>Field Breakdown</h2>
    <table>
    <tr><th>snake_case key</th><th>camelCase key</th><th>snake count</th><th>camel count</th><th>status</th></tr>
    <cfloop array="#variables.results#" index="variables.r">
        <tr>
            <td>#variables.r.snake_key#</td>
            <td>#variables.r.camel_key#</td>
            <td class="#variables.r.snake_count gt 0 ? 'warn' : ''#">#variables.r.snake_count#</td>
            <td>#variables.r.camel_count#</td>
            <td class="#variables.r.status eq 'OK' ? 'ok' : 'warn'#">#variables.r.status#</td>
        </tr>
    </cfloop>
    </table>

    <h2>Remediation</h2>
    <cfif variables.totalSnake gt 0>
        <p>Run: <code>POST /ajax/importv3/normalize_fact_fieldnames.cfm?job_id=#variables.jobId#</code></p>
    <cfelse>
        <p class="ok">No remediation needed.</p>
    </cfif>
    </body></html>
    </cfoutput>
</cfif>
