<cfscript>
cfcontent(type="application/json");

// Feature flag check
if (NOT structKeyExists(application, "features") 
    OR NOT structKeyExists(application.features, "importV3Enabled")
    OR NOT application.features.importV3Enabled) {
    writeOutput(serializeJSON({
        success: false,
        error: "FEATURE_DISABLED",
        message: "Contact Import V3 is not enabled"
    }));
    abort;
}

// Auth check
if (NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid)) {
    writeOutput(serializeJSON({success: false, error: "AUTH_REQUIRED", message: "Authentication required"}));
    abort;
}

try {
    var service = new services.ContactImportV3Service();
    var limit = structKeyExists(url, "limit") AND isNumeric(url.limit) ? val(url.limit) : 25;
    var jobs = service.getUserJobHistory(session.userid, limit);
    
    var jobList = [];
    for (var row in jobs) {
        arrayAppend(jobList, {
            job_id: row.job_id,
            source_filename: row.source_filename,
            status: row.status,
            total_rows: isNull(row.total_rows) ? 0 : row.total_rows,
            valid_rows: isNull(row.valid_rows) ? 0 : row.valid_rows,
            problem_rows: isNull(row.problem_rows) ? 0 : row.problem_rows,
            duplicate_rows: isNull(row.duplicate_rows) ? 0 : row.duplicate_rows,
            skipped_rows: isNull(row.skipped_rows) ? 0 : row.skipped_rows,
            imported_rows: isNull(row.imported_rows) ? 0 : row.imported_rows,
            updated_rows: isNull(row.updated_rows) ? 0 : row.updated_rows,
            created_at: dateTimeFormat(row.created_at, "yyyy-mm-dd HH:nn:ss"),
            finished_at: isDate(row.finished_at) ? dateTimeFormat(row.finished_at, "yyyy-mm-dd HH:nn:ss") : ""
        });
    }
    
    writeOutput(serializeJSON({success: true, jobs: jobList}));
} catch (any e) {
    writeOutput(serializeJSON({success: false, error: "HISTORY_ERROR", message: e.message}));
}
</cfscript>
