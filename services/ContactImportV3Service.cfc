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
        "parsed": ["mapping", "reviewing", "failed", "cancelled"],
        "mapping": ["reviewing", "failed", "cancelled"],
        "reviewing": ["finalizing", "failed", "cancelled"],
        "finalizing": ["completed", "failed", "cancelled", "reviewing"],
        "completed": ["reviewing"],
        "failed": ["reviewing"],
        "cancelled": ["reviewing"]
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
            // Don't let logging failure mask the real error
            try {
                logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "error_get_job", detail = { error: e.message, detail: e.detail });
            } catch (any logErr) {
                // Ignore logging errors
            }
            return fail(code = "INTERNAL_ERROR", message = "An error occurred: " & e.message & " | SQL Detail: " & e.detail, data = { job_id: arguments.job_id, error_detail: e.detail, error_type: e.type });
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
                writeLog(file="importv3", text="[acquireJobLock] ACQUIRED job_id=" & arguments.job_id & " userid=" & arguments.userid & " purpose=" & arguments.lock_purpose);
                return { "acquired": true, "message": "" };
            } else {
                var jobResult = getJobForUser(arguments.job_id, arguments.userid);
                if (!jobResult.success) {
                    return { "acquired": false, "message": jobResult.message };
                }
                writeLog(file="importv3", text="[acquireJobLock] DENIED job_id=" & arguments.job_id & " userid=" & arguments.userid & " purpose=" & arguments.lock_purpose & " current_status=" & jobResult.data.job.status);
                return { "acquired": false, "message": "Job cannot be locked from current status: " & jobResult.data.job.status };
            }
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_error", detail = { error: e.message });
            writeLog(file="importv3", text="[acquireJobLock] ERROR job_id=" & arguments.job_id & " userid=" & arguments.userid & " message=" & e.message);
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
            writeLog(file="importv3", text="[releaseJobLock] RELEASED job_id=" & arguments.job_id & " userid=" & arguments.userid & " from=" & job.status & " to=" & targetStatus);
            return { "released": true };
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_release_error", detail = { error: e.message });
            writeLog(file="importv3", text="[releaseJobLock] ERROR job_id=" & arguments.job_id & " userid=" & arguments.userid & " message=" & e.message);
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
            cflog(file="importv3", text="[service] setJobStatus START job_id=#arguments.job_id# userid=#arguments.userid# new_status=#arguments.new_status#");
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
            writeLog(file="importv3", text="[setJobStatus] TRANSITION job_id=" & arguments.job_id & " userid=" & arguments.userid & " from=" & currentStatus & " to=" & arguments.new_status);
            
            return ok(data = { previous_status: currentStatus, new_status: arguments.new_status }, message = "Status updated.");
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "status_change_error", detail = { error: e.message });
            writeLog(file="importv3", text="[service.setJobStatus] ERROR job_id=" & arguments.job_id & " new_status=" & arguments.new_status & " message=" & e.message);
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

                    var qResultCount = queryExecute(
                        "SELECT COUNT(*) as cnt FROM import_v3_row_results WHERE row_id IN (:rowIdList)",
                        { rowIdList: { value: rowIdList, cfsqltype: "cf_sql_integer", list: true } },
                        { datasource: application.datasource }
                    );
                    result.row_results_deleted = qResultCount.cnt;
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

                // 3. Delete facts and row_results (reference row_id)
                if (qRowIds.recordCount gt 0) {
                    var rowIdList = valueList(qRowIds.row_id);
                    var qFactDel = {};
                    queryExecute(
                        "DELETE FROM import_v3_facts WHERE row_id IN (:rowIdList)",
                        { rowIdList: { value: rowIdList, cfsqltype: "cf_sql_integer", list: true } },
                        { datasource: application.datasource, result: "qFactDel" }
                    );
                    result.facts_deleted = structKeyExists(qFactDel, "recordCount") ? qFactDel.recordCount : 0;

                    // 3b. Delete row_results (references row_id)
                    var qResultDel = {};
                    queryExecute(
                        "DELETE FROM import_v3_row_results WHERE row_id IN (:rowIdList)",
                        { rowIdList: { value: rowIdList, cfsqltype: "cf_sql_integer", list: true } },
                        { datasource: application.datasource, result: "qResultDel" }
                    );
                    result.row_results_deleted = structKeyExists(qResultDel, "recordCount") ? qResultDel.recordCount : 0;
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

    // ============================================================
    // PHASE 5: FINALIZE JOB - IDEMPOTENT, TRANSACTIONAL, AUDITED
    // ============================================================

    /**
     * Finalize import job: Create contacts from approved rows.
     *
     * IDEMPOTENCY: Running twice produces same result - already imported rows are skipped.
     * TRANSACTIONS: Each row is processed in its own transaction for isolation.
     * AUDIT: Every action is logged to import_v3_events and import_v3_row_results.
     *
     * Phase 5 Constraints:
     * - Create-only mode (no updates to existing contacts)
     * - No relationship system enrollment (future phase)
     *
     * @param job_id The import job ID
     * @param userid The user ID (must own the job)
     * @return struct with counts, errors, and timing metrics
     */
    public struct function finalizeJob(required numeric job_id, required numeric userid) {
        var startTime = getTickCount();
        var lockToken = createUUID();
        writeLog(file="importv3", text="[finalizeJob] START job_id=" & arguments.job_id & " userid=" & arguments.userid);

        // Initialize metrics and counts
        var metrics = {
            "total_rows_processed": 0,
            "elapsed_ms_total": 0,
            "elapsed_ms_per_row_avg": 0
        };

        var counts = {
            "attempted": 0,
            "imported_new": 0,
            "updated_existing": 0,
            "skipped_already_imported": 0,
            "skipped_ignored": 0,
            "skipped_not_ready": 0,
            "failed": 0
        };

        var failures = []; // Array of {row_id, code, message}
        var warnings = [];

        try {
            // A) Acquire job lock (transitions status to 'finalizing')
            var lockResult = acquireJobLock(
                job_id = arguments.job_id,
                userid = arguments.userid,
                lock_token = lockToken,
                lock_purpose = "finalize"
            );

            if (!lockResult.acquired) {
                // Check if already finalizing or completed
                var jobCheck = getJobForUser(arguments.job_id, arguments.userid);
                if (jobCheck.success && jobCheck.data.job.status eq "finalizing") {
                    return fail(
                        code = "ALREADY_RUNNING",
                        message = "Finalize is already in progress for this job.",
                        data = { job_id: arguments.job_id }
                    );
                }
                if (jobCheck.success && jobCheck.data.job.status eq "completed") {
                    return fail(
                        code = "ALREADY_COMPLETED",
                        message = "This job has already been finalized.",
                        data = { job_id: arguments.job_id }
                    );
                }
                return fail(
                    code = "LOCK_FAILED",
                    message = lockResult.message,
                    data = { job_id: arguments.job_id }
                );
            }

            // Log finalize start
            logEvent(
                job_id = arguments.job_id,
                userid = arguments.userid,
                event_type = "finalize_started",
                detail = { lock_token: lockToken }
            );

            // B) Fetch rows eligible for import
            // Status = 'ready' OR (status = 'dupe' AND user_action = 'import_new')
            var qRows = queryExecute(
                "SELECT r.row_id, r.row_num, r.status, r.user_action, r.created_contactid
                 FROM import_v3_rows r
                 WHERE r.job_id = :job_id
                   AND (
                       r.status = 'ready'
                       OR (r.status = 'dupe' AND r.user_action = 'import_new')
                   )
                 ORDER BY r.row_num ASC",
                { job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            counts.attempted = qRows.recordCount;

            if (qRows.recordCount eq 0) {
                // No rows to import - revert to reviewing so user can fix/approve rows
                releaseJobLock(
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    lock_token = lockToken
                );

                logEvent(
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    event_type = "finalize_no_rows",
                    detail = { counts: counts, reason: "no_rows_to_import" }
                );

                return fail(
                    code = "NO_ROWS_ELIGIBLE",
                    message = "No rows are eligible for import. Please review and approve rows before finalizing.",
                    data = { counts: counts }
                );
            }

            // C) Process each row
            for (var row in qRows) {
                var rowStartTime = getTickCount();
                var rowResult = processRowForImport(
                    row_id = row.row_id,
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    row_status = row.status,
                    user_action = row.user_action,
                    existing_contactid = row.created_contactid
                );

                metrics.total_rows_processed++;

                writeLog(file="importv3", text="[finalizeJob] ROW_PROCESSED job_id=" & arguments.job_id & " row_id=" & row.row_id & " success=" & rowResult.success & " action=" & (structKeyExists(rowResult, "action") ? rowResult.action : "n/a"));
                if (rowResult.success) {
                    switch (rowResult.action) {
                        case "created":
                            counts.imported_new++;
                            break;
                        case "updated":
                            counts.updated_existing++;
                            break;
                        case "skipped_already_imported":
                            counts.skipped_already_imported++;
                            break;
                        case "skipped_ignored":
                            counts.skipped_ignored++;
                            break;
                        case "skipped_not_ready":
                            counts.skipped_not_ready++;
                            break;
                    }
                } else {
                    counts.failed++;
                    arrayAppend(failures, {
                        "row_id": row.row_id,
                        "row_num": row.row_num,
                        "code": rowResult.code,
                        "message": rowResult.message
                    });
                }
            }

            // D) Update job status based on actual import results
            // Only count genuinely new imports (not skipped/idempotent rows)
            var newlyImported = counts.imported_new + counts.updated_existing;
            cflog(file="importv3", text="[finalize] COMPLETION_CHECK job_id=#arguments.job_id# imported_new=#counts.imported_new# updated_existing=#counts.updated_existing# skipped_already=#counts.skipped_already_imported# failed=#counts.failed# newlyImported=#newlyImported#");

            if (newlyImported gt 0) {
                // Contacts were actually created/updated this run - mark completed
                setJobStatus(
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    new_status = "completed"
                );
            } else if (counts.skipped_already_imported gt 0 && counts.failed eq 0) {
                // All rows were already imported (idempotent re-run) - mark completed
                setJobStatus(
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    new_status = "completed"
                );
                arrayAppend(warnings, "All eligible rows were already imported from a previous run.");
            } else {
                // Nothing was actually imported (all failed or skipped) - revert to reviewing
                logEvent(
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    event_type = "finalize_all_failed",
                    detail = { counts: counts, failures_count: arrayLen(failures) }
                );
                releaseJobLock(
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    lock_token = lockToken
                );
                arrayAppend(warnings, "No contacts were successfully imported. Job returned to review status.");
            }

            // Update job counts
            updateJobCounts(arguments.job_id, counts);

            // Calculate final metrics
            metrics.elapsed_ms_total = getTickCount() - startTime;
            if (metrics.total_rows_processed gt 0) {
                metrics.elapsed_ms_per_row_avg = round(metrics.elapsed_ms_total / metrics.total_rows_processed);
            }

            // Log completion
            logEvent(
                job_id = arguments.job_id,
                userid = arguments.userid,
                event_type = "finalize_completed",
                detail = { counts: counts, metrics: metrics, failure_count: arrayLen(failures) }
            );

            writeLog(file="importv3", text="[finalizeJob] COMPLETED job_id=" & arguments.job_id & " userid=" & arguments.userid & " imported=" & counts.imported_new & " failed=" & counts.failed & " skipped=" & counts.skipped_already_imported & " elapsed_ms=" & metrics.elapsed_ms_total);
            var message = "Finalize completed. " & counts.imported_new & " contacts created.";
            if (counts.skipped_already_imported gt 0) {
                message &= " " & counts.skipped_already_imported & " already imported.";
            }
            if (counts.failed gt 0) {
                message &= " " & counts.failed & " failed.";
            }

            return ok(
                data = {
                    counts: counts,
                    metrics: metrics,
                    failures: failures,
                    warnings: warnings
                },
                message = message
            );

        } catch (any e) {
            // Log error
            logEvent(
                job_id = arguments.job_id,
                userid = arguments.userid,
                event_type = "finalize_error",
                detail = { error: e.message, detail: e.detail }
            );

            writeLog(file="importv3", text="[service.finalizeJob] ERROR job_id=" & arguments.job_id & " userid=" & arguments.userid & " message=" & e.message);

            // Attempt to release lock (revert status to reviewing)
            try {
                releaseJobLock(
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    lock_token = lockToken
                );
            } catch (any lockErr) {
                // Ignore lock release errors
            }

            return fail(
                code = "INTERNAL_ERROR",
                message = "Finalize failed: " & e.message,
                data = { job_id: arguments.job_id }
            );
        }
    }

    /**
     * Process a single row for import.
     * Each row is processed in its own transaction for isolation.
     *
     * @param row_id The row ID
     * @param job_id The job ID
     * @param userid The user ID
     * @param row_status Current row status
     * @param user_action User's chosen action (for dupe rows)
     * @param existing_contactid If already imported, the contact ID
     * @return struct with success, action, contactid
     */
    private struct function processRowForImport(
        required numeric row_id,
        required numeric job_id,
        required numeric userid,
        required string row_status,
        string user_action = "",
        any existing_contactid = ""
    ) {
        var _rowStart = getTickCount();
        try {
            // A) Idempotency check: If already imported, skip
            if (isNumeric(arguments.existing_contactid) && arguments.existing_contactid gt 0) {
                // Check if row_result already exists
                var qExistingResult = queryExecute(
                    "SELECT result_id, action_taken, contactid
                     FROM import_v3_row_results
                     WHERE row_id = :row_id",
                    { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
                    { datasource: application.datasource }
                );

                if (qExistingResult.recordCount gt 0) {
                    return {
                        "success": true,
                        "action": "skipped_already_imported",
                        "contactid": qExistingResult.contactid
                    };
                }
            }

            // B) Load facts for this row
            var qFacts = queryExecute(
                "SELECT f.fact_id, f.field_name, f.normalized_value, f.is_valid
                 FROM import_v3_facts f
                 WHERE f.row_id = :row_id
                   AND f.is_valid = 1
                   AND f.normalized_value IS NOT NULL
                   AND f.normalized_value != ''",
                { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            if (qFacts.recordCount eq 0) {
                // No valid facts - mark as failed
                recordRowResult(
                    row_id = arguments.row_id,
                    job_id = arguments.job_id,
                    action_taken = "failed",
                    error_code = "NO_VALID_FACTS",
                    error_message = "No valid fields to import"
                );
                return {
                    "success": false,
                    "code": "NO_VALID_FACTS",
                    "message": "Row has no valid fields to import"
                };
            }

            // C) Build contact data from facts
            var contactData = buildContactDataFromFacts(qFacts);

            // Validate minimum requirements (need at least a name)
            if (!len(trim(contactData.contactFullName))) {
                recordRowResult(
                    row_id = arguments.row_id,
                    job_id = arguments.job_id,
                    action_taken = "failed",
                    error_code = "MISSING_NAME",
                    error_message = "Contact name is required"
                );
                return {
                    "success": false,
                    "code": "MISSING_NAME",
                    "message": "Contact name is required"
                };
            }

            // D) Create contact in transaction
            var newContactId = 0;
            var itemsCreated = 0;

            transaction {
                // D1) Insert into contactdetails
                var qInsertResult = {};
                queryExecute(
                    "INSERT INTO contactdetails (
                        userid,
                        contactFullName,
                        recordname,
                        contactBirthday,
                        user_yn,
                        created_at
                    ) VALUES (
                        :userid,
                        :contactFullName,
                        :recordname,
                        :contactBirthday,
                        'Y',
                        NOW()
                    )",
                    {
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                        contactFullName: { value: contactData.contactFullName, cfsqltype: "cf_sql_varchar" },
                        recordname: { value: contactData.contactFullName, cfsqltype: "cf_sql_varchar" },
                        contactBirthday: { value: contactData.contactBirthday, cfsqltype: "cf_sql_date", null: !len(trim(contactData.contactBirthday)) }
                    },
                    { datasource: application.datasource, result: "qInsertResult" }
                );

                newContactId = qInsertResult.generatedKey;

                // D2) Insert contact items (emails, phones, company, address)
                itemsCreated = insertContactItems(newContactId, contactData);

                // D3) Update import_v3_rows
                queryExecute(
                    "UPDATE import_v3_rows
                     SET status = 'imported',
                         created_contactid = :contactid,
                         imported_at = NOW(),
                         updated_at = NOW()
                     WHERE row_id = :row_id",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        contactid: { value: newContactId, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource: application.datasource }
                );

                // D4) Record result in import_v3_row_results
                queryExecute(
                    "INSERT INTO import_v3_row_results (
                        row_id, job_id, action_taken, contactid,
                        fields_written, items_created, created_at
                    ) VALUES (
                        :row_id, :job_id, 'created', :contactid,
                        :fields_written, :items_created, NOW()
                    )
                    ON DUPLICATE KEY UPDATE
                        action_taken = 'created',
                        contactid = :contactid,
                        fields_written = :fields_written,
                        items_created = :items_created",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                        contactid: { value: newContactId, cfsqltype: "cf_sql_integer" },
                        fields_written: { value: qFacts.recordCount, cfsqltype: "cf_sql_integer" },
                        items_created: { value: itemsCreated, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource: application.datasource }
                );
            }

            // E) Log success event (no PII)
            logEvent(
                job_id = arguments.job_id,
                userid = arguments.userid,
                event_type = "row_imported",
                row_id = arguments.row_id,
                detail = { contactid: newContactId, items_created: itemsCreated }
            );

            return {
                "success": true,
                "action": "created",
                "contactid": newContactId
            };

        } catch (any e) {
            // Log error and record failure
            writeLog(file="importv3", text="[processRowForImport] ERROR job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " message=" & e.message);
            logEvent(
                job_id = arguments.job_id,
                userid = arguments.userid,
                event_type = "row_import_error",
                row_id = arguments.row_id,
                detail = { error: e.message }
            );

            // Record failure result
            recordRowResult(
                row_id = arguments.row_id,
                job_id = arguments.job_id,
                action_taken = "failed",
                error_code = "IMPORT_EXCEPTION",
                error_message = left(e.message, 500)
            );

            // Update row status to failed
            try {
                queryExecute(
                    "UPDATE import_v3_rows
                     SET status = 'failed',
                         import_error = :error,
                         updated_at = NOW()
                     WHERE row_id = :row_id",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        error: { value: left(e.message, 500), cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
            } catch (any updateErr) {
                // Ignore update errors
            }

            return {
                "success": false,
                "code": "IMPORT_EXCEPTION",
                "message": e.message
            };
        }
    }

    /**
     * Build contact data struct from facts query.
     * Maps EAV facts to contact fields.
     */
    private struct function buildContactDataFromFacts(required query qFacts) {
        var data = {
            "contactFullName": "",
            "firstName": "",
            "lastName": "",
            "contactBirthday": "",
            "emails": [],
            "phones": [],
            "company": "",
            "title": "",
            "address": {
                "street1": "",
                "street2": "",
                "city": "",
                "state": "",
                "zip": "",
                "country": ""
            },
            "website": "",
            "linkedin": "",
            "twitter": "",
            "instagram": "",
            "notes": "",
            "tags": []
        };

        for (var fact in arguments.qFacts) {
            var fieldName = fact.field_name;
            var value = trim(fact.normalized_value);

            if (!len(value)) continue;

            switch (fieldName) {
                case "firstName":
                case "first_name":
                    data.firstName = value;
                    break;
                case "lastName":
                case "last_name":
                    data.lastName = value;
                    break;
                case "contactFullName":
                case "contact_full_name":
                case "full_name":
                    data.contactFullName = value;
                    break;
                case "birthday":
                case "contactBirthday":
                case "contact_birthday":
                    data.contactBirthday = value;
                    break;
                case "email_business":
                    arrayAppend(data.emails, { value: value, type: "Business" });
                    break;
                case "email_personal":
                    arrayAppend(data.emails, { value: value, type: "Personal" });
                    break;
                case "phone_work":
                    arrayAppend(data.phones, { value: value, type: "Work" });
                    break;
                case "phone_mobile":
                    arrayAppend(data.phones, { value: value, type: "Mobile" });
                    break;
                case "phone_home":
                    arrayAppend(data.phones, { value: value, type: "Home" });
                    break;
                case "company":
                    data.company = value;
                    break;
                case "title":
                    data.title = value;
                    break;
                case "address1":
                    data.address.street1 = value;
                    break;
                case "address2":
                    data.address.street2 = value;
                    break;
                case "city":
                    data.address.city = value;
                    break;
                case "state":
                    data.address.state = value;
                    break;
                case "zip":
                    data.address.zip = value;
                    break;
                case "country":
                    data.address.country = value;
                    break;
                case "website":
                    data.website = value;
                    break;
                case "linkedin":
                    data.linkedin = value;
                    break;
                case "twitter":
                    data.twitter = value;
                    break;
                case "instagram":
                    data.instagram = value;
                    break;
                case "notes":
                    data.notes = value;
                    break;
                case "tags":
                    // Tags might be comma-separated
                    var tagList = listToArray(value, ",");
                    for (var tag in tagList) {
                        if (len(trim(tag))) {
                            arrayAppend(data.tags, trim(tag));
                        }
                    }
                    break;
            }
        }

        // Build contactFullName if not provided directly
        if (!len(data.contactFullName)) {
            if (len(data.firstName) || len(data.lastName)) {
                data.contactFullName = trim(data.firstName & " " & data.lastName);
            }
        }

        return data;
    }

    /**
     * Insert contact items (emails, phones, company, address, etc.)
     * Returns count of items created.
     *
     * Includes deduplication: checks for existing items before insert.
     */
    private numeric function insertContactItems(required numeric contactid, required struct contactData) {
        var itemsCreated = 0;

        // Insert emails
        for (var email in arguments.contactData.emails) {
            if (len(trim(email.value)) && !contactItemExists(arguments.contactid, "Email", email.value)) {
                queryExecute(
                    "INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
                     VALUES (:contactid, 'Email', :valueType, :valuetext, 'Active')",
                    {
                        contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                        valueType: { value: email.type, cfsqltype: "cf_sql_varchar" },
                        valuetext: { value: trim(email.value), cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
                itemsCreated++;
            }
        }

        // Insert phones
        for (var phone in arguments.contactData.phones) {
            if (len(trim(phone.value)) && !contactItemExists(arguments.contactid, "Phone", phone.value)) {
                queryExecute(
                    "INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
                     VALUES (:contactid, 'Phone', :valueType, :valuetext, 'Active')",
                    {
                        contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                        valueType: { value: phone.type, cfsqltype: "cf_sql_varchar" },
                        valuetext: { value: trim(phone.value), cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
                itemsCreated++;
            }
        }

        // Insert company
        if (len(trim(arguments.contactData.company))) {
            queryExecute(
                "INSERT INTO contactitems (contactid, valueCategory, valueType, valueCompany, valueTitle, itemStatus)
                 VALUES (:contactid, 'Company', 'Company', :company, :title, 'Active')",
                {
                    contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                    company: { value: trim(arguments.contactData.company), cfsqltype: "cf_sql_varchar" },
                    title: { value: trim(arguments.contactData.title), cfsqltype: "cf_sql_varchar", null: !len(trim(arguments.contactData.title)) }
                },
                { datasource: application.datasource }
            );
            itemsCreated++;
        }

        // Insert address (if any address field is populated)
        var addr = arguments.contactData.address;
        if (len(trim(addr.street1)) || len(trim(addr.city)) || len(trim(addr.state)) || len(trim(addr.zip))) {
            queryExecute(
                "INSERT INTO contactitems (
                    contactid, valueCategory, valueType,
                    valueStreetAddress, valueExtendedAddress,
                    valueCity, valueRegion, valuePostalCode, valueCountry,
                    itemStatus
                ) VALUES (
                    :contactid, 'Address', 'Work',
                    :street1, :street2,
                    :city, :state, :zip, :country,
                    'Active'
                )",
                {
                    contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                    street1: { value: trim(addr.street1), cfsqltype: "cf_sql_varchar", null: !len(trim(addr.street1)) },
                    street2: { value: trim(addr.street2), cfsqltype: "cf_sql_varchar", null: !len(trim(addr.street2)) },
                    city: { value: trim(addr.city), cfsqltype: "cf_sql_varchar", null: !len(trim(addr.city)) },
                    state: { value: trim(addr.state), cfsqltype: "cf_sql_varchar", null: !len(trim(addr.state)) },
                    zip: { value: trim(addr.zip), cfsqltype: "cf_sql_varchar", null: !len(trim(addr.zip)) },
                    country: { value: trim(addr.country), cfsqltype: "cf_sql_varchar", null: !len(trim(addr.country)) }
                },
                { datasource: application.datasource }
            );
            itemsCreated++;
        }

        // Insert website
        if (len(trim(arguments.contactData.website))) {
            queryExecute(
                "INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
                 VALUES (:contactid, 'Website', 'Website', :value, 'Active')",
                {
                    contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                    value: { value: trim(arguments.contactData.website), cfsqltype: "cf_sql_varchar" }
                },
                { datasource: application.datasource }
            );
            itemsCreated++;
        }

        // Insert social media
        if (len(trim(arguments.contactData.linkedin))) {
            queryExecute(
                "INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
                 VALUES (:contactid, 'Social', 'LinkedIn', :value, 'Active')",
                {
                    contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                    value: { value: trim(arguments.contactData.linkedin), cfsqltype: "cf_sql_varchar" }
                },
                { datasource: application.datasource }
            );
            itemsCreated++;
        }

        if (len(trim(arguments.contactData.twitter))) {
            queryExecute(
                "INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
                 VALUES (:contactid, 'Social', 'Twitter', :value, 'Active')",
                {
                    contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                    value: { value: trim(arguments.contactData.twitter), cfsqltype: "cf_sql_varchar" }
                },
                { datasource: application.datasource }
            );
            itemsCreated++;
        }

        if (len(trim(arguments.contactData.instagram))) {
            queryExecute(
                "INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
                 VALUES (:contactid, 'Social', 'Instagram', :value, 'Active')",
                {
                    contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                    value: { value: trim(arguments.contactData.instagram), cfsqltype: "cf_sql_varchar" }
                },
                { datasource: application.datasource }
            );
            itemsCreated++;
        }

        // Insert tags
        for (var tag in arguments.contactData.tags) {
            if (len(trim(tag)) && !contactItemExists(arguments.contactid, "Tag", tag)) {
                queryExecute(
                    "INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
                     VALUES (:contactid, 'Tag', 'Tags', :value, 'Active')",
                    {
                        contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                        value: { value: trim(tag), cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
                itemsCreated++;
            }
        }

        // Insert notes
        if (len(trim(arguments.contactData.notes))) {
            queryExecute(
                "INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext, itemStatus)
                 VALUES (:contactid, 'Note', 'Note', :value, 'Active')",
                {
                    contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                    value: { value: trim(arguments.contactData.notes), cfsqltype: "cf_sql_longvarchar" }
                },
                { datasource: application.datasource }
            );
            itemsCreated++;
        }

        return itemsCreated;
    }

    /**
     * Check if a contact item already exists (for deduplication).
     */
    private boolean function contactItemExists(
        required numeric contactid,
        required string valueCategory,
        required string valuetext
    ) {
        var qCheck = queryExecute(
            "SELECT 1 FROM contactitems
             WHERE contactid = :contactid
               AND valueCategory = :valueCategory
               AND valuetext = :valuetext
               AND itemStatus = 'Active'
             LIMIT 1",
            {
                contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer" },
                valueCategory: { value: arguments.valueCategory, cfsqltype: "cf_sql_varchar" },
                valuetext: { value: arguments.valuetext, cfsqltype: "cf_sql_varchar" }
            },
            { datasource: application.datasource }
        );
        return qCheck.recordCount gt 0;
    }

    /**
     * Record result in import_v3_row_results table.
     */
    private void function recordRowResult(
        required numeric row_id,
        required numeric job_id,
        required string action_taken,
        string error_code = "",
        string error_message = "",
        numeric contactid = 0,
        numeric fields_written = 0,
        numeric items_created = 0
    ) {
        try {
            queryExecute(
                "INSERT INTO import_v3_row_results (
                    row_id, job_id, action_taken, contactid,
                    fields_written, items_created, error_code, error_message, created_at
                ) VALUES (
                    :row_id, :job_id, :action_taken, :contactid,
                    :fields_written, :items_created, :error_code, :error_message, NOW()
                )
                ON DUPLICATE KEY UPDATE
                    action_taken = :action_taken,
                    contactid = :contactid,
                    error_code = :error_code,
                    error_message = :error_message",
                {
                    row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    action_taken: { value: arguments.action_taken, cfsqltype: "cf_sql_varchar" },
                    contactid: { value: arguments.contactid, cfsqltype: "cf_sql_integer", null: arguments.contactid eq 0 },
                    fields_written: { value: arguments.fields_written, cfsqltype: "cf_sql_integer" },
                    items_created: { value: arguments.items_created, cfsqltype: "cf_sql_integer" },
                    error_code: { value: arguments.error_code, cfsqltype: "cf_sql_varchar", null: !len(arguments.error_code) },
                    error_message: { value: arguments.error_message, cfsqltype: "cf_sql_varchar", null: !len(arguments.error_message) }
                },
                { datasource: application.datasource }
            );
        } catch (any e) {
            // Ignore errors recording results - don't fail the import
        }
    }

    /**
     * Update job counts after finalize.
     */
    private void function updateJobCounts(required numeric job_id, required struct counts) {
        try {
            queryExecute(
                "UPDATE import_v3_jobs SET
                    imported_rows = :imported_new,
                    updated_rows = :updated_existing,
                    skipped_rows = :skipped,
                    updated_at = NOW()
                 WHERE job_id = :job_id",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    imported_new: { value: arguments.counts.imported_new, cfsqltype: "cf_sql_integer" },
                    updated_existing: { value: arguments.counts.updated_existing, cfsqltype: "cf_sql_integer" },
                    skipped: { value: arguments.counts.skipped_already_imported + arguments.counts.skipped_ignored + arguments.counts.skipped_not_ready, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );
        } catch (any e) {
            // Ignore errors updating counts
        }
    }

    // ============================================================
    // PHASE 6: ROW LISTING, DETAIL, EDITING, AND ACTIONS
    // ============================================================

    /**
     * Get job statistics by status.
     * Used for stats bar and stats_only mode.
     */
    public struct function getJobStats(required numeric job_id) {
        var stats = {
            "total": 0,
            "ready": 0,
            "problem": 0,
            "dupe": 0,
            "ignored": 0,
            "imported": 0
        };

        try {
            var qStats = queryExecute(
                "SELECT status, COUNT(*) as cnt
                 FROM import_v3_rows
                 WHERE job_id = :job_id
                 GROUP BY status",
                { job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            var total = 0;
            for (var row in qStats) {
                var st = lcase(row.status);
                total += row.cnt;
                if (structKeyExists(stats, st)) {
                    stats[st] = row.cnt;
                } else if (st eq "updated" or st eq "failed") {
                    // Count updated/failed as imported for display
                    stats.imported += row.cnt;
                }
            }
            stats.total = total;

        } catch (any e) {
            // Return zeros on error
        }

        return stats;
    }

    /**
     * Get paginated rows for a job with optional status filter.
     * Phase 6: Batch-loads facts to avoid N+1 queries.
     *
     * @param job_id The job ID
     * @param userid The user ID (for ownership check, already validated by caller)
     * @param statusFilter Filter: ready|problem|dupe|ignored|imported|all
     * @param page Page number (1-based)
     * @param pageSize Rows per page (max 200)
     * @return struct with rows array, pagination info, and stats
     */
    public struct function getRows(
        required numeric job_id,
        required numeric userid,
        string statusFilter = "all",
        numeric page = 1,
        numeric pageSize = 50,
        string search = ""
    ) {
        try {
            // Sanitize pagination
            var safePage = max(1, arguments.page);
            var safePageSize = min(200, max(1, arguments.pageSize));
            var offset = (safePage - 1) * safePageSize;

            // Sanitize search term
            var searchTerm = trim(arguments.search);
            var hasSearch = len(searchTerm) gt 0;

            // Build status filter clause
            var statusClause = "";
            var statusList = "";
            if (arguments.statusFilter neq "all" and len(arguments.statusFilter)) {
                if (arguments.statusFilter eq "imported") {
                    // Include imported, updated, failed statuses
                    statusList = "'imported','updated','failed'";
                    statusClause = "AND r.status IN (#statusList#)";
                } else {
                    statusClause = "AND r.status = :status";
                }
            }

            // Build search clause: join facts table for text search on key fields
            var searchClause = "";
            if (hasSearch) {
                searchClause = "AND r.row_id IN (
                    SELECT DISTINCT f.row_id FROM import_v3_facts f
                    WHERE f.row_id IN (SELECT r2.row_id FROM import_v3_rows r2 WHERE r2.job_id = :job_id_search)
                      AND f.field_name IN ('first_name','last_name','contactFullName','email_business','email_personal','company','phone_work','phone_mobile')
                      AND f.normalized_value LIKE :search_term
                )";
            }

            // Get total count for pagination
            var countSql = "SELECT COUNT(*) as cnt FROM import_v3_rows r WHERE r.job_id = :job_id #statusClause# #searchClause#";
            var countParams = { job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" } };
            if (len(statusClause) and arguments.statusFilter neq "imported") {
                countParams.status = { value: arguments.statusFilter, cfsqltype: "cf_sql_varchar" };
            }
            if (hasSearch) {
                countParams.job_id_search = { value: arguments.job_id, cfsqltype: "cf_sql_integer" };
                countParams.search_term = { value: "%" & searchTerm & "%", cfsqltype: "cf_sql_varchar" };
            }

            var qCount = queryExecute(countSql, countParams, { datasource: application.datasource });
            var totalRows = qCount.cnt;
            var totalPages = ceiling(totalRows / safePageSize);

            // Fetch rows
            var rowsSql = "
                SELECT r.row_id, r.row_num, r.status, r.error_count, r.warning_count,
                       r.matched_contactid, r.best_match_score, r.user_action,
                       r.created_contactid, r.updated_contactid, r.import_error,
                       r.validation_summary, r.dupe_candidates_json
                FROM import_v3_rows r
                WHERE r.job_id = :job_id
                #statusClause#
                #searchClause#
                ORDER BY r.row_num ASC
                LIMIT :limit OFFSET :offset
            ";

            var rowParams = {
                job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                limit: { value: safePageSize, cfsqltype: "cf_sql_integer" },
                offset: { value: offset, cfsqltype: "cf_sql_integer" }
            };
            if (len(statusClause) and arguments.statusFilter neq "imported") {
                rowParams.status = { value: arguments.statusFilter, cfsqltype: "cf_sql_varchar" };
            }
            if (hasSearch) {
                rowParams.job_id_search = { value: arguments.job_id, cfsqltype: "cf_sql_integer" };
                rowParams.search_term = { value: "%" & searchTerm & "%", cfsqltype: "cf_sql_varchar" };
            }

            var qRows = queryExecute(rowsSql, rowParams, { datasource: application.datasource });

            // Collect row IDs for batch fact loading
            var rowIds = [];
            for (var row in qRows) {
                arrayAppend(rowIds, row.row_id);
            }

            // Batch load facts for all rows (parameterized list to prevent SQL injection)
            var factsMap = {};
            if (arrayLen(rowIds) gt 0) {
                var factsSql = "
                    SELECT f.row_id, f.field_name, f.normalized_value, f.is_valid,
                           f.validation_code, f.validation_message
                    FROM import_v3_facts f
                    WHERE f.row_id IN (:row_id_list)
                    ORDER BY f.row_id, f.field_name
                ";
                var qFacts = queryExecute(factsSql, {
                    row_id_list: { value: arrayToList(rowIds), cfsqltype: "cf_sql_integer", list: true }
                }, { datasource: application.datasource });

                for (var fact in qFacts) {
                    if (!structKeyExists(factsMap, fact.row_id)) {
                        factsMap[fact.row_id] = { data: {}, validation: {}, errors: [] };
                    }
                    factsMap[fact.row_id].data[fact.field_name] = isNull(fact.normalized_value) ? "" : fact.normalized_value;
                    factsMap[fact.row_id].validation[fact.field_name] = fact.is_valid ? true : false;
                    if (!fact.is_valid and len(fact.validation_message)) {
                        arrayAppend(factsMap[fact.row_id].errors, {
                            "field": fact.field_name,
                            "code": isNull(fact.validation_code) ? "" : fact.validation_code,
                            "message": fact.validation_message
                        });
                    }
                }
            }

            // Build rows array
            var rows = [];
            for (var row in qRows) {
                var rowData = {
                    "row_id": row.row_id,
                    "row_num": row.row_num,
                    "status": row.status,
                    "error_count": row.error_count,
                    "warning_count": row.warning_count,
                    "user_action": isNull(row.user_action) ? "" : row.user_action,
                    "created_contactid": isNull(row.created_contactid) ? 0 : row.created_contactid,
                    "best_match_score": isNull(row.best_match_score) ? 0 : row.best_match_score,
                    "data": structKeyExists(factsMap, row.row_id) ? factsMap[row.row_id].data : {},
                    "validation": structKeyExists(factsMap, row.row_id) ? factsMap[row.row_id].validation : {},
                    "errors": structKeyExists(factsMap, row.row_id) ? factsMap[row.row_id].errors : []
                };

                // Parse duplicates from JSON (minimal info for list view)
                if (!isNull(row.dupe_candidates_json) and len(row.dupe_candidates_json)) {
                    try {
                        var dupes = deserializeJSON(row.dupe_candidates_json);
                        // Only include count and best score for list view
                        rowData["dupe_count"] = arrayLen(dupes);
                    } catch (any e) {
                        rowData["dupe_count"] = 0;
                    }
                } else {
                    rowData["dupe_count"] = 0;
                }

                arrayAppend(rows, rowData);
            }

            // Get stats
            var stats = getJobStats(arguments.job_id);

            return ok(
                data = {
                    rows: rows,
                    total: totalRows,
                    page: safePage,
                    page_size: safePageSize,
                    total_pages: totalPages,
                    stats: stats
                }
            );

        } catch (any e) {
            writeLog(file="importv3", text="[getRows] ERROR job_id=" & arguments.job_id & " userid=" & arguments.userid & " filter=" & arguments.statusFilter & " message=" & e.message);
            return fail(
                code = "QUERY_ERROR",
                message = "Failed to load rows: " & e.message
            );
        }
    }

    /**
     * Get detailed information for a single row.
     * Includes full facts, validation, and duplicate candidates with contact names.
     */
    public struct function getRowDetail(
        required numeric job_id,
        required numeric row_id,
        required numeric userid
    ) {
        try {
            // Fetch row
            var qRow = queryExecute(
                "SELECT r.*
                 FROM import_v3_rows r
                 WHERE r.row_id = :row_id AND r.job_id = :job_id",
                {
                    row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );

            if (qRow.recordCount eq 0) {
                return fail(code = "NOT_FOUND", message = "Row not found");
            }

            var row = qRow;

            // Fetch facts
            var qFacts = queryExecute(
                "SELECT f.fact_id, f.column_id, f.field_name, f.raw_value, f.normalized_value,
                        f.is_valid, f.validation_code, f.validation_message,
                        f.existing_value, f.has_conflict, f.user_choice
                 FROM import_v3_facts f
                 WHERE f.row_id = :row_id
                 ORDER BY f.field_name",
                { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            // Build data and validation structs
            var data = {};
            var validation = {};
            var errors = [];
            var facts = [];

            for (var fact in qFacts) {
                data[fact.field_name] = isNull(fact.normalized_value) ? "" : fact.normalized_value;
                validation[fact.field_name] = fact.is_valid ? true : false;

                if (!fact.is_valid and len(fact.validation_message)) {
                    arrayAppend(errors, {
                        "field": fact.field_name,
                        "code": isNull(fact.validation_code) ? "" : fact.validation_code,
                        "message": fact.validation_message
                    });
                }

                arrayAppend(facts, {
                    "fact_id": fact.fact_id,
                    "column_id": fact.column_id,
                    "field_name": fact.field_name,
                    "raw_value": isNull(fact.raw_value) ? "" : fact.raw_value,
                    "normalized_value": isNull(fact.normalized_value) ? "" : fact.normalized_value,
                    "is_valid": fact.is_valid,
                    "validation_code": isNull(fact.validation_code) ? "" : fact.validation_code,
                    "validation_message": isNull(fact.validation_message) ? "" : fact.validation_message,
                    "existing_value": isNull(fact.existing_value) ? "" : fact.existing_value,
                    "has_conflict": fact.has_conflict
                });
            }

            // Parse duplicates with contact info (minimal - no PII beyond name which is already in DB)
            var duplicates = [];
            var warnings = [];

            if (!isNull(row.dupe_candidates_json) and len(row.dupe_candidates_json)) {
                try {
                    var rawDupes = deserializeJSON(row.dupe_candidates_json);
                    // Fetch contact names for dupe candidates
                    for (var dupe in rawDupes) {
                        var dupeInfo = {
                            "contactid": dupe.contactid,
                            "score": structKeyExists(dupe, "score") ? dupe.score : 0,
                            "reasons": structKeyExists(dupe, "reasons") ? dupe.reasons : [],
                            "contactFullName": ""
                        };

                        // Lookup contact name (allowed since it's already in DB)
                        try {
                            var qContact = queryExecute(
                                "SELECT contactFullName FROM contactdetails WHERE contactid = :cid AND userid = :uid",
                                {
                                    cid: { value: dupe.contactid, cfsqltype: "cf_sql_integer" },
                                    uid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                                },
                                { datasource: application.datasource }
                            );
                            if (qContact.recordCount gt 0) {
                                dupeInfo.contactFullName = qContact.contactFullName;
                            }
                        } catch (any e) {
                            // Ignore lookup errors
                        }

                        arrayAppend(duplicates, dupeInfo);
                    }
                } catch (any e) {
                    arrayAppend(warnings, "Failed to parse duplicate candidates");
                }
            }

            // Build response
            var rowDetail = {
                "row_id": row.row_id,
                "row_num": row.row_num,
                "job_id": row.job_id,
                "status": row.status,
                "error_count": row.error_count,
                "warning_count": row.warning_count,
                "user_action": isNull(row.user_action) ? "" : row.user_action,
                "matched_contactid": isNull(row.matched_contactid) ? 0 : row.matched_contactid,
                "best_match_score": isNull(row.best_match_score) ? 0 : row.best_match_score,
                "created_contactid": isNull(row.created_contactid) ? 0 : row.created_contactid,
                "updated_contactid": isNull(row.updated_contactid) ? 0 : row.updated_contactid,
                "import_error": isNull(row.import_error) ? "" : row.import_error,
                "data": data,
                "validation": validation,
                "errors": errors,
                "facts": facts,
                "duplicates": duplicates,
                "warnings": warnings
            };

            return ok(data = { row: rowDetail });

        } catch (any e) {
            writeLog(file="importv3", text="[getRowDetail] ERROR job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " message=" & e.message);
            return fail(
                code = "QUERY_ERROR",
                message = "Failed to load row detail: " & e.message
            );
        }
    }

    /**
     * Update facts for a row and recompute status.
     * Phase 6: Supports batch field updates with revalidation.
     *
     * @param job_id The job ID
     * @param row_id The row ID
     * @param fields Struct of field_name -> new_value
     * @param userid The user ID
     * @return struct with updated row detail
     */
    public struct function updateRowFacts(
        required numeric job_id,
        required numeric row_id,
        required struct fields,
        required numeric userid
    ) {
        try {
            writeLog(file="importv3", text="[service.updateRowFacts] START job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " field_count=" & structCount(arguments.fields));
            // Verify row exists and belongs to job
            var qRow = queryExecute(
                "SELECT r.row_id, r.status, r.dupe_candidates_json
                 FROM import_v3_rows r
                 INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
                 WHERE r.row_id = :row_id AND r.job_id = :job_id AND j.userid = :userid",
                {
                    row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );

            if (qRow.recordCount eq 0) {
                return fail(code = "NOT_FOUND", message = "Row not found or access denied");
            }

            // Don't allow editing imported/failed rows
            if (listFindNoCase("imported,updated,failed", qRow.status)) {
                return fail(code = "INVALID_STATE", message = "Cannot edit rows that have been imported");
            }

            // Initialize validation service
            var validationService = new services.ValidationService();

            // Field-type mapping for routing to correct validator
            var fieldTypes = {
                "email_business": "email", "email_personal": "email",
                "phone_work": "phone", "phone_mobile": "phone", "phone_home": "phone",
                "birthday": "date", "relationship_start": "date",
                "website": "url", "linkedin": "url",
                "tags": "tag",
                "notes": "text"
            };

            // Track which fields were updated
            var updatedFields = [];
            var validationErrors = [];

            // Update each field
            for (var fieldName in arguments.fields) {
                var newValue = arguments.fields[fieldName];

                // Route to correct validator based on field type
                var fType = structKeyExists(fieldTypes, fieldName) ? fieldTypes[fieldName] : "string";
                var vr = {};
                switch (fType) {
                    case "email": vr = validationService.validateEmail(newValue); break;
                    case "phone": vr = validationService.validatePhone(newValue); break;
                    case "date":  vr = validationService.validateDate(newValue);  break;
                    case "url":   vr = validationService.validateURL(newValue);   break;
                    case "tag":   vr = validationService.validateTag(newValue);   break;
                    case "text":  vr = validationService.validateString(newValue, 65535); break;
                    default:      vr = validationService.validateString(newValue, 255);   break;
                }

                // Normalize result keys (validators return: valid, normalized, error)
                var isValid = structKeyExists(vr, "valid") ? vr.valid : true;
                var normalizedVal = structKeyExists(vr, "normalized") ? vr.normalized : newValue;
                var errCode = !isValid ? (structKeyExists(vr, "code") ? vr.code : "INVALID") : "";
                var errMsg = !isValid ? (structKeyExists(vr, "error") ? vr.error : "") : "";

                // Upsert the fact
                queryExecute(
                    "INSERT INTO import_v3_facts (row_id, column_id, field_name, raw_value, normalized_value, is_valid, validation_code, validation_message, updated_at)
                     SELECT :row_id, COALESCE(c.column_id, 0), :field_name, :raw_value, :normalized_value, :is_valid, :validation_code, :validation_message, NOW()
                     FROM (SELECT 1) AS dummy
                     LEFT JOIN import_v3_columns c ON c.job_id = :job_id AND c.mapped_field = :field_name
                     ON DUPLICATE KEY UPDATE
                         raw_value = :raw_value,
                         normalized_value = :normalized_value,
                         is_valid = :is_valid,
                         validation_code = :validation_code,
                         validation_message = :validation_message,
                         updated_at = NOW()",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                        field_name: { value: fieldName, cfsqltype: "cf_sql_varchar" },
                        raw_value: { value: newValue, cfsqltype: "cf_sql_varchar", null: !len(newValue) },
                        normalized_value: { value: normalizedVal, cfsqltype: "cf_sql_varchar", null: !len(normalizedVal) },
                        is_valid: { value: isValid ? 1 : 0, cfsqltype: "cf_sql_integer" },
                        validation_code: { value: errCode, cfsqltype: "cf_sql_varchar", null: isValid },
                        validation_message: { value: errMsg, cfsqltype: "cf_sql_varchar", null: isValid }
                    },
                    { datasource: application.datasource }
                );

                arrayAppend(updatedFields, fieldName);

                if (!isValid) {
                    arrayAppend(validationErrors, {
                        "field": fieldName,
                        "code": errCode,
                        "message": errMsg
                    });
                }
            }

            // Handle contactFullName dependency on firstName/lastName
            if (structKeyExists(arguments.fields, "firstName") or structKeyExists(arguments.fields, "lastName")) {
                recomputeFullName(arguments.row_id);
            }

            // Recompute row status
            var newStatus = recomputeRowStatus(arguments.row_id, qRow.dupe_candidates_json);

            // Update row
            queryExecute(
                "UPDATE import_v3_rows
                 SET status = :status,
                     error_count = (SELECT COUNT(*) FROM import_v3_facts WHERE row_id = :row_id AND is_valid = 0),
                     updated_at = NOW()
                 WHERE row_id = :row_id",
                {
                    row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                    status: { value: newStatus, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: application.datasource }
            );

            // Update job counts
            updateJobRowCounts(arguments.job_id);

            // Return updated row detail
            writeLog(file="importv3", text="[service.updateRowFacts] OK job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " fields_updated=" & arrayLen(updatedFields));
            return getRowDetail(arguments.job_id, arguments.row_id, arguments.userid);

        } catch (any e) {
            writeLog(file="importv3", text="[updateRowFacts] ERROR job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " fields=" & structKeyList(arguments.fields) & " message=" & e.message);
            return fail(
                code = "UPDATE_ERROR",
                message = "Failed to update row: " & e.message
            );
        }
    }

    /**
     * Recompute contactFullName from firstName and lastName.
     */
    private void function recomputeFullName(required numeric row_id) {
        try {
            var qNames = queryExecute(
                "SELECT field_name, normalized_value
                 FROM import_v3_facts
                 WHERE row_id = :row_id AND field_name IN ('firstName', 'lastName')",
                { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            var firstName = "";
            var lastName = "";
            for (var row in qNames) {
                if (row.field_name eq "firstName") firstName = isNull(row.normalized_value) ? "" : row.normalized_value;
                if (row.field_name eq "lastName") lastName = isNull(row.normalized_value) ? "" : row.normalized_value;
            }

            var fullName = trim(firstName & " " & lastName);

            if (len(fullName)) {
                queryExecute(
                    "UPDATE import_v3_facts
                     SET normalized_value = :fullName, updated_at = NOW()
                     WHERE row_id = :row_id AND field_name = 'contactFullName'",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        fullName: { value: fullName, cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
            }
        } catch (any e) {
            // Ignore errors
        }
    }

    /**
     * Recompute row status based on validation and duplicates.
     * Returns: ready|problem|dupe
     */
    private string function recomputeRowStatus(required numeric row_id, any dupe_candidates_json = "") {
        // Check for validation errors
        var qErrors = queryExecute(
            "SELECT COUNT(*) as cnt FROM import_v3_facts WHERE row_id = :row_id AND is_valid = 0",
            { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        );

        if (qErrors.cnt gt 0) {
            return "problem";
        }

        // Check for duplicates
        if (!isNull(arguments.dupe_candidates_json) and len(arguments.dupe_candidates_json)) {
            try {
                var dupes = deserializeJSON(arguments.dupe_candidates_json);
                if (isArray(dupes) and arrayLen(dupes) gt 0) {
                    return "dupe";
                }
            } catch (any e) {
                // Ignore parse errors
            }
        }

        return "ready";
    }

    /**
     * Update job row counts from actual row data.
     */
    private void function updateJobRowCounts(required numeric job_id) {
        try {
            queryExecute(
                "UPDATE import_v3_jobs j
                 SET j.valid_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'ready'),
                     j.problem_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'problem'),
                     j.dupe_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'dupe'),
                     j.skipped_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'ignored'),
                     j.imported_rows = (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status IN ('imported', 'updated')),
                     j.updated_at = NOW()
                 WHERE j.job_id = :job_id",
                { job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );
        } catch (any e) {
            // Ignore errors
        }
    }

    /**
     * Set user action on a single row (ignore/create).
     * Phase 6: Create-only mode, no update support.
     *
     * @param job_id The job ID
     * @param row_id The row ID
     * @param action The action: ignore|create (update not supported)
     * @param userid The user ID
     * @return struct with updated row and stats
     */
    public struct function setRowAction(
        required numeric job_id,
        required numeric row_id,
        required string action,
        required numeric userid,
        numeric matchedContactId = 0
    ) {
        try {
            writeLog(file="importv3", text="[service.setRowAction] START job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " action=" & arguments.action);
            // Normalize action
            var normalizedAction = lcase(trim(arguments.action));

            // Map UI actions to DB values
            // UI sends: ignore, create, update
            // DB stores: skip, import_new, update_existing
            var dbAction = "";
            var newStatus = "";

            switch (normalizedAction) {
                case "ignore":
                case "skip":
                    dbAction = "skip";
                    newStatus = "ignored";
                    break;
                case "create":
                case "import_new":
                    dbAction = "import_new";
                    // For ignored rows, restore to ready so finalize picks them up
                    // For dupe/ready rows, keep current status
                    newStatus = "";
                    break;
                case "update":
                case "update_existing":
                    // Create-only mode enforcement
                    return fail(
                        code = "UPDATE_NOT_SUPPORTED",
                        message = "Update mode is not supported in the current release. Only new contact creation is available."
                    );
                default:
                    return fail(
                        code = "INVALID_ACTION",
                        message = "Invalid action: " & normalizedAction & ". Valid actions: ignore, create"
                    );
            }

            // Verify row exists and belongs to job/user
            var qRow = queryExecute(
                "SELECT r.row_id, r.status
                 FROM import_v3_rows r
                 INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
                 WHERE r.row_id = :row_id AND r.job_id = :job_id AND j.userid = :userid",
                {
                    row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );

            if (qRow.recordCount eq 0) {
                return fail(code = "NOT_FOUND", message = "Row not found or access denied");
            }

            // Don't allow changing imported/failed rows
            if (listFindNoCase("imported,updated,failed", qRow.status)) {
                return fail(code = "INVALID_STATE", message = "Cannot change action on imported rows");
            }

            // Restore ignored rows back to ready when user includes them
            if (dbAction eq "import_new" and qRow.status eq "ignored") {
                newStatus = "ready";
            }

            // Update row
            if (len(newStatus)) {
                queryExecute(
                    "UPDATE import_v3_rows
                     SET user_action = :action,
                         status = :status,
                         user_action_at = NOW(),
                         updated_at = NOW()
                     WHERE row_id = :row_id",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        action: { value: dbAction, cfsqltype: "cf_sql_varchar" },
                        status: { value: newStatus, cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
            } else {
                queryExecute(
                    "UPDATE import_v3_rows
                     SET user_action = :action,
                         user_action_at = NOW(),
                         updated_at = NOW()
                     WHERE row_id = :row_id",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        action: { value: dbAction, cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
            }

            // Update job counts
            updateJobRowCounts(arguments.job_id);

            // Get updated stats
            var stats = getJobStats(arguments.job_id);

            writeLog(file="importv3", text="[service.setRowAction] OK job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " action=" & dbAction);
            return ok(
                data = {
                    row_id: arguments.row_id,
                    action: dbAction,
                    status: len(newStatus) ? newStatus : qRow.status,
                    stats: stats
                },
                message = "Row action updated"
            );

        } catch (any e) {
            writeLog(file="importv3", text="[setRowAction] ERROR job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " action=" & arguments.action & " message=" & e.message);
            return fail(
                code = "UPDATE_ERROR",
                message = "Failed to update row action: " & e.message
            );
        }
    }

    /**
     * Set user action on multiple rows (bulk ignore/create).
     *
     * @param job_id The job ID
     * @param row_ids Array of row IDs
     * @param action The action: ignore|create
     * @param userid The user ID
     * @return struct with count of updated rows and stats
     */
    public struct function bulkRowAction(
        required numeric job_id,
        required array row_ids,
        required string action,
        required numeric userid
    ) {
        try {
            writeLog(file="importv3", text="[service.bulkRowAction] START job_id=" & arguments.job_id & " row_count=" & arrayLen(arguments.row_ids) & " action=" & arguments.action);
            if (arrayLen(arguments.row_ids) eq 0) {
                return fail(code = "MISSING_PARAMS", message = "No row IDs provided");
            }

            // Normalize action
            var normalizedAction = lcase(trim(arguments.action));
            var dbAction = "";
            var newStatus = "";

            switch (normalizedAction) {
                case "ignore":
                case "skip":
                    dbAction = "skip";
                    newStatus = "ignored";
                    break;
                case "create":
                case "import_new":
                    dbAction = "import_new";
                    newStatus = "";
                    break;
                case "update":
                case "update_existing":
                    return fail(
                        code = "UPDATE_NOT_SUPPORTED",
                        message = "Update mode is not supported in the current release."
                    );
                default:
                    return fail(
                        code = "INVALID_ACTION",
                        message = "Invalid action: " & normalizedAction
                    );
            }

            // Build safe ID list
            var safeIds = [];
            for (var id in arguments.row_ids) {
                if (isNumeric(id) and val(id) gt 0) {
                    arrayAppend(safeIds, val(id));
                }
            }

            if (arrayLen(safeIds) eq 0) {
                return fail(code = "MISSING_PARAMS", message = "No valid row IDs provided");
            }

            // Update rows (only those not already imported)
            var updateSql = "";
            if (len(newStatus)) {
                updateSql = "
                    UPDATE import_v3_rows r
                    INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
                    SET r.user_action = :action,
                        r.status = :status,
                        r.user_action_at = NOW(),
                        r.updated_at = NOW()
                    WHERE r.row_id IN (:safe_id_list)
                      AND r.job_id = :job_id
                      AND j.userid = :userid
                      AND r.status NOT IN ('imported', 'updated', 'failed')
                ";
            } else {
                // For import_new: restore ignored rows back to ready, keep others as-is
                updateSql = "
                    UPDATE import_v3_rows r
                    INNER JOIN import_v3_jobs j ON r.job_id = j.job_id
                    SET r.user_action = :action,
                        r.status = CASE WHEN r.status = 'ignored' THEN 'ready' ELSE r.status END,
                        r.user_action_at = NOW(),
                        r.updated_at = NOW()
                    WHERE r.row_id IN (:safe_id_list)
                      AND r.job_id = :job_id
                      AND j.userid = :userid
                      AND r.status NOT IN ('imported', 'updated', 'failed')
                ";
            }

            var updateParams = {
                job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                action: { value: dbAction, cfsqltype: "cf_sql_varchar" },
                safe_id_list: { value: arrayToList(safeIds), cfsqltype: "cf_sql_integer", list: true }
            };
            if (len(newStatus)) {
                updateParams.status = { value: newStatus, cfsqltype: "cf_sql_varchar" };
            }

            var result = {};
            queryExecute(updateSql, updateParams, { datasource: application.datasource, result: "result" });

            var updatedCount = structKeyExists(result, "recordCount") ? result.recordCount : arrayLen(safeIds);

            // Update job counts
            updateJobRowCounts(arguments.job_id);

            // Get updated stats
            var stats = getJobStats(arguments.job_id);

            writeLog(file="importv3", text="[service.bulkRowAction] OK job_id=" & arguments.job_id & " action=" & dbAction & " updated_count=" & updatedCount);
            return ok(
                data = {
                    updated_count: updatedCount,
                    requested_count: arrayLen(safeIds),
                    action: dbAction,
                    stats: stats
                },
                message = updatedCount & " row(s) updated"
            );

        } catch (any e) {
            writeLog(file="importv3", text="[bulkRowAction] ERROR job_id=" & arguments.job_id & " row_count=" & arrayLen(arguments.row_ids) & " action=" & arguments.action & " message=" & e.message);
            return fail(
                code = "UPDATE_ERROR",
                message = "Failed to update rows: " & e.message
            );
        }
    }

}

