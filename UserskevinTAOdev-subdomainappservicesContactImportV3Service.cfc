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

    // ============================================================
    // VALID STATUS VALUES AND TRANSITIONS
    // ============================================================
    
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

    // ============================================================
    // CONSTRUCTOR
    // ============================================================
    
    public ContactImportV3Service function init() {
        return this;
    }

    // ============================================================
    // JSON ENVELOPE HELPERS
    // ============================================================
    
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

    // ============================================================
    // JOB HELPERS
    // ============================================================
    
    public struct function getJob(required numeric job_id) {
        var result = { "found": false };
        
        try {
            var qJob = queryExecute(
                "SELECT job_id, userid, source_filename, file_type, file_size, file_hash,
                    stored_file_path, status, error_message, created_at, updated_at,
                    started_at, finished_at, total_rows, parsed_rows, valid_rows,
                    problem_rows, dupe_rows, imported_rows, updated_rows, skipped_rows,
                    options_json, import_mode, allow_blank_overwrite,
                    relationship_system_default, folder_assignment_json
                FROM import_v3_jobs WHERE job_id = :job_id",
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
                "SELECT job_id FROM import_v3_jobs WHERE job_id = :job_id AND userid = :userid",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );
            
            if (qCheck.recordCount eq 1) {
                return { "valid": true };
            } else {
                return fail(code = "ACCESS_DENIED", message = "You do not have access to this import job.", data = { job_id: arguments.job_id });
            }
        } catch (any e) {
            return fail(code = "ACCESS_DENIED", message = "Unable to verify job ownership.", data = { job_id: arguments.job_id });
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

    // ============================================================
    // EVENT LOGGING
    // ============================================================
    
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
    // LOCKING
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
            
            // Build IN clause for valid source statuses
            var statusList = "";
            for (var s in validSourceStatuses) {
                statusList = listAppend(statusList, chr(39) & s & chr(39));
            }
            
            // Attempt atomic status transition with ownership check
            var updateResult = queryExecute(
                "UPDATE import_v3_jobs
                SET status = :target_status, updated_at = NOW(),
                    options_json = JSON_SET(COALESCE(options_json, " & chr(39) & "{}" & chr(39) & "), " & chr(39) & "$$.lock_token" & chr(39) & ", :lock_token, " & chr(39) & "$$.lock_acquired_at" & chr(39) & ", NOW())
                WHERE job_id = :job_id AND userid = :userid AND status IN (" & statusList & ")",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                    target_status: { value: targetStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                    lock_token: { value: arguments.lock_token, cfsqltype: "cf_sql_varchar", maxlength: 64 }
                },
                { datasource: application.datasource, result: "qResult" }
            );
            
            if (qResult.recordCount eq 1) {
                logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_acquired", detail = { purpose: arguments.lock_purpose, lock_token: arguments.lock_token });
                return { "acquired": true, "message": "" };
            } else {
                var jobResult = getJobForUser(arguments.job_id, arguments.userid);
                if (!jobResult.success) {
                    return { "acquired": false, "message": jobResult.message };
                }
                var currentStatus = jobResult.data.job.status;
                if (currentStatus eq targetStatus) {
                    return { "acquired": false, "message": "Job is already locked for " & arguments.lock_purpose & ". Another operation may be in progress." };
                } else {
                    return { "acquired": false, "message": "Job is in status " & chr(39) & currentStatus & chr(39) & " which cannot be locked for " & arguments.lock_purpose & ". Expected: " & arrayToList(validSourceStatuses, " or ") & "." };
                }
            }
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_error", detail = { error: e.message, purpose: arguments.lock_purpose });
            return { "acquired": false, "message": "An error occurred acquiring the lock: " & e.message };
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
            
            // Verify lock token if stored in options_json
            if (len(job.options_json)) {
                var options = {};
                try { options = deserializeJSON(job.options_json); } catch (any e) { options = {}; }
                if (structKeyExists(options, "lock_token") && options.lock_token neq arguments.lock_token) {
                    return { "released": false, "message": "Lock token mismatch. You are not the lock holder." };
                }
            }
            
            // Determine target status based on current locked status
            var targetStatus = "";
            switch (job.status) {
                case "finalizing": targetStatus = "reviewing"; break;
                case "parsing": targetStatus = "uploaded"; break;
                default:
                    return { "released": false, "message": "Job is not currently locked. Current status: " & job.status };
            }
            
            // Release by transitioning back and clearing lock token
            queryExecute(
                "UPDATE import_v3_jobs SET status = :target_status, updated_at = NOW(),
                    options_json = JSON_REMOVE(COALESCE(options_json, " & chr(39) & "{}" & chr(39) & "), " & chr(39) & "$$.lock_token" & chr(39) & ", " & chr(39) & "$$.lock_acquired_at" & chr(39) & ")
                WHERE job_id = :job_id AND userid = :userid",
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
            return { "released": false, "message": "An error occurred releasing the lock: " & e.message };
        }
    }


    // ============================================================
    // LOCKING
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
            
            // Build IN clause for valid source statuses
            var statusList = "";
            for (var s in validSourceStatuses) {
                statusList = listAppend(statusList, chr(39) & s & chr(39));
            }
            
            // Attempt atomic status transition with ownership check
            var updateResult = queryExecute(
                "UPDATE import_v3_jobs
                SET status = :target_status, updated_at = NOW(),
                    options_json = JSON_SET(COALESCE(options_json, " & chr(39) & "{}" & chr(39) & "), " & chr(39) & "$.lock_token" & chr(39) & ", :lock_token, " & chr(39) & "$.lock_acquired_at" & chr(39) & ", NOW())
                WHERE job_id = :job_id AND userid = :userid AND status IN (" & statusList & ")",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                    target_status: { value: targetStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                    lock_token: { value: arguments.lock_token, cfsqltype: "cf_sql_varchar", maxlength: 64 }
                },
                { datasource: application.datasource, result: "qResult" }
            );
            
            if (qResult.recordCount eq 1) {
                logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_acquired", detail = { purpose: arguments.lock_purpose, lock_token: arguments.lock_token });
                return { "acquired": true, "message": "" };
            } else {
                var jobResult = getJobForUser(arguments.job_id, arguments.userid);
                if (!jobResult.success) {
                    return { "acquired": false, "message": jobResult.message };
                }
                var currentStatus = jobResult.data.job.status;
                if (currentStatus eq targetStatus) {
                    return { "acquired": false, "message": "Job is already locked for " & arguments.lock_purpose & ". Another operation may be in progress." };
                } else {
                    return { "acquired": false, "message": "Job is in status " & chr(39) & currentStatus & chr(39) & " which cannot be locked for " & arguments.lock_purpose & ". Expected: " & arrayToList(validSourceStatuses, " or ") & "." };
                }
            }
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_error", detail = { error: e.message, purpose: arguments.lock_purpose });
            return { "acquired": false, "message": "An error occurred acquiring the lock: " & e.message };
        }
    }
    
    public struct function releaseJobLock(
        required numeric job_id,
        required numeric userid,
        required string lock_token
        if (!structKeyExists(variables.STATUS_TRANSITIONS, arguments.from_status)) { return false; }
        try {
            var jobResult = getJobForUser(arguments.job_id, arguments.userid);
            if (!jobResult.success) {
                return { "released": false, "message": jobResult.message };
            }
            
            var job = jobResult.data.job;
            
            if (len(job.options_json)) {
                var options = {};
                try { options = deserializeJSON(job.options_json); } catch (any e) { options = {}; }
                if (structKeyExists(options, "lock_token") && options.lock_token neq arguments.lock_token) {
                    return { "released": false, "message": "Lock token mismatch. You are not the lock holder." };
                }
            }
            
            var targetStatus = "";
            switch (job.status) {
                case "finalizing": targetStatus = "reviewing"; break;
                case "parsing": targetStatus = "uploaded"; break;
                default:
                    return { "released": false, "message": "Job is not currently locked. Current status: " & job.status };
            }
            
            queryExecute(
                "UPDATE import_v3_jobs SET status = :target_status, updated_at = NOW(),
                    options_json = JSON_REMOVE(COALESCE(options_json, " & chr(39) & "{}" & chr(39) & "), " & chr(39) & "$.lock_token" & chr(39) & ", " & chr(39) & "$.lock_acquired_at" & chr(39) & ")
                WHERE job_id = :job_id AND userid = :userid",
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
            return { "released": false, "message": "An error occurred releasing the lock: " & e.message };
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
                return fail(code = "INVALID_STATUS", message = "Invalid status value: " & arguments.new_status, data = { valid_statuses: variables.VALID_STATUSES });
            }
            
            if (arguments.new_status eq "failed" && !len(trim(arguments.error_message))) {
                return fail(code = "MISSING_ERROR_MESSAGE", message = "An error message is required when setting status to failed.", data = {});
            }
            
            var jobResult = getJobForUser(arguments.job_id, arguments.userid);
            if (!jobResult.success) {
                return jobResult;
            }
            
            var currentStatus = jobResult.data.job.status;
            
            if (!isValidTransition(currentStatus, arguments.new_status)) {
                return fail(
                    code = "INVALID_STATE",
                    message = "Cannot transition from " & chr(39) & currentStatus & chr(39) & " to " & chr(39) & arguments.new_status & chr(39) & ".",
                    data = {
                        current_status: currentStatus,
                        requested_status: arguments.new_status,
                        allowed_transitions: structKeyExists(variables.STATUS_TRANSITIONS, currentStatus) ? variables.STATUS_TRANSITIONS[currentStatus] : []
                    }
                );
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
            
            queryExecute(
                "UPDATE import_v3_jobs SET status = :new_status, updated_at = NOW() " & additionalFields & " WHERE job_id = :job_id AND userid = :userid",
                params,
                { datasource: application.datasource }
            );
            
            logEvent(
                job_id = arguments.job_id,
                userid = arguments.userid,
                event_type = "status_changed",
                detail = { from_status: currentStatus, to_status: arguments.new_status, error_message: arguments.new_status eq "failed" ? arguments.error_message : "" }
            );
            
            return ok(data = { previous_status: currentStatus, new_status: arguments.new_status }, message = "Status updated successfully.");
            
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "status_change_error", detail = { requested_status: arguments.new_status, error: e.message });
            return fail(code = "INTERNAL_ERROR", message = "An error occurred updating job status.", data = { job_id: arguments.job_id });
        }
    }
    
    private boolean function isValidTransition(required string from_status, required string to_status) {
        if (arguments.from_status eq arguments.to_status) {
            return true;
        }
        if (!structKeyExists(variables.STATUS_TRANSITIONS, arguments.from_status)) {
            return false;
        }
        var allowedTransitions = variables.STATUS_TRANSITIONS[arguments.from_status];
        return arrayFindNoCase(allowedTransitions, arguments.to_status) > 0;
    }

}


    // ============================================================
    // LOCKING
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
            
            var statusList = "";
            for (var s in validSourceStatuses) {
                statusList = listAppend(statusList, chr(39) & s & chr(39));
            }
            
            var updateResult = queryExecute(
                "UPDATE import_v3_jobs
                SET status = :target_status, updated_at = NOW(),
                    options_json = JSON_SET(COALESCE(options_json, " & chr(39) & "{}" & chr(39) & "), " & chr(39) & "$.lock_token" & chr(39) & ", :lock_token, " & chr(39) & "$.lock_acquired_at" & chr(39) & ", NOW())
                WHERE job_id = :job_id AND userid = :userid AND status IN (" & statusList & ")",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                    target_status: { value: targetStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 },
                    lock_token: { value: arguments.lock_token, cfsqltype: "cf_sql_varchar", maxlength: 64 }
                },
                { datasource: application.datasource, result: "qResult" }
            );
            
            if (qResult.recordCount eq 1) {
                logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_acquired", detail = { purpose: arguments.lock_purpose, lock_token: arguments.lock_token });
                return { "acquired": true, "message": "" };
            } else {
                var jobResult = getJobForUser(arguments.job_id, arguments.userid);
                if (!jobResult.success) {
                    return { "acquired": false, "message": jobResult.message };
                }
                var currentStatus = jobResult.data.job.status;
                if (currentStatus eq targetStatus) {
                    return { "acquired": false, "message": "Job is already locked for " & arguments.lock_purpose & ". Another operation may be in progress." };
                } else {
                    return { "acquired": false, "message": "Job is in status " & chr(39) & currentStatus & chr(39) & " which cannot be locked for " & arguments.lock_purpose & ". Expected: " & arrayToList(validSourceStatuses, " or ") & "." };
                }
            }
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_error", detail = { error: e.message, purpose: arguments.lock_purpose });
            return { "acquired": false, "message": "An error occurred acquiring the lock: " & e.message };
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
            
            if (len(job.options_json)) {
                var options = {};
                try { options = deserializeJSON(job.options_json); } catch (any e) { options = {}; }
                if (structKeyExists(options, "lock_token") && options.lock_token neq arguments.lock_token) {
                    return { "released": false, "message": "Lock token mismatch. You are not the lock holder." };
                }
            }
            
            var targetStatus = "";
            switch (job.status) {
                case "finalizing": targetStatus = "reviewing"; break;
                case "parsing": targetStatus = "uploaded"; break;
                default:
                    return { "released": false, "message": "Job is not currently locked. Current status: " & job.status };
            }
            
            queryExecute(
                "UPDATE import_v3_jobs SET status = :target_status, updated_at = NOW(),
                    options_json = JSON_REMOVE(COALESCE(options_json, " & chr(39) & "{}" & chr(39) & "), " & chr(39) & "$.lock_token" & chr(39) & ", " & chr(39) & "$.lock_acquired_at" & chr(39) & ")
                WHERE job_id = :job_id AND userid = :userid",
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
            return { "released": false, "message": "An error occurred releasing the lock: " & e.message };
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
                return fail(code = "INVALID_STATUS", message = "Invalid status value: " & arguments.new_status, data = { valid_statuses: variables.VALID_STATUSES });
            }
            
            if (arguments.new_status eq "failed" && !len(trim(arguments.error_message))) {
                return fail(code = "MISSING_ERROR_MESSAGE", message = "An error message is required when setting status to failed.", data = {});
            }
            
            var jobResult = getJobForUser(arguments.job_id, arguments.userid);
            if (!jobResult.success) {
                return jobResult;
            }
            
            var currentStatus = jobResult.data.job.status;
            
            if (!isValidTransition(currentStatus, arguments.new_status)) {
                return fail(
                    code = "INVALID_STATE",
                    message = "Cannot transition from " & chr(39) & currentStatus & chr(39) & " to " & chr(39) & arguments.new_status & chr(39) & ".",
                    data = {
                        current_status: currentStatus,
                        requested_status: arguments.new_status,
                        allowed_transitions: structKeyExists(variables.STATUS_TRANSITIONS, currentStatus) ? variables.STATUS_TRANSITIONS[currentStatus] : []
                    }
                );
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
            
            queryExecute(
                "UPDATE import_v3_jobs SET status = :new_status, updated_at = NOW() " & additionalFields & " WHERE job_id = :job_id AND userid = :userid",
                params,
                { datasource: application.datasource }
            );
            
            logEvent(
                job_id = arguments.job_id,
                userid = arguments.userid,
                event_type = "status_changed",
                detail = { from_status: currentStatus, to_status: arguments.new_status, error_message: arguments.new_status eq "failed" ? arguments.error_message : "" }
            );
            
            return ok(data = { previous_status: currentStatus, new_status: arguments.new_status }, message = "Status updated successfully.");
            
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "status_change_error", detail = { requested_status: arguments.new_status, error: e.message });
            return fail(code = "INTERNAL_ERROR", message = "An error occurred updating job status.", data = { job_id: arguments.job_id });
        }
    }
    
    private boolean function isValidTransition(required string from_status, required string to_status) {
        if (arguments.from_status eq arguments.to_status) {
            return true;
        }
        if (!structKeyExists(variables.STATUS_TRANSITIONS, arguments.from_status)) {
            return false;
        }
        var allowedTransitions = variables.STATUS_TRANSITIONS[arguments.from_status];
        return arrayFindNoCase(allowedTransitions, arguments.to_status) > 0;
    }

}
