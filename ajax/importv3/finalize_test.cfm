<!---
    finalize_test.cfm - Diagnostic page to test finalize step by step.
    Access via browser: /ajax/importv3/finalize_test.cfm?job_id=30
    DELETE THIS FILE after debugging is complete.
--->
<cfset steps = []>
<cfset overallError = "">

<cftry>
    <!--- Step 1: Auth --->
    <cfif structKeyExists(session, "userid") AND isNumeric(session.userid) AND session.userid GT 0>
        <cfset arrayAppend(steps, "1. AUTH: OK (userid=" & session.userid & ")")>
    <cfelse>
        <cfset arrayAppend(steps, "1. AUTH: FAILED - no session.userid")>
        <cfthrow message="Auth failed">
    </cfif>
    <cfset userid = session.userid>

    <!--- Step 2: job_id param --->
    <cfparam name="url.job_id" default="">
    <cfif isNumeric(url.job_id) AND val(url.job_id) GT 0>
        <cfset jobId = val(url.job_id)>
        <cfset arrayAppend(steps, "2. JOB_ID: OK (" & jobId & ")")>
    <cfelse>
        <cfset arrayAppend(steps, "2. JOB_ID: FAILED - pass ?job_id=N")>
        <cfthrow message="Missing job_id">
    </cfif>

    <!--- Step 3: Service compilation --->
    <cftry>
        <cfset v3Service = new services.ContactImportV3Service()>
        <cfset arrayAppend(steps, "3. SERVICE COMPILE: OK")>
        <cfcatch type="any">
            <cfset arrayAppend(steps, "3. SERVICE COMPILE: FAILED - " & cfcatch.message & " | Detail: " & cfcatch.detail)>
            <cfthrow message="Service compile failed">
        </cfcatch>
    </cftry>

    <!--- Step 4: getJobForUser --->
    <cftry>
        <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
        <cfif jobResult.success>
            <cfset arrayAppend(steps, "4. GET JOB: OK (status=" & jobResult.data.job.status & ")")>
        <cfelse>
            <cfset arrayAppend(steps, "4. GET JOB: FAILED - code=" & jobResult.code & " msg=" & jobResult.message)>
            <cfthrow message="Get job failed">
        </cfif>
        <cfcatch type="any">
            <cfif NOT find("Get job failed", cfcatch.message)>
                <cfset arrayAppend(steps, "4. GET JOB: EXCEPTION - " & cfcatch.message & " | Detail: " & cfcatch.detail)>
            </cfif>
            <cfrethrow>
        </cfcatch>
    </cftry>

    <!--- Step 5: Check eligible rows --->
    <cftry>
        <cfquery name="qRows" datasource="#application.datasource#">
            SELECT r.row_id, r.row_num, r.status, r.user_action, r.created_contactid
            FROM import_v3_rows r
            WHERE r.job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
              AND (
                  r.status = 'ready'
                  OR (r.status = 'dupe' AND r.user_action = 'import_new')
              )
            ORDER BY r.row_num ASC
        </cfquery>
        <cfset arrayAppend(steps, "5. ELIGIBLE ROWS: " & qRows.recordCount & " rows")>

        <!--- Show first 3 rows --->
        <cfset rowSamples = []>
        <cfset counter = 0>
        <cfloop query="qRows">
            <cfset counter++>
            <cfif counter LTE 3>
                <cfset arrayAppend(rowSamples, "row_id=" & qRows.row_id & " status=" & qRows.status & " contactid=" & qRows.created_contactid)>
            </cfif>
        </cfloop>
        <cfset arrayAppend(steps, "   Sample rows: " & arrayToList(rowSamples, " | "))>
        <cfcatch type="any">
            <cfset arrayAppend(steps, "5. ELIGIBLE ROWS: EXCEPTION - " & cfcatch.message)>
            <cfrethrow>
        </cfcatch>
    </cftry>

    <!--- Step 6: Check facts for first eligible row --->
    <cfif qRows.recordCount GT 0>
        <cftry>
            <cfset testRowId = qRows.row_id[1]>
            <cfquery name="qFacts" datasource="#application.datasource#">
                SELECT f.fact_id, f.field_name, f.normalized_value, f.is_valid
                FROM import_v3_facts f
                WHERE f.row_id = <cfqueryparam value="#testRowId#" cfsqltype="cf_sql_integer">
                  AND f.is_valid = 1
                  AND f.normalized_value IS NOT NULL
                  AND f.normalized_value != ''
            </cfquery>
            <cfset arrayAppend(steps, "6. FACTS (row_id=" & testRowId & "): " & qFacts.recordCount & " valid facts")>

            <!--- Show fact field names --->
            <cfset factNames = []>
            <cfloop query="qFacts">
                <cfset arrayAppend(factNames, qFacts.field_name & "=" & left(qFacts.normalized_value, 30))>
            </cfloop>
            <cfset arrayAppend(steps, "   Facts: " & arrayToList(factNames, " | "))>
            <cfcatch type="any">
                <cfset arrayAppend(steps, "6. FACTS: EXCEPTION - " & cfcatch.message)>
                <cfrethrow>
            </cfcatch>
        </cftry>

        <!--- Step 7: Test buildContactDataFromFacts --->
        <cftry>
            <!--- Use reflection to call the private method indirectly --->
            <cfset arrayAppend(steps, "7. BUILD_CONTACT_DATA: (skipped - private method, tested via processRow)")>
            <cfcatch type="any">
                <cfset arrayAppend(steps, "7. BUILD_CONTACT_DATA: EXCEPTION - " & cfcatch.message)>
            </cfcatch>
        </cftry>

        <!--- Step 8: Check contactdetails table structure --->
        <cftry>
            <cfquery name="qCols" datasource="#application.datasource#">
                SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'contactdetails'
                  AND COLUMN_NAME IN ('userid','contactFullName','contactBirthday','user_yn','IsDeleted','contactid')
                ORDER BY ORDINAL_POSITION
            </cfquery>
            <cfset colList = []>
            <cfloop query="qCols">
                <cfset arrayAppend(colList, qCols.COLUMN_NAME & "(" & qCols.DATA_TYPE & ")")>
            </cfloop>
            <cfset arrayAppend(steps, "8. CONTACTDETAILS SCHEMA: " & qCols.recordCount & " matched cols: " & arrayToList(colList, ", "))>

            <cfif qCols.recordCount EQ 0>
                <cfset arrayAppend(steps, "   WARNING: contactdetails table may not exist or has no matching columns!")>
            </cfif>
            <cfcatch type="any">
                <cfset arrayAppend(steps, "8. CONTACTDETAILS SCHEMA: EXCEPTION - " & cfcatch.message)>
            </cfcatch>
        </cftry>

        <!--- Step 9: Check contactitems table structure --->
        <cftry>
            <cfquery name="qItemCols" datasource="#application.datasource#">
                SELECT COLUMN_NAME
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'contactitems'
                  AND COLUMN_NAME IN ('contactid','valueCategory','valueType','valuetext','itemStatus','valueCompany','valueTitle','valueStreetAddress','valueExtendedAddress','valueCity','valueRegion','valuePostalCode','valueCountry')
                ORDER BY ORDINAL_POSITION
            </cfquery>
            <cfset itemColList = []>
            <cfloop query="qItemCols">
                <cfset arrayAppend(itemColList, qItemCols.COLUMN_NAME)>
            </cfloop>
            <cfset arrayAppend(steps, "9. CONTACTITEMS SCHEMA: " & qItemCols.recordCount & " matched cols: " & arrayToList(itemColList, ", "))>
            <cfcatch type="any">
                <cfset arrayAppend(steps, "9. CONTACTITEMS SCHEMA: EXCEPTION - " & cfcatch.message)>
            </cfcatch>
        </cftry>

        <!--- Step 10: Check import_v3_row_results table --->
        <cftry>
            <cfquery name="qResultCols" datasource="#application.datasource#">
                SELECT COLUMN_NAME
                FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                  AND TABLE_NAME = 'import_v3_row_results'
                ORDER BY ORDINAL_POSITION
            </cfquery>
            <cfset resultColList = []>
            <cfloop query="qResultCols">
                <cfset arrayAppend(resultColList, qResultCols.COLUMN_NAME)>
            </cfloop>
            <cfset arrayAppend(steps, "10. ROW_RESULTS TABLE: " & qResultCols.recordCount & " cols: " & arrayToList(resultColList, ", "))>
            <cfif qResultCols.recordCount EQ 0>
                <cfset arrayAppend(steps, "    CRITICAL: import_v3_row_results table does not exist!")>
            </cfif>
            <cfcatch type="any">
                <cfset arrayAppend(steps, "10. ROW_RESULTS TABLE: EXCEPTION - " & cfcatch.message)>
            </cfcatch>
        </cftry>

        <!--- Step 11: Test acquireJobLock (DRY RUN - don't actually lock) --->
        <cftry>
            <cfquery name="qJobStatus" datasource="#application.datasource#">
                SELECT status FROM import_v3_jobs
                WHERE job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
                  AND userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif qJobStatus.recordCount EQ 1>
                <cfset curStatus = qJobStatus.status>
                <cfset canLock = (curStatus EQ "reviewing" OR curStatus EQ "finalizing")>
                <cfset arrayAppend(steps, "11. LOCK CHECK: current_status=" & curStatus & " can_lock=" & canLock)>
            <cfelse>
                <cfset arrayAppend(steps, "11. LOCK CHECK: job not found for this user")>
            </cfif>
            <cfcatch type="any">
                <cfset arrayAppend(steps, "11. LOCK CHECK: EXCEPTION - " & cfcatch.message)>
            </cfcatch>
        </cftry>

        <!--- Step 12: Try calling finalizeJob and capture the error --->
        <cftry>
            <cfset arrayAppend(steps, "12. FINALIZE CALL: Attempting...")>
            <cfset result = v3Service.finalizeJob(jobId, userid)>
            <cfset arrayAppend(steps, "12. FINALIZE CALL: Returned success=" & result.success & " message=" & result.message)>
            <cfif structKeyExists(result, "code")>
                <cfset arrayAppend(steps, "    code=" & result.code)>
            </cfif>
            <cfif structKeyExists(result, "data")>
                <cfset arrayAppend(steps, "    data keys=" & structKeyList(result.data))>
            </cfif>
            <cfcatch type="any">
                <cfset arrayAppend(steps, "12. FINALIZE CALL: EXCEPTION")>
                <cfset arrayAppend(steps, "    type=" & cfcatch.type)>
                <cfset arrayAppend(steps, "    message=" & cfcatch.message)>
                <cfset arrayAppend(steps, "    detail=" & cfcatch.detail)>
                <cfif len(cfcatch.tagcontext) AND isArray(cfcatch.tagcontext) AND arrayLen(cfcatch.tagcontext) GT 0>
                    <cfloop from="1" to="#min(5, arrayLen(cfcatch.tagcontext))#" index="i">
                        <cfset tc = cfcatch.tagcontext[i]>
                        <cfset arrayAppend(steps, "    stack[" & i & "]: " & tc.template & " line " & tc.line)>
                    </cfloop>
                </cfif>
            </cfcatch>
        </cftry>
    <cfelse>
        <cfset arrayAppend(steps, "6-12. SKIPPED - no eligible rows to test")>
    </cfif>

    <cfcatch type="any">
        <cfset overallError = cfcatch.message>
    </cfcatch>
</cftry>

<cfcontent type="application/json; charset=utf-8" reset="true">
<cfoutput>#serializeJSON({
    "steps": steps,
    "overall_error": overallError,
    "timestamp": now()
})#</cfoutput>
