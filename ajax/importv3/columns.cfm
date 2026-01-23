<cfsilent>
<!---
    Contact Import V3 - Columns Endpoint
    GET/POST /ajax/importv3/columns.cfm

    GET: Returns columns for a job with sample values
    POST: Updates column mapping (intent, target_key, transform_json, user_confirmed)

    Request Parameters:
    - job_id (required): The import job ID

    POST Parameters (for single column update):
    - column_id (required): The column to update
    - intent (optional): ignore|contact_field|contact_item|tag|note|custom_meta
    - target_key (optional): Target field key (required for contact_field, contact_item, custom_meta)
    - transform_json (optional): JSON transformation rules
    - user_confirmed (optional): 1 to confirm, 0 to unconfirm

    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job does not exist
    - MISSING_JOB_ID: job_id parameter missing
    - MISSING_COLUMN_ID: column_id parameter missing for POST
    - INVALID_INTENT: intent value not in allowed list
    - TARGET_KEY_REQUIRED: target_key required for this intent
    - INVALID_JSON: transform_json is not valid JSON
    - UPDATE_FAILED: Column update failed
--->

<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<!--- Valid intent values --->
<cfset VALID_INTENTS = ["ignore", "contact_field", "contact_item", "tag", "note", "custom_meta"]>
<cfset INTENTS_REQUIRING_TARGET = ["contact_field", "contact_item", "custom_meta"]>

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>

    <!--- Validate job_id parameter --->
    <cfparam name="form.job_id" default="">
    <cfparam name="url.job_id" default="">
    <cfset jobId = val(url.job_id)>
    <cfif jobId eq 0>
        <cfset jobId = val(form.job_id)>
    </cfif>
    <cfif jobId lte 0>
        <cfset response.code = "MISSING_JOB_ID">
        <cfset response.message = "job_id is required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Initialize V3 service --->
    <cfset v3Service = new services.ContactImportV3Service()>

    <!--- Verify job ownership --->
    <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
    <cfif not jobResult.success>
        <cfset response.code = jobResult.code>
        <cfset response.message = jobResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset job = jobResult.data.job>

    <!--- Branch based on HTTP method --->
    <cfset httpMethod = cgi.request_method>

    <!--- ======================= GET: Retrieve columns ======================= --->
    <cfif httpMethod eq "GET">

        <!--- Get columns for this job --->
        <cfset qColumns = queryExecute(
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
            { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>

        <!--- Build columns array with sample values from facts --->
        <cfset columnsArray = []>
        <cfloop query="qColumns">
            <cfset columnData = {
                "column_id": qColumns.column_id,
                "source_column_index": qColumns.source_column_index,
                "source_name": qColumns.source_column_name,
                "intent": isNull(qColumns.intent) ? "" : qColumns.intent,
                "target_key": isNull(qColumns.target_key) ? "" : qColumns.target_key,
                "transform_json": isNull(qColumns.transform_json) ? "" : qColumns.transform_json,
                "user_confirmed": qColumns.user_confirmed,
                "mapped_field": isNull(qColumns.mapped_field) ? "" : qColumns.mapped_field,
                "is_custom_field": qColumns.is_custom_field,
                "confidence": isNull(qColumns.confidence) ? "" : qColumns.confidence,
                "sample_values": []
            }>

            <!--- Try to get sample values from facts table (up to 5 non-empty values) --->
            <cfset qSamples = queryExecute(
                "SELECT DISTINCT f.raw_value
                FROM import_v3_facts f
                INNER JOIN import_v3_rows r ON f.row_id = r.row_id
                WHERE f.column_id = :column_id
                  AND r.job_id = :job_id
                  AND f.raw_value IS NOT NULL
                  AND TRIM(f.raw_value) != ''
                LIMIT 5",
                {
                    column_id: { value: qColumns.column_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: jobId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            )>

            <!--- Build sample values array --->
            <cfset sampleVals = []>
            <cfloop query="qSamples">
                <cfset arrayAppend(sampleVals, qSamples.raw_value)>
            </cfloop>

            <!--- If no samples from facts, try to parse from stored sample_values JSON --->
            <cfif arrayLen(sampleVals) eq 0 and len(qColumns.sample_values)>
                <cftry>
                    <cfset storedSamples = deserializeJSON(qColumns.sample_values)>
                    <cfif isArray(storedSamples)>
                        <cfloop array="#storedSamples#" index="sv">
                            <cfif len(trim(sv)) and arrayLen(sampleVals) lt 5>
                                <cfset arrayAppend(sampleVals, sv)>
                            </cfif>
                        </cfloop>
                    </cfif>
                    <cfcatch type="any"><!--- ignore JSON parse errors ---></cfcatch>
                </cftry>
            </cfif>

            <cfset columnData.sample_values = sampleVals>
            <cfset arrayAppend(columnsArray, columnData)>
        </cfloop>

        <!--- Define available fields for mapping dropdown --->
        <cfset availableFields = [
            { "field": "firstName", "display_name": "First Name" },
            { "field": "lastName", "display_name": "Last Name" },
            { "field": "contactFullName", "display_name": "Full Name" },
            { "field": "email_business", "display_name": "Business Email" },
            { "field": "email_personal", "display_name": "Personal Email" },
            { "field": "phone_work", "display_name": "Work Phone" },
            { "field": "phone_mobile", "display_name": "Mobile Phone" },
            { "field": "phone_home", "display_name": "Home Phone" },
            { "field": "company", "display_name": "Company" },
            { "field": "title", "display_name": "Title" },
            { "field": "address1", "display_name": "Address Line 1" },
            { "field": "address2", "display_name": "Address Line 2" },
            { "field": "city", "display_name": "City" },
            { "field": "state", "display_name": "State" },
            { "field": "zip", "display_name": "Zip Code" },
            { "field": "country", "display_name": "Country" },
            { "field": "birthday", "display_name": "Birthday" },
            { "field": "relationship_start", "display_name": "Relationship Start" },
            { "field": "website", "display_name": "Website" },
            { "field": "linkedin", "display_name": "LinkedIn" },
            { "field": "twitter", "display_name": "Twitter" },
            { "field": "instagram", "display_name": "Instagram" },
            { "field": "notes", "display_name": "Notes" },
            { "field": "tags", "display_name": "Tags" },
            { "field": "category", "display_name": "Category" },
            { "field": "contactType", "display_name": "Contact Type" },
            { "field": "relationship_system", "display_name": "Relationship System" }
        ]>

        <!--- Build success response --->
        <cfset response.success = true>
        <cfset response.message = "">
        <cfset response.data = {
            "job": {
                "job_id": jobId,
                "status": job.status
            },
            "columns": columnsArray,
            "available_fields": availableFields
        }>

    <!--- ======================= POST: Update column mapping ======================= --->
    <cfelseif httpMethod eq "POST">

        <!--- Validate column_id --->
        <cfparam name="form.column_id" default="">
        <cfset columnId = val(form.column_id)>
        <cfif columnId lte 0>
            <cfset response.code = "MISSING_COLUMN_ID">
            <cfset response.message = "column_id is required">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
        </cfif>

        <!--- Verify column belongs to this job --->
        <cfset qColumnCheck = queryExecute(
            "SELECT c.column_id
            FROM import_v3_columns c
            INNER JOIN import_v3_jobs j ON c.job_id = j.job_id
            WHERE c.column_id = :column_id
              AND c.job_id = :job_id
              AND j.userid = :userid",
            {
                column_id: { value: columnId, cfsqltype: "cf_sql_integer" },
                job_id: { value: jobId, cfsqltype: "cf_sql_integer" },
                userid: { value: userid, cfsqltype: "cf_sql_integer" }
            },
            { datasource: application.datasource }
        )>

        <cfif qColumnCheck.recordCount eq 0>
            <cfset response.code = "ACCESS_DENIED">
            <cfset response.message = "Column not found or access denied">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
        </cfif>

        <!--- Get POST parameters --->
        <cfparam name="form.intent" default="">
        <cfparam name="form.target_key" default="">
        <cfparam name="form.transform_json" default="">
        <cfparam name="form.user_confirmed" default="">

        <cfset newIntent = trim(form.intent)>
        <cfset newTargetKey = trim(form.target_key)>
        <cfset newTransformJson = trim(form.transform_json)>
        <cfset newUserConfirmed = val(form.user_confirmed)>

        <!--- Validate intent if provided --->
        <cfif len(newIntent) and not arrayFindNoCase(VALID_INTENTS, newIntent)>
            <cfset response.code = "INVALID_INTENT">
            <cfset response.message = "Invalid intent value. Allowed: " & arrayToList(VALID_INTENTS, ", ")>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
        </cfif>

        <!--- Validate target_key is provided when required --->
        <cfif len(newIntent) and arrayFindNoCase(INTENTS_REQUIRING_TARGET, newIntent) and not len(newTargetKey)>
            <cfset response.code = "TARGET_KEY_REQUIRED">
            <cfset response.message = "target_key is required when intent is " & newIntent>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
        </cfif>

        <!--- Validate transform_json is valid JSON if provided --->
        <cfif len(newTransformJson)>
            <cftry>
                <cfset testJson = deserializeJSON(newTransformJson)>
                <cfcatch type="any">
                    <cfset response.code = "INVALID_JSON">
                    <cfset response.message = "transform_json must be valid JSON">
                    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
                </cfcatch>
            </cftry>
        </cfif>

        <!--- Track what changed for event logging --->
        <cfset changedFields = []>

        <!--- Build dynamic UPDATE query --->
        <cfset updateParts = []>
        <cfset updateParams = {
            column_id: { value: columnId, cfsqltype: "cf_sql_integer" },
            job_id: { value: jobId, cfsqltype: "cf_sql_integer" }
        }>

        <!--- Always update timestamp --->
        <cfset arrayAppend(updateParts, "updated_at = NOW()")>

        <!--- Intent --->
        <cfif len(form.intent) or structKeyExists(form, "intent")>
            <cfset arrayAppend(updateParts, "intent = :intent")>
            <cfif len(newIntent)>
                <cfset updateParams.intent = { value: newIntent, cfsqltype: "cf_sql_varchar", maxlength: 20 }>
            <cfelse>
                <cfset updateParams.intent = { value: "", cfsqltype: "cf_sql_varchar", null: true }>
            </cfif>
            <cfset arrayAppend(changedFields, "intent")>
        </cfif>

        <!--- Target key --->
        <cfif len(form.target_key) or structKeyExists(form, "target_key")>
            <cfset arrayAppend(updateParts, "target_key = :target_key")>
            <cfif len(newTargetKey)>
                <cfset updateParams.target_key = { value: newTargetKey, cfsqltype: "cf_sql_varchar", maxlength: 100 }>
            <cfelse>
                <cfset updateParams.target_key = { value: "", cfsqltype: "cf_sql_varchar", null: true }>
            </cfif>
            <cfset arrayAppend(changedFields, "target_key")>
        </cfif>

        <!--- Transform JSON --->
        <cfif len(form.transform_json) or structKeyExists(form, "transform_json")>
            <cfset arrayAppend(updateParts, "transform_json = :transform_json")>
            <cfif len(newTransformJson)>
                <cfset updateParams.transform_json = { value: newTransformJson, cfsqltype: "cf_sql_longvarchar" }>
            <cfelse>
                <cfset updateParams.transform_json = { value: "", cfsqltype: "cf_sql_longvarchar", null: true }>
            </cfif>
            <cfset arrayAppend(changedFields, "transform_json")>
        </cfif>

        <!--- User confirmed --->
        <cfif len(form.user_confirmed) or structKeyExists(form, "user_confirmed")>
            <cfset arrayAppend(updateParts, "user_confirmed = :user_confirmed")>
            <cfset updateParams.user_confirmed = { value: (newUserConfirmed gt 0 ? 1 : 0), cfsqltype: "cf_sql_tinyint" }>
            <cfset arrayAppend(changedFields, "user_confirmed")>
        </cfif>

        <!--- Execute update if we have fields to update --->
        <cfif arrayLen(updateParts) gt 1>
            <cfset updateSQL = "UPDATE import_v3_columns SET " & arrayToList(updateParts, ", ") & " WHERE column_id = :column_id AND job_id = :job_id">

            <cfset qUpdateResult = {}>
            <cftry>
                <cfset queryExecute(updateSQL, updateParams, { datasource: application.datasource, result: "qUpdateResult" })>
                <cfcatch type="any">
                    <cfset response.code = "UPDATE_FAILED">
                    <cfset response.message = "Failed to update column: " & cfcatch.message>
                    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
                </cfcatch>
            </cftry>

            <!--- If user_confirmed changed to 1 and job status is parsed, transition to mapping --->
            <cfif newUserConfirmed gt 0 and job.status eq "parsed">
                <cftry>
                    <cfset v3Service.setJobStatus(jobId, userid, "mapping")>
                    <cfcatch type="any"><!--- ignore status transition errors ---></cfcatch>
                </cftry>
            </cfif>

            <!--- Log event --->
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "columns_updated",
                detail = {
                    column_id: columnId,
                    changed_fields: changedFields,
                    intent: newIntent,
                    target_key: newTargetKey,
                    user_confirmed: newUserConfirmed
                }
            )>
        </cfif>

        <!--- Return updated columns list (same as GET) --->
        <cfset qColumns = queryExecute(
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
            { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>

        <!--- Build columns array --->
        <cfset columnsArray = []>
        <cfloop query="qColumns">
            <cfset columnData = {
                "column_id": qColumns.column_id,
                "source_column_index": qColumns.source_column_index,
                "source_name": qColumns.source_column_name,
                "intent": isNull(qColumns.intent) ? "" : qColumns.intent,
                "target_key": isNull(qColumns.target_key) ? "" : qColumns.target_key,
                "transform_json": isNull(qColumns.transform_json) ? "" : qColumns.transform_json,
                "user_confirmed": qColumns.user_confirmed,
                "mapped_field": isNull(qColumns.mapped_field) ? "" : qColumns.mapped_field,
                "is_custom_field": qColumns.is_custom_field,
                "confidence": isNull(qColumns.confidence) ? "" : qColumns.confidence,
                "sample_values": []
            }>

            <!--- Get sample values from facts --->
            <cfset qSamples = queryExecute(
                "SELECT DISTINCT f.raw_value
                FROM import_v3_facts f
                INNER JOIN import_v3_rows r ON f.row_id = r.row_id
                WHERE f.column_id = :column_id
                  AND r.job_id = :job_id
                  AND f.raw_value IS NOT NULL
                  AND TRIM(f.raw_value) != ''
                LIMIT 5",
                {
                    column_id: { value: qColumns.column_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: jobId, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            )>

            <cfset sampleVals = []>
            <cfloop query="qSamples">
                <cfset arrayAppend(sampleVals, qSamples.raw_value)>
            </cfloop>

            <!--- Fallback to stored sample_values --->
            <cfif arrayLen(sampleVals) eq 0 and len(qColumns.sample_values)>
                <cftry>
                    <cfset storedSamples = deserializeJSON(qColumns.sample_values)>
                    <cfif isArray(storedSamples)>
                        <cfloop array="#storedSamples#" index="sv">
                            <cfif len(trim(sv)) and arrayLen(sampleVals) lt 5>
                                <cfset arrayAppend(sampleVals, sv)>
                            </cfif>
                        </cfloop>
                    </cfif>
                    <cfcatch type="any"></cfcatch>
                </cftry>
            </cfif>

            <cfset columnData.sample_values = sampleVals>
            <cfset arrayAppend(columnsArray, columnData)>
        </cfloop>

        <!--- Get updated job status --->
        <cfset updatedJobResult = v3Service.getJobForUser(jobId, userid)>
        <cfset updatedJob = updatedJobResult.data.job>

        <!--- Build success response --->
        <cfset response.success = true>
        <cfset response.message = "Column mapping updated">
        <cfset response.data = {
            "job": {
                "job_id": jobId,
                "status": updatedJob.status
            },
            "columns": columnsArray,
            "updated_column_id": columnId
        }>

    <cfelse>
        <!--- Unsupported method --->
        <cfset response.code = "INVALID_METHOD">
        <cfset response.message = "Only GET and POST methods are supported">
    </cfif>

    <cfcatch type="any">
        <cftry>
            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "columns_error",
                detail = { error: cfcatch.message }
            )>
            <cfcatch type="any"></cfcatch>
        </cftry>
        <cfset response.code = "INTERNAL_ERROR">
        <cfset response.message = "An error occurred: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
