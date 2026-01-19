<!---
    diagnostics.cfm
    Contact Import V3 - Job Diagnostics Endpoint

    Returns a diagnostic snapshot for debugging import jobs.
    Access: Job owner OR admin, feature flag must be enabled.

    Request Parameters:
    - job_id (required): The job to diagnose

    Response includes:
    - job: All job fields
    - counts: columns, rows, facts, row_results
    - row_status_distribution: Count by row status
    - recent_events: Last 25 events
--->
<cfsilent>
    <cfset response = {
        "success": false,
        "code": "",
        "message": "",
        "data": {}
    }>

    <!--- Feature flag check --->
    <cfif NOT structKeyExists(application, "features")
        OR NOT structKeyExists(application.features, "importV3Enabled")
        OR NOT application.features.importV3Enabled>

        <!--- Also check allowlist for current user --->
        <cfset userAllowed = false>
        <cfif structKeyExists(session, "userid") AND isNumeric(session.userid)>
            <cfif structKeyExists(application.features, "importV3AllowedUsers")
                AND isArray(application.features.importV3AllowedUsers)
                AND arrayFind(application.features.importV3AllowedUsers, session.userid) GT 0>
                <cfset userAllowed = true>
            </cfif>
        </cfif>

        <cfif NOT userAllowed>
            <cfset response.code = "FEATURE_DISABLED">
            <cfset response.message = "Contact Import V3 is not enabled">
            <cfcontent type="application/json" reset="true">
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfif>
    </cfif>

    <!--- Auth check --->
    <cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid) OR session.userid LTE 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfheader statuscode="401">
        <cfcontent type="application/json" reset="true">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset currentUserid = session.userid>

    <!--- Check admin status --->
    <cfset isAdmin = false>
    <cfif structKeyExists(session, "userrole")>
        <cfif session.userrole EQ "Admin" OR session.userrole EQ "Administrator">
            <cfset isAdmin = true>
        </cfif>
    </cfif>

    <!--- Require job_id parameter --->
    <cfparam name="url.job_id" default="">
    <cfif NOT isNumeric(url.job_id) OR url.job_id LTE 0>
        <cfset response.code = "INVALID_JOB_ID">
        <cfset response.message = "job_id parameter is required and must be a positive integer">
        <cfcontent type="application/json" reset="true">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset jobId = val(url.job_id)>

    <cftry>
        <!--- Fetch job --->
        <cfquery name="qJob" datasource="#application.datasource#">
            SELECT
                job_id, userid, source_filename, file_type, file_size, file_hash,
                stored_file_path, status, error_message,
                created_at, updated_at, started_at, finished_at,
                total_rows, parsed_rows, valid_rows, problem_rows, dupe_rows,
                imported_rows, updated_rows, skipped_rows,
                import_mode, allow_blank_overwrite, relationship_system_default
            FROM import_v3_jobs
            WHERE job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif qJob.recordCount EQ 0>
            <cfset response.code = "JOB_NOT_FOUND">
            <cfset response.message = "Job not found">
            <cfheader statuscode="404">
            <cfcontent type="application/json" reset="true">
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfif>

        <!--- Ownership check: must be owner OR admin --->
        <cfif qJob.userid NEQ currentUserid AND NOT isAdmin>
            <cfset response.code = "ACCESS_DENIED">
            <cfset response.message = "You do not have access to this job">
            <cfheader statuscode="403">
            <cfcontent type="application/json" reset="true">
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfif>

        <!--- Build job struct --->
        <cfset jobData = {
            "job_id": qJob.job_id,
            "userid": qJob.userid,
            "source_filename": qJob.source_filename,
            "file_type": qJob.file_type,
            "file_size": qJob.file_size,
            "file_hash": qJob.file_hash,
            "stored_file_path": qJob.stored_file_path,
            "status": qJob.status,
            "error_message": qJob.error_message,
            "created_at": qJob.created_at,
            "updated_at": qJob.updated_at,
            "started_at": qJob.started_at,
            "finished_at": qJob.finished_at,
            "total_rows": qJob.total_rows,
            "parsed_rows": qJob.parsed_rows,
            "valid_rows": qJob.valid_rows,
            "problem_rows": qJob.problem_rows,
            "dupe_rows": qJob.dupe_rows,
            "imported_rows": qJob.imported_rows,
            "updated_rows": qJob.updated_rows,
            "skipped_rows": qJob.skipped_rows,
            "import_mode": qJob.import_mode,
            "allow_blank_overwrite": qJob.allow_blank_overwrite,
            "relationship_system_default": qJob.relationship_system_default
        }>

        <!--- Count columns --->
        <cfquery name="qColumnCount" datasource="#application.datasource#">
            SELECT COUNT(*) as cnt FROM import_v3_columns
            WHERE job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Count rows --->
        <cfquery name="qRowCount" datasource="#application.datasource#">
            SELECT COUNT(*) as cnt FROM import_v3_rows
            WHERE job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Count facts --->
        <cfquery name="qFactCount" datasource="#application.datasource#">
            SELECT COUNT(*) as cnt FROM import_v3_facts f
            JOIN import_v3_rows r ON f.row_id = r.row_id
            WHERE r.job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Count row_results --->
        <cfquery name="qResultCount" datasource="#application.datasource#">
            SELECT COUNT(*) as cnt FROM import_v3_row_results
            WHERE job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset counts = {
            "columns": qColumnCount.cnt,
            "rows": qRowCount.cnt,
            "facts": qFactCount.cnt,
            "row_results": qResultCount.cnt
        }>

        <!--- Row status distribution --->
        <cfquery name="qRowStatus" datasource="#application.datasource#">
            SELECT status, COUNT(*) as cnt
            FROM import_v3_rows
            WHERE job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
            GROUP BY status
            ORDER BY cnt DESC
        </cfquery>

        <cfset rowStatusDist = {}>
        <cfloop query="qRowStatus">
            <cfset rowStatusDist[qRowStatus.status] = qRowStatus.cnt>
        </cfloop>

        <!--- Validation error summary --->
        <cfquery name="qValidationErrors" datasource="#application.datasource#">
            SELECT f.validation_code, COUNT(*) as cnt
            FROM import_v3_facts f
            JOIN import_v3_rows r ON f.row_id = r.row_id
            WHERE r.job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
              AND f.is_valid = 0
              AND f.validation_code IS NOT NULL
            GROUP BY f.validation_code
            ORDER BY cnt DESC
            LIMIT 10
        </cfquery>

        <cfset validationErrors = []>
        <cfloop query="qValidationErrors">
            <cfset arrayAppend(validationErrors, {
                "code": qValidationErrors.validation_code,
                "count": qValidationErrors.cnt
            })>
        </cfloop>

        <!--- Last 25 events --->
        <cfquery name="qEvents" datasource="#application.datasource#">
            SELECT event_id, event_type, event_detail, row_id, userid, created_at
            FROM import_v3_events
            WHERE job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
            ORDER BY created_at DESC
            LIMIT 25
        </cfquery>

        <cfset recentEvents = []>
        <cfloop query="qEvents">
            <cfset eventItem = {
                "event_id": qEvents.event_id,
                "event_type": qEvents.event_type,
                "row_id": qEvents.row_id,
                "userid": qEvents.userid,
                "created_at": qEvents.created_at
            }>
            <!--- Parse event_detail if JSON --->
            <cfif len(qEvents.event_detail)>
                <cftry>
                    <cfset eventItem.detail = deserializeJSON(qEvents.event_detail)>
                    <cfcatch>
                        <cfset eventItem.detail = qEvents.event_detail>
                    </cfcatch>
                </cftry>
            <cfelse>
                <cfset eventItem.detail = "">
            </cfif>
            <cfset arrayAppend(recentEvents, eventItem)>
        </cfloop>

        <!--- Column mappings --->
        <cfquery name="qColumns" datasource="#application.datasource#">
            SELECT column_id, source_column_index, source_column_name,
                   mapped_field, is_custom_field, confidence, user_confirmed
            FROM import_v3_columns
            WHERE job_id = <cfqueryparam value="#jobId#" cfsqltype="cf_sql_integer">
            ORDER BY source_column_index
        </cfquery>

        <cfset columnMappings = []>
        <cfloop query="qColumns">
            <cfset arrayAppend(columnMappings, {
                "column_id": qColumns.column_id,
                "index": qColumns.source_column_index,
                "source_name": qColumns.source_column_name,
                "mapped_field": qColumns.mapped_field,
                "is_custom": qColumns.is_custom_field,
                "confidence": qColumns.confidence,
                "confirmed": qColumns.user_confirmed
            })>
        </cfloop>

        <!--- Build response --->
        <cfset response.success = true>
        <cfset response.data = {
            "job": jobData,
            "counts": counts,
            "row_status_distribution": rowStatusDist,
            "validation_error_summary": validationErrors,
            "column_mappings": columnMappings,
            "recent_events": recentEvents,
            "diagnostics_generated_at": now(),
            "access_type": isAdmin ? "admin" : "owner"
        }>

        <cfcatch type="any">
            <cfset response.code = "QUERY_ERROR">
            <cfset response.message = "Diagnostics failed: " & cfcatch.message>
        </cfcatch>
    </cftry>
</cfsilent>
<cfcontent type="application/json" reset="true">
<cfoutput>#serializeJSON(response)#</cfoutput>
