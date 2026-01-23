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

<cfset response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {},
    "debug": []
}>

<!--- Debug helper --->
<cffunction name="addDebug" access="public" returntype="void" output="false">
    <cfargument name="msg" type="string" required="true">
    <cfset arrayAppend(response.debug, "[" & timeFormat(now(), "HH:mm:ss") & "] " & arguments.msg)>
</cffunction>

<cftry>
    <cfset addDebug("Parse endpoint called")>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset addDebug("AUTH FAILED - no session.userid")>
        <cfset response.code = "AUTH_REQUIRED">
        <cfset response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset userid = session.userid>
    <cfset addDebug("Auth OK - userid=" & userid)>

    <!--- Validate job_id parameter - check JSON body, form, and URL --->
    <cfset requestBody = {}>
    <cfset rawBodyStr = "">
    <cftry>
        <cfset rawBody = getHttpRequestData().content>
        <cfif isBinary(rawBody)>
            <cfset rawBodyStr = toString(rawBody)>
        <cfelseif isSimpleValue(rawBody)>
            <cfset rawBodyStr = rawBody>
        </cfif>
        <cfset addDebug("Raw body length=" & len(rawBodyStr) & " content=" & left(rawBodyStr, 200))>
        <cfif len(trim(rawBodyStr)) gt 0>
            <cfset requestBody = deserializeJSON(rawBodyStr)>
            <cfset addDebug("Parsed JSON body keys=" & structKeyList(requestBody))>
        </cfif>
        <cfcatch>
            <cfset addDebug("JSON parse error: " & cfcatch.message)>
        </cfcatch>
    </cftry>

    <cfparam name="form.job_id" default="">
    <cfparam name="url.job_id" default="">
    <cfset addDebug("form.job_id=" & form.job_id & " url.job_id=" & url.job_id)>

    <cfset jobId = 0>
    <cfif structKeyExists(requestBody, "job_id")>
        <cfset jobId = val(requestBody.job_id)>
        <cfset addDebug("Got job_id from JSON body: " & jobId)>
    </cfif>
    <cfif jobId eq 0>
        <cfset jobId = val(form.job_id)>
        <cfif jobId gt 0><cfset addDebug("Got job_id from form: " & jobId)></cfif>
    </cfif>
    <cfif jobId eq 0>
        <cfset jobId = val(url.job_id)>
        <cfif jobId gt 0><cfset addDebug("Got job_id from URL: " & jobId)></cfif>
    </cfif>
    <cfif jobId lte 0>
        <cfset addDebug("VALIDATION FAILED - no valid job_id found")>
        <cfset response.code = "VALIDATION_ERROR">
        <cfset response.message = "job_id is required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("Final jobId=" & jobId)>

    <!--- Initialize V3 service --->
    <cfset addDebug("Initializing V3 service...")>
    <cfset v3Service = new services.ContactImportV3Service()>
    <cfset addDebug("V3 service initialized")>

    <!--- A) Get job with ownership verification --->
    <cfset addDebug("Getting job for user...")>
    <cfset jobResult = v3Service.getJobForUser(jobId, userid)>
    <cfset addDebug("getJobForUser result: success=" & jobResult.success)>
    <cfif not jobResult.success>
        <cfset addDebug("Job fetch failed: code=" & jobResult.code & " msg=" & jobResult.message)>
        <cfset response.code = jobResult.code>
        <cfset response.message = jobResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset job = jobResult.data.job>
    <cfset addDebug("Job loaded: status=" & job.status & " file_type=" & job.file_type & " stored_file_path=" & job.stored_file_path)>

    <!--- C) Idempotency check: If already parsed, return current counts --->
    <cfif job.status eq "parsed" or job.status eq "mapping" or job.status eq "reviewing" or job.status eq "finalizing" or job.status eq "completed">
        <!--- Check if data already exists --->
        <cfset qRowCount = queryExecute(
            "SELECT COUNT(*) as cnt FROM import_v3_rows WHERE job_id = :job_id",
            { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
            { datasource: application.datasource }
        )>
        <cfif qRowCount.cnt gt 0>
            <!--- Already parsed - return idempotent response --->
            <cfset qCounts = queryExecute(
                "SELECT
                    (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = :job_id) as columns_count,
                    (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = :job_id) as rows_count,
                    (SELECT COUNT(*) FROM import_v3_facts f
                     INNER JOIN import_v3_rows r ON f.row_id = r.row_id
                     WHERE r.job_id = :job_id) as facts_count",
                { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
                { datasource: application.datasource }
            )>

            <cfset v3Service.logEvent(
                job_id = jobId,
                userid = userid,
                event_type = "parse_already_done",
                detail = { status: job.status, rows: qCounts.rows_count, columns: qCounts.columns_count }
            )>

            <cfset response.success = true>
            <cfset response.code = "ALREADY_PARSED">
            <cfset response.message = "Job has already been parsed">
            <cfset response.data = {
                "job": {
                    "job_id": jobId,
                    "status": job.status,
                    "source_filename": job.source_filename
                },
                "columns_created": qCounts.columns_count,
                "rows_created": qCounts.rows_count,
                "facts_created": qCounts.facts_count
            }>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
        </cfif>
    </cfif>

    <!--- Check VCF not supported yet --->
    <cfif job.file_type eq "vcf">
        <cfset response.code = "UNSUPPORTED_FILE_TYPE">
        <cfset response.message = "VCF (vCard) parsing is not yet supported">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- B) Acquire lock for parse operation --->
    <cfset lockResult = v3Service.acquireJobLock(
        job_id = jobId,
        userid = userid,
        lock_token = createUUID(),
        lock_purpose = "parse"
    )>
    <cfif not lockResult.acquired>
        <cfset response.code = "LOCKED">
        <cfset response.message = lockResult.message>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>

    <!--- Set status to parsing --->
    <cfset v3Service.setJobStatus(jobId, userid, "parsing")>

    <!--- Log parse started --->
    <cfset v3Service.logEvent(
        job_id = jobId,
        userid = userid,
        event_type = "parse_started",
        detail = { file_type: job.file_type, source_filename: job.source_filename }
    )>

    <!--- Read and parse the file based on type --->
    <cfset filePath = job.stored_file_path>
    <cfset addDebug("Checking file path: " & filePath)>
    <cfif not fileExists(filePath)>
        <cfset addDebug("FILE NOT FOUND!")>
        <cfset v3Service.setJobStatus(jobId, userid, "failed", "File not found: " & job.source_filename)>
        <cfset v3Service.logEvent(job_id = jobId, userid = userid, event_type = "parse_failed", detail = { error: "File not found" })>
        <cfset response.code = "PARSE_FAILED">
        <cfset response.message = "Uploaded file not found on server: " & filePath>
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
    </cfif>
    <cfset addDebug("File exists!")>

    <cfset headers = []>
    <cfset dataRows = []>

    <cftry>
        <cfif job.file_type eq "csv">
            <cfset addDebug("Parsing CSV file...")>
            <!--- Parse CSV file --->
            <cfset fileContent = fileRead(filePath, "utf-8")>
            <cfset addDebug("File read, length=" & len(fileContent))>

            <!--- Normalize line endings --->
            <cfset fileContent = replace(fileContent, chr(13) & chr(10), chr(10), "all")>
            <cfset fileContent = replace(fileContent, chr(13), chr(10), "all")>

            <!--- Split into lines --->
            <cfset lines = listToArray(fileContent, chr(10))>
            <cfset addDebug("Lines found: " & arrayLen(lines))>

            <cfif arrayLen(lines) eq 0>
                <cfthrow message="File is empty">
            </cfif>

            <!--- Detect delimiter: check first line for comma vs tab --->
            <cfset firstLine = lines[1]>
            <cfset addDebug("First line: " & left(firstLine, 200))>
            <cfset commaCount = len(firstLine) - len(replace(firstLine, ",", "", "all"))>
            <cfset tabCount = len(firstLine) - len(replace(firstLine, chr(9), "", "all"))>
            <cfset delimiter = ",">
            <cfif tabCount gt commaCount>
                <cfset delimiter = chr(9)>
            </cfif>
            <cfset addDebug("Delimiter: " & (delimiter eq "," ? "comma" : "tab") & " (commas=" & commaCount & " tabs=" & tabCount & ")")>

            <!--- Parse header row --->
            <cfset headerRow = parseCSVLine(firstLine, delimiter)>
            <cfset addDebug("Header row parsed, fields=" & arrayLen(headerRow))>
            <cfset headers = processHeaders(headerRow)>
            <cfset addDebug("Headers: " & arrayToList(headers, ", "))>

            <!--- Parse data rows --->
            <cfloop from="2" to="#arrayLen(lines)#" index="i">
                <cfset lineText = trim(lines[i])>
                <cfif len(lineText) gt 0>
                    <cfset rowData = parseCSVLine(lineText, delimiter)>
                    <cfset arrayAppend(dataRows, rowData)>
                </cfif>
            </cfloop>
            <cfset addDebug("Data rows parsed: " & arrayLen(dataRows))>

        <cfelseif job.file_type eq "xls" or job.file_type eq "xlsx">
            <!--- Parse Excel using cfspreadsheet --->
            <cfspreadsheet action="read" src="#filePath#" query="spreadsheetData" headerrow="1">

            <!--- Get headers from column names --->
            <cfset rawHeaders = listToArray(spreadsheetData.columnList)>
            <cfset headers = processHeaders(rawHeaders)>

            <!--- Get data rows --->
            <cfloop query="spreadsheetData">
                <cfset rowData = []>
                <cfloop list="#spreadsheetData.columnList#" index="colName">
                    <cfset cellValue = spreadsheetData[colName][spreadsheetData.currentRow]>
                    <cfif isNull(cellValue)>
                        <cfset cellValue = "">
                    </cfif>
                    <cfset arrayAppend(rowData, toString(cellValue))>
                </cfloop>
                <cfset arrayAppend(dataRows, rowData)>
            </cfloop>
        </cfif>

        <cfcatch type="any">
            <cfset addDebug("FILE PARSE ERROR: " & cfcatch.message & " | " & cfcatch.detail)>
            <cfset v3Service.setJobStatus(jobId, userid, "failed", "Parse error: " & cfcatch.message)>
            <cfset v3Service.logEvent(job_id = jobId, userid = userid, event_type = "parse_failed", detail = { error: cfcatch.message })>
            <cfset response.code = "PARSE_FAILED">
            <cfset response.message = "Failed to parse file: " & cfcatch.message>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput><cfabort>
        </cfcatch>
    </cftry>

    <cfset addDebug("Starting DB inserts - headers=" & arrayLen(headers) & " dataRows=" & arrayLen(dataRows))>
    <!--- Insert columns with INSERT IGNORE --->
    <cfset columnsCreated = 0>
    <cfloop from="1" to="#arrayLen(headers)#" index="colIdx">
        <cfset headerName = headers[colIdx]>
        <cfset sampleVals = []>
        <!--- Collect up to 3 sample values --->
        <cfloop from="1" to="#min(3, arrayLen(dataRows))#" index="sampleIdx">
            <cfif arrayLen(dataRows[sampleIdx]) gte colIdx>
                <cfset arrayAppend(sampleVals, dataRows[sampleIdx][colIdx])>
            </cfif>
        </cfloop>

        <cfset qColResult = {}>
        <cfset queryExecute(
            "INSERT IGNORE INTO import_v3_columns
             (job_id, source_column_index, source_column_name, sample_values, created_at, updated_at)
             VALUES (:job_id, :col_index, :col_name, :sample_values, NOW(), NOW())",
            {
                job_id: { value: jobId, cfsqltype: "cf_sql_integer" },
                col_index: { value: colIdx - 1, cfsqltype: "cf_sql_integer" },
                col_name: { value: headerName, cfsqltype: "cf_sql_varchar", maxlength: 255 },
                sample_values: { value: serializeJSON(sampleVals), cfsqltype: "cf_sql_longvarchar" }
            },
            { datasource: application.datasource, result: "qColResult" }
        )>
        <cfif structKeyExists(qColResult, "recordCount") and qColResult.recordCount gt 0>
            <cfset columnsCreated++>
        </cfif>
    </cfloop>

    <!--- Get column IDs for fact insertion --->
    <cfset qColumns = queryExecute(
        "SELECT column_id, source_column_index FROM import_v3_columns WHERE job_id = :job_id ORDER BY source_column_index",
        { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <!--- Build column index to ID map --->
    <cfset colIdMap = {}>
    <cfloop query="qColumns">
        <cfset colIdMap[qColumns.source_column_index] = qColumns.column_id>
    </cfloop>

    <!--- Insert rows with INSERT IGNORE --->
    <cfset rowsCreated = 0>
    <cfloop from="1" to="#arrayLen(dataRows)#" index="rowIdx">
        <cfset rowData = dataRows[rowIdx]>
        <!--- Build raw_json as object with column indices as keys --->
        <cfset rawJson = {}>
        <cfloop from="1" to="#arrayLen(rowData)#" index="cellIdx">
            <cfset rawJson[cellIdx - 1] = rowData[cellIdx]>
        </cfloop>

        <cfset qRowResult = {}>
        <cfset queryExecute(
            "INSERT IGNORE INTO import_v3_rows
             (job_id, row_num, raw_json, status, created_at, updated_at)
             VALUES (:job_id, :row_num, :raw_json, 'pending', NOW(), NOW())",
            {
                job_id: { value: jobId, cfsqltype: "cf_sql_integer" },
                row_num: { value: rowIdx, cfsqltype: "cf_sql_integer" },
                raw_json: { value: serializeJSON(rawJson), cfsqltype: "cf_sql_longvarchar" }
            },
            { datasource: application.datasource, result: "qRowResult" }
        )>
        <cfif structKeyExists(qRowResult, "recordCount") and qRowResult.recordCount gt 0>
            <cfset rowsCreated++>
        </cfif>
    </cfloop>

    <!--- Get row IDs for fact insertion --->
    <cfset qRows = queryExecute(
        "SELECT row_id, row_num FROM import_v3_rows WHERE job_id = :job_id ORDER BY row_num",
        { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <!--- Build row_num to ID map --->
    <cfset rowIdMap = {}>
    <cfloop query="qRows">
        <cfset rowIdMap[qRows.row_num] = qRows.row_id>
    </cfloop>

    <!--- Insert facts for each cell --->
    <cfset factsCreated = 0>
    <cfloop from="1" to="#arrayLen(dataRows)#" index="rowIdx">
        <cfset rowData = dataRows[rowIdx]>
        <cfif structKeyExists(rowIdMap, rowIdx)>
            <cfset currentRowId = rowIdMap[rowIdx]>

            <cfloop from="1" to="#arrayLen(headers)#" index="colIdx">
                <cfset colIndex = colIdx - 1>
                <cfif structKeyExists(colIdMap, colIndex)>
                    <cfset currentColId = colIdMap[colIndex]>
                    <cfset cellValue = "">
                    <cfif arrayLen(rowData) gte colIdx>
                        <cfset cellValue = rowData[colIdx]>
                    </cfif>

                    <!--- field_name is placeholder until mapping phase --->
                    <cfset fieldName = "unmapped_" & colIndex>

                    <cfset qFactResult = {}>
                    <cfset queryExecute(
                        "INSERT IGNORE INTO import_v3_facts
                         (row_id, column_id, field_name, raw_value, created_at, updated_at)
                         VALUES (:row_id, :column_id, :field_name, :raw_value, NOW(), NOW())",
                        {
                            row_id: { value: currentRowId, cfsqltype: "cf_sql_integer" },
                            column_id: { value: currentColId, cfsqltype: "cf_sql_integer" },
                            field_name: { value: fieldName, cfsqltype: "cf_sql_varchar", maxlength: 50 },
                            raw_value: { value: cellValue, cfsqltype: "cf_sql_longvarchar", null: (len(trim(cellValue)) eq 0) }
                        },
                        { datasource: application.datasource, result: "qFactResult" }
                    )>
                    <cfif structKeyExists(qFactResult, "recordCount") and qFactResult.recordCount gt 0>
                        <cfset factsCreated++>
                    </cfif>
                </cfif>
            </cfloop>
        </cfif>
    </cfloop>

    <!--- Update job counts --->
    <cfset queryExecute(
        "UPDATE import_v3_jobs
         SET total_rows = :total_rows,
             parsed_rows = :parsed_rows,
             updated_at = NOW()
         WHERE job_id = :job_id AND userid = :userid",
        {
            job_id: { value: jobId, cfsqltype: "cf_sql_integer" },
            userid: { value: userid, cfsqltype: "cf_sql_integer" },
            total_rows: { value: arrayLen(dataRows), cfsqltype: "cf_sql_integer" },
            parsed_rows: { value: arrayLen(dataRows), cfsqltype: "cf_sql_integer" }
        },
        { datasource: application.datasource }
    )>

    <!--- Set status to parsed --->
    <cfset v3Service.setJobStatus(jobId, userid, "parsed")>

    <!--- Log parse completed --->
    <cfset v3Service.logEvent(
        job_id = jobId,
        userid = userid,
        event_type = "parse_completed",
        detail = {
            columns_created: columnsCreated,
            rows_created: rowsCreated,
            facts_created: factsCreated,
            total_rows: arrayLen(dataRows)
        }
    )>

    <!--- Get final counts from DB --->
    <cfset qFinalCounts = queryExecute(
        "SELECT
            (SELECT COUNT(*) FROM import_v3_columns WHERE job_id = :job_id) as columns_count,
            (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = :job_id) as rows_count,
            (SELECT COUNT(*) FROM import_v3_facts f
             INNER JOIN import_v3_rows r ON f.row_id = r.row_id
             WHERE r.job_id = :job_id) as facts_count",
        { job_id: { value: jobId, cfsqltype: "cf_sql_integer" } },
        { datasource: application.datasource }
    )>

    <cfset addDebug("Final counts - columns=" & qFinalCounts.columns_count & " rows=" & qFinalCounts.rows_count & " facts=" & qFinalCounts.facts_count)>

    <!--- Success response --->
    <cfset response.success = true>
    <cfset response.code = "">
    <cfset response.message = "File parsed successfully">
    <cfset response.data = {
        "job": {
            "job_id": jobId,
            "status": "parsed",
            "source_filename": job.source_filename,
            "total_rows": arrayLen(dataRows)
        },
        "columns_created": qFinalCounts.columns_count,
        "rows_created": qFinalCounts.rows_count,
        "facts_created": qFinalCounts.facts_count
    }>
    <cfset addDebug("SUCCESS - Parse complete!")>

    <cfcatch type="any">
        <!--- Log and set failed status --->
        <cfset addDebug("OUTER CATCH ERROR: " & cfcatch.message & " | " & cfcatch.detail & " | Type: " & cfcatch.type)>
        <cftry>
            <cfset v3Service.setJobStatus(jobId, userid, "failed", cfcatch.message)>
            <cfset v3Service.logEvent(job_id = jobId, userid = userid, event_type = "parse_failed", detail = { error: cfcatch.message })>
            <cfcatch type="any">
                <cfset addDebug("Logging error: " & cfcatch.message)>
            </cfcatch>
        </cftry>
        <cfset response.code = "PARSE_FAILED">
        <cfset response.message = "Parse failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>

<!--- Helper function to parse a CSV line handling quoted values --->
<cffunction name="parseCSVLine" access="private" returntype="array" output="false">
    <cfargument name="line" type="string" required="true">
    <cfargument name="delimiter" type="string" required="true">

    <cfset var result = []>
    <cfset var inQuotes = false>
    <cfset var currentField = "">
    <cfset var chars = arguments.line.toCharArray()>
    <cfset var i = 1>
    <cfset var charLen = arrayLen(chars)>

    <cfloop from="1" to="#charLen#" index="i">
        <cfset var c = chars[i]>

        <cfif c eq '"'>
            <!--- Check for escaped quote --->
            <cfif inQuotes and i lt charLen and chars[i+1] eq '"'>
                <cfset currentField &= '"'>
                <cfset i++>
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

<!--- Helper function to process headers (handle blanks and duplicates) --->
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
