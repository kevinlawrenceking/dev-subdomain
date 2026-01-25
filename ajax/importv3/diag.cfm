<cftry>
<cfset result = {}>

<!--- Test 0: Which database are we using? --->
<cftry>
    <cfset q0 = queryExecute("SELECT DATABASE() as db_name", {}, { datasource: application.datasource })>
    <cfset result.current_database = q0.db_name>
    <cfset result.datasource_name = application.datasource>
    <cfset result.server_name = cgi.server_name>
    <cfset result.host_check = ListFirst(cgi.server_name, ".")>
<cfcatch><cfset result.test0 = "FAIL: " & cfcatch.message></cfcatch>
</cftry>

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
<cfparam name="url.job_id" default="3">
<cftry>
    <cfset q3 = queryExecute(
        "SELECT column_id, source_column_index, source_column_name, mapped_field,
                is_custom_field, custom_field_id, confidence, user_confirmed,
                sample_values, intent, target_key, transform_json
         FROM import_v3_columns WHERE job_id = :jid",
        { jid: { value: url.job_id, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <cfset result.test3_query = "OK - " & q3.recordCount & " rows for job_id=" & url.job_id>
<cfcatch><cfset result.test3_query = "FAIL: " & cfcatch.message & " | " & cfcatch.detail></cfcatch>
</cftry>

<!--- Test 4: Test getJobForUser query --->
<cftry>
    <cfset q4 = queryExecute(
        "SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
            stored_file_path, status, error_message, created_at, updated_at,
            started_at, finished_at, total_rows, parsed_rows, valid_rows,
            problem_rows, dupe_rows, imported_rows, updated_rows, skipped_rows,
            options_json, import_mode, allow_blank_overwrite,
            relationship_system_default, folder_assignment_json
        FROM import_v3_jobs WHERE job_id = :jid",
        { jid: { value: url.job_id, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>
    <cfset result.test4_jobs_query = "OK - " & q4.recordCount & " rows, status=" & (q4.recordCount gt 0 ? q4.status : "N/A")>
<cfcatch><cfset result.test4_jobs_query = "FAIL: " & cfcatch.message & " | " & cfcatch.detail></cfcatch>
</cftry>

<!--- Test 5: Test service instantiation --->
<cftry>
    <cfset svc = new services.ContactImportV3Service()>
    <cfset result.test5_service = "OK - service created">
<cfcatch><cfset result.test5_service = "FAIL: " & cfcatch.message & " | " & cfcatch.detail></cfcatch>
</cftry>

<!--- Test 6: Test getJobForUser via service --->
<cftry>
    <cfset svc = new services.ContactImportV3Service()>
    <cfset jobResult = svc.getJobForUser(url.job_id, session.userid)>
    <cfset result.test6_getJobForUser = "success=" & jobResult.success & " code=" & (structKeyExists(jobResult, "code") ? jobResult.code : "none")>
    <cfif structKeyExists(jobResult, "message")>
        <cfset result.test6_message = jobResult.message>
    </cfif>
<cfcatch><cfset result.test6_getJobForUser = "EXCEPTION: " & cfcatch.message & " | " & cfcatch.detail></cfcatch>
</cftry>

<!--- Test 7: Test ValidationService --->
<cftry>
    <cfset valSvc = new services.ValidationService()>
    <cfset result.test7_validation_service = "OK - ValidationService created">
<cfcatch><cfset result.test7_validation_service = "FAIL: " & cfcatch.message & " | " & cfcatch.detail></cfcatch>
</cftry>

<!--- Test 8: Test DuplicateMatcherService --->
<cftry>
    <cfset dupeSvc = new services.DuplicateMatcherService()>
    <cfset result.test8_dupe_service = "OK - DuplicateMatcherService created">
<cfcatch><cfset result.test8_dupe_service = "FAIL: " & cfcatch.message & " | " & cfcatch.detail></cfcatch>
</cftry>

<cfcatch type="any">
    <cfset result.outer_error = cfcatch.message>
</cfcatch>
</cftry>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(result)#</cfoutput>
