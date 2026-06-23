<cfsilent>
<!---
    Audition Import - Parse Endpoint
    POST /ajax/import-auditions/parse.cfm

    Parses an uploaded file for a job and populates:
    - import_auditions_columns (headers)
    - import_auditions_rows (data rows with raw_json)
    - import_auditions_facts (cell values)

    Request:
    - job_id (required): The import job ID

    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job does not exist
    - LOCKED: Job is locked by another operation
    - INVALID_STATE: Job not in 'uploaded' status
    - UNSUPPORTED_FILE_TYPE: File type not supported (CSV, XLS, XLSX only)
    - PARSE_FAILED: File parsing error
    - ALREADY_PARSED: Job already has parsed data (idempotent return)
--->

<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {},
    "debug": []
}>

<!--- Debug helper --->
<cffunction name="addDebug" access="public" returntype="void" output="false">
    <cfargument name="msg" type="string" required="true">
    <cfset arrayAppend(variables.response.debug, "[" & timeFormat(now(), "HH:mm:ss") & "] " & arguments.msg)>
</cffunction>

<cftry>
    <cfset addDebug("Parse endpoint called")>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset addDebug("AUTH FAILED - no session.userid")>
        <cfset variables.response.code = "AUTH_REQUIRED">
        <cfset variables.response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfset addDebug("Auth OK - userid=" & variables.userid)>
    <cflog file="import_auditions" text="[parse] START userid=#variables.userid#">

    <!--- CSRF validation — check form, headers, and JSON body --->
    <cfset variables.csrfToken = "">
    <cfif structKeyExists(form, "csrf_token") and len(trim(form.csrf_token))>
        <cfset variables.csrfToken = trim(form.csrf_token)>
    </cfif>
    <cfif not len(variables.csrfToken)>
        <cftry>
            <cfset variables.reqHeaders = getHTTPRequestData().headers>
            <cfif structKeyExists(variables.reqHeaders, "X-CSRF-Token") and len(trim(variables.reqHeaders["X-CSRF-Token"]))>
                <cfset variables.csrfToken = trim(variables.reqHeaders["X-CSRF-Token"])>
            </cfif>
        <cfcatch type="any"><!--- ignore header read errors ---></cfcatch>
        </cftry>
    </cfif>
    <cfif not len(variables.csrfToken) and structKeyExists(cgi, "HTTP_X_CSRF_TOKEN") and len(trim(cgi.HTTP_X_CSRF_TOKEN))>
        <cfset variables.csrfToken = trim(cgi.HTTP_X_CSRF_TOKEN)>
    </cfif>
    <cfif not len(variables.csrfToken)>
        <cftry>
            <cfset variables.csrfRawBody = getHTTPRequestData().content>
            <cfif isBinary(variables.csrfRawBody)><cfset variables.csrfRawBody = toString(variables.csrfRawBody)></cfif>
            <cfif isJSON(variables.csrfRawBody)>
                <cfset variables.csrfBodyJson = deserializeJSON(variables.csrfRawBody)>
                <cfif isStruct(variables.csrfBodyJson) and structKeyExists(variables.csrfBodyJson, "csrf_token") and len(trim(variables.csrfBodyJson.csrf_token))>
                    <cfset variables.csrfToken = trim(variables.csrfBodyJson.csrf_token)>
                </cfif>
            </cfif>
        <cfcatch type="any"><!--- ignore body parse errors ---></cfcatch>
        </cftry>
    </cfif>
    <cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>
    <cfif not len(variables.csrfToken) or variables.csrfToken neq session.csrf_token>
        <cfset addDebug("FAIL: csrf_invalid token_received=" & left(variables.csrfToken, 8) & "... session=" & left(session.csrf_token, 8) & "...")>
        <cfset variables.response.code = "CSRF_INVALID">
        <cfset variables.response.message = "Invalid or missing CSRF token">
        <cfheader statuscode="403">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("csrf_ok")>

    <!--- Validate job_id parameter - check JSON body, form, and URL --->
    <cfset variables.requestBody = {}>
    <cfset variables.rawBodyStr = "">
    <cftry>
        <cfset variables.rawBody = getHttpRequestData().content>
        <cfif isBinary(variables.rawBody)>
            <cfset variables.rawBodyStr = toString(variables.rawBody)>
        <cfelseif isSimpleValue(variables.rawBody)>
            <cfset variables.rawBodyStr = variables.rawBody>
        </cfif>
        <cfset addDebug("Raw body length=" & len(variables.rawBodyStr) & " content=" & left(variables.rawBodyStr, 200))>
        <cfif len(trim(variables.rawBodyStr)) gt 0>
            <cfset variables.requestBody = deserializeJSON(variables.rawBodyStr)>
            <cfset addDebug("Parsed JSON body keys=" & structKeyList(variables.requestBody))>
        </cfif>
        <cfcatch>
            <cfset addDebug("JSON parse error: " & cfcatch.message)>
        </cfcatch>
    </cftry>

    <cfparam name="form.job_id" default="">
    <cfparam name="url.job_id" default="">
    <cfset addDebug("form.job_id=" & form.job_id & " url.job_id=" & url.job_id)>

    <cfset variables.jobId = 0>
    <cfif structKeyExists(variables.requestBody, "job_id")>
        <cfset variables.jobId = val(variables.requestBody.job_id)>
        <cfset addDebug("Got job_id from JSON body: " & variables.jobId)>
    </cfif>
    <cfif variables.jobId eq 0>
        <cfset variables.jobId = val(form.job_id)>
        <cfif variables.jobId gt 0><cfset addDebug("Got job_id from form: " & variables.jobId)></cfif>
    </cfif>
    <cfif variables.jobId eq 0>
        <cfset variables.jobId = val(url.job_id)>
        <cfif variables.jobId gt 0><cfset addDebug("Got job_id from URL: " & variables.jobId)></cfif>
    </cfif>
    <cfif variables.jobId lte 0>
        <cfset addDebug("VALIDATION FAILED - no valid job_id found")>
        <cfset variables.response.code = "VALIDATION_ERROR">
        <cfset variables.response.message = "job_id is required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("Final jobId=" & variables.jobId)>
    <cflog file="import_auditions" text="[parse] PARAMS userid=#variables.userid# job_id=#variables.jobId#">

    <!--- Initialize Audition Import service --->
    <cfset addDebug("Initializing AuditionImportService...")>
    <cfset variables.importService = new services.AuditionImportService()>
    <cfset addDebug("AuditionImportService initialized")>

    <!--- A) Get job with ownership verification --->
    <cfset addDebug("Getting job for user...")>
    <cftry>
        <cfset variables.jobResult = variables.importService.getJobForUser(variables.jobId, variables.userid)>
        <cfset addDebug("getJobForUser result: success=" & variables.jobResult.success)>
        <cfcatch type="any">
            <cfset addDebug("getJobForUser EXCEPTION: " & cfcatch.message & " | " & cfcatch.detail)>
            <cfset variables.response.code = "SERVICE_ERROR">
            <cfset variables.response.message = "Service error: " & cfcatch.message & " | Detail: " & cfcatch.detail>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfcatch>
    </cftry>
    <cfif not variables.jobResult.success>
        <cfset addDebug("Job fetch failed: code=" & variables.jobResult.code & " msg=" & variables.jobResult.message)>
        <cfif structKeyExists(variables.jobResult, "data") and structKeyExists(variables.jobResult.data, "error_detail")>
            <cfset addDebug("Error detail: " & variables.jobResult.data.error_detail)>
        </cfif>
        <cfset variables.response.code = variables.jobResult.code>
        <cfset variables.response.message = variables.jobResult.message>
        <cfset variables.response.data = variables.jobResult.data>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.job = variables.jobResult.data.job>
    <cfset addDebug("Job loaded: status=" & variables.job.status & " file_type=" & variables.job.file_type & " stored_file_path=" & variables.job.stored_file_path)>

    <!--- C) Reject unsupported file types (no VCF for auditions) --->
    <cfif variables.job.file_type neq "csv" and variables.job.file_type neq "xls" and variables.job.file_type neq "xlsx">
        <cfset addDebug("UNSUPPORTED FILE TYPE: " & variables.job.file_type)>
        <cfset variables.response.code = "UNSUPPORTED_FILE_TYPE">
        <cfset variables.response.message = "Audition import supports CSV, XLS, and XLSX files only. Got: " & variables.job.file_type>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- D) Idempotency check: if job already has parsed data, return existing counts instead of re-parsing --->
    <cfif variables.job.status eq "parsed" or variables.job.status eq "mapping" or variables.job.status eq "reviewing" or variables.job.status eq "finalizing" or variables.job.status eq "completed">
        <!--- Check if data already exists --->
        <cfset variables.qRowCount = queryExecute(
            "SELECT COUNT(*) as cnt FROM import_auditions_rows WHERE job_id = :job_id",
            { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <cfif variables.qRowCount.cnt gt 0>
            <!--- Already parsed - return idempotent response --->
            <cfset variables.qCounts = queryExecute(
                "SELECT
                    (SELECT COUNT(*) FROM import_auditions_columns WHERE job_id = :job_id) as columns_count,
                    (SELECT COUNT(*) FROM import_auditions_rows WHERE job_id = :job_id) as rows_count,
                    (SELECT COUNT(*) FROM import_auditions_facts f
                     INNER JOIN import_auditions_rows r ON f.row_id = r.row_id
                     WHERE r.job_id = :job_id) as facts_count",
                { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            )>

            <cfset variables.importService.logEvent(
                job_id = variables.jobId,
                userid = variables.userid,
                event_type = "parse_already_done",
                detail = { status: variables.job.status, rows: variables.qCounts.rows_count, columns: variables.qCounts.columns_count }
            )>

            <cfset variables.response.success = true>
            <cfset variables.response.code = "ALREADY_PARSED">
            <cfset variables.response.message = "Job has already been parsed">
            <cfset variables.response.data = {
                "job": {
                    "job_id": variables.jobId,
                    "status": variables.job.status,
                    "source_filename": variables.job.source_filename
                },
                "columns_created": variables.qCounts.columns_count,
                "rows_created": variables.qCounts.rows_count,
                "facts_created": variables.qCounts.facts_count
            }>
            <cflog file="import_auditions" text="[parse] ALREADY_PARSED userid=#variables.userid# job_id=#variables.jobId# status=#variables.job.status#">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>
    </cfif>

    <!--- E) Acquire job lock to prevent concurrent parse operations --->
    <cfset variables.lockResult = variables.importService.acquireJobLock(
        job_id = variables.jobId,
        userid = variables.userid,
        lock_token = createUUID(),
        lock_purpose = "parse"
    )>
    <cfif not variables.lockResult.acquired>
        <cfset variables.response.code = "LOCKED">
        <cfset variables.response.message = variables.lockResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- F) Transition job status to "parsing" and log the event --->
    <cfset variables.importService.setJobStatus(variables.jobId, variables.userid, "parsing")>
    <cfset variables.importService.logEvent(
        job_id = variables.jobId,
        userid = variables.userid,
        event_type = "parse_started",
        detail = { file_type: variables.job.file_type, source_filename: variables.job.source_filename }
    )>

    <!--- G) Read and parse the uploaded file based on type (CSV or XLS/XLSX) --->
    <cfset variables.filePath = variables.job.stored_file_path>
    <cfset addDebug("Checking file path: " & variables.filePath)>
    <cfif not fileExists(variables.filePath)>
        <cfset addDebug("FILE NOT FOUND!")>
        <cfset variables.importService.setJobStatus(variables.jobId, variables.userid, "failed", "File not found: " & variables.job.source_filename)>
        <cfset variables.importService.logEvent(job_id = variables.jobId, userid = variables.userid, event_type = "parse_failed", detail = { error: "File not found" })>
        <cfset variables.response.code = "PARSE_FAILED">
        <cfset variables.response.message = "Uploaded file not found on server: " & variables.filePath>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("File exists!")>
    <cflog file="import_auditions" text="[parse] FILE_FOUND userid=#variables.userid# job_id=#variables.jobId# file_type=#variables.job.file_type#">

    <cfset variables.headers = []>
    <cfset variables.dataRows = []>

    <cftry>
        <cfif variables.job.file_type eq "csv">
            <cfset addDebug("Parsing CSV file...")>
            <!--- Parse CSV file --->
            <cfset variables.fileContent = fileRead(variables.filePath, "utf-8")>
            <cfset addDebug("File read, length=" & len(variables.fileContent))>

            <!--- Normalize line endings --->
            <cfset variables.fileContent = replace(variables.fileContent, chr(13) & chr(10), chr(10), "all")>
            <cfset variables.fileContent = replace(variables.fileContent, chr(13), chr(10), "all")>

            <!--- Split into lines --->
            <cfset variables.lines = listToArray(variables.fileContent, chr(10))>
            <cfset addDebug("Lines found: " & arrayLen(variables.lines))>

            <cfif arrayLen(variables.lines) eq 0>
                <cfthrow message="File is empty">
            </cfif>

            <!--- Detect delimiter: check first line for comma vs tab --->
            <cfset variables.firstLine = variables.lines[1]>
            <cfset addDebug("First line: " & left(variables.firstLine, 200))>
            <cfset variables.commaCount = len(variables.firstLine) - len(replace(variables.firstLine, ",", "", "all"))>
            <cfset variables.tabCount = len(variables.firstLine) - len(replace(variables.firstLine, chr(9), "", "all"))>
            <cfset variables.delimiter = ",">
            <cfif variables.tabCount gt variables.commaCount>
                <cfset variables.delimiter = chr(9)>
            </cfif>
            <cfset addDebug("Delimiter: " & (variables.delimiter eq "," ? "comma" : "tab") & " (commas=" & variables.commaCount & " tabs=" & variables.tabCount & ")")>

            <!--- Parse header row --->
            <cfset variables.headerRow = parseCSVLine(variables.firstLine, variables.delimiter)>
            <cfset addDebug("Header row parsed, fields=" & arrayLen(variables.headerRow))>
            <cfset variables.headers = processHeaders(variables.headerRow)>
            <cfset addDebug("Headers: " & arrayToList(variables.headers, ", "))>

            <!--- Parse data rows --->
            <cfloop from="2" to="#arrayLen(variables.lines)#" index="i">
                <cfset variables.lineText = trim(variables.lines[i])>
                <cfif len(variables.lineText) gt 0>
                    <cfset variables.rowData = parseCSVLine(variables.lineText, variables.delimiter)>
                    <cfset arrayAppend(variables.dataRows, variables.rowData)>
                </cfif>
            </cfloop>
            <cfset addDebug("Data rows parsed: " & arrayLen(variables.dataRows))>

        <cfelseif variables.job.file_type eq "xls" or variables.job.file_type eq "xlsx">
            <!--- Parse Excel using cfspreadsheet --->
            <cfspreadsheet action="read" src="#variables.filePath#" query="spreadsheetData" headerrow="1">

            <!--- Get headers from column names --->
            <cfset variables.rawHeaders = listToArray(variables.spreadsheetData.columnList)>
            <cfset variables.headers = processHeaders(variables.rawHeaders)>

            <!--- Get data rows --->
            <cfloop query="variables.spreadsheetData">
                <cfset variables.rowData = []>
                <cfloop list="#variables.spreadsheetData.columnList#" index="colName">
                    <cfset variables.cellValue = variables.spreadsheetData[variables.colName][variables.spreadsheetData.currentRow]>
                    <cfif isNull(variables.cellValue)>
                        <cfset variables.cellValue = "">
                    </cfif>
                    <cfset arrayAppend(variables.rowData, toString(variables.cellValue))>
                </cfloop>
                <cfset arrayAppend(variables.dataRows, variables.rowData)>
            </cfloop>
        </cfif>

        <cfcatch type="any">
            <cfset addDebug("FILE PARSE ERROR: " & cfcatch.message & " | " & cfcatch.detail)>
            <cfset variables.importService.setJobStatus(variables.jobId, variables.userid, "failed", "Parse error: " & cfcatch.message)>
            <cfset variables.importService.logEvent(job_id = variables.jobId, userid = variables.userid, event_type = "parse_failed", detail = { error: cfcatch.message })>
            <cfset variables.response.code = "PARSE_FAILED">
            <cfset variables.response.message = "Failed to parse file: " & cfcatch.message>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfcatch>
    </cftry>

    <cfset addDebug("Starting DB inserts - headers=" & arrayLen(variables.headers) & " dataRows=" & arrayLen(variables.dataRows))>
    <!--- H) Insert column definitions into import_auditions_columns (INSERT IGNORE for idempotency) --->
    <cfset variables.columnsCreated = 0>
    <cfloop from="1" to="#arrayLen(variables.headers)#" index="colIdx">
        <cfset variables.headerName = variables.headers[colIdx]>
        <cfset variables.sampleVals = []>
        <!--- Collect up to 3 sample values --->
        <cfloop from="1" to="#min(3, arrayLen(variables.dataRows))#" index="sampleIdx">
            <cfif arrayLen(variables.dataRows[sampleIdx]) gte colIdx>
                <cfset arrayAppend(variables.sampleVals, variables.dataRows[sampleIdx][colIdx])>
            </cfif>
        </cfloop>

        <!--- Auto-map this column header to an audition field --->
        <cfset variables.autoMap = autoMapAuditionColumn(variables.headerName)>

        <cfset variables.qColResult = {}>
        <cfset queryExecute(
            "INSERT IGNORE INTO import_auditions_columns
             (job_id, source_column_index, source_column_name, sample_values, intent, target_key, confidence, user_confirmed)
             VALUES (:job_id, :col_index, :col_name, :sample_values, :intent, :target_key, :confidence, 0)",
            {
                job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
                col_index: { value: colIdx - 1, cfsqltype: "cf_sql_integer" },
                col_name: { value: variables.headerName, cfsqltype: "cf_sql_varchar", maxlength: 255 },
                sample_values: { value: serializeJSON(variables.sampleVals), cfsqltype: "cf_sql_longvarchar" },
                intent: { value: variables.autoMap.intent, cfsqltype: "cf_sql_varchar", maxlength: 50 },
                target_key: { value: variables.autoMap.field_name, cfsqltype: "cf_sql_varchar", maxlength: 100 },
                confidence: { value: variables.autoMap.confidence, cfsqltype: "cf_sql_decimal", scale: 2 }
            },
            { datasource: application.datasource, result: "variables.qColResult" }
        )>
        <cfif structKeyExists(variables.qColResult, "recordCount") and variables.qColResult.recordCount gt 0>
            <cfset variables.columnsCreated++>
        </cfif>
    <cfset addDebug("Column " & colIdx & " header=" & variables.headerName & " -> " & variables.autoMap.intent & ":" & variables.autoMap.field_name & " (conf=" & variables.autoMap.confidence & ")")>
    </cfloop>

    <!--- I) Build column index-to-ID lookup map for fact insertion --->
    <cfset variables.qColumns = queryExecute(
        "SELECT column_id, source_column_index FROM import_auditions_columns WHERE job_id = :job_id ORDER BY source_column_index",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <!--- Build column index to ID map --->
    <cfset variables.colIdMap = {}>
    <cfloop query="variables.qColumns">
        <cfset variables.colIdMap[variables.qColumns.source_column_index] = variables.qColumns.column_id>
    </cfloop>

    <!--- J) Insert data rows into import_auditions_rows (INSERT IGNORE for idempotency) --->
    <cfset variables.rowsCreated = 0>
    <cfloop from="1" to="#arrayLen(variables.dataRows)#" index="rowIdx">
        <cfset variables.rowData = variables.dataRows[rowIdx]>
        <!--- Build raw_json as object with column indices as keys --->
        <cfset variables.rawJson = {}>
        <cfloop from="1" to="#arrayLen(variables.rowData)#" index="cellIdx">
            <cfset variables.rawJson[cellIdx - 1] = variables.rowData[cellIdx]>
        </cfloop>

        <cfset variables.qRowResult = {}>
        <cfset queryExecute(
            "INSERT IGNORE INTO import_auditions_rows
             (job_id, row_num, raw_json, status, created_at, updated_at)
             VALUES (:job_id, :row_num, :raw_json, 'pending', NOW(), NOW())",
            {
                job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
                row_num: { value: rowIdx, cfsqltype: "cf_sql_integer" },
                raw_json: { value: serializeJSON(variables.rawJson), cfsqltype: "cf_sql_longvarchar" }
            },
            { datasource: application.datasource, result: "variables.qRowResult" }
        )>
        <cfif structKeyExists(variables.qRowResult, "recordCount") and variables.qRowResult.recordCount gt 0>
            <cfset variables.rowsCreated++>
        </cfif>
    </cfloop>

    <!--- K) Build row_num-to-ID lookup map for fact insertion --->
    <cfset variables.qRows = queryExecute(
        "SELECT row_id, row_num FROM import_auditions_rows WHERE job_id = :job_id ORDER BY row_num",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <!--- Build row_num to ID map --->
    <cfset variables.rowIdMap = {}>
    <cfloop query="variables.qRows">
        <cfset variables.rowIdMap[variables.qRows.row_num] = variables.qRows.row_id>
    </cfloop>

    <!--- L) Insert individual cell facts into import_auditions_facts (one per cell per row) --->
    <cfset variables.factsCreated = 0>
    <cfloop from="1" to="#arrayLen(variables.dataRows)#" index="rowIdx">
        <cfset variables.rowData = variables.dataRows[rowIdx]>
        <cfif structKeyExists(variables.rowIdMap, rowIdx)>
            <cfset variables.currentRowId = variables.rowIdMap[rowIdx]>

            <cfloop from="1" to="#arrayLen(variables.headers)#" index="colIdx">
                <cfset variables.colIndex = colIdx - 1>
                <cfif structKeyExists(variables.colIdMap, variables.colIndex)>
                    <cfset variables.currentColId = variables.colIdMap[variables.colIndex]>
                    <cfset variables.cellValue = "">
                    <cfif arrayLen(variables.rowData) gte colIdx>
                        <cfset variables.cellValue = variables.rowData[colIdx]>
                    </cfif>

                    <!--- field_name is placeholder until mapping phase --->
                    <cfset variables.fieldName = "unmapped_" & variables.colIndex>

                    <cfset variables.qFactResult = {}>
                    <cfset queryExecute(
                        "INSERT IGNORE INTO import_auditions_facts
                         (row_id, column_id, field_name, raw_value, created_at, updated_at)
                         VALUES (:row_id, :column_id, :field_name, :raw_value, NOW(), NOW())",
                        {
                            row_id: { value: variables.currentRowId, cfsqltype: "cf_sql_integer" },
                            column_id: { value: variables.currentColId, cfsqltype: "cf_sql_integer" },
                            field_name: { value: variables.fieldName, cfsqltype: "cf_sql_varchar", maxlength: 50 },
                            raw_value: { value: variables.cellValue, cfsqltype: "cf_sql_longvarchar", null: (len(trim(variables.cellValue)) eq 0) }
                        },
                        { datasource: application.datasource, result: "variables.qFactResult" }
                    )>
                    <cfif structKeyExists(variables.qFactResult, "recordCount") and variables.qFactResult.recordCount gt 0>
                        <cfset variables.factsCreated++>
                    </cfif>
                </cfif>
            </cfloop>
        </cfif>
    </cfloop>

    <!--- N) Update job row counts in import_auditions_jobs --->
    <cfset queryExecute(
        "UPDATE import_auditions_jobs
         SET total_rows = :total_rows,
             parsed_rows = :parsed_rows,
             updated_at = NOW()
         WHERE job_id = :job_id AND userid = :userid",
        {
            job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
            userid: { value: variables.userid, cfsqltype: "cf_sql_integer" },
            total_rows: { value: arrayLen(variables.dataRows), cfsqltype: "cf_sql_integer" },
            parsed_rows: { value: arrayLen(variables.dataRows), cfsqltype: "cf_sql_integer" }
        },
        { datasource: application.datasource }
    )>

    <cflog file="import_auditions" text="[parse] DB_INSERTS_DONE userid=#variables.userid# job_id=#variables.jobId# columns=#variables.columnsCreated# rows=#variables.rowsCreated# facts=#variables.factsCreated#">
    <!--- Set status to parsed --->
    <cfset variables.importService.setJobStatus(variables.jobId, variables.userid, "parsed")>

    <!--- Log parse completed --->
    <cfset variables.importService.logEvent(
        job_id = variables.jobId,
        userid = variables.userid,
        event_type = "parse_completed",
        detail = {
            columns_created: variables.columnsCreated,
            rows_created: variables.rowsCreated,
            facts_created: variables.factsCreated,
            total_rows: arrayLen(variables.dataRows)
        }
    )>

    <!--- N) Get verified counts from DB for the response (not in-memory counters) --->
    <cfset variables.qFinalCounts = queryExecute(
        "SELECT
            (SELECT COUNT(*) FROM import_auditions_columns WHERE job_id = :job_id) as columns_count,
            (SELECT COUNT(*) FROM import_auditions_rows WHERE job_id = :job_id) as rows_count,
            (SELECT COUNT(*) FROM import_auditions_facts f
             INNER JOIN import_auditions_rows r ON f.row_id = r.row_id
             WHERE r.job_id = :job_id) as facts_count",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <cfset addDebug("Final counts - columns=" & variables.qFinalCounts.columns_count & " rows=" & variables.qFinalCounts.rows_count & " facts=" & variables.qFinalCounts.facts_count)>

    <!--- Success response --->
    <cfset variables.response.success = true>
    <cfset variables.response.code = "">
    <cfset variables.response.message = "File parsed successfully">
    <cfset variables.response.data = {
        "job": {
            "job_id": variables.jobId,
            "status": "parsed",
            "source_filename": variables.job.source_filename,
            "total_rows": arrayLen(variables.dataRows)
        },
        "columns_created": variables.qFinalCounts.columns_count,
        "rows_created": variables.qFinalCounts.rows_count,
        "facts_created": variables.qFinalCounts.facts_count
    }>
    <cfset addDebug("SUCCESS - Parse complete!")>
    <cflog file="import_auditions" text="[parse] SUCCESS userid=#variables.userid# job_id=#variables.jobId# columns=#variables.qFinalCounts.columns_count# rows=#variables.qFinalCounts.rows_count# facts=#variables.qFinalCounts.facts_count#">

    <cfcatch type="any">
        <!--- Log and set failed status --->
        <cfset addDebug("OUTER CATCH ERROR: " & cfcatch.message & " | " & cfcatch.detail & " | Type: " & cfcatch.type)>
        <cflog file="import_auditions" text="[parse] ERROR userid=#variables.userid# job_id=#variables.jobId# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cftry>
            <cfset variables.importService.setJobStatus(variables.jobId, variables.userid, "failed", cfcatch.message)>
            <cfset variables.importService.logEvent(job_id = variables.jobId, userid = variables.userid, event_type = "parse_failed", detail = { error: cfcatch.message })>
            <cfcatch type="any">
                <cfset addDebug("Logging error: " & cfcatch.message)>
            </cfcatch>
        </cftry>
        <cfset variables.response.code = "PARSE_FAILED">
        <cfset variables.response.message = "Parse failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>

<!--- ==================== HELPER FUNCTIONS ==================== --->

<!--- parseCSVLine: Parse a single CSV line handling quoted values and escaped quotes --->
<cffunction name="parseCSVLine" access="private" returntype="array" output="false">
    <cfargument name="line" type="string" required="true">
    <cfargument name="delimiter" type="string" required="true">

    <cfset var result = []>
    <cfset var inQuotes = false>
    <cfset var currentField = "">
    <cfset var chars = arguments.line.toCharArray()>
    <cfset var i = 1>
    <cfset var charLen = arrayLen(chars)>
    <cfset var skipNext = false>

    <cfloop from="1" to="#charLen#" index="i">
        <!--- Skip the second quote of an escaped "" pair. A <cfloop from/to> ignores
              reassigning its index var, so we cannot advance i directly (the old
              "<cfset i++>" was a no-op). A flag does the skip correctly. Without this,
              an escaped quote left inQuotes inverted, shifting every later column and
              truncating quoted notes mid-text. --->
        <cfif skipNext>
            <cfset skipNext = false>
            <cfcontinue>
        </cfif>

        <cfset var c = chars[i]>

        <cfif c eq '"'>
            <!--- Escaped quote ("") inside a quoted field -> one literal " --->
            <cfif inQuotes and i lt charLen and chars[i+1] eq '"'>
                <cfset currentField &= '"'>
                <cfset skipNext = true>
            <cfelse>
                <cfset inQuotes = not inQuotes>
            </cfif>
        <cfelseif c eq arguments.delimiter and not inQuotes>
            <cfset arrayAppend(result, trim(currentField))>
            <cfset currentField = "">
        <cfelse>
            <cfset currentField &= c>
        </cfif>
    </cfloop>

    <!--- Add last field --->
    <cfset arrayAppend(result, trim(currentField))>

    <cfreturn result>
</cffunction>

<!--- processHeaders: Normalize header names, assign names for blank headers, deduplicate --->
<cffunction name="processHeaders" access="private" returntype="array" output="false">
    <cfargument name="rawHeaders" type="array" required="true">

    <cfset var result = []>
    <cfset var usedNames = {}>

    <cfloop from="1" to="#arrayLen(arguments.rawHeaders)#" index="i">
        <cfset var header = trim(arguments.rawHeaders[i])>

        <!--- Handle blank headers --->
        <cfif len(header) eq 0>
            <cfset header = "Column " & i>
        </cfif>

        <!--- Handle duplicate headers --->
        <cfset var baseName = header>
        <cfset var suffix = 1>
        <cfloop condition="structKeyExists(usedNames, lcase(header))">
            <cfset suffix++>
            <cfset header = baseName & " (" & suffix & ")">
        </cfloop>

        <cfset usedNames[lcase(header)] = true>
        <cfset arrayAppend(result, header)>
    </cfloop>

    <cfreturn result>
</cffunction>

<!--- ==================== AUDITION COLUMN AUTO-MAPPING ==================== --->

<!---
    autoMapAuditionColumn: Map a source column header to an audition field.
    Confidence: exact=1.00, partial=0.75, none=0.00
    Intent values: ignore, audition_field, note
--->
<cffunction name="autoMapAuditionColumn" access="private" returntype="struct" output="false">
    <cfargument name="headerName" type="string" required="true">

    <cfset var result = { field_name: "", intent: "ignore", confidence: 0.00 }>
    <cfset var h = lCase(trim(arguments.headerName))>

    <!--- If header is empty, return ignore --->
    <cfif len(h) eq 0>
        <cfreturn result>
    </cfif>

    <!--- Mapping rules. Order matters: specific compound-name fields (project_name,
         role_name, casting_director) BEFORE contact_name so the "name" keyword
         doesn't steal headers like "role_name" or "project_name".
         Also: callback/booking before date. --->
    <cfset var rules = []>

    <!--- contact_email (no "name" keyword, safe to be early) --->
    <cfset arrayAppend(rules, { keywords: ["email"], field: "contact_email" })>
    <!--- project_name (before contact_name: "name" is substring of "project_name") --->
    <cfset arrayAppend(rules, { keywords: ["project", "show", "film", "title"], field: "project_name" })>
    <!--- role_name (before contact_name: "name" is substring of "role_name") --->
    <cfset arrayAppend(rules, { keywords: ["role", "character", "part"], field: "role_name" })>
    <!--- casting_director (before contact_name: "name" could appear in "casting_director_name") --->
    <cfset arrayAppend(rules, { keywords: ["casting", "cd", "director"], field: "casting_director" })>
    <!--- contact_name (AFTER project/role/casting so their compound names match first) --->
    <cfset arrayAppend(rules, { keywords: ["actor", "talent", "contact", "name", "performer"], field: "contact_name" })>
    <!--- agency --->
    <cfset arrayAppend(rules, { keywords: ["agency", "office"], field: "agency" })>
    <!--- callback_date (before audition_date) --->
    <cfset arrayAppend(rules, { keywords: ["callback"], field: "callback_date" })>
    <!--- booking_date (before audition_date) --->
    <cfset arrayAppend(rules, { keywords: ["booked", "booking"], field: "booking_date" })>
    <!--- audition_date (excludes callback/booking) --->
    <cfset arrayAppend(rules, { keywords: ["date"], field: "audition_date", excludeKeywords: ["callback", "booking", "booked"] })>
    <!--- audition_time --->
    <cfset arrayAppend(rules, { keywords: ["time"], field: "audition_time" })>
    <!--- location --->
    <cfset arrayAppend(rules, { keywords: ["location", "address", "room", "studio"], field: "location" })>
    <!--- medium (do NOT include "category" here: a column literally named "Category"
         must fall through to the category rule below, which resolves to audsubcatid
         and is what the Review grid displays). --->
    <cfset arrayAppend(rules, { keywords: ["medium", "type", "format"], field: "medium" })>
    <!--- status --->
    <cfset arrayAppend(rules, { keywords: ["status", "result", "outcome"], field: "status" })>
    <!--- self_tape --->
    <cfset arrayAppend(rules, { keywords: ["self tape", "self-tape", "self.tape", "selftape", "remote"], field: "self_tape" })>
    <!--- category (Category - SubCategory combo) --->
    <cfset arrayAppend(rules, { keywords: ["category", "subcategory", "sub-category", "genre"], field: "category" })>
    <!--- notes --->
    <cfset arrayAppend(rules, { keywords: ["note", "comment", "memo"], field: "notes" })>

    <!--- Iterate rules in order (first match wins) --->
    <cfloop array="#rules#" index="local.rule">
        <!--- Check for exclusion keywords first --->
        <cfset var excluded = false>
        <cfif structKeyExists(local.rule, "excludeKeywords")>
            <cfloop array="#local.rule.excludeKeywords#" index="local.exKw">
                <cfif findNoCase(local.exKw, h) gt 0>
                    <cfset excluded = true>
                    <cfbreak>
                </cfif>
            </cfloop>
        </cfif>
        <cfif excluded>
            <cfcontinue>
        </cfif>

        <!--- Check keywords for exact or partial match --->
        <cfloop array="#local.rule.keywords#" index="local.kw">
            <cfif h eq local.kw>
                <!--- Exact match --->
                <cfset result.field_name = local.rule.field>
                <cfset result.intent = "audition_field">
                <cfset result.confidence = 1.00>
                <cfreturn result>
            <cfelseif findNoCase(local.kw, h) gt 0>
                <!--- Partial/contains match --->
                <cfset result.field_name = local.rule.field>
                <cfset result.intent = "audition_field">
                <cfset result.confidence = 0.75>
                <cfreturn result>
            </cfif>
        </cfloop>
    </cfloop>

    <!--- No match found - return ignore with 0.00 confidence --->
    <cfreturn result>
</cffunction>
