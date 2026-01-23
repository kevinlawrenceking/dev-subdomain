<cftry>
<cfset result = {}>

<!--- Test 1: Basic query --->
<cftry>
    <cfset q1 = queryExecute("SELECT 1 as test", {}, { datasource: application.datasource })>
    <cfset result.test1 = "OK">
<cfcatch><cfset result.test1 = "FAIL: " & cfcatch.message></cfcatch>
</cftry>

<!--- Test 2: Check import_v3_columns structure --->
<cftry>
    <cfset q2 = queryExecute("DESCRIBE import_v3_columns", {}, { datasource: application.datasource })>
    <cfset cols = []>
    <cfloop query="q2">
        <cfset arrayAppend(cols, q2.Field)>
    </cfloop>
    <cfset result.import_v3_columns_fields = arrayToList(cols)>
<cfcatch><cfset result.test2 = "FAIL: " & cfcatch.message></cfcatch>
</cftry>

<!--- Test 3: Try the exact failing query --->
<cftry>
    <cfset q3 = queryExecute(
        "SELECT column_id, source_column_index, source_column_name, mapped_field,
                is_custom_field, custom_field_id, confidence, user_confirmed,
                sample_values, intent, target_key, transform_json
         FROM import_v3_columns WHERE job_id = 7",
        {},
        { datasource: application.datasource }
    )>
    <cfset result.test3_query = "OK - " & q3.recordCount & " rows">
<cfcatch><cfset result.test3_query = "FAIL: " & cfcatch.message & " | " & cfcatch.detail></cfcatch>
</cftry>

<cfcatch type="any">
    <cfset result.outer_error = cfcatch.message>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(result)#</cfoutput>
