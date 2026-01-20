/**
 * ContactImportV3Service.cfc
 * 
 * Core service for Contact Import V3 operations.
 * Handles job management, ownership verification, locking, status transitions, and event logging.
 * 
 * All public methods return stable response envelopes:
 *   Success: {success: true, message: "", data: {...}}
 *   Failure: {success: false, code: "ERROR_CODE", message: "...", data: {...}}
 * 
 * CRITICAL: All SQL queries enforce ownership via WHERE clauses (not post-query IF checks).
 * CRITICAL: All queries use cfqueryparam - no string concatenation.
 * 
 * @author TAO Development
 * @created 2026-01-17
 */
component displayname="ContactImportV3Service" accessors="true" output="false" {

    // =============================================================
    // VALID STATUS VALUES AND TRANSITIONS
    // =============================================================
    
    variables.VALID_STATUSES = [
        "created",
        "uploaded",
        "parsing",
        "parsed",
        "mapping",
        "reviewing",
        "finalizing",
        "completed",
        "failed",
        "cancelled"
    ];
    
    variables.STATUS_TRANSITIONS = {
        "created": ["uploaded", "failed", "cancelled"],
        "uploaded": ["parsing", "failed", "cancelled"],
        "parsing": ["parsed", "failed", "cancelled"],
        "parsed": ["mapping", "failed", "cancelled"],
        "mapping": ["reviewing", "failed", "cancelled"],
        "reviewing": ["finalizing", "failed", "cancelled"],
        "finalizing": ["completed", "failed", "cancelled"],
        "completed": [],
        "failed": [],
        "cancelled": []
    };

    // =============================================================
    // CONSTRUCTOR
    // =============================================================
    
    public ContactImportV3Service function init() {
        return this;
    }

    // =============================================================
    // JSON ENVELOPE HELPERS
    // =============================================================
    
    public struct function ok(struct data = {}, string message = "") {
        return {
            "success": true,
            "message": arguments.message,
            "data": arguments.data
        };
    }
    
    public struct function fail(required string code, required string message, struct data = {}) {
        return {
            "success": false,
            "code": arguments.code,
            "message": arguments.message,
            "data": arguments.data
        };
    }

    // =============================================================
    // FEATURE FLAG HELPERS
    // =============================================================

    /**
     * Check if Import V3 is enabled for a specific user.
     * Uses DB-driven feature flags with per-user allowlist override.
     *
     * Logic:
     * - If global flag import_v3_enabled = true, all users have access
     * - If global flag = false, only users in feature_flag_users allowlist have access
     * - Falls back to false if flags not loaded (safe default)
     *
     * @param userid The user ID to check
     * @return boolean True if user can access Import V3
     */
    public boolean function isImportV3Enabled(required numeric userid) {
        try {
            // Check if features struct exists
            if (!structKeyExists(application, "features")) {
                return false;
            }

            // If global flag is enabled, all users have access
            if (structKeyExists(application.features, "importV3Enabled")
                && application.features.importV3Enabled eq true) {
                return true;
            }

            // Check per-user allowlist
            if (structKeyExists(application.features, "importV3AllowedUsers")
                && isArray(application.features.importV3AllowedUsers)
                && arrayFind(application.features.importV3AllowedUsers, arguments.userid) gt 0) {
                return true;
            }

            return false;
        } catch (any e) {
            // On any error, return false (safe default)
            return false;
        }
    }

    /**
     * Get current feature flag status for diagnostics.
     * Admin-only - should be gated by caller.
     *
     * @return struct Feature flag status information
     */
    public struct function getFeatureFlagStatus() {
        var status = {
            "importV3Enabled": false,
            "allowedUserCount": 0,
            "allowedUserIds": [],
            "cacheAge": 0,
            "cacheTTL": 60
        };

        try {
            if (structKeyExists(application, "features")) {
                if (structKeyExists(application.features, "importV3Enabled")) {
                    status.importV3Enabled = application.features.importV3Enabled;
                }
                if (structKeyExists(application.features, "importV3AllowedUsers")) {
                    status.allowedUserIds = application.features.importV3AllowedUsers;
                    status.allowedUserCount = arrayLen(application.features.importV3AllowedUsers);
                }
            }
            if (structKeyExists(application, "featureFlagCacheTime")) {
                status.cacheAge = dateDiff("s", application.featureFlagCacheTime, now());
            }
            if (structKeyExists(application, "featureFlagCacheTTL")) {
                status.cacheTTL = application.featureFlagCacheTTL;
            }
        } catch (any e) {
            // Ignore errors, return defaults
        }

        return status;
    }

    // =============================================================
    // JOB HELPERS
    // =============================================================
    
    public struct function getJob(required numeric job_id) {
        var result = {
            "found": false
        };
        
        try {
            var qJob = queryExecute(
                "SELECT 
                    job_id,
                    userid,
                    source_filename,
                    file_type,
                    file_size,
                    file_hash,
                    stored_file_path,
                    status,
                    error_message,
                    created_at,
                    updated_at,
                    started_at,
                    finished_at,
                    total_rows,
                    parsed_rows,
                    valid_rows,
                    problem_rows,
                    dupe_rows,
                    imported_rows,
                    updated_rows,
                    skipped_rows,
                    options_json,
                    import_mode,
                    allow_blank_overwrite,
                    relationship_system_default,
                    folder_assignment_json
                FROM import_v3_jobs
                WHERE job_id = :job_id",
                { job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );
            
            if (qJob.recordCount eq 1) {
                result.found = true;
                result.job = queryGetRow(qJob, 1);
            }
        } catch (any e) {
            result.found = false;
        }
        
        return result;
    }
    
    public struct function assertJobOwnership(required numeric job_id, required numeric userid) {
        try {
            var qCheck = queryExecute(
                "SELECT job_id
                FROM import_v3_jobs
                WHERE job_id = :job_id
                  AND userid = :userid",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );
            
            if (qCheck.recordCount eq 1) {
                return { "valid": true };
            } else {
                return fail(
                    code = "ACCESS_DENIED",
                    message = "You do not have access to this import job.",
                    data = { job_id: arguments.job_id }
                );
            }
        } catch (any e) {
            return fail(
                code = "ACCESS_DENIED",
                message = "Unable to verify job ownership.",
                data = { job_id: arguments.job_id }
            );
        }
    }

    public struct function getJobForUser(required numeric job_id, required numeric userid) {
        try {
            var qJob = queryExecute(
                "SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
                    stored_file_path, status, error_message, created_at, updated_at,
                    started_at, finished_at, total_rows, parsed_rows, valid_rows,
                    problem_rows, dupe_rows, imported_rows, updated_rows, skipped_rows,
                    options_json, import_mode, allow_blank_overwrite,
                    relationship_system_default, folder_assignment_json
                FROM import_v3_jobs WHERE job_id = :job_id AND userid = :userid",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );
            
            if (qJob.recordCount eq 0) {
                var qExists = queryExecute(
                    "SELECT job_id FROM import_v3_jobs WHERE job_id = :job_id",
                    { job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" } },
                    { datasource: application.datasource }
                );
                
                if (qExists.recordCount eq 0) {
                    return fail(code = "NOT_FOUND", message = "Import job not found.", data = { job_id: arguments.job_id });
                } else {
                    return fail(code = "ACCESS_DENIED", message = "You do not have access to this import job.", data = { job_id: arguments.job_id });
                }
            }
            
            return ok(data = { "job": queryGetRow(qJob, 1) }, message = "");
            
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "error_get_job", detail = { error: e.message });
            return fail(code = "INTERNAL_ERROR", message = "An error occurred retrieving the job.", data = { job_id: arguments.job_id });
        }
    }

    // =============================================================
    // EVENT LOGGING
    // =============================================================
    
    public boolean function logEvent(
        required numeric job_id,
        required numeric userid,
        required string event_type,
        struct detail = {},
        numeric row_id = 0,
        string correlation_id = ""
    ) {
        try {
            var detailJson = "";
            if (!structIsEmpty(arguments.detail)) {
                if (len(arguments.correlation_id)) {
                    arguments.detail["correlation_id"] = arguments.correlation_id;
                }
                detailJson = serializeJSON(arguments.detail);
            }
            
            if (arguments.row_id gt 0) {
                queryExecute(
                    "INSERT INTO import_v3_events (job_id, userid, event_type, event_detail, row_id, created_at)
                    VALUES (:job_id, :userid, :event_type, :event_detail, :row_id, NOW())",
                    {
                        job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                        event_type: { value: arguments.event_type, cfsqltype: "cf_sql_varchar", maxlength: 50 },
                        event_detail: { value: detailJson, cfsqltype: "cf_sql_longvarchar", null: !len(detailJson) },
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource: application.datasource }
                );
            } else {
                queryExecute(
                    "INSERT INTO import_v3_events (job_id, userid, event_type, event_detail, created_at)
                    VALUES (:job_id, :userid, :event_type, :event_detail, NOW())",
                    {
                        job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                        event_type: { value: arguments.event_type, cfsqltype: "cf_sql_varchar", maxlength: 50 },
                        event_detail: { value: detailJson, cfsqltype: "cf_sql_longvarchar", null: !len(detailJson) }
                    },
                    { datasource: application.datasource }
                );
            }
            return true;
        } catch (any e) {
            return false;
        }
    }

    // ============================================================
    // LOCKING - Uses status transitions as lock mechanism
    // ============================================================
    
    public struct function acquireJobLock(
        required numeric job_id,
        required numeric userid,
        required string lock_token,
        required string lock_purpose
    ) {
        try {
            var targetStatus = "";
            var validSourceStatuses = [];
            
            switch (arguments.lock_purpose) {
                case "finalize":
                    targetStatus = "finalizing";
                    validSourceStatuses = ["reviewing"];
                    break;
                case "parse":
                    targetStatus = "parsing";
                    validSourceStatuses = ["uploaded"];
                    break;
                default:
                    return { "acquired": false, "message": "Unknown lock purpose: " & arguments.lock_purpose };
            }
            
            // Use parameterized list for status check (safe pattern)
            var statusListValue = arrayToList(validSourceStatuses, ",");

            var qResult = {};
            queryExecute(
                "UPDATE import_v3_jobs SET status = :target_status, updated_at = NOW()
                 WHERE job_id = :job_id AND userid = :userid AND status IN (:status_list)",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                    target_status: { value: targetStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                    status_list: { value: statusListValue, cfsqltype: "cf_sql_varchar", list: true }
                },
                { datasource: application.datasource, result: "qResult" }
            );
            
            if (qResult.recordCount eq 1) {
                logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_acquired", detail = { purpose: arguments.lock_purpose });
                return { "acquired": true, "message": "" };
            } else {
                var jobResult = getJobForUser(arguments.job_id, arguments.userid);
                if (!jobResult.success) {
                    return { "acquired": false, "message": jobResult.message };
                }
                return { "acquired": false, "message": "Job cannot be locked from current status: " & jobResult.data.job.status };
            }
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_error", detail = { error: e.message });
            return { "acquired": false, "message": "Lock acquisition failed: " & e.message };
        }
    }
    
    public struct function releaseJobLock(
        required numeric job_id,
        required numeric userid,
        required string lock_token
    ) {
        try {
            var jobResult = getJobForUser(arguments.job_id, arguments.userid);
            if (!jobResult.success) {
                return { "released": false, "message": jobResult.message };
            }
            
            var job = jobResult.data.job;
            var targetStatus = "";
            switch (job.status) {
                case "finalizing": targetStatus = "reviewing"; break;
                case "parsing": targetStatus = "uploaded"; break;
                default:
                    return { "released": false, "message": "Job is not currently locked. Status: " & job.status };
            }
            
            queryExecute(
                "UPDATE import_v3_jobs SET status = :target_status, updated_at = NOW() WHERE job_id = :job_id AND userid = :userid",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                    target_status: { value: targetStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 }
                },
                { datasource: application.datasource }
            );
            
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_released", detail = { previous_status: job.status, new_status: targetStatus });
            return { "released": true };
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_release_error", detail = { error: e.message });
            return { "released": false, "message": "Lock release failed: " & e.message };
        }
    }


    // ============================================================
    // STATUS TRANSITIONS
    // ============================================================
    
    public struct function setJobStatus(
        required numeric job_id,
        required numeric userid,
        required string new_status,
        string error_message = ""
    ) {
        try {
            if (!arrayFindNoCase(variables.VALID_STATUSES, arguments.new_status)) {
                return fail(code = "INVALID_STATUS", message = "Invalid status: " & arguments.new_status, data = { valid_statuses: variables.VALID_STATUSES });
            }
            
            if (arguments.new_status eq "failed" && !len(trim(arguments.error_message))) {
                return fail(code = "MISSING_ERROR_MESSAGE", message = "Error message required for failed status.", data = {});
            }
            
            var jobResult = getJobForUser(arguments.job_id, arguments.userid);
            if (!jobResult.success) { return jobResult; }
            
            var currentStatus = jobResult.data.job.status;
            
            if (!isValidTransition(currentStatus, arguments.new_status)) {
                return fail(code = "INVALID_STATE", message = "Cannot transition from " & currentStatus & " to " & arguments.new_status, data = { current_status: currentStatus, allowed: structKeyExists(variables.STATUS_TRANSITIONS, currentStatus) ? variables.STATUS_TRANSITIONS[currentStatus] : [] });
            }
            
            var additionalFields = "";
            var additionalParams = {};
            
            if (arguments.new_status eq "parsing" || arguments.new_status eq "finalizing") {
                additionalFields = ", started_at = NOW()";
            }
            if (arguments.new_status eq "completed" || arguments.new_status eq "failed" || arguments.new_status eq "cancelled") {
                additionalFields = ", finished_at = NOW()";
            }
            if (arguments.new_status eq "failed" && len(arguments.error_message)) {
                additionalFields = additionalFields & ", error_message = :error_message";
                additionalParams.error_message = { value: arguments.error_message, cfsqltype: "cf_sql_longvarchar" };
            }
            
            var params = {
                job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                new_status: { value: arguments.new_status, cfsqltype: "cf_sql_varchar", maxlength: 20 }
            };
            structAppend(params, additionalParams);
            
            queryExecute("UPDATE import_v3_jobs SET status = :new_status, updated_at = NOW() " & additionalFields & " WHERE job_id = :job_id AND userid = :userid", params, { datasource: application.datasource });
            
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "status_changed", detail = { from_status: currentStatus, to_status: arguments.new_status });
            
            return ok(data = { previous_status: currentStatus, new_status: arguments.new_status }, message = "Status updated.");
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "status_change_error", detail = { error: e.message });
            return fail(code = "INTERNAL_ERROR", message = "Status update failed.", data = { job_id: arguments.job_id });
        }
    }
    
    private boolean function isValidTransition(required string from_status, required string to_status) {
        if (arguments.from_status eq arguments.to_status) { return true; }
        if (!structKeyExists(variables.STATUS_TRANSITIONS, arguments.from_status)) { return false; }
        return arrayFindNoCase(variables.STATUS_TRANSITIONS[arguments.from_status], arguments.to_status) > 0;
    }

    // ============================================================
    // ADMIN CLEANUP - Purge old completed/failed jobs
    // ============================================================

    /**
     * Cleanup old import jobs and their associated data.
     * Only deletes jobs with status IN ('completed', 'failed') older than retention_days.
     * Deletes in correct FK dependency order and attempts file deletion.
     * All database deletes are wrapped in a transaction for atomicity.
     *
     * @param retention_days Number of days to retain jobs (default 30)
     * @param uploads_base_path Base path for uploaded files (required for file deletion)
     * @param dry_run If true, only reports what would be deleted without actually deleting
     * @return struct with summary counts and any errors
     */
    public struct function cleanupOldJobs(
        numeric retention_days = 30,
        required string uploads_base_path,
        boolean dry_run = false
    ) {
        var result = {
            "success": true,
            "dry_run": arguments.dry_run,
            "retention_days": arguments.retention_days,
            "jobs_found": 0,
            "jobs_deleted": 0,
            "events_deleted": 0,
            "facts_deleted": 0,
            "rows_deleted": 0,
            "columns_deleted": 0,
            "files_deleted": 0,
            "files_skipped": 0,
            "errors": [],
            "deleted_job_ids": []
        };

        try {
            // Validate uploads_base_path is a real directory
            if (!directoryExists(arguments.uploads_base_path)) {
                arrayAppend(result.errors, "uploads_base_path does not exist: " & arguments.uploads_base_path);
                result.success = false;
                return result;
            }

            // Canonicalize and normalize the base path for comparison
            var canonicalBasePath = getCanonicalPath(arguments.uploads_base_path);
            var normalizedBasePath = replace(lcase(canonicalBasePath), "/", "\", "all");
            if (right(normalizedBasePath, 1) eq "\") {
                normalizedBasePath = left(normalizedBasePath, len(normalizedBasePath) - 1);
            }

            // Find jobs eligible for cleanup
            var qJobs = queryExecute(
                "SELECT job_id, userid, stored_file_path, status, created_at, finished_at
                 FROM import_v3_jobs
                 WHERE status IN ('completed', 'failed')
                   AND finished_at < DATE_SUB(NOW(), INTERVAL :retention_days DAY)
                 LIMIT 1000",
                {
                    retention_days: { value: arguments.retention_days, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );

            result.jobs_found = qJobs.recordCount;

            if (qJobs.recordCount eq 0) {
                return result;
            }

            // Collect job IDs for batch deletion (using parameterized queries with list=true)
            var jobIds = [];
            for (var row in qJobs) {
                arrayAppend(jobIds, row.job_id);
            }
            var jobIdList = arrayToList(jobIds, ",");

            if (arguments.dry_run) {
                // Dry run: just count what would be deleted using parameterized queries
                var qEventCount = queryExecute(
                    "SELECT COUNT(*) as cnt FROM import_v3_events WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource }
                );
                result.events_deleted = qEventCount.cnt;

                // Get row_ids for this job to count facts
                var qRowIds = queryExecute(
                    "SELECT row_id FROM import_v3_rows WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource }
                );
                if (qRowIds.recordCount gt 0) {
                    var rowIdList = valueList(qRowIds.row_id);
                    var qFactCount = queryExecute(
                        "SELECT COUNT(*) as cnt FROM import_v3_facts WHERE row_id IN (:rowIdList)",
                        { rowIdList: { value: rowIdList, cfsqltype: "cf_sql_integer", list: true } },
                        { datasource: application.datasource }
                    );
                    result.facts_deleted = qFactCount.cnt;
                }

                var qRowCount = queryExecute(
                    "SELECT COUNT(*) as cnt FROM import_v3_rows WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource }
                );
                result.rows_deleted = qRowCount.cnt;

                var qColCount = queryExecute(
                    "SELECT COUNT(*) as cnt FROM import_v3_columns WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource }
                );
                result.columns_deleted = qColCount.cnt;

                result.jobs_deleted = qJobs.recordCount;
                result.deleted_job_ids = jobIds;

                // Count files that would be deleted
                for (var row in qJobs) {
                    if (len(trim(row.stored_file_path)) && isPathWithinBase(row.stored_file_path, normalizedBasePath)) {
                        if (fileExists(row.stored_file_path)) {
                            result.files_deleted++;
                        } else {
                            result.files_skipped++;
                        }
                    } else {
                        result.files_skipped++;
                    }
                }

                return result;
            }

            // Actual deletion - wrapped in transaction for atomicity
            // File deletion happens AFTER transaction commits (files can't be rolled back)
            var filesToDelete = [];

            transaction {
                // 1. Delete events (references job_id and optionally row_id)
                var qEventDel = {};
                queryExecute(
                    "DELETE FROM import_v3_events WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource, result: "qEventDel" }
                );
                result.events_deleted = structKeyExists(qEventDel, "recordCount") ? qEventDel.recordCount : 0;

                // 2. Get row_ids first for facts deletion
                var qRowIds = queryExecute(
                    "SELECT row_id FROM import_v3_rows WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource }
                );

                // 3. Delete facts (references row_id)
                if (qRowIds.recordCount gt 0) {
                    var rowIdList = valueList(qRowIds.row_id);
                    var qFactDel = {};
                    queryExecute(
                        "DELETE FROM import_v3_facts WHERE row_id IN (:rowIdList)",
                        { rowIdList: { value: rowIdList, cfsqltype: "cf_sql_integer", list: true } },
                        { datasource: application.datasource, result: "qFactDel" }
                    );
                    result.facts_deleted = structKeyExists(qFactDel, "recordCount") ? qFactDel.recordCount : 0;
                }

                // 4. Delete rows (references job_id)
                var qRowDel = {};
                queryExecute(
                    "DELETE FROM import_v3_rows WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource, result: "qRowDel" }
                );
                result.rows_deleted = structKeyExists(qRowDel, "recordCount") ? qRowDel.recordCount : 0;

                // 5. Delete columns (references job_id)
                var qColDel = {};
                queryExecute(
                    "DELETE FROM import_v3_columns WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource, result: "qColDel" }
                );
                result.columns_deleted = structKeyExists(qColDel, "recordCount") ? qColDel.recordCount : 0;

                // 6. Delete jobs (parent table - last in transaction)
                var qJobDel = {};
                queryExecute(
                    "DELETE FROM import_v3_jobs WHERE job_id IN (:jobIdList)",
                    { jobIdList: { value: jobIdList, cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource, result: "qJobDel" }
                );
                result.jobs_deleted = structKeyExists(qJobDel, "recordCount") ? qJobDel.recordCount : 0;
                result.deleted_job_ids = jobIds;

                // Collect files to delete (will be deleted after transaction commits)
                for (var row in qJobs) {
                    if (len(trim(row.stored_file_path))) {
                        arrayAppend(filesToDelete, row.stored_file_path);
                    }
                }
            }

            // 7. Delete uploaded files AFTER transaction commits (only if within allowed base path)
            for (var filePath in filesToDelete) {
                if (isPathWithinBase(filePath, normalizedBasePath)) {
                    try {
                        if (fileExists(filePath)) {
                            fileDelete(filePath);
                            result.files_deleted++;
                        } else {
                            result.files_skipped++;
                        }
                    } catch (any e) {
                        arrayAppend(result.errors, "Failed to delete file: " & filePath & " - " & e.message);
                        result.files_skipped++;
                    }
                } else {
                    result.files_skipped++;
                    arrayAppend(result.errors, "File outside allowed path (skipped): " & filePath);
                }
            }

        } catch (any e) {
            result.success = false;
            arrayAppend(result.errors, "Cleanup failed: " & e.message);
        }

        return result;
    }

    /**
     * Helper: Check if a file path is within the allowed base path.
     * Uses canonical path resolution to prevent directory traversal attacks.
     * Prevents arbitrary file deletion outside the uploads directory.
     */
    private boolean function isPathWithinBase(required string filePath, required string basePath) {
        try {
            // Canonicalize the file path to resolve any .. sequences
            var canonicalFilePath = getCanonicalPath(arguments.filePath);
            var normalizedFilePath = replace(lcase(canonicalFilePath), "/", "\", "all");
            // Check if resolved file path starts with base path
            return left(normalizedFilePath, len(arguments.basePath)) eq arguments.basePath;
        } catch (any e) {
            // If canonicalization fails, reject the path for safety
            return false;
        }
    }

    /**
     * Helper: Get canonical path using Java File class.
     * Resolves . and .. sequences and normalizes the path.
     */
    private string function getCanonicalPath(required string path) {
        var javaFile = createObject("java", "java.io.File").init(arguments.path);
        return javaFile.getCanonicalPath();
    }

    // ============================================================
    // USER JOB HISTORY
    // ============================================================

    /**
     * Get import job history for a specific user.
     * Returns a query object for template iteration.
     *
     * @param userid The user ID to filter by
     * @param limit Maximum number of jobs to return (default 25)
     * @return query object with job records
     */
    public query function getUserJobHistory(required numeric userid, numeric limit = 25) {
        return queryExecute(
            "SELECT
                job_id,
                source_filename,
                file_type,
                status,
                created_at,
                finished_at,
                total_rows,
                parsed_rows,
                valid_rows,
                problem_rows,
                dupe_rows AS duplicate_rows,
                skipped_rows,
                imported_rows,
                updated_rows,
                error_message
            FROM import_v3_jobs
            WHERE userid = :userid
            ORDER BY created_at DESC
            LIMIT :limit",
            {
                userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                limit: { value: arguments.limit, cfsqltype: "cf_sql_integer" }
            },
            { datasource: application.datasource }
        );
    }

    /**
     * Alias for getUserJobHistory for backward compatibility.
     *
     * @param userid The user ID to filter by
     * @param limit Maximum number of jobs to return (default 25)
     * @return query object with job records
     */
    public query function getJobHistory(required numeric userid, numeric limit = 25) {
        return getUserJobHistory(arguments.userid, arguments.limit);
    }

    // ============================================================
    // ADMIN DASHBOARD - Job observability
    // ============================================================

    /**
     * Get recent import jobs for admin dashboard.
     * Returns last N jobs with key metrics.
     *
     * @param limit Maximum number of jobs to return (default 50)
     * @return struct with success flag and jobs array
     */
    public struct function getRecentJobs(numeric limit = 50) {
        try {
            var qJobs = queryExecute(
                "SELECT
                    j.job_id,
                    j.userid,
                    u.userfirst,
                    u.userlast,
                    u.useremail,
                    j.source_filename,
                    j.file_type,
                    j.status,
                    j.created_at,
                    j.finished_at,
                    j.total_rows,
                    j.imported_rows,
                    j.updated_rows,
                    j.problem_rows,
                    j.dupe_rows,
                    j.error_message
                FROM import_v3_jobs j
                LEFT JOIN taousers u ON j.userid = u.userid
                ORDER BY j.created_at DESC
                LIMIT :limit",
                { limit: { value: arguments.limit, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            var jobs = [];
            for (var row in qJobs) {
                arrayAppend(jobs, {
                    "job_id": row.job_id,
                    "userid": row.userid,
                    "user_name": trim(row.userfirst & " " & row.userlast),
                    "user_email": row.useremail,
                    "source_filename": row.source_filename,
                    "file_type": row.file_type,
                    "status": row.status,
                    "created_at": row.created_at,
                    "finished_at": row.finished_at,
                    "total_rows": row.total_rows,
                    "imported_rows": row.imported_rows,
                    "updated_rows": row.updated_rows,
                    "problem_rows": row.problem_rows,
                    "dupe_rows": row.dupe_rows,
                    "error_message": row.error_message
                });
            }

            return ok(data = { "jobs": jobs }, message = "");
        } catch (any e) {
            return fail(code = "QUERY_ERROR", message = "Failed to load jobs: " & e.message, data = {});
        }
    }

    /**
     * Get dashboard summary statistics.
     * Returns counts and averages for monitoring.
     *
     * @return struct with stats
     */
    public struct function getDashboardStats() {
        try {
            // Today's counts
            var qToday = queryExecute(
                "SELECT
                    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_today,
                    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed_today,
                    COUNT(*) as total_today
                FROM import_v3_jobs
                WHERE DATE(created_at) = CURDATE()",
                {},
                { datasource: application.datasource }
            );

            // 7-day averages
            var qWeek = queryExecute(
                "SELECT
                    COALESCE(AVG(total_rows), 0) as avg_rows_per_job,
                    COALESCE(AVG(imported_rows + updated_rows), 0) as avg_processed_per_job,
                    COUNT(*) as jobs_last_7_days,
                    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_last_7_days,
                    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed_last_7_days
                FROM import_v3_jobs
                WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)",
                {},
                { datasource: application.datasource }
            );

            // Active jobs (not terminal)
            var qActive = queryExecute(
                "SELECT COUNT(*) as active_jobs
                FROM import_v3_jobs
                WHERE status NOT IN ('completed', 'failed', 'cancelled')",
                {},
                { datasource: application.datasource }
            );

            // Unique users with jobs
            var qUsers = queryExecute(
                "SELECT COUNT(DISTINCT userid) as unique_users
                FROM import_v3_jobs
                WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)",
                {},
                { datasource: application.datasource }
            );

            return ok(data = {
                "completed_today": val(qToday.completed_today),
                "failed_today": val(qToday.failed_today),
                "total_today": val(qToday.total_today),
                "avg_rows_per_job": round(val(qWeek.avg_rows_per_job)),
                "avg_processed_per_job": round(val(qWeek.avg_processed_per_job)),
                "jobs_last_7_days": val(qWeek.jobs_last_7_days),
                "completed_last_7_days": val(qWeek.completed_last_7_days),
                "failed_last_7_days": val(qWeek.failed_last_7_days),
                "active_jobs": val(qActive.active_jobs),
                "unique_users_7_days": val(qUsers.unique_users)
            }, message = "");
        } catch (any e) {
            return fail(code = "QUERY_ERROR", message = "Failed to load stats: " & e.message, data = {});
        }
    }

    /**
     * Get allowed users list with user details.
     * Admin-only for managing allowlist.
     *
     * @return struct with users array
     */
    public struct function getAllowedUsers() {
        try {
            var qUsers = queryExecute(
                "SELECT
                    ffu.userid,
                    ffu.is_enabled,
                    ffu.created_at,
                    ffu.notes,
                    u.userfirst,
                    u.userlast,
                    u.useremail
                FROM feature_flag_users ffu
                LEFT JOIN taousers u ON ffu.userid = u.userid
                WHERE ffu.flag_key = 'import_v3_enabled'
                ORDER BY ffu.created_at DESC",
                {},
                { datasource: application.datasource }
            );

            var users = [];
            for (var row in qUsers) {
                arrayAppend(users, {
                    "userid": row.userid,
                    "is_enabled": (row.is_enabled eq 1),
                    "created_at": row.created_at,
                    "notes": row.notes,
                    "user_name": trim(row.userfirst & " " & row.userlast),
                    "user_email": row.useremail
                });
            }

            return ok(data = { "users": users }, message = "");
        } catch (any e) {
            return fail(code = "QUERY_ERROR", message = "Failed to load allowed users: " & e.message, data = {});
        }
    }

    /**
     * Add a user to the Import V3 allowlist.
     * Admin-only action.
     *
     * @param userid User ID to add
     * @param notes Optional notes about why user was added
     * @return struct with success/failure
     */
    public struct function addAllowedUser(required numeric userid, string notes = "") {
        try {
            // Verify user exists
            var qUser = queryExecute(
                "SELECT userid FROM taousers WHERE userid = :userid",
                { userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            if (qUser.recordCount eq 0) {
                return fail(code = "USER_NOT_FOUND", message = "User not found.", data = {});
            }

            // Insert or update allowlist entry
            queryExecute(
                "INSERT INTO feature_flag_users (flag_key, userid, is_enabled, notes, created_at)
                VALUES ('import_v3_enabled', :userid, 1, :notes, NOW())
                ON DUPLICATE KEY UPDATE is_enabled = 1, notes = :notes, updated_at = NOW()",
                {
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                    notes: { value: arguments.notes, cfsqltype: "cf_sql_varchar", null: !len(arguments.notes) }
                },
                { datasource: application.datasource }
            );

            return ok(message = "User added to allowlist.");
        } catch (any e) {
            return fail(code = "INSERT_ERROR", message = "Failed to add user: " & e.message, data = {});
        }
    }

    /**
     * Remove a user from the Import V3 allowlist.
     * Admin-only action.
     *
     * @param userid User ID to remove
     * @return struct with success/failure
     */
    public struct function removeAllowedUser(required numeric userid) {
        try {
            queryExecute(
                "DELETE FROM feature_flag_users
                WHERE flag_key = 'import_v3_enabled' AND userid = :userid",
                { userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            return ok(message = "User removed from allowlist.");
        } catch (any e) {
            return fail(code = "DELETE_ERROR", message = "Failed to remove user: " & e.message, data = {});
        }
    }

    /**
     * Set global feature flag state.
     * Admin-only action.
     *
     * @param flag_key The flag key to update
     * @param is_enabled New enabled state
     * @return struct with success/failure
     */
    public struct function setFeatureFlag(required string flag_key, required boolean is_enabled) {
        try {
            var qResult = {};
            queryExecute(
                "UPDATE feature_flags SET is_enabled = :is_enabled, updated_at = NOW()
                WHERE flag_key = :flag_key",
                {
                    flag_key: { value: arguments.flag_key, cfsqltype: "cf_sql_varchar" },
                    is_enabled: { value: arguments.is_enabled ? 1 : 0, cfsqltype: "cf_sql_tinyint" }
                },
                { datasource: application.datasource, result: "qResult" }
            );

            if (val(qResult.recordCount) eq 0) {
                return fail(code = "FLAG_NOT_FOUND", message = "Feature flag not found.", data = {});
            }

            return ok(message = "Feature flag updated.");
        } catch (any e) {
            return fail(code = "UPDATE_ERROR", message = "Failed to update flag: " & e.message, data = {});
        }
    }

}

