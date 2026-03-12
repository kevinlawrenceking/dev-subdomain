/**
 * ImportAuditionsLogger.cfc
 *
 * Per-request structured logger for the Audition Import pipeline.
 * Generates a correlation ID on init, writes structured lines to cflog
 * file "import_auditions_debug", and maintains an in-memory debug trail array.
 *
 * Direct port of ImportV3Logger.cfc with audition-domain log file.
 *
 * Usage:
 *   var logger = new services.ImportAuditionsLogger(endpoint="recompute");
 *   logger.setUserId(session.userid);
 *   logger.setJobId(jobId);
 *   logger.info("load_columns", "Loaded 18 columns", { count: 18 });
 *
 * @author TAO Development
 * @created 2026-03-09
 */
component displayname="ImportAuditionsLogger" accessors="false" output="false" {

    variables.correlationId = "";
    variables.endpoint = "";
    variables.jobId = 0;
    variables.userId = 0;
    variables.startTick = 0;
    variables.debugTrail = [];
    variables.LOG_FILE = "import_auditions_debug";

    public ImportAuditionsLogger function init(required string endpoint) {
        variables.endpoint = arguments.endpoint;
        variables.startTick = getTickCount();
        variables.correlationId = generateCorrelationId();
        variables.debugTrail = [];
        return this;
    }

    // --- Context setters ---

    public void function setUserId(required numeric userId) {
        variables.userId = arguments.userId;
    }

    public void function setJobId(required numeric jobId) {
        variables.jobId = arguments.jobId;
    }

    // --- Convenience log-level methods ---

    public void function debug(required string stage, required string message, struct detail = {}) {
        logEntry("DEBUG", arguments.stage, arguments.message, arguments.detail);
    }

    public void function info(required string stage, required string message, struct detail = {}) {
        logEntry("INFO", arguments.stage, arguments.message, arguments.detail);
    }

    public void function warn(required string stage, required string message, struct detail = {}) {
        logEntry("WARN", arguments.stage, arguments.message, arguments.detail);
    }

    public void function error(required string stage, required string message, struct detail = {}) {
        logEntry("ERROR", arguments.stage, arguments.message, arguments.detail);
    }

    public void function fatal(required string stage, required string message, struct detail = {}) {
        logEntry("FATAL", arguments.stage, arguments.message, arguments.detail);
    }

    // --- Core structured log writer ---

    private void function logEntry(
        required string level,
        required string stage,
        required string message,
        struct detail = {}
    ) {
        var elapsed = getTickCount() - variables.startTick;
        var detailStr = "";
        if (!structIsEmpty(arguments.detail)) {
            try {
                detailStr = serializeJSON(arguments.detail);
            } catch (any e) {
                detailStr = "{serialization_error}";
            }
        }

        var line = "cid=#variables.correlationId#"
            & " job=#variables.jobId#"
            & " uid=#variables.userId#"
            & " ep=#variables.endpoint#"
            & " stage=#arguments.stage#"
            & " [#arguments.level#] #arguments.message#";

        if (len(detailStr)) {
            line &= " detail=#detailStr#";
        }
        line &= " elapsed_ms=#elapsed#";

        try {
            writeLog(text=line, file=variables.LOG_FILE, type="information");
        } catch (any e) {
            // Never let logging failure propagate
        }

        arrayAppend(variables.debugTrail, {
            "ts": elapsed,
            "level": arguments.level,
            "stage": arguments.stage,
            "msg": arguments.message
        });
    }

    // --- Error extraction ---

    /**
     * Safely extracts diagnostic fields from a cfcatch exception struct.
     */
    public struct function extractErrorDetail(required any exception) {
        var info = {
            "message": "",
            "detail": "",
            "type": "",
            "sql": "",
            "tagcontext": []
        };

        try {
            if (structKeyExists(arguments.exception, "message")) {
                info.message = left(arguments.exception.message, 500);
            }
            if (structKeyExists(arguments.exception, "detail")) {
                info.detail = left(arguments.exception.detail, 500);
            }
            if (structKeyExists(arguments.exception, "type")) {
                info.type = arguments.exception.type;
            }
            if (structKeyExists(arguments.exception, "queryError")) {
                info.sql = left(arguments.exception.queryError, 500);
            }
            if (structKeyExists(arguments.exception, "sql")) {
                info.sql = left(arguments.exception.sql, 500);
            }
            if (structKeyExists(arguments.exception, "tagcontext") && isArray(arguments.exception.tagcontext)) {
                var maxEntries = min(arrayLen(arguments.exception.tagcontext), 5);
                for (var i = 1; i <= maxEntries; i++) {
                    var entry = arguments.exception.tagcontext[i];
                    var tplName = "";
                    if (structKeyExists(entry, "template") && len(entry.template)) {
                        var tplPath = entry.template;
                        var slashPos = max(tplPath.lastIndexOf("/"), tplPath.lastIndexOf(chr(92)));
                        tplName = (slashPos gte 0) ? mid(tplPath, slashPos + 2, len(tplPath)) : tplPath;
                    }
                    arrayAppend(info.tagcontext, {
                        "template": tplName,
                        "line": structKeyExists(entry, "line") ? entry.line : 0
                    });
                }
            }
        } catch (any e) {
            info.message = "Error extracting exception detail: " & e.message;
        }

        return info;
    }

    /**
     * Builds a client-safe JSON error response with correlation ID and debug trail.
     */
    public struct function buildErrorResponse(
        required string code,
        required any exception,
        string clientMessage = ""
    ) {
        var errInfo = extractErrorDetail(arguments.exception);

        fatal("error_response", errInfo.message, errInfo);

        var safeMsg = len(arguments.clientMessage)
            ? arguments.clientMessage
            : "An internal error occurred. Reference: " & variables.correlationId;

        return {
            "success": false,
            "code": arguments.code,
            "message": safeMsg,
            "correlation_id": variables.correlationId,
            "debug": variables.debugTrail,
            "elapsed_ms": getTickCount() - variables.startTick,
            "error_type": errInfo.type,
            "tagcontext": errInfo.tagcontext
        };
    }

    // --- Accessors ---

    public string function getCorrelationId() {
        return variables.correlationId;
    }

    public array function getDebugTrail() {
        return variables.debugTrail;
    }

    public numeric function getElapsedMs() {
        return getTickCount() - variables.startTick;
    }

    // --- Internal helpers ---

    private string function generateCorrelationId() {
        var raw = createUUID();
        return uCase(left(replace(raw, "-", "", "ALL"), 8));
    }

}
