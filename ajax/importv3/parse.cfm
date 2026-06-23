<cfsilent>
<!---
    Contact Import V3 - Parse Endpoint
    POST /ajax/importv3/parse.cfm

    Parses an uploaded file for a job and populates:
    - import_v3_columns (headers)
    - import_v3_rows (data rows with raw_json)
    - import_v3_facts (cell values)

    Request:
    - job_id (required): The import job ID

    Response codes:
    - AUTH_REQUIRED: No session userid
    - ACCESS_DENIED: Job does not belong to user
    - NOT_FOUND: Job does not exist
    - LOCKED: Job is locked by another operation
    - INVALID_STATE: Job not in 'uploaded' status
    - UNSUPPORTED_FILE_TYPE: VCF not yet supported
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
    <cflog file="importv3" text="[parse] START userid=#variables.userid#">

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
    <cflog file="importv3" text="[parse] PARAMS userid=#variables.userid# job_id=#variables.jobId#">

    <!--- Initialize V3 service --->
    <cfset addDebug("Initializing V3 service...")>
    <cfset variables.v3Service = new services.ContactImportV3Service()>
    <cfset addDebug("V3 service initialized")>

    <!--- A) Get job with ownership verification --->
    <cfset addDebug("Getting job for user...")>
    <cftry>
        <cfset variables.jobResult = variables.v3Service.getJobForUser(variables.jobId, variables.userid)>
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

    <!--- C) Idempotency check: if job already has parsed data, return existing counts instead of re-parsing --->
    <cfif variables.job.status eq "parsed" or variables.job.status eq "mapping" or variables.job.status eq "reviewing" or variables.job.status eq "finalizing" or variables.job.status eq "completed">
        <!--- Check if data already exists --->
        <cfset variables.qRowCount = queryExecute(
            "SELECT COUNT(*) as cnt FROM import_v3_rows WHERE job_id = :job_id",
            { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <cfif variables.qRowCount.cnt gt 0>
            <!--- Already parsed - return idempotent response --->
            <cfset variables.qCounts = queryExecute(
                "SELECT
                    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = :job_id) as columns_count,
                    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = :job_id) as rows_count,
                    (SELECT COUNT(*) FROM import_v3_facts f
                     INNER JOIN import_v3_rows r ON f.row_id = r.row_id
                     WHERE r.job_id = :job_id) as facts_count",
                { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            )>

            <cfset variables.v3Service.logEvent(
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
            <cflog file="importv3" text="[parse] ALREADY_PARSED userid=#variables.userid# job_id=#variables.jobId# status=#variables.job.status#">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfif>
    </cfif>

    <!--- D) VCF is now supported (parsed below alongside CSV/XLS) --->

    <!--- E) Acquire job lock to prevent concurrent parse operations --->
    <cfset variables.lockResult = variables.v3Service.acquireJobLock(
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
    <cfset variables.v3Service.setJobStatus(variables.jobId, variables.userid, "parsing")>
    <cfset variables.v3Service.logEvent(
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
        <cfset variables.v3Service.setJobStatus(variables.jobId, variables.userid, "failed", "File not found: " & variables.job.source_filename)>
        <cfset variables.v3Service.logEvent(job_id = variables.jobId, userid = variables.userid, event_type = "parse_failed", detail = { error: "File not found" })>
        <cfset variables.response.code = "PARSE_FAILED">
        <cfset variables.response.message = "Uploaded file not found on server: " & variables.filePath>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("File exists!")>
    <cflog file="importv3" text="[parse] FILE_FOUND userid=#variables.userid# job_id=#variables.jobId# file_type=#variables.job.file_type#">

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
            <!--- Parse Excel using cfspreadsheet; fall back to CSV if POI rejects the file --->
            <cfset variables.excelParsed = false>
            <cftry>
                <cfspreadsheet action="read" src="#variables.filePath#" query="spreadsheetData" headerrow="1">
                <cfset variables.excelParsed = true>
                <cfcatch type="any">
                    <cfset addDebug("Excel parse failed (" & cfcatch.message & "), trying CSV fallback...")>
                </cfcatch>
            </cftry>

            <cfif variables.excelParsed>
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
            <cfelse>
                <!--- Fallback: try reading as CSV (file may be CSV saved with .xls/.xlsx extension) --->
                <cfset addDebug("Attempting CSV fallback for " & variables.job.file_type & " file...")>
                <cfset variables.fileContent = fileRead(variables.filePath, "utf-8")>
                <cfset variables.fileContent = replace(variables.fileContent, chr(13) & chr(10), chr(10), "all")>
                <cfset variables.fileContent = replace(variables.fileContent, chr(13), chr(10), "all")>
                <cfset variables.lines = listToArray(variables.fileContent, chr(10))>
                <cfif arrayLen(variables.lines) eq 0>
                    <cfthrow message="File is empty and not a valid Excel workbook">
                </cfif>
                <cfset variables.firstLine = variables.lines[1]>
                <cfset variables.commaCount = len(variables.firstLine) - len(replace(variables.firstLine, ",", "", "all"))>
                <cfset variables.tabCount = len(variables.firstLine) - len(replace(variables.firstLine, chr(9), "", "all"))>
                <cfset variables.delimiter = ",">
                <cfif variables.tabCount gt variables.commaCount>
                    <cfset variables.delimiter = chr(9)>
                </cfif>
                <cfset variables.headerRow = parseCSVLine(variables.firstLine, variables.delimiter)>
                <cfset variables.headers = processHeaders(variables.headerRow)>
                <cfloop from="2" to="#arrayLen(variables.lines)#" index="i">
                    <cfset variables.lineText = trim(variables.lines[i])>
                    <cfif len(variables.lineText) gt 0>
                        <cfset variables.rowData = parseCSVLine(variables.lineText, variables.delimiter)>
                        <cfset arrayAppend(variables.dataRows, variables.rowData)>
                    </cfif>
                </cfloop>
                <cfset addDebug("CSV fallback succeeded: " & arrayLen(variables.headers) & " headers, " & arrayLen(variables.dataRows) & " rows")>
            </cfif>
        <cfelseif variables.job.file_type eq "vcf">
            <cfset addDebug("Parsing VCF file...")>
            <!--- Parse VCF (vCard) file --->
            <cfset variables.fileContent = fileRead(variables.filePath, "utf-8")>
            <cfset addDebug("File read, length=" & len(variables.fileContent))>

            <!--- Normalize line endings: CRLF -> LF, CR -> LF --->
            <cfset variables.fileContent = replace(variables.fileContent, chr(13) & chr(10), chr(10), "all")>
            <cfset variables.fileContent = replace(variables.fileContent, chr(13), chr(10), "all")>

            <!--- Split into raw lines --->
            <cfset variables.rawLines = listToArray(variables.fileContent, chr(10), true)>
            <cfset addDebug("Raw lines: " & arrayLen(variables.rawLines))>

            <!--- Unfold continuation lines (RFC 2425: line starting with space/tab is continuation) --->
            <cfset variables.unfoldedLines = unfoldVCFLines(variables.rawLines)>
            <cfset addDebug("Unfolded lines: " & arrayLen(variables.unfoldedLines))>

            <!--- Split into vCard blocks --->
            <cfset variables.vcardBlocks = []>
            <cfset variables.currentBlock = []>
            <cfset variables.inCard = false>
            <cfloop array="#variables.unfoldedLines#" index="variables.vcfLine">
                <cfset variables.vcfLineTrimmed = trim(variables.vcfLine)>
                <cfif uCase(variables.vcfLineTrimmed) eq "BEGIN:VCARD">
                    <cfset variables.inCard = true>
                    <cfset variables.currentBlock = []>
                <cfelseif uCase(variables.vcfLineTrimmed) eq "END:VCARD" and variables.inCard>
                    <cfset variables.inCard = false>
                    <cfset arrayAppend(variables.vcardBlocks, variables.currentBlock)>
                <cfelseif variables.inCard and len(variables.vcfLineTrimmed) gt 0>
                    <cfset arrayAppend(variables.currentBlock, variables.vcfLineTrimmed)>
                </cfif>
            </cfloop>
            <cfset addDebug("vCard blocks found: " & arrayLen(variables.vcardBlocks))>

            <cfif arrayLen(variables.vcardBlocks) eq 0>
                <cfthrow message="VCF file contains no contacts">
            </cfif>

            <!--- Define fixed VCF virtual columns --->
            <cfset variables.vcfHeaderDefs = [
                { name: "First Name", field: "firstName" },
                { name: "Last Name", field: "lastName" },
                { name: "Full Name", field: "contactFullName" },
                { name: "Business Email", field: "email_business" },
                { name: "Personal Email", field: "email_personal" },
                { name: "Work Phone", field: "phone_work" },
                { name: "Mobile Phone", field: "phone_mobile" },
                { name: "Home Phone", field: "phone_home" },
                { name: "Company", field: "company" },
                { name: "Title", field: "title" },
                { name: "Address Line 1", field: "address1" },
                { name: "City", field: "city" },
                { name: "State", field: "state" },
                { name: "Zip Code", field: "zip" },
                { name: "Country", field: "country" },
                { name: "Birthday", field: "birthday" },
                { name: "Website", field: "website" },
                { name: "Notes", field: "notes" },
                { name: "Tags", field: "tags" }
            ]>

            <!--- Build headers array from definitions --->
            <cfloop array="#variables.vcfHeaderDefs#" index="variables.hDef">
                <cfset arrayAppend(variables.headers, variables.hDef.name)>
            </cfloop>

            <!--- Parse each vCard block into a row --->
            <cfset variables.skippedCards = 0>
            <cfloop array="#variables.vcardBlocks#" index="variables.block">
                <cfset variables.rowData = parseVCardBlock(variables.block, arrayLen(variables.vcfHeaderDefs))>
                <!--- Skip completely empty vCards --->
                <cfset variables.hasData = false>
                <cfloop from="1" to="#arrayLen(variables.rowData)#" index="variables.rdIdx">
                    <cfif len(trim(variables.rowData[variables.rdIdx])) gt 0>
                        <cfset variables.hasData = true>
                        <cfbreak>
                    </cfif>
                </cfloop>
                <cfif variables.hasData>
                    <cfset arrayAppend(variables.dataRows, variables.rowData)>
                <cfelse>
                    <cfset variables.skippedCards++>
                </cfif>
            </cfloop>
            <cfset addDebug("Data rows parsed: " & arrayLen(variables.dataRows) & " (skipped empty: " & variables.skippedCards & ")")>

            <cfif arrayLen(variables.dataRows) eq 0>
                <cfthrow message="VCF file contains no contacts with data">
            </cfif>

        </cfif>

        <cfcatch type="any">
            <cfset addDebug("FILE PARSE ERROR: " & cfcatch.message & " | " & cfcatch.detail)>
            <cfset variables.v3Service.setJobStatus(variables.jobId, variables.userid, "failed", "Parse error: " & cfcatch.message)>
            <cfset variables.v3Service.logEvent(job_id = variables.jobId, userid = variables.userid, event_type = "parse_failed", detail = { error: cfcatch.message })>
            <cfset variables.response.code = "PARSE_FAILED">
            <cfset variables.response.message = "Failed to parse file: " & cfcatch.message>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfcatch>
    </cftry>

    <cfset addDebug("Starting DB inserts - headers=" & arrayLen(variables.headers) & " dataRows=" & arrayLen(variables.dataRows))>
    <!--- H) Insert column definitions into import_v3_columns (INSERT IGNORE for idempotency) --->
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

        <cfset variables.qColResult = {}>
        <cfset queryExecute(
            "INSERT IGNORE INTO import_v3_columns
             (job_id, source_column_index, source_column_name, sample_values, created_at, updated_at)
             VALUES (:job_id, :col_index, :col_name, :sample_values, NOW(), NOW())",
            {
                job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
                col_index: { value: colIdx - 1, cfsqltype: "cf_sql_integer" },
                col_name: { value: variables.headerName, cfsqltype: "cf_sql_varchar", maxlength: 255 },
                sample_values: { value: serializeJSON(variables.sampleVals), cfsqltype: "cf_sql_longvarchar" }
            },
            { datasource: application.datasource, result: "variables.qColResult" }
        )>
        <cfif structKeyExists(variables.qColResult, "recordCount") and variables.qColResult.recordCount gt 0>
            <cfset variables.columnsCreated++>
        </cfif>
    </cfloop>

    <!--- I) Build column index-to-ID lookup map for fact insertion --->
    <cfset variables.qColumns = queryExecute(
        "SELECT column_id, source_column_index FROM import_v3_columns WHERE job_id = :job_id ORDER BY source_column_index",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <!--- Build column index to ID map --->
    <cfset variables.colIdMap = {}>
    <cfloop query="variables.qColumns">
        <cfset variables.colIdMap[variables.qColumns.source_column_index] = variables.qColumns.column_id>
    </cfloop>

    <!--- J) Insert data rows into import_v3_rows (INSERT IGNORE for idempotency) --->
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
            "INSERT IGNORE INTO import_v3_rows
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
        "SELECT row_id, row_num FROM import_v3_rows WHERE job_id = :job_id ORDER BY row_num",
        { job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <!--- Build row_num to ID map --->
    <cfset variables.rowIdMap = {}>
    <cfloop query="variables.qRows">
        <cfset variables.rowIdMap[variables.qRows.row_num] = variables.qRows.row_id>
    </cfloop>

    <!--- L) Insert individual cell facts into import_v3_facts (one per cell per row) --->
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
                        "INSERT IGNORE INTO import_v3_facts
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

    <!--- M-VCF) Auto-map columns for VCF files (columns are deterministic, no manual mapping needed) --->
    <cfset variables.isAutoMapped = false>
    <cfif variables.job.file_type eq "vcf" and isDefined("variables.vcfHeaderDefs")>
        <cfset addDebug("VCF auto-mapping columns...")>
        <cfloop from="1" to="#arrayLen(variables.vcfHeaderDefs)#" index="variables.vcfColIdx">
            <cfset variables.vcfColIndex = variables.vcfColIdx - 1>
            <cfset variables.vcfFieldName = variables.vcfHeaderDefs[variables.vcfColIdx].field>
            <cfif structKeyExists(variables.colIdMap, variables.vcfColIndex)>
                <cfset queryExecute(
                    "UPDATE import_v3_columns
                     SET intent = 'contact_field',
                         target_key = :target_key,
                         user_confirmed = 1,
                         updated_at = NOW()
                     WHERE column_id = :column_id
                       AND job_id = :job_id",
                    {
                        column_id: { value: variables.colIdMap[variables.vcfColIndex], cfsqltype: "cf_sql_integer" },
                        job_id: { value: variables.jobId, cfsqltype: "cf_sql_integer" },
                        target_key: { value: variables.vcfFieldName, cfsqltype: "cf_sql_varchar", maxlength: 100 }
                    },
                    { datasource: application.datasource }
                )>
            </cfif>
        </cfloop>
        <cfset variables.isAutoMapped = true>
        <cfset addDebug("VCF auto-mapping complete - " & arrayLen(variables.vcfHeaderDefs) & " columns mapped")>

        <cfset variables.v3Service.logEvent(
            job_id = variables.jobId,
            userid = variables.userid,
            event_type = "vcf_auto_mapped",
            detail = { columns_mapped: arrayLen(variables.vcfHeaderDefs) }
        )>
    </cfif>

    <!--- N) Update job row counts in import_v3_jobs --->
    <cfset queryExecute(
        "UPDATE import_v3_jobs
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

    <cflog file="importv3" text="[parse] DB_INSERTS_DONE userid=#variables.userid# job_id=#variables.jobId# columns=#variables.columnsCreated# rows=#variables.rowsCreated# facts=#variables.factsCreated#">
    <!--- Set status to parsed --->
    <cfset variables.v3Service.setJobStatus(variables.jobId, variables.userid, "parsed")>

    <!--- Log parse completed --->
    <cfset variables.v3Service.logEvent(
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
            (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = :job_id) as columns_count,
            (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = :job_id) as rows_count,
            (SELECT COUNT(*) FROM import_v3_facts f
             INNER JOIN import_v3_rows r ON f.row_id = r.row_id
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
        "facts_created": variables.qFinalCounts.facts_count,
        "auto_mapped": variables.isAutoMapped
    }>
    <cfset addDebug("SUCCESS - Parse complete!")>
    <cflog file="importv3" text="[parse] SUCCESS userid=#variables.userid# job_id=#variables.jobId# columns=#variables.qFinalCounts.columns_count# rows=#variables.qFinalCounts.rows_count# facts=#variables.qFinalCounts.facts_count#">

    <cfcatch type="any">
        <!--- Log and set failed status --->
        <cfset addDebug("OUTER CATCH ERROR: " & cfcatch.message & " | " & cfcatch.detail & " | Type: " & cfcatch.type)>
        <cflog file="importv3" text="[parse] ERROR userid=#variables.userid# job_id=#variables.jobId# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cftry>
            <cfset variables.v3Service.setJobStatus(variables.jobId, variables.userid, "failed", cfcatch.message)>
            <cfset variables.v3Service.logEvent(job_id = variables.jobId, userid = variables.userid, event_type = "parse_failed", detail = { error: cfcatch.message })>
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
              an escaped quote left inQuotes inverted, so the next comma was treated as a
              column break and quoted notes were truncated mid-text. --->
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

<!--- ==================== VCF HELPER FUNCTIONS ==================== --->

<!--- unfoldVCFLines: Handle RFC 2425 line folding (continuation lines starting with space/tab) --->
<cffunction name="unfoldVCFLines" access="private" returntype="array" output="false">
    <cfargument name="rawLines" type="array" required="true">

    <cfset var result = []>
    <cfset var i = 0>

    <cfloop from="1" to="#arrayLen(arguments.rawLines)#" index="i">
        <cfset var line = arguments.rawLines[i]>
        <!--- Check if line starts with space or tab (continuation of previous line) --->
        <cfif len(line) gt 0 and (left(line, 1) eq " " or left(line, 1) eq chr(9)) and arrayLen(result) gt 0>
            <!--- Append to previous line, stripping the leading whitespace character --->
            <cfset result[arrayLen(result)] = result[arrayLen(result)] & mid(line, 2, len(line) - 1)>
        <cfelse>
            <cfset arrayAppend(result, line)>
        </cfif>
    </cfloop>

    <cfreturn result>
</cffunction>

<!--- unescapeVCF: Handle vCard escaped characters (\n, \,, \\) --->
<cffunction name="unescapeVCF" access="private" returntype="string" output="false">
    <cfargument name="value" type="string" required="true">

    <cfset var result = arguments.value>
    <!--- Order matters: unescape \\ first (to temp placeholder), then \n and \,, then restore \\ --->
    <cfset result = replace(result, "\\", chr(0), "all")>
    <cfset result = replace(result, "\n", chr(10), "all")>
    <cfset result = replace(result, "\N", chr(10), "all")>
    <cfset result = replace(result, "\,", ",", "all")>
    <cfset result = replace(result, chr(0), "\", "all")>

    <cfreturn result>
</cffunction>

<!--- parseVCFPropertyTypes: Extract type= values from property parameters --->
<cffunction name="parseVCFPropertyTypes" access="private" returntype="struct" output="false">
    <cfargument name="params" type="array" required="true">

    <cfset var result = { types: {}, hasPref: false }>

    <cfloop array="#arguments.params#" index="local.param">
        <cfset local.paramUpper = uCase(trim(local.param))>
        <!--- Handle type=VALUE format --->
        <cfif left(local.paramUpper, 5) eq "TYPE=">
            <cfset local.typeVal = mid(local.paramUpper, 6, len(local.paramUpper) - 5)>
            <!--- Handle comma-separated types: type=CELL,VOICE --->
            <cfloop list="#local.typeVal#" index="local.singleType">
                <cfset local.singleType = trim(local.singleType)>
                <cfif local.singleType eq "PREF">
                    <cfset result.hasPref = true>
                <cfelse>
                    <cfset result.types[local.singleType] = true>
                </cfif>
            </cfloop>
        <!--- Handle bare type values (vCard 2.1 style): CELL, WORK, HOME, etc. --->
        <cfelseif local.paramUpper eq "PREF">
            <cfset result.hasPref = true>
        <cfelseif listFindNoCase("CELL,WORK,HOME,VOICE,FAX,IPHONE,MAIN,OTHER,INTERNET", local.paramUpper)>
            <cfset result.types[local.paramUpper] = true>
        </cfif>
    </cfloop>

    <cfreturn result>
</cffunction>

<!--- parseVCardBlock: Parse a single vCard block into an 18-element row array --->
<cffunction name="parseVCardBlock" access="private" returntype="array" output="false">
    <cfargument name="blockLines" type="array" required="true">
    <cfargument name="columnCount" type="numeric" required="true">

    <!--- Initialize empty row with correct number of columns --->
    <cfset var row = []>
    <cfloop from="1" to="#arguments.columnCount#" index="local.ci">
        <cfset arrayAppend(row, "")>
    </cfloop>

    <!--- Temporary collectors for multi-value properties --->
    <cfset var phones = []>
    <cfset var emails = []>
    <cfset var addresses = []>
    <cfset var urls = []>
    <cfset var noteParts = []>

    <!--- Parse each property line --->
    <cfloop array="#arguments.blockLines#" index="local.line">
        <cfset local.workLine = local.line>

        <!--- Strip Apple itemN. grouping prefix (e.g., item1.EMAIL -> EMAIL) --->
        <cfif reFindNoCase("^item\d+\.", local.workLine)>
            <cfset local.workLine = reReplaceNoCase(local.workLine, "^item\d+\.", "")>
        </cfif>

        <!--- Skip X-ABLabel lines (Apple label metadata) --->
        <cfif left(uCase(local.workLine), 10) eq "X-ABLABEL:">
            <cfcontinue>
        </cfif>

        <!--- Split on first colon: left = propName;params, right = value --->
        <cfset local.colonPos = find(":", local.workLine)>
        <cfif local.colonPos eq 0>
            <cfcontinue>
        </cfif>
        <cfset local.propLeft = left(local.workLine, local.colonPos - 1)>
        <cfset local.propValue = mid(local.workLine, local.colonPos + 1, len(local.workLine) - local.colonPos)>

        <!--- Split propLeft on semicolon: first element is property name, rest are params --->
        <cfset local.propParts = listToArray(local.propLeft, ";", true)>
        <cfset local.propName = uCase(trim(local.propParts[1]))>
        <cfset local.propParams = []>
        <cfif arrayLen(local.propParts) gt 1>
            <cfloop from="2" to="#arrayLen(local.propParts)#" index="local.pp">
                <cfset arrayAppend(local.propParams, local.propParts[local.pp])>
            </cfloop>
        </cfif>

        <!--- Parse type parameters --->
        <cfset local.typeInfo = parseVCFPropertyTypes(local.propParams)>

        <!--- Unescape the value --->
        <cfset local.propValue = unescapeVCF(local.propValue)>

        <!--- Route by property name --->
        <cfswitch expression="#local.propName#">

            <!--- N: Name components - N:Last;First;Middle;Prefix;Suffix --->
            <cfcase value="N">
                <cfset local.nameParts = listToArray(local.propValue, ";", true)>
                <!--- lastName = component 0 (family name) --->
                <cfif arrayLen(local.nameParts) gte 1>
                    <cfset row[2] = trim(local.nameParts[1])>
                </cfif>
                <!--- firstName = component 1 (given name), optionally + component 2 (middle) --->
                <cfif arrayLen(local.nameParts) gte 2>
                    <cfset local.givenName = trim(local.nameParts[2])>
                    <cfif arrayLen(local.nameParts) gte 3 and len(trim(local.nameParts[3])) gt 0>
                        <cfset local.givenName = local.givenName & " " & trim(local.nameParts[3])>
                    </cfif>
                    <cfset row[1] = trim(local.givenName)>
                </cfif>
            </cfcase>

            <!--- FN: Formatted name --->
            <cfcase value="FN">
                <cfset row[3] = trim(local.propValue)>
            </cfcase>

            <!--- TEL: Phone number --->
            <cfcase value="TEL">
                <cfif len(trim(local.propValue)) gt 0>
                    <!--- Skip fax-only numbers --->
                    <cfif not (structKeyExists(local.typeInfo.types, "FAX") and structCount(local.typeInfo.types) eq 1)>
                        <cfset arrayAppend(phones, {
                            value: trim(local.propValue),
                            types: local.typeInfo.types,
                            hasPref: local.typeInfo.hasPref
                        })>
                    </cfif>
                </cfif>
            </cfcase>

            <!--- EMAIL: Email address --->
            <cfcase value="EMAIL">
                <cfif len(trim(local.propValue)) gt 0>
                    <cfset arrayAppend(emails, {
                        value: trim(local.propValue),
                        types: local.typeInfo.types,
                        hasPref: local.typeInfo.hasPref
                    })>
                </cfif>
            </cfcase>

            <!--- ORG: Organization/Company --->
            <cfcase value="ORG">
                <!--- ORG value may be "Company;" or "Company;Department" - take first part --->
                <cfset local.orgParts = listToArray(local.propValue, ";", true)>
                <cfif arrayLen(local.orgParts) gte 1 and len(trim(local.orgParts[1])) gt 0>
                    <cfset row[9] = trim(local.orgParts[1])>
                </cfif>
            </cfcase>

            <!--- TITLE: Job title --->
            <cfcase value="TITLE">
                <cfset row[10] = trim(local.propValue)>
            </cfcase>

            <!--- ADR: Address - PO;Extended;Street;City;Region;PostalCode;Country --->
            <cfcase value="ADR">
                <cfset local.adrParts = listToArray(local.propValue, ";", true)>
                <cfset arrayAppend(addresses, {
                    parts: local.adrParts,
                    types: local.typeInfo.types,
                    hasPref: local.typeInfo.hasPref
                })>
            </cfcase>

            <!--- BDAY: Birthday --->
            <cfcase value="BDAY">
                <cfset local.bdayVal = trim(local.propValue)>
                <!--- Handle compact YYYYMMDD format -> YYYY-MM-DD --->
                <cfif reFindNoCase("^\d{8}$", local.bdayVal)>
                    <cfset local.bdayVal = left(local.bdayVal, 4) & "-" & mid(local.bdayVal, 5, 2) & "-" & right(local.bdayVal, 2)>
                </cfif>
                <cfset row[16] = local.bdayVal>
            </cfcase>

            <!--- URL: Website --->
            <cfcase value="URL">
                <cfif len(trim(local.propValue)) gt 0>
                    <cfset arrayAppend(urls, {
                        value: trim(local.propValue),
                        types: local.typeInfo.types,
                        hasPref: local.typeInfo.hasPref
                    })>
                </cfif>
            </cfcase>

            <!--- NOTE: Notes --->
            <cfcase value="NOTE">
                <cfif len(trim(local.propValue)) gt 0>
                    <cfset arrayAppend(noteParts, trim(local.propValue))>
                </cfif>
            </cfcase>

            <!--- CATEGORIES: Tags (column 19) --->
            <cfcase value="CATEGORIES">
                <cfif len(trim(local.propValue)) gt 0>
                    <!--- Append to existing tags if any --->
                    <cfif len(row[19]) gt 0>
                        <cfset row[19] = row[19] & "," & trim(local.propValue)>
                    <cfelse>
                        <cfset row[19] = trim(local.propValue)>
                    </cfif>
                </cfif>
            </cfcase>

        </cfswitch>
    </cfloop>

    <!--- Resolve phones: assign best match for each slot --->
    <!--- Column 6 = phone_work, Column 7 = phone_mobile, Column 8 = phone_home --->
    <cfset var phoneWork = "">
    <cfset var phoneMobile = "">
    <cfset var phoneHome = "">
    <cfset var phoneWorkScore = -1>
    <cfset var phoneMobileScore = -1>
    <cfset var phoneHomeScore = -1>

    <cfloop array="#phones#" index="local.ph">
        <cfset local.score = 0>
        <cfset local.slot = "">

        <!--- Determine best slot for this phone --->
        <cfif structKeyExists(local.ph.types, "CELL") or structKeyExists(local.ph.types, "IPHONE")>
            <cfset local.slot = "mobile">
            <cfset local.score = 10>
        <cfelseif structKeyExists(local.ph.types, "WORK") or structKeyExists(local.ph.types, "MAIN")>
            <cfset local.slot = "work">
            <cfset local.score = 10>
        <cfelseif structKeyExists(local.ph.types, "HOME")>
            <cfset local.slot = "home">
            <cfset local.score = 10>
        </cfif>
        <cfif local.ph.hasPref>
            <cfset local.score = local.score + 5>
        </cfif>

        <!--- Assign to slot if better than current --->
        <cfif local.slot eq "mobile" and local.score gt phoneMobileScore>
            <cfset phoneMobile = local.ph.value>
            <cfset phoneMobileScore = local.score>
        <cfelseif local.slot eq "work" and local.score gt phoneWorkScore>
            <cfset phoneWork = local.ph.value>
            <cfset phoneWorkScore = local.score>
        <cfelseif local.slot eq "home" and local.score gt phoneHomeScore>
            <cfset phoneHome = local.ph.value>
            <cfset phoneHomeScore = local.score>
        <cfelseif local.slot eq "">
            <!--- Generic phone (no matching type) -> assign to first empty slot --->
            <cfif not len(phoneMobile)>
                <cfset phoneMobile = local.ph.value>
                <cfset phoneMobileScore = local.score>
            <cfelseif not len(phoneHome)>
                <cfset phoneHome = local.ph.value>
                <cfset phoneHomeScore = local.score>
            <cfelseif not len(phoneWork)>
                <cfset phoneWork = local.ph.value>
                <cfset phoneWorkScore = local.score>
            </cfif>
        </cfif>
    </cfloop>
    <cfset row[6] = phoneWork>
    <cfset row[7] = phoneMobile>
    <cfset row[8] = phoneHome>

    <!--- Resolve emails: assign best match for each slot --->
    <!--- Column 4 = email_business, Column 5 = email_personal --->
    <cfset var emailBiz = "">
    <cfset var emailPersonal = "">
    <cfloop array="#emails#" index="local.em">
        <cfif structKeyExists(local.em.types, "WORK")>
            <cfif not len(emailBiz)>
                <cfset emailBiz = local.em.value>
            </cfif>
        <cfelse>
            <!--- HOME, INTERNET, or no type -> personal --->
            <cfif not len(emailPersonal)>
                <cfset emailPersonal = local.em.value>
            <cfelseif not len(emailBiz)>
                <!--- Overflow to business slot if personal is full --->
                <cfset emailBiz = local.em.value>
            </cfif>
        </cfif>
    </cfloop>
    <cfset row[4] = emailBiz>
    <cfset row[5] = emailPersonal>

    <!--- Resolve address: pick preferred or first --->
    <cfif arrayLen(addresses) gt 0>
        <cfset var bestAddr = addresses[1]>
        <cfloop array="#addresses#" index="local.addr">
            <cfif local.addr.hasPref>
                <cfset bestAddr = local.addr>
                <cfbreak>
            </cfif>
        </cfloop>
        <cfset var ap = bestAddr.parts>
        <!--- ADR: PO(0);Extended(1);Street(2);City(3);Region(4);PostalCode(5);Country(6) --->
        <cfset var street = "">
        <cfif arrayLen(ap) gte 1 and len(trim(ap[1])) gt 0>
            <cfset street = trim(ap[1])>
        </cfif>
        <cfif arrayLen(ap) gte 3 and len(trim(ap[3])) gt 0>
            <cfif len(street) gt 0>
                <cfset street = street & ", " & trim(ap[3])>
            <cfelse>
                <cfset street = trim(ap[3])>
            </cfif>
        </cfif>
        <!--- Replace newlines in street with comma-space --->
        <cfset street = replace(street, chr(10), ", ", "all")>
        <cfset row[11] = street>
        <!--- City --->
        <cfif arrayLen(ap) gte 4>
            <cfset row[12] = trim(ap[4])>
        </cfif>
        <!--- State/Region --->
        <cfif arrayLen(ap) gte 5>
            <cfset row[13] = trim(ap[5])>
        </cfif>
        <!--- Zip/Postal Code --->
        <cfif arrayLen(ap) gte 6>
            <cfset row[14] = trim(ap[6])>
        </cfif>
        <!--- Country --->
        <cfif arrayLen(ap) gte 7>
            <cfset row[15] = trim(ap[7])>
        </cfif>
    </cfif>

    <!--- Resolve URL: pick preferred or first --->
    <cfif arrayLen(urls) gt 0>
        <cfset var bestUrl = urls[1]>
        <cfloop array="#urls#" index="local.u">
            <cfif local.u.hasPref>
                <cfset bestUrl = local.u>
                <cfbreak>
            </cfif>
        </cfloop>
        <cfset row[17] = bestUrl.value>
    </cfif>

    <!--- Combine notes --->
    <cfif arrayLen(noteParts) gt 0>
        <cfset row[18] = arrayToList(noteParts, chr(10))>
    </cfif>

    <cfreturn row>
</cffunction>
