/**
 * AuditionImportService.cfc
 *
 * Core service for Audition Import operations.
 * Handles job management, ownership verification, locking, status transitions, and event logging.
 * Direct port of ContactImportV3Service.cfc with audition-domain table references.
 *
 * All public methods return stable response envelopes:
 *   Success: {success: true, message: "", data: {...}}
 *   Failure: {success: false, code: "ERROR_CODE", message: "...", data: {...}}
 *
 * CRITICAL: All SQL queries enforce ownership via WHERE clauses (not post-query IF checks).
 * CRITICAL: All queries use cfqueryparam - no string concatenation.
 *
 * @author TAO Development
 * @created 2026-03-09
 */
component displayname="AuditionImportService" accessors="true" output="false" {

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

    public AuditionImportService function init() {
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
     * Check if Audition Import is enabled for a specific user.
     */
    public boolean function isAuditionImportEnabled(required numeric userid) {
        try {
            if (!structKeyExists(application, "features")) {
                return false;
            }
            if (structKeyExists(application.features, "auditionImportEnabled")
                && application.features.auditionImportEnabled eq true) {
                return true;
            }
            if (structKeyExists(application.features, "auditionImportAllowedUsers")
                && isArray(application.features.auditionImportAllowedUsers)
                && arrayFind(application.features.auditionImportAllowedUsers, arguments.userid) gt 0) {
                return true;
            }
            return false;
        } catch (any e) {
            return false;
        }
    }

    /**
     * Get current feature flag status for diagnostics.
     */
    public struct function getFeatureFlagStatus() {
        var status = {
            "auditionImportEnabled": false,
            "allowedUserCount": 0,
            "allowedUserIds": [],
            "cacheAge": 0,
            "cacheTTL": 60
        };
        try {
            if (structKeyExists(application, "features")) {
                if (structKeyExists(application.features, "auditionImportEnabled")) {
                    status.auditionImportEnabled = application.features.auditionImportEnabled;
                }
                if (structKeyExists(application.features, "auditionImportAllowedUsers")) {
                    status.allowedUserIds = application.features.auditionImportAllowedUsers;
                    status.allowedUserCount = arrayLen(application.features.auditionImportAllowedUsers);
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

    private struct function getJob(required numeric job_id) {
        var result = {
            "found": false
        };

        try {
            var qJob = queryExecute(
                "SELECT
                    job_id, userid, source_filename, file_type, file_size, file_hash,
                    stored_file_path, status, error_message,
                    created_at, updated_at, started_at, finished_at,
                    total_rows, parsed_rows, valid_rows, problem_rows,
                    dupe_rows, imported_rows, skipped_rows,
                    options_json, import_mode
                FROM import_auditions_jobs
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
            result.error = e.message;
            result.errorType = e.type;
            try {
                writeLog(text="[AuditionImport] getJob FAIL job_id=#arguments.job_id# error=#e.message# detail=#e.detail# type=#e.type#", file="import_auditions", type="error");
            } catch (any logErr) {}
        }

        return result;
    }

    public struct function assertJobOwnership(required numeric job_id, required numeric userid) {
        try {
            var qCheck = queryExecute(
                "SELECT job_id
                FROM import_auditions_jobs
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
            try {
                writeLog(text="[AuditionImport] assertJobOwnership FAIL job_id=#arguments.job_id# userid=#arguments.userid# error=#e.message#", file="import_auditions", type="error");
            } catch (any logErr) {}
            return fail(
                code = "OWNERSHIP_CHECK_ERROR",
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
                    problem_rows, dupe_rows, imported_rows, skipped_rows,
                    options_json, import_mode
                FROM import_auditions_jobs WHERE job_id = :job_id AND userid = :userid",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );

            if (qJob.recordCount eq 0) {
                var qExists = queryExecute(
                    "SELECT job_id FROM import_auditions_jobs WHERE job_id = :job_id",
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
            try {
                logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "error_get_job", detail = { error: e.message, detail: e.detail });
            } catch (any logErr) {}
            try {
                writeLog(text="[AuditionImport] getJobForUser FAIL job_id=#arguments.job_id# userid=#arguments.userid# error=#e.message#", file="import_auditions", type="error");
            } catch (any wlErr) {}
            return fail(code = "INTERNAL_ERROR", message = "An error occurred loading this job. Check server logs for details.", data = { job_id: arguments.job_id, error_type: e.type });
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
                    "INSERT INTO import_auditions_events (job_id, userid, event_type, event_detail, row_id, created_at)
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
                    "INSERT INTO import_auditions_events (job_id, userid, event_type, event_detail, created_at)
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
            try {
                writeLog(text="[AuditionImport] logEvent FAIL job_id=#arguments.job_id# event_type=#arguments.event_type# error=#e.message#", file="import_auditions", type="error");
            } catch (any wlErr) {}
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
                    validSourceStatuses = ["reviewing", "finalizing"];
                    break;
                case "parse":
                    targetStatus = "parsing";
                    validSourceStatuses = ["uploaded"];
                    break;
                default:
                    return { "acquired": false, "message": "Unknown lock purpose: " & arguments.lock_purpose };
            }

            var statusListValue = arrayToList(validSourceStatuses, ",");

            var qResult = {};
            queryExecute(
                "UPDATE import_auditions_jobs SET status = :target_status, updated_at = NOW()
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
                writeLog(file="import_auditions", text="[acquireJobLock] ACQUIRED job_id=" & arguments.job_id & " userid=" & arguments.userid & " purpose=" & arguments.lock_purpose);
                return { "acquired": true, "message": "" };
            } else {
                var jobResult = getJobForUser(arguments.job_id, arguments.userid);
                if (!jobResult.success) {
                    return { "acquired": false, "message": jobResult.message };
                }
                writeLog(file="import_auditions", text="[acquireJobLock] DENIED job_id=" & arguments.job_id & " userid=" & arguments.userid & " purpose=" & arguments.lock_purpose & " current_status=" & jobResult.data.job.status);
                return { "acquired": false, "message": "Job cannot be locked from current status: " & jobResult.data.job.status };
            }
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_error", detail = { error: e.message });
            writeLog(file="import_auditions", text="[acquireJobLock] ERROR job_id=" & arguments.job_id & " userid=" & arguments.userid & " message=" & e.message);
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
                "UPDATE import_auditions_jobs SET status = :target_status, updated_at = NOW() WHERE job_id = :job_id AND userid = :userid",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                    target_status: { value: targetStatus, cfsqltype: "cf_sql_varchar", maxlength: 20 }
                },
                { datasource: application.datasource }
            );

            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_released", detail = { previous_status: job.status, new_status: targetStatus });
            writeLog(file="import_auditions", text="[releaseJobLock] RELEASED job_id=" & arguments.job_id & " from=" & job.status & " to=" & targetStatus);
            return { "released": true };
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "lock_release_error", detail = { error: e.message });
            writeLog(file="import_auditions", text="[releaseJobLock] ERROR job_id=" & arguments.job_id & " message=" & e.message);
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
            writeLog(file="import_auditions", text="[service] setJobStatus START job_id=" & arguments.job_id & " userid=" & arguments.userid & " new_status=" & arguments.new_status);
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

            queryExecute("UPDATE import_auditions_jobs SET status = :new_status, updated_at = NOW() " & additionalFields & " WHERE job_id = :job_id AND userid = :userid", params, { datasource: application.datasource });

            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "status_changed", detail = { from_status: currentStatus, to_status: arguments.new_status });
            writeLog(file="import_auditions", text="[setJobStatus] TRANSITION job_id=" & arguments.job_id & " from=" & currentStatus & " to=" & arguments.new_status);

            return ok(data = { previous_status: currentStatus, new_status: arguments.new_status }, message = "Status updated.");
        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "status_change_error", detail = { error: e.message });
            writeLog(file="import_auditions", text="[service.setJobStatus] ERROR job_id=" & arguments.job_id & " new_status=" & arguments.new_status & " message=" & e.message);
            return fail(code = "INTERNAL_ERROR", message = "Status update failed.", data = { job_id: arguments.job_id });
        }
    }

    private boolean function isValidTransition(required string from_status, required string to_status) {
        if (arguments.from_status eq arguments.to_status) { return true; }
        if (!structKeyExists(variables.STATUS_TRANSITIONS, arguments.from_status)) { return false; }
        return arrayFindNoCase(variables.STATUS_TRANSITIONS[arguments.from_status], arguments.to_status) > 0;
    }

    // ============================================================
    // ROW QUERY METHODS
    // ============================================================

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
                 FROM import_auditions_rows
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
                } else if (st eq "failed") {
                    stats.imported += row.cnt;
                }
            }
            stats.total = total;

        } catch (any e) {
            writeLog(file="import_auditions", text="[getJobStats] ERROR job_id=" & arguments.job_id & " msg=" & e.message & " detail=" & e.detail, type="error");
        }

        return stats;
    }

    public struct function getRows(
        required numeric job_id,
        required numeric userid,
        string statusFilter = "all",
        numeric page = 1,
        numeric pageSize = 50,
        string search = ""
    ) {
        try {
            var safePage = max(1, arguments.page);
            var safePageSize = min(200, max(1, arguments.pageSize));
            var offset = (safePage - 1) * safePageSize;

            var searchTerm = trim(arguments.search);
            var hasSearch = len(searchTerm) gt 0;

            // Build status filter clause
            var statusClause = "";
            if (arguments.statusFilter neq "all" and len(arguments.statusFilter)) {
                if (arguments.statusFilter eq "imported") {
                    statusClause = "AND r.status IN ('imported','failed')";
                } else {
                    statusClause = "AND r.status = :status";
                }
            }

            // Build search clause: search across audition-specific fields
            var searchClause = "";
            if (hasSearch) {
                searchClause = "AND r.row_id IN (
                    SELECT DISTINCT f.row_id FROM import_auditions_facts f
                    WHERE f.row_id IN (SELECT r2.row_id FROM import_auditions_rows r2 WHERE r2.job_id = :job_id_search)
                      AND f.field_name IN ('contact_name','project_name','role_name','casting_director')
                      AND f.normalized_value LIKE :search_term
                )";
            }

            // Get total count (ownership enforced via JOIN to jobs table)
            var countSql = "SELECT COUNT(*) as cnt FROM import_auditions_rows r
                INNER JOIN import_auditions_jobs j ON j.job_id = r.job_id AND j.userid = :userid
                WHERE r.job_id = :job_id #statusClause# #searchClause#";
            var countParams = {
                job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
            };
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

            // Fetch rows (ownership enforced via JOIN to jobs table)
            var rowsSql = "
                SELECT r.row_id, r.row_num, r.status, r.error_count, r.warning_count,
                       r.matched_audition_id, r.best_match_score, r.user_action,
                       r.created_audition_id, r.import_error,
                       r.validation_summary, r.dupe_candidates_json
                FROM import_auditions_rows r
                INNER JOIN import_auditions_jobs j ON j.job_id = r.job_id AND j.userid = :userid
                WHERE r.job_id = :job_id
                #statusClause#
                #searchClause#
                ORDER BY r.row_num ASC
                LIMIT :limit OFFSET :offset
            ";

            var rowParams = {
                job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
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

            // Batch load facts
            var factsMap = {};
            if (arrayLen(rowIds) gt 0) {
                var qFacts = queryExecute(
                    "SELECT f.row_id, f.field_name, f.normalized_value, f.is_valid,
                            f.validation_code, f.validation_message
                     FROM import_auditions_facts f
                     WHERE f.row_id IN (:row_id_list)
                     ORDER BY f.row_id, f.field_name",
                    { row_id_list: { value: arrayToList(rowIds), cfsqltype: "cf_sql_integer", list: true } },
                    { datasource: application.datasource }
                );

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
                    "created_audition_id": isNull(row.created_audition_id) ? 0 : row.created_audition_id,
                    "best_match_score": isNull(row.best_match_score) ? 0 : row.best_match_score,
                    "data": structKeyExists(factsMap, row.row_id) ? factsMap[row.row_id].data : {},
                    "validation": structKeyExists(factsMap, row.row_id) ? factsMap[row.row_id].validation : {},
                    "errors": structKeyExists(factsMap, row.row_id) ? factsMap[row.row_id].errors : []
                };

                if (!isNull(row.dupe_candidates_json) and len(row.dupe_candidates_json)) {
                    try {
                        var dupes = deserializeJSON(row.dupe_candidates_json);
                        rowData["dupe_count"] = arrayLen(dupes);
                    } catch (any e) {
                        rowData["dupe_count"] = 0;
                    }
                } else {
                    rowData["dupe_count"] = 0;
                }

                arrayAppend(rows, rowData);
            }

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
            writeLog(file="import_auditions", text="[getRows] ERROR job_id=" & arguments.job_id & " message=" & e.message);
            return fail(code = "QUERY_ERROR", message = "Failed to load rows: " & e.message);
        }
    }

    public struct function getRowDetail(
        required numeric job_id,
        required numeric row_id,
        required numeric userid
    ) {
        try {
            var qRow = queryExecute(
                "SELECT r.*
                 FROM import_auditions_rows r
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
                 FROM import_auditions_facts f
                 WHERE f.row_id = :row_id
                 ORDER BY f.field_name",
                { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

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

            // Parse duplicates with audition info
            var duplicates = [];
            var warnings = [];

            if (!isNull(row.dupe_candidates_json) and len(row.dupe_candidates_json)) {
                try {
                    var rawDupes = deserializeJSON(row.dupe_candidates_json);
                    for (var dupe in rawDupes) {
                        var dupeInfo = {
                            "audition_id": structKeyExists(dupe, "audition_id") ? dupe.audition_id : 0,
                            "score": structKeyExists(dupe, "score") ? dupe.score : 0
                        };

                        // Lookup audition details
                        try {
                            var qAud = queryExecute(
                                "SELECT a.project_name, a.role_name, a.audition_date, a.casting_director
                                 FROM auditions a
                                 WHERE a.audition_id = :aid AND a.userid = :uid",
                                {
                                    aid: { value: dupeInfo.audition_id, cfsqltype: "cf_sql_integer" },
                                    uid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                                },
                                { datasource: application.datasource }
                            );
                            if (qAud.recordCount gt 0) {
                                dupeInfo["project_name"] = qAud.project_name;
                                dupeInfo["role_name"] = qAud.role_name;
                                dupeInfo["audition_date"] = isDate(qAud.audition_date) ? dateFormat(qAud.audition_date, "yyyy-mm-dd") : "";
                                dupeInfo["casting_director"] = qAud.casting_director;
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

            var rowDetail = {
                "row_id": row.row_id,
                "row_num": row.row_num,
                "job_id": row.job_id,
                "status": row.status,
                "error_count": row.error_count,
                "warning_count": row.warning_count,
                "user_action": isNull(row.user_action) ? "" : row.user_action,
                "matched_audition_id": isNull(row.matched_audition_id) ? 0 : row.matched_audition_id,
                "best_match_score": isNull(row.best_match_score) ? 0 : row.best_match_score,
                "created_audition_id": isNull(row.created_audition_id) ? 0 : row.created_audition_id,
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
            writeLog(file="import_auditions", text="[getRowDetail] ERROR job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " message=" & e.message);
            return fail(code = "QUERY_ERROR", message = "Failed to load row detail: " & e.message);
        }
    }

    // ============================================================
    // ROW ACTION METHODS
    // ============================================================

    public struct function setRowAction(
        required numeric job_id,
        required numeric row_id,
        required string action,
        required numeric userid
    ) {
        try {
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
                    return fail(code = "UPDATE_NOT_SUPPORTED", message = "Update mode is not supported. Only new audition creation is available.");
                default:
                    return fail(code = "INVALID_ACTION", message = "Invalid action: " & normalizedAction);
            }

            var qRow = queryExecute(
                "SELECT r.row_id, r.status
                 FROM import_auditions_rows r
                 INNER JOIN import_auditions_jobs j ON r.job_id = j.job_id
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

            if (listFindNoCase("imported,failed", qRow.status)) {
                return fail(code = "INVALID_STATE", message = "Cannot change action on imported rows");
            }

            if (dbAction eq "import_new" and qRow.status eq "ignored") {
                newStatus = "ready";
            }

            if (len(newStatus)) {
                queryExecute(
                    "UPDATE import_auditions_rows
                     SET user_action = :action, status = :status, user_action_at = NOW(), updated_at = NOW()
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
                    "UPDATE import_auditions_rows
                     SET user_action = :action, user_action_at = NOW(), updated_at = NOW()
                     WHERE row_id = :row_id",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        action: { value: dbAction, cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
            }

            updateJobRowCounts(arguments.job_id);
            var stats = getJobStats(arguments.job_id);

            return ok(
                data = { row_id: arguments.row_id, action: dbAction, status: len(newStatus) ? newStatus : qRow.status, stats: stats },
                message = "Row action updated"
            );

        } catch (any e) {
            writeLog(file="import_auditions", text="[setRowAction] ERROR job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " message=" & e.message);
            return fail(code = "UPDATE_ERROR", message = "Failed to update row action: " & e.message);
        }
    }

    public struct function bulkRowAction(
        required numeric job_id,
        required array row_ids,
        required string action,
        required numeric userid
    ) {
        try {
            if (arrayLen(arguments.row_ids) eq 0) {
                return fail(code = "MISSING_PARAMS", message = "No row IDs provided");
            }

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
                    return fail(code = "UPDATE_NOT_SUPPORTED", message = "Update mode is not supported.");
                default:
                    return fail(code = "INVALID_ACTION", message = "Invalid action: " & normalizedAction);
            }

            var safeIds = [];
            for (var id in arguments.row_ids) {
                if (isNumeric(id) and val(id) gt 0) {
                    arrayAppend(safeIds, val(id));
                }
            }

            if (arrayLen(safeIds) eq 0) {
                return fail(code = "MISSING_PARAMS", message = "No valid row IDs provided");
            }

            var updateSql = "";
            if (len(newStatus)) {
                updateSql = "
                    UPDATE import_auditions_rows r
                    INNER JOIN import_auditions_jobs j ON r.job_id = j.job_id
                    SET r.user_action = :action, r.status = :status,
                        r.user_action_at = NOW(), r.updated_at = NOW()
                    WHERE r.row_id IN (:safe_id_list)
                      AND r.job_id = :job_id AND j.userid = :userid
                      AND r.status NOT IN ('imported', 'failed')
                ";
            } else {
                updateSql = "
                    UPDATE import_auditions_rows r
                    INNER JOIN import_auditions_jobs j ON r.job_id = j.job_id
                    SET r.user_action = :action,
                        r.status = CASE WHEN r.status = 'ignored' THEN 'ready' ELSE r.status END,
                        r.user_action_at = NOW(), r.updated_at = NOW()
                    WHERE r.row_id IN (:safe_id_list)
                      AND r.job_id = :job_id AND j.userid = :userid
                      AND r.status NOT IN ('imported', 'failed')
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

            updateJobRowCounts(arguments.job_id);
            var stats = getJobStats(arguments.job_id);

            return ok(
                data = { updated_count: updatedCount, requested_count: arrayLen(safeIds), action: dbAction, stats: stats },
                message = updatedCount & " row(s) updated"
            );

        } catch (any e) {
            writeLog(file="import_auditions", text="[bulkRowAction] ERROR job_id=" & arguments.job_id & " message=" & e.message);
            return fail(code = "UPDATE_ERROR", message = "Failed to update rows: " & e.message);
        }
    }

    // ============================================================
    // HELPER METHODS
    // ============================================================

    private void function updateJobRowCounts(required numeric job_id) {
        try {
            queryExecute(
                "UPDATE import_auditions_jobs j
                 SET j.valid_rows = (SELECT COUNT(*) FROM import_auditions_rows WHERE job_id = j.job_id AND status = 'ready'),
                     j.problem_rows = (SELECT COUNT(*) FROM import_auditions_rows WHERE job_id = j.job_id AND status = 'problem'),
                     j.dupe_rows = (SELECT COUNT(*) FROM import_auditions_rows WHERE job_id = j.job_id AND status = 'dupe'),
                     j.skipped_rows = (SELECT COUNT(*) FROM import_auditions_rows WHERE job_id = j.job_id AND status = 'ignored'),
                     j.imported_rows = (SELECT COUNT(*) FROM import_auditions_rows WHERE job_id = j.job_id AND status = 'imported'),
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
     * Update facts for a row and recompute status.
     */
    public struct function updateRowFacts(
        required numeric job_id,
        required numeric row_id,
        required struct fields,
        required numeric userid
    ) {
        try {
            var qRow = queryExecute(
                "SELECT r.row_id, r.status, r.dupe_candidates_json
                 FROM import_auditions_rows r
                 INNER JOIN import_auditions_jobs j ON r.job_id = j.job_id
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

            if (listFindNoCase("imported,failed", qRow.status)) {
                return fail(code = "INVALID_STATE", message = "Cannot edit rows that have been imported");
            }

            var updatedFields = [];

            for (var fieldName in arguments.fields) {
                var newValue = arguments.fields[fieldName];
                var isValid = true;
                var normalizedVal = trim(newValue);
                var errCode = "";
                var errMsg = "";

                // Basic audition field validation
                switch (fieldName) {
                    case "contact_email":
                        if (len(normalizedVal) and not reFindNoCase("^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$", normalizedVal)) {
                            isValid = false;
                            errCode = "INVALID_EMAIL";
                            errMsg = "Invalid email format";
                        }
                        break;
                    case "audition_date":
                    case "callback_date":
                    case "booking_date":
                        if (len(normalizedVal)) {
                            try {
                                normalizedVal = dateFormat(parseDateTime(normalizedVal), "yyyy-mm-dd");
                            } catch (any e) {
                                isValid = false;
                                errCode = "INVALID_DATE";
                                errMsg = "Invalid date format";
                            }
                        }
                        break;
                    case "medium":
                        if (len(normalizedVal) and not listFindNoCase("film,television,theater,commercial,industrial,new media,voiceover,print,music video,web series,short film,student film,other", normalizedVal)) {
                            isValid = false;
                            errCode = "INVALID_MEDIUM";
                            errMsg = "Must be one of: film, television, theater, commercial, industrial, new media, voiceover, print, music video, web series, short film, student film, other";
                        }
                        break;
                    case "status":
                        if (len(normalizedVal) and not listFindNoCase("scheduled,completed,callback,booked,pass,confirmed,cancelled,pending", normalizedVal)) {
                            isValid = false;
                            errCode = "INVALID_STATUS";
                            errMsg = "Must be one of: scheduled, completed, callback, booked, pass, confirmed, cancelled, pending";
                        }
                        break;
                    case "self_tape":
                        if (len(normalizedVal)) {
                            normalizedVal = listFindNoCase("yes,true,1,y", normalizedVal) ? "1" : "0";
                        }
                        break;
                    case "category":
                        // Category is always valid - resolved at finalize time
                        // Accept any text: "Film", "Film - Feature", "TV-Episodic", etc.
                        break;
                }

                // Upsert the fact (unique key: row_id + field_name)
                queryExecute(
                    "INSERT INTO import_auditions_facts (row_id, column_id, field_name, raw_value, normalized_value, is_valid, validation_code, validation_message, updated_at)
                     SELECT :row_id, COALESCE(c.column_id, 0), :field_name, :raw_value, :normalized_value, :is_valid, :validation_code, :validation_message, NOW()
                     FROM (SELECT 1) AS dummy
                     LEFT JOIN import_auditions_columns c ON c.job_id = :job_id AND c.mapped_field = :field_name
                     ON DUPLICATE KEY UPDATE
                         column_id = VALUES(column_id),
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
            }

            // Recompute row status
            var qErrors = queryExecute(
                "SELECT COUNT(*) as cnt FROM import_auditions_facts WHERE row_id = :row_id AND is_valid = 0",
                { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            var newStatus = "ready";
            if (qErrors.cnt gt 0) {
                newStatus = "problem";
            } else if (!isNull(qRow.dupe_candidates_json) and len(qRow.dupe_candidates_json)) {
                try {
                    var dupes = deserializeJSON(qRow.dupe_candidates_json);
                    if (isArray(dupes) and arrayLen(dupes) gt 0) {
                        newStatus = "dupe";
                    }
                } catch (any e) {}
            }

            queryExecute(
                "UPDATE import_auditions_rows
                 SET status = :status,
                     error_count = (SELECT COUNT(*) FROM import_auditions_facts WHERE row_id = :row_id AND is_valid = 0),
                     updated_at = NOW()
                 WHERE row_id = :row_id",
                {
                    row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                    status: { value: newStatus, cfsqltype: "cf_sql_varchar" }
                },
                { datasource: application.datasource }
            );

            updateJobRowCounts(arguments.job_id);

            return getRowDetail(arguments.job_id, arguments.row_id, arguments.userid);

        } catch (any e) {
            writeLog(file="import_auditions", text="[updateRowFacts] ERROR job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " message=" & e.message);
            return fail(code = "UPDATE_ERROR", message = "Failed to update row: " & e.message);
        }
    }

    // =============================================================
    // FINALIZE JOB
    // =============================================================

    /**
     * Finalize a job: process all eligible rows into production auditions table.
     * Per-row transactions. Idempotent via import_auditions_row_results UNIQUE(row_id).
     */
    public struct function finalizeJob(required numeric job_id, required numeric userid) {
        var startTime = getTickCount();
        var lockToken = createUUID();
        writeLog(file="import_auditions", text="[finalizeJob] START job_id=" & arguments.job_id & " userid=" & arguments.userid);

        var counts = {
            "attempted": 0,
            "imported_new": 0,
            "skipped_already_imported": 0,
            "skipped_ignored": 0,
            "skipped_not_ready": 0,
            "failed": 0
        };
        var failures = [];
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
                var jobCheck = getJobForUser(arguments.job_id, arguments.userid);
                if (jobCheck.success && jobCheck.data.job.status eq "finalizing") {
                    return fail(code = "ALREADY_RUNNING", message = "Finalize is already in progress for this job.", data = { job_id: arguments.job_id });
                }
                if (jobCheck.success && jobCheck.data.job.status eq "completed") {
                    return fail(code = "ALREADY_COMPLETED", message = "This job has already been finalized.", data = { job_id: arguments.job_id });
                }
                return fail(code = "LOCK_FAILED", message = lockResult.message, data = { job_id: arguments.job_id });
            }

            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "finalize_started", detail = { lock_token: lockToken });

            // A2) Verify required lookup data exists before processing any rows
            var qRoleTypeCheck = queryExecute(
                "SELECT COUNT(*) as cnt FROM audroletypes WHERE audroletypeid = 1",
                {}, { datasource: application.datasource }
            );
            var qStepCheck = queryExecute(
                "SELECT COUNT(*) as cnt FROM audsteps WHERE audstepid = 1",
                {}, { datasource: application.datasource }
            );
            if (qRoleTypeCheck.cnt eq 0 or qStepCheck.cnt eq 0) {
                releaseJobLock(job_id = arguments.job_id, userid = arguments.userid, lock_token = lockToken);
                return fail(
                    code = "MISSING_LOOKUP_DATA",
                    message = "Required lookup data missing: audRoleTypeID=1 or audStepID=1 not found. Contact support.",
                    data = { job_id: arguments.job_id, roleTypeExists: qRoleTypeCheck.cnt gt 0, stepExists: qStepCheck.cnt gt 0 }
                );
            }

            // B) Reset rows that failed from a prior finalize attempt so they can be retried
            var qReset = {};
            queryExecute(
                "UPDATE import_auditions_rows
                 SET status = 'ready', import_error = NULL, updated_at = NOW()
                 WHERE job_id = :job_id AND status = 'failed' AND created_audition_id IS NULL",
                { job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource, result: "qReset" }
            );
            if (qReset.recordCount gt 0) {
                writeLog(file="import_auditions", text="[finalizeJob] RESET_FAILED_ROWS job_id=" & arguments.job_id & " count=" & qReset.recordCount);
            }

            // C) Fetch rows eligible for import
            var qRows = queryExecute(
                "SELECT r.row_id, r.row_num, r.status, r.user_action, r.created_audition_id
                 FROM import_auditions_rows r
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
                releaseJobLock(job_id = arguments.job_id, userid = arguments.userid, lock_token = lockToken);
                logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "finalize_no_rows", detail = { counts: counts });
                return fail(code = "NO_ROWS_ELIGIBLE", message = "No rows are eligible for import. Please review and approve rows before finalizing.", data = { counts: counts });
            }

            // D) Process each row
            for (var row in qRows) {
                var rowResult = processRowForImport(
                    row_id = row.row_id,
                    job_id = arguments.job_id,
                    userid = arguments.userid,
                    row_status = row.status,
                    user_action = row.user_action,
                    existing_audition_id = row.created_audition_id
                );

                writeLog(file="import_auditions", text="[finalizeJob] ROW_PROCESSED job_id=" & arguments.job_id & " row_id=" & row.row_id & " success=" & rowResult.success & " action=" & (structKeyExists(rowResult, "action") ? rowResult.action : "n/a"));

                if (rowResult.success) {
                    switch (rowResult.action) {
                        case "created":
                            counts.imported_new++;
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

            // E) Update job status based on results
            if (counts.imported_new gt 0) {
                setJobStatus(job_id = arguments.job_id, userid = arguments.userid, new_status = "completed");
            } else if (counts.skipped_already_imported gt 0 && counts.failed eq 0) {
                setJobStatus(job_id = arguments.job_id, userid = arguments.userid, new_status = "completed");
                arrayAppend(warnings, "All eligible rows were already imported from a previous run.");
            } else {
                logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "finalize_all_failed", detail = { counts: counts, failures_count: arrayLen(failures) });
                releaseJobLock(job_id = arguments.job_id, userid = arguments.userid, lock_token = lockToken);
                arrayAppend(warnings, "No auditions were successfully imported. Job returned to review status.");
            }

            updateFinalCounts(arguments.job_id, counts);

            var elapsedMs = getTickCount() - startTime;
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "finalize_completed", detail = { counts: counts, elapsed_ms: elapsedMs, failure_count: arrayLen(failures) });
            writeLog(file="import_auditions", text="[finalizeJob] COMPLETED job_id=" & arguments.job_id & " imported=" & counts.imported_new & " failed=" & counts.failed & " skipped=" & counts.skipped_already_imported & " elapsed_ms=" & elapsedMs);

            var message = "Finalize completed. " & counts.imported_new & " auditions created.";
            if (counts.skipped_already_imported gt 0) { message &= " " & counts.skipped_already_imported & " already imported."; }
            if (counts.failed gt 0) { message &= " " & counts.failed & " failed."; }

            return ok(data = { counts: counts, failures: failures, warnings: warnings, elapsed_ms: elapsedMs }, message = message);

        } catch (any e) {
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "finalize_error", detail = { error: e.message, detail: e.detail });
            writeLog(file="import_auditions", text="[finalizeJob] ERROR job_id=" & arguments.job_id & " message=" & e.message);
            try { releaseJobLock(job_id = arguments.job_id, userid = arguments.userid, lock_token = lockToken); } catch (any lockErr) {}
            return fail(code = "INTERNAL_ERROR", message = "Finalize failed: " & e.message, data = { job_id: arguments.job_id });
        }
    }

    // =============================================================
    // EVENT STATUS MAPPING
    // =============================================================

    private string function mapStatusToEventStatus(required string importStatus) {
        switch (lcase(arguments.importStatus)) {
            case "completed": case "callback": case "booked": case "pass":
                return "Completed";
            default:
                return "Active";
        }
    }

    // =============================================================
    // PROCESS SINGLE ROW FOR IMPORT (per-row transaction)
    // =============================================================

    private struct function processRowForImport(
        required numeric row_id,
        required numeric job_id,
        required numeric userid,
        required string row_status,
        string user_action = "",
        any existing_audition_id = ""
    ) {
        try {
            // A) Idempotency check: Always check row_results table to prevent
            //    duplicate creates on retry after partial transaction failure.
            //    If a prior attempt created records but the transaction rolled back
            //    before updating import_auditions_rows.created_audition_id, the row
            //    would still have NULL existing_audition_id — so we check row_results
            //    unconditionally instead of gating on existing_audition_id.
            var qExistingResult = queryExecute(
                "SELECT result_id, action_taken, audition_id
                 FROM import_auditions_row_results WHERE row_id = :row_id",
                { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );
            if (qExistingResult.recordCount gt 0 && qExistingResult.action_taken eq "created") {
                return { "success": true, "action": "skipped_already_imported", "audition_id": qExistingResult.audition_id };
            }
            // If prior attempt was "failed", allow retry by continuing

            // B) Load valid facts for this row
            var qFacts = queryExecute(
                "SELECT f.fact_id, f.field_name, f.normalized_value, f.is_valid
                 FROM import_auditions_facts f
                 WHERE f.row_id = :row_id AND f.is_valid = 1
                   AND f.normalized_value IS NOT NULL AND f.normalized_value != ''",
                { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            );

            if (qFacts.recordCount eq 0) {
                recordRowResult(row_id = arguments.row_id, job_id = arguments.job_id, action_taken = "failed", error_code = "NO_VALID_FACTS", error_message = "No valid fields to import");
                return { "success": false, "code": "NO_VALID_FACTS", "message": "Row has no valid fields to import" };
            }

            // C) Build audition data from facts
            var audData = {
                "project_name": "", "role_name": "", "casting_director": "", "agency": "",
                "audition_date": "", "audition_time": "", "location": "", "medium": "",
                "status": "", "callback_date": "", "booking_date": "", "self_tape": "0",
                "notes": "", "contact_name": "", "contact_email": "", "category": ""
            };

            for (var fact in qFacts) {
                if (structKeyExists(audData, fact.field_name)) {
                    audData[fact.field_name] = fact.normalized_value;
                }
            }

            // Validate minimum: need at least project_name
            if (!len(trim(audData.project_name))) {
                recordRowResult(row_id = arguments.row_id, job_id = arguments.job_id, action_taken = "failed", error_code = "MISSING_PROJECT", error_message = "Project name is required");
                return { "success": false, "code": "MISSING_PROJECT", "message": "Project name is required" };
            }

            // D) Resolve contact: lookup by email or name, or create minimal contact
            var contactId = 0;
            if (len(trim(audData.contact_email))) {
                var qContact = queryExecute(
                    "SELECT cd.contactid
                     FROM contactdetails cd
                     INNER JOIN phonebook pb ON pb.contactid = cd.contactid
                     WHERE cd.userid = :userid AND pb.type = 'email'
                       AND pb.phoneNumber = :email AND cd.IsDeleted = 0
                     LIMIT 1",
                    {
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                        email: { value: trim(audData.contact_email), cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
                if (qContact.recordCount gt 0) {
                    contactId = qContact.contactid;
                }
            }

            if (contactId eq 0 && len(trim(audData.contact_name))) {
                var qContact2 = queryExecute(
                    "SELECT contactid FROM contactdetails
                     WHERE userid = :userid AND contactFullName = :name AND IsDeleted = 0
                     LIMIT 1",
                    {
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                        name: { value: trim(audData.contact_name), cfsqltype: "cf_sql_varchar" }
                    },
                    { datasource: application.datasource }
                );
                if (qContact2.recordCount gt 0) {
                    contactId = qContact2.contactid;
                }
            }

            // D2) Resolve category (optional - 0 means no category, audition still imports)
            var audSubCatId = resolveCategoryToSubCatId(audData.category);

            // D3) Determine event date (default to today if no date provided)
            var eventDate = len(trim(audData.audition_date)) ? audData.audition_date : dateFormat(now(), "yyyy-mm-dd");

            // E) Create audition records in the real tables (audprojects -> audroles -> events_tbl)
            var newProjectId = 0;
            var newRoleId = 0;
            var newEventId = 0;
            var fieldsWritten = 0;

            transaction {
                // E1) INSERT into audprojects (the real project table)
                var qProjectResult = {};
                queryExecute(
                    "INSERT INTO audprojects (
                        projName, projDescription, userid, audSubCatID,
                        isDeleted, isDirect, contactid, projdate, audprojectdate
                    ) VALUES (
                        :projName, :projDescription, :userid, :audSubCatID,
                        0, 0, :contactid, :projdate, :projdate
                    )",
                    {
                        projName: { value: left(trim(audData.project_name), 500), cfsqltype: "cf_sql_varchar" },
                        projDescription: { value: audData.notes, cfsqltype: "cf_sql_longvarchar", null: !len(audData.notes) },
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                        audSubCatID: { value: audSubCatId, cfsqltype: "cf_sql_integer", null: audSubCatId eq 0 },
                        contactid: { value: contactId, cfsqltype: "cf_sql_integer", null: contactId eq 0 },
                        projdate: { value: eventDate, cfsqltype: "cf_sql_date" }
                    },
                    { datasource: application.datasource, result: "qProjectResult" }
                );
                newProjectId = qProjectResult.generatedKey;

                // E2) INSERT into audroles (linked to project)
                var roleName = len(trim(audData.role_name)) ? left(trim(audData.role_name), 500) : "Imported Role";
                var qRoleResult = {};
                queryExecute(
                    "INSERT INTO audroles (
                        audRoleName, audprojectID, audRoleTypeID,
                        charDescription, userid, isDeleted, isBooked
                    ) VALUES (
                        :roleName, :projectId, 1,
                        :charDescription, :userid, 0, 0
                    )",
                    {
                        roleName: { value: roleName, cfsqltype: "cf_sql_varchar" },
                        projectId: { value: newProjectId, cfsqltype: "cf_sql_integer" },
                        charDescription: { value: audData.notes, cfsqltype: "cf_sql_longvarchar", null: !len(audData.notes) },
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource: application.datasource, result: "qRoleResult" }
                );
                newRoleId = qRoleResult.generatedKey;

                // E3) INSERT into events_tbl (linked to role - the actual audition event)
                var qEventResult = {};
                // Determine audition type: 2 = Self-Tape, 1 = In-Person (default)
                var audTypeId = (audData.self_tape eq "1") ? 2 : 1;

                queryExecute(
                    "INSERT INTO events_tbl (
                        userid, audRoleID, eventtitle,
                        eventStart, eventStartTime,
                        audLocation, audStepID, eventstatus, audTypeID
                    ) VALUES (
                        :userid, :roleId, :eventtitle,
                        :eventStart, :eventStartTime,
                        :audLocation, :audStepID, :eventstatus, :audTypeID
                    )",
                    {
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                        roleId: { value: newRoleId, cfsqltype: "cf_sql_integer" },
                        eventtitle: { value: left(trim(audData.project_name), 500), cfsqltype: "cf_sql_varchar" },
                        eventStart: { value: eventDate, cfsqltype: "cf_sql_date" },
                        eventStartTime: { value: audData.audition_time, cfsqltype: "cf_sql_time", null: !len(trim(audData.audition_time)) },
                        audLocation: { value: audData.location, cfsqltype: "cf_sql_varchar", null: !len(trim(audData.location)) },
                        audStepID: { value: 1, cfsqltype: "cf_sql_integer" },
                        eventstatus: { value: mapStatusToEventStatus(len(audData.status) ? audData.status : "scheduled"), cfsqltype: "cf_sql_varchar" },
                        audTypeID: { value: audTypeId, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource: application.datasource, result: "qEventResult" }
                );
                newEventId = qEventResult.generatedKey;

                // E4) Also write to flat auditions table (backward-compat for dupe detection)
                queryExecute(
                    "INSERT INTO auditions (
                        userid, contactid, project_name, role_name, casting_director,
                        agency, audition_date, audition_time, location, medium,
                        status, callback_date, booking_date, self_tape, notes
                    ) VALUES (
                        :userid, :contactid, :project_name, :role_name, :casting_director,
                        :agency, :audition_date, :audition_time, :location, :medium,
                        :status, :callback_date, :booking_date, :self_tape, :notes
                    )",
                    {
                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                        contactid: { value: contactId, cfsqltype: "cf_sql_integer", null: contactId eq 0 },
                        project_name: { value: audData.project_name, cfsqltype: "cf_sql_varchar" },
                        role_name: { value: audData.role_name, cfsqltype: "cf_sql_varchar", null: !len(audData.role_name) },
                        casting_director: { value: audData.casting_director, cfsqltype: "cf_sql_varchar", null: !len(audData.casting_director) },
                        agency: { value: audData.agency, cfsqltype: "cf_sql_varchar", null: !len(audData.agency) },
                        audition_date: { value: audData.audition_date, cfsqltype: "cf_sql_date", null: !len(audData.audition_date) },
                        audition_time: { value: audData.audition_time, cfsqltype: "cf_sql_varchar", null: !len(audData.audition_time) },
                        location: { value: audData.location, cfsqltype: "cf_sql_varchar", null: !len(audData.location) },
                        medium: { value: audData.medium, cfsqltype: "cf_sql_varchar", null: !len(audData.medium) },
                        status: { value: len(audData.status) ? audData.status : "scheduled", cfsqltype: "cf_sql_varchar" },
                        callback_date: { value: audData.callback_date, cfsqltype: "cf_sql_date", null: !len(audData.callback_date) },
                        booking_date: { value: audData.booking_date, cfsqltype: "cf_sql_date", null: !len(audData.booking_date) },
                        self_tape: { value: audData.self_tape eq "1" ? 1 : 0, cfsqltype: "cf_sql_integer" },
                        notes: { value: audData.notes, cfsqltype: "cf_sql_longvarchar", null: !len(audData.notes) }
                    },
                    { datasource: application.datasource }
                );

                fieldsWritten = qFacts.recordCount;

                // E5) Update import_auditions_rows with the event ID as the primary reference
                queryExecute(
                    "UPDATE import_auditions_rows
                     SET status = 'imported', created_audition_id = :event_id,
                         imported_at = NOW(), updated_at = NOW()
                     WHERE row_id = :row_id",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        event_id: { value: newEventId, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource: application.datasource }
                );

                // E6) Record result (idempotency via UNIQUE(row_id))
                queryExecute(
                    "INSERT INTO import_auditions_row_results (
                        row_id, job_id, action_taken, audition_id, fields_written, created_at
                    ) VALUES (
                        :row_id, :job_id, 'created', :audition_id, :fields_written, NOW()
                    )
                    ON DUPLICATE KEY UPDATE
                        action_taken = 'created', audition_id = :audition_id,
                        fields_written = :fields_written",
                    {
                        row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                        job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                        audition_id: { value: newEventId, cfsqltype: "cf_sql_integer" },
                        fields_written: { value: fieldsWritten, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource: application.datasource }
                );
            }

            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "row_imported", row_id = arguments.row_id, detail = { event_id: newEventId, project_id: newProjectId, role_id: newRoleId, contactid: contactId, audSubCatId: audSubCatId, fields_written: fieldsWritten });
            return { "success": true, "action": "created", "audition_id": newEventId };

        } catch (any e) {
            writeLog(file="import_auditions", text="[processRowForImport] ERROR job_id=" & arguments.job_id & " row_id=" & arguments.row_id & " message=" & e.message);
            logEvent(job_id = arguments.job_id, userid = arguments.userid, event_type = "row_import_error", row_id = arguments.row_id, detail = { error: e.message });
            recordRowResult(row_id = arguments.row_id, job_id = arguments.job_id, action_taken = "failed", error_code = "IMPORT_EXCEPTION", error_message = left(e.message, 500));
            try {
                queryExecute(
                    "UPDATE import_auditions_rows SET status = 'failed', import_error = :error, updated_at = NOW() WHERE row_id = :row_id",
                    { row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" }, error: { value: left(e.message, 500), cfsqltype: "cf_sql_varchar" } },
                    { datasource: application.datasource }
                );
            } catch (any updateErr) {}
            return { "success": false, "code": "IMPORT_EXCEPTION", "message": e.message };
        }
    }

    // =============================================================
    // RECORD ROW RESULT (idempotent via UNIQUE(row_id))
    // =============================================================

    private void function recordRowResult(
        required numeric row_id,
        required numeric job_id,
        required string action_taken,
        string error_code = "",
        string error_message = ""
    ) {
        try {
            queryExecute(
                "INSERT INTO import_auditions_row_results (row_id, job_id, action_taken, error_code, error_message, created_at)
                 VALUES (:row_id, :job_id, :action_taken, :error_code, :error_message, NOW())
                 ON DUPLICATE KEY UPDATE action_taken = :action_taken, error_code = :error_code, error_message = :error_message",
                {
                    row_id: { value: arguments.row_id, cfsqltype: "cf_sql_integer" },
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    action_taken: { value: arguments.action_taken, cfsqltype: "cf_sql_varchar" },
                    error_code: { value: arguments.error_code, cfsqltype: "cf_sql_varchar", null: !len(arguments.error_code) },
                    error_message: { value: arguments.error_message, cfsqltype: "cf_sql_varchar", null: !len(arguments.error_message) }
                },
                { datasource: application.datasource }
            );
        } catch (any e) {
            writeLog(file="import_auditions", text="[recordRowResult] ERROR row_id=" & arguments.row_id & " message=" & e.message);
        }
    }

    // =============================================================
    // UPDATE FINAL COUNTS (after finalize)
    // =============================================================

    private void function updateFinalCounts(required numeric job_id, required struct counts) {
        try {
            queryExecute(
                "UPDATE import_auditions_jobs SET
                    imported_rows = :imported_new,
                    skipped_rows = :skipped,
                    updated_at = NOW()
                 WHERE job_id = :job_id",
                {
                    job_id: { value: arguments.job_id, cfsqltype: "cf_sql_integer" },
                    imported_new: { value: arguments.counts.imported_new, cfsqltype: "cf_sql_integer" },
                    skipped: { value: arguments.counts.skipped_already_imported + arguments.counts.skipped_ignored + arguments.counts.skipped_not_ready, cfsqltype: "cf_sql_integer" }
                },
                { datasource: application.datasource }
            );
        } catch (any e) {
            writeLog(file="import_auditions", text="[updateFinalCounts] ERROR job_id=" & arguments.job_id & " message=" & e.message);
        }
    }

    // =============================================================
    // GET USER JOB HISTORY
    // =============================================================

    public query function auditionImports(required numeric userid) {
        return queryExecute(
            "SELECT DISTINCT u.uploadid, u.timestamp
             FROM uploads u
             JOIN auditionsimport ai ON ai.uploadid = u.uploadid
             WHERE u.userid = :userid
             ORDER BY u.timestamp DESC",
            {
                userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" }
            },
            { datasource: application.datasource }
        );
    }

    public query function getUserJobHistory(required numeric userid, numeric limit = 25) {
        return queryExecute(
            "SELECT job_id, source_filename, file_type, status, created_at, finished_at,
                    total_rows, parsed_rows, valid_rows, problem_rows,
                    dupe_rows, skipped_rows, imported_rows, error_message
             FROM import_auditions_jobs
             WHERE userid = :userid
             ORDER BY created_at DESC
             LIMIT :lim",
            {
                userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
                lim: { value: arguments.limit, cfsqltype: "cf_sql_integer" }
            },
            { datasource: application.datasource }
        );
    }

    // =============================================================
    // RESOLVE CATEGORY STRING TO audsubcatid
    // =============================================================
    // Accepts formats: "Film - Feature", "Film-Feature", "Film",
    // "Television", "TV", "Commercial", etc.
    // Returns 0 if no match (category is optional).

    private numeric function resolveCategoryToSubCatId(required string categoryText) {
        var raw = trim(arguments.categoryText);
        if (!len(raw)) return 0;

        // Try exact "Category - SubCategory" match first
        // Normalize separators: " - ", "-", "/"
        var qExact = queryExecute(
            "SELECT s.audsubcatid
             FROM audcategories c
             INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
             WHERE c.isdeleted = 0 AND s.isdeleted = 0
               AND CONCAT(c.audcatname, ' - ', s.audsubcatname) = :raw
             LIMIT 1",
            { raw: { value: raw, cfsqltype: "cf_sql_varchar" } },
            { datasource: application.datasource }
        );
        if (qExact.recordCount) return qExact.audsubcatid;

        // Try with dash separator (no spaces): "Film-Feature"
        var qDash = queryExecute(
            "SELECT s.audsubcatid
             FROM audcategories c
             INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
             WHERE c.isdeleted = 0 AND s.isdeleted = 0
               AND CONCAT(c.audcatname, '-', s.audsubcatname) = :raw
             LIMIT 1",
            { raw: { value: raw, cfsqltype: "cf_sql_varchar" } },
            { datasource: application.datasource }
        );
        if (qDash.recordCount) return qDash.audsubcatid;

        // Try category name only - pick the first subcategory
        var qCatOnly = queryExecute(
            "SELECT s.audsubcatid
             FROM audcategories c
             INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
             WHERE c.isdeleted = 0 AND s.isdeleted = 0
               AND LOWER(c.audcatname) = LOWER(:raw)
             ORDER BY s.audsubcatid
             LIMIT 1",
            { raw: { value: raw, cfsqltype: "cf_sql_varchar" } },
            { datasource: application.datasource }
        );
        if (qCatOnly.recordCount) return qCatOnly.audsubcatid;

        // Try subcategory name only (e.g. "Feature", "Episodic")
        var qSubOnly = queryExecute(
            "SELECT s.audsubcatid
             FROM audcategories c
             INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
             WHERE c.isdeleted = 0 AND s.isdeleted = 0
               AND LOWER(s.audsubcatname) = LOWER(:raw)
             LIMIT 1",
            { raw: { value: raw, cfsqltype: "cf_sql_varchar" } },
            { datasource: application.datasource }
        );
        if (qSubOnly.recordCount) return qSubOnly.audsubcatid;

        // Try LIKE match on category or subcategory
        var qFuzzy = queryExecute(
            "SELECT s.audsubcatid
             FROM audcategories c
             INNER JOIN audsubcategories s ON s.audcatid = c.audcatid
             WHERE c.isdeleted = 0 AND s.isdeleted = 0
               AND (LOWER(c.audcatname) LIKE :pattern
                    OR LOWER(s.audsubcatname) LIKE :pattern)
             ORDER BY s.audsubcatid
             LIMIT 1",
            { pattern: { value: "%" & lcase(raw) & "%", cfsqltype: "cf_sql_varchar" } },
            { datasource: application.datasource }
        );
        if (qFuzzy.recordCount) return qFuzzy.audsubcatid;

        // No match - return 0 (category will be NULL, audition still imports)
        return 0;
    }

}
