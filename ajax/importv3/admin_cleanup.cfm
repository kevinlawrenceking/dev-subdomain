<cfsilent>
<!---
    Contact Import V3 - Admin Cleanup Endpoint
    POST /ajax/importv3/admin_cleanup.cfm

    Purges old completed/failed import jobs and their associated data.
    Admin-only endpoint with feature flag requirement.

    Request Parameters:
    - csrf_token (required): CSRF protection token
    - retention_days (optional): Number of days to retain (default 30, min 1)
    - dry_run (optional): If "true", only report what would be deleted

    Response codes:
    - AUTH_REQUIRED: No session userid
    - ADMIN_REQUIRED: User is not an admin
    - CSRF_INVALID: Invalid or missing CSRF token
    - FEATURE_DISABLED: Import V3 feature is not enabled
    - INVALID_RETENTION: retention_days must be >= 1
    - CLEANUP_FAILED: Cleanup operation failed

    Security:
    - Requires admin session (session.isAdmin = true)
    - Requires importV3Enabled feature flag
    - Only deletes files within allowed upload directory
    - Idempotent: safe to run multiple times
--->

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
    <cfset response.code = "FEATURE_DISABLED">
    <cfset response.message = "Contact Import V3 is not enabled">
    <cfcontent type="application/json" reset="true">
    <cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid) OR session.userid LTE 0>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfheader statuscode="401">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- B) Admin check: Require admin session --->
    <cfif NOT isDefined("session.isAdmin") OR session.isAdmin NEQ true>
        <cfset response.code = "ADMIN_REQUIRED">
        <cfset response.message = "Administrator access required">
        <cfheader statuscode="403">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- C) CSRF: Generate token if not exists, then validate --->
    <cfif NOT structKeyExists(session, "csrf_token") OR NOT len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>
    <cfparam name="form.csrf_token" default="">
    <cfif NOT len(form.csrf_token) OR form.csrf_token NEQ session.csrf_token>
        <cfset response.code = "CSRF_INVALID">
        <cfset response.message = "Invalid or missing CSRF token">
        <cfheader statuscode="403">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- D) Parse parameters --->
    <cfparam name="form.retention_days" default="30">
    <cfparam name="url.retention_days" default="">
    <cfparam name="form.dry_run" default="false">
    <cfparam name="url.dry_run" default="">

    <!--- Prefer URL params, fall back to form --->
    <cfset retentionDays = val(url.retention_days)>
    <cfif retentionDays eq 0>
        <cfset retentionDays = val(form.retention_days)>
    </cfif>
    <cfif retentionDays lt 1>
        <cfset retentionDays = 30>
    </cfif>

    <cfset isDryRun = false>
    <cfif len(url.dry_run) AND (url.dry_run eq "true" OR url.dry_run eq "1")>
        <cfset isDryRun = true>
    <cfelseif len(form.dry_run) AND (form.dry_run eq "true" OR form.dry_run eq "1")>
        <cfset isDryRun = true>
    </cfif>

    <!--- E) Determine uploads base path --->
    <!--- The upload directory is: application.baseMediaPath & "\users" --->
    <!--- Files are stored at: application.baseMediaPath & "\users\" & userid & "\imports" --->
    <cfset uploadsBasePath = application.baseMediaPath & "\users">

    <!--- F) Initialize service and run cleanup --->
    <cfset v3Service = new services.ContactImportV3Service()>

    <cfset cleanupResult = v3Service.cleanupOldJobs(
        retention_days = retentionDays,
        uploads_base_path = uploadsBasePath,
        dry_run = isDryRun
    )>

    <!--- G) Build response --->
    <cfif cleanupResult.success>
        <cfset response.success = true>
        <cfif isDryRun>
            <cfset response.message = "Dry run completed. No data was deleted.">
        <cfelse>
            <cfset response.message = "Cleanup completed successfully.">
        </cfif>
        <cfset response.data = {
            "dry_run": cleanupResult.dry_run,
            "retention_days": cleanupResult.retention_days,
            "jobs_found": cleanupResult.jobs_found,
            "jobs_deleted": cleanupResult.jobs_deleted,
            "events_deleted": cleanupResult.events_deleted,
            "facts_deleted": cleanupResult.facts_deleted,
            "rows_deleted": cleanupResult.rows_deleted,
            "columns_deleted": cleanupResult.columns_deleted,
            "files_deleted": cleanupResult.files_deleted,
            "files_skipped": cleanupResult.files_skipped,
            "deleted_job_ids": cleanupResult.deleted_job_ids,
            "errors": cleanupResult.errors
        }>
    <cfelse>
        <cfset response.code = "CLEANUP_FAILED">
        <cfset response.message = "Cleanup failed">
        <cfset response.data = {
            "errors": cleanupResult.errors
        }>
    </cfif>

    <cfcatch type="any">
        <cfset response.code = "CLEANUP_FAILED">
        <cfset response.message = "Cleanup failed: " & cfcatch.message>
        <cfset response.data = {
            "detail": cfcatch.detail
        }>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
