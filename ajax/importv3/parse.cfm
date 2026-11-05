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
            <!--- Parse Excel with cfspreadsheet. The CSV fallback below is ONLY for a text file saved
                  with an Excel extension: reading a real workbook's bytes (zip = .xlsx, OLE2 = .xls) as
                  CSV text produced junk columns and rows and reported success. A real workbook that
                  cfspreadsheet cannot read now FAILS the job with a message telling the user to save
                  as CSV (TAO.Import.ExcelUnreadable, handled by the parse catch below).
                  2026-10-13 prod (error_tickets 565-569, CF 2021,0,21): POI threw
                  java.lang.NoSuchMethodError at ZipArchiveInputStream.getNextEntry() - the
                  commons-compress on the server classpath is older than the POI that cfspreadsheet
                  ships. That is a java.lang.Error, and it escaped every cfcatch type="any" in this
                  file (the ticket stack lines match these line numbers). So: (1) for .xlsx, probe
                  the linkage by reflection before calling cfspreadsheet and fail cleanly when it is
                  incompatible; (2) also catch java.lang.LinkageError by class around the read. --->
            <cfset variables.excelParsed = false>
            <cfset variables.excelFailure = "">
            <cfset variables.fileSignature = importFileSignature(variables.filePath)>
            <cfset addDebug("File signature: " & variables.fileSignature)>
            <cfset variables.zipReader = { "status": "n/a", "detail": "" }>
            <cfif variables.fileSignature eq "zip">
                <cfset variables.zipReader = excelZipReaderStatus()>
                <cfset addDebug("Excel zip reader: " & variables.zipReader.status & " " & variables.zipReader.detail)>
            </cfif>
            <cfif variables.zipReader.status eq "incompatible">
                <cfset variables.excelFailure = "POI/commons-compress incompatible: " & variables.zipReader.detail>
            <cfelse>
                <cftry>
                    <cfspreadsheet action="read" src="#variables.filePath#" query="spreadsheetData" headerrow="1">
                    <cfset variables.excelParsed = true>
                    <cfcatch type="java.lang.LinkageError">
                        <cfset variables.excelFailure = "LinkageError: " & cfcatch.message>
                    </cfcatch>
                    <cfcatch type="any">
                        <cfset variables.excelFailure = cfcatch.message>
                    </cfcatch>
                </cftry>
            </cfif>

            <!--- 2026-10-29: a real .xlsx that cfspreadsheet could not read (incompatible jars or a read
                  error) goes through the POI-free reader before giving up. --->
            <cfset variables.nativeParsed = false>
            <cfif NOT variables.excelParsed AND variables.fileSignature eq "zip">
                <cftry>
                    <cfset variables.nativeSheet = readXlsxNative(variables.filePath)>
                    <cfset variables.headers = processHeaders(variables.nativeSheet.headers)>
                    <cfset variables.dataRows = variables.nativeSheet.rows>
                    <cfset variables.nativeParsed = true>
                    <cfset addDebug("Native xlsx reader: " & arrayLen(variables.headers) & " headers, " & arrayLen(variables.dataRows) & " rows (cfspreadsheet: " & variables.excelFailure & ")")>
                    <cflog file="importv3" type="information"
                           text="[parse] XLSX_NATIVE userid=#variables.userid# job_id=#variables.jobId# rows=#arrayLen(variables.dataRows)# cause=#left(variables.excelFailure, 300)#">
                    <cfcatch type="any">
                        <cfset variables.headers = []>
                        <cfset variables.dataRows = []>
                        <cfset variables.excelFailure = variables.excelFailure & "; native reader: " & cfcatch.message>
                    </cfcatch>
                </cftry>
            </cfif>

            <cfif NOT variables.excelParsed AND NOT variables.nativeParsed AND variables.fileSignature neq "text">
                <cflog file="importv3" type="error"
                       text="[parse] EXCEL_UNREADABLE userid=#variables.userid# job_id=#variables.jobId# signature=#variables.fileSignature# err=#left(variables.excelFailure, 500)#">
                <cfthrow type="TAO.Import.ExcelUnreadable"
                         message="We couldn't read this Excel file right now. Please save it as CSV (.csv) and upload it again."
                         detail="signature=#variables.fileSignature#; #variables.excelFailure#">
            </cfif>
            <cfif NOT variables.excelParsed AND NOT variables.nativeParsed>
                <cfset addDebug("Excel read failed on a text file (" & variables.excelFailure & "), trying CSV fallback...")>
            </cfif>

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
            <cfelseif NOT variables.nativeParsed>
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

        <cfcatch type="TAO.Import.ExcelUnreadable">
            <!--- A real workbook cfspreadsheet could not read. The job fails (never reported as parsed);
                  the user gets the save-as-CSV instruction verbatim; the root cause goes to
                  error_tickets as a handled ticket (no email per occurrence) so admins still see it. --->
            <cfset addDebug("EXCEL UNREADABLE: " & cfcatch.detail)>
            <cfset variables.v3Service.setJobStatus(variables.jobId, variables.userid, "failed", "Excel unreadable: " & left(cfcatch.detail, 400))>
            <cfset variables.v3Service.logEvent(job_id = variables.jobId, userid = variables.userid, event_type = "parse_failed", detail = { error: "excel_unreadable", cause: left(cfcatch.detail, 400) })>
            <cftry>
                <cfif structKeyExists(application, "services") AND structKeyExists(application.services, "errorService")>
                    <cfset application.services.errorService.captureHandled(cfcatch, "importv3-parse-excel")>
                </cfif>
                <cfcatch type="any"></cfcatch>
            </cftry>
            <cfset variables.response.code = "PARSE_FAILED">
            <cfset variables.response.message = cfcatch.message>
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
        </cfcatch>
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

<!--- Identify a file by its leading bytes: "zip" (50 4B 03 04 - .xlsx), "ole" (D0 CF 11 E0 - legacy
      .xls), "empty", or "text" (anything else, e.g. a CSV saved with an Excel extension). Reads at
      most 8 bytes. An unreadable file reports "unknown", which is treated like a workbook (no CSV
      fallback). --->
<cffunction name="importFileSignature" access="public" returntype="string" output="false">
    <cfargument name="path" type="string" required="true">
    <cfset var fh = "">
    <cfset var head = "">
    <cfset var hex = "">
    <cftry>
        <cfset fh = fileOpen(arguments.path, "readBinary")>
        <cftry>
            <cfif fileIsEOF(fh)>
                <cfreturn "empty">
            </cfif>
            <cfset head = fileRead(fh, 8)>
            <cffinally>
                <cfset fileClose(fh)>
            </cffinally>
        </cftry>
        <cfcatch type="any">
            <cfreturn "unknown">
        </cfcatch>
    </cftry>
    <cfset hex = uCase(binaryEncode(head, "hex"))>
    <cfif left(hex, 8) eq "504B0304">
        <cfreturn "zip">
    </cfif>
    <cfif left(hex, 8) eq "D0CF11E0">
        <cfreturn "ole">
    </cfif>
    <cfreturn "text">
</cffunction>

<!--- Check, without reading any workbook, whether the commons-compress class that POI's zip reader
      links against has the getNextEntry() signature POI was compiled for (returning ZipArchiveEntry).
      The class is resolved through POI's own classloader so the answer matches what cfspreadsheet
      would hit. Returns status "compatible" | "incompatible" | "unknown" (reflection unavailable -
      the caller then tries cfspreadsheet as before) and a detail naming the jar locations. --->
<cffunction name="excelZipReaderStatus" access="public" returntype="struct" output="false">
    <cfset var result = { "status": "unknown", "detail": "" }>
    <cfset var poiCls = "">
    <cfset var zisCls = "">
    <cfset var m = "">
    <cfset var where = "">
    <cftry>
        <cfset poiCls = createObject("java", "java.lang.Class").forName("org.apache.poi.openxml4j.util.ZipArchiveThresholdInputStream")>
        <cfset zisCls = poiCls.getClassLoader().loadClass("org.apache.commons.compress.archivers.zip.ZipArchiveInputStream")>
        <cftry>
            <cfset where = "poi=" & poiCls.getProtectionDomain().getCodeSource().getLocation().toString()
                         & " compress=" & zisCls.getProtectionDomain().getCodeSource().getLocation().toString()>
            <cfcatch type="any"><cfset where = "jar locations unavailable"></cfcatch>
        </cftry>
        <cfset result.status = "incompatible">
        <cfloop array="#zisCls.getMethods()#" index="m">
            <cfif m.getName() eq "getNextEntry" AND arrayLen(m.getParameterTypes()) eq 0
                  AND m.getReturnType().getName() eq "org.apache.commons.compress.archivers.zip.ZipArchiveEntry">
                <cfset result.status = "compatible">
                <cfbreak>
            </cfif>
        </cfloop>
        <cfset result.detail = where>
        <cfcatch type="any">
            <cfset result = { "status": "unknown", "detail": left(cfcatch.message, 200) }>
        </cfcatch>
    </cftry>
    <cfreturn result>
</cffunction>

<!--- 2026-10-29: POI-free .xlsx reader. Used only when cfspreadsheet cannot read a real workbook
      (zip signature): the probe reports POI/commons-compress incompatible, or the read throws.
      Uses the JDK's java.util.zip (never commons-compress) plus xmlParse, reads the FIRST sheet,
      first non-empty row = headers. Shared strings, inline strings, booleans and date-styled
      numbers (built-in date formats and custom d/m/y formats -> yyyy-mm-dd) are handled.
      Formulas yield their cached value. Any problem throws; the caller then fails the job with
      the save-as-CSV message, as before. Returns { headers: [], rows: [[]] }. --->
<cffunction name="xlsxLocalName" access="private" returntype="string" output="false">
    <cfargument name="node" required="true">
    <cfreturn listLast(arguments.node.xmlName, ":")>
</cffunction>

<cffunction name="xlsxChildren" access="private" returntype="array" output="false">
    <cfargument name="node" required="true">
    <cfargument name="name" type="string" required="true">
    <cfset var out = []>
    <cfset var c = "">
    <cfloop array="#arguments.node.xmlChildren#" index="c">
        <cfif xlsxLocalName(c) eq arguments.name>
            <cfset arrayAppend(out, c)>
        </cfif>
    </cfloop>
    <cfreturn out>
</cffunction>

<!--- Concatenated text of every <t> under node, skipping phonetic runs (<rPh>). --->
<cffunction name="xlsxText" access="private" returntype="string" output="false">
    <cfargument name="node" required="true">
    <cfset var out = "">
    <cfset var c = "">
    <cfset var nm = "">
    <cfloop array="#arguments.node.xmlChildren#" index="c">
        <cfset nm = xlsxLocalName(c)>
        <cfif nm eq "t">
            <cfset out &= c.xmlText>
        <cfelseif nm neq "rPh">
            <cfset out &= xlsxText(c)>
        </cfif>
    </cfloop>
    <cfreturn out>
</cffunction>

<cffunction name="xlsxEntryXml" access="private" returntype="any" output="false">
    <cfargument name="zip" required="true">
    <cfargument name="name" type="string" required="true">
    <cfargument name="required" type="boolean" default="true">
    <cfset var entry = arguments.zip.getEntry(arguments.name)>
    <cfset var ins = "">
    <cfset var txt = "">
    <cfif isNull(entry)>
        <cfif arguments.required>
            <cfthrow type="TAO.Import.XlsxNative" message="Workbook part missing: #arguments.name#">
        </cfif>
        <cfreturn "">
    </cfif>
    <!--- Zip-bomb guard: 60 MB uncompressed per part (getSize is -1 when unknown) --->
    <cfif entry.getSize() GT 62914560>
        <cfthrow type="TAO.Import.XlsxNative" message="Workbook part too large: #arguments.name#">
    </cfif>
    <cfset ins = arguments.zip.getInputStream(entry)>
    <cftry>
        <cfset txt = createObject("java", "java.lang.String").init(ins.readAllBytes(), "UTF-8")>
        <cffinally>
            <cfset ins.close()>
        </cffinally>
    </cftry>
    <cfif len(txt) AND asc(left(txt, 1)) eq 65279>
        <cfset txt = mid(txt, 2, len(txt))>
    </cfif>
    <!--- No DTDs in OOXML parts; refusing them closes the XXE door regardless of parser settings --->
    <cfif findNoCase("<!DOCTYPE", txt)>
        <cfthrow type="TAO.Import.XlsxNative" message="Workbook part has a DOCTYPE: #arguments.name#">
    </cfif>
    <cfreturn xmlParse(txt)>
</cffunction>

<!--- "B12" -> 2 --->
<cffunction name="xlsxColumnIndex" access="private" returntype="numeric" output="false">
    <cfargument name="ref" type="string" required="true">
    <cfset var letters = uCase(reReplace(arguments.ref, "[^A-Za-z]", "", "all"))>
    <cfset var n = 0>
    <cfset var i = 0>
    <cfloop from="1" to="#len(letters)#" index="i">
        <cfset n = n * 26 + (asc(mid(letters, i, 1)) - 64)>
    </cfloop>
    <cfreturn n>
</cffunction>

<cffunction name="xlsxAttr" access="private" returntype="string" output="false">
    <cfargument name="node" required="true">
    <cfargument name="name" type="string" required="true">
    <cfargument name="default" type="string" default="">
    <cfif structKeyExists(arguments.node.xmlAttributes, arguments.name)>
        <cfreturn arguments.node.xmlAttributes[arguments.name]>
    </cfif>
    <cfreturn arguments.default>
</cffunction>

<cffunction name="readXlsxNative" access="public" returntype="struct" output="false">
    <cfargument name="path" type="string" required="true">
    <cfset var zip = createObject("java", "java.util.zip.ZipFile").init(arguments.path)>
    <cfset var result = { "headers": [], "rows": [] }>
    <cfset var shared = []>
    <cfset var dateStyles = {}>
    <cfset var dateFmtIds = {}>
    <cfset var sheetPath = "xl/worksheets/sheet1.xml">
    <cfset var doc = "">
    <cfset var x = "">
    <cfset var n = "">
    <cfset var rid = "">
    <cfset var target = "">
    <cfset var idx = 0>
    <cfset var sheetData = "">
    <cfset var rowNode = "">
    <cfset var cell = "">
    <cfset var cells = "">
    <cfset var vals = "">
    <cfset var col = 0>
    <cfset var nextCol = 0>
    <cfset var maxCol = 0>
    <cfset var t = "">
    <cfset var v = "">
    <cfset var s = "">
    <cfset var ref = "">
    <cfset var hasValue = false>
    <cfset var headerCount = 0>
    <cfset var outRow = "">
    <cfset var i = 0>
    <cfset var k = "">
    <cfset var code = "">
    <cftry>
        <!--- Shared strings (optional part) --->
        <cfset doc = xlsxEntryXml(zip, "xl/sharedStrings.xml", false)>
        <cfif isXmlDoc(doc)>
            <cfloop array="#xlsxChildren(doc.xmlRoot, 'si')#" index="x">
                <cfset arrayAppend(shared, xlsxText(x))>
            </cfloop>
        </cfif>

        <!--- Date-styled cell formats: built-in 14-22 and 45-47, plus custom codes with d/m/y
              outside quoted literals, [bracketed] sections and escaped characters --->
        <cfloop list="14,15,16,17,18,19,20,21,22,45,46,47" index="k">
            <cfset dateFmtIds[k] = true>
        </cfloop>
        <cfset doc = xlsxEntryXml(zip, "xl/styles.xml", false)>
        <cfif isXmlDoc(doc)>
            <cfloop array="#xlsxChildren(doc.xmlRoot, 'numFmts')#" index="x">
                <cfloop array="#xlsxChildren(x, 'numFmt')#" index="n">
                    <cfset code = reReplace(xlsxAttr(n, "formatCode"), '"[^"]*"|\[[^\]]*\]|\\.', "", "all")>
                    <cfif reFindNoCase("[dmy]", code)>
                        <cfset dateFmtIds[xlsxAttr(n, "numFmtId")] = true>
                    </cfif>
                </cfloop>
            </cfloop>
            <cfloop array="#xlsxChildren(doc.xmlRoot, 'cellXfs')#" index="x">
                <cfset idx = 0>
                <cfloop array="#xlsxChildren(x, 'xf')#" index="n">
                    <cfif structKeyExists(dateFmtIds, xlsxAttr(n, "numFmtId", "0"))>
                        <cfset dateStyles[idx] = true>
                    </cfif>
                    <cfset idx = idx + 1>
                </cfloop>
            </cfloop>
        </cfif>

        <!--- First sheet: workbook.xml first <sheet> r:id -> workbook rels Target --->
        <cftry>
            <cfset doc = xlsxEntryXml(zip, "xl/workbook.xml")>
            <cfset x = xlsxChildren(xlsxChildren(doc.xmlRoot, "sheets")[1], "sheet")[1]>
            <cfloop collection="#x.xmlAttributes#" item="k">
                <cfif listLast(k, ":") eq "id"><cfset rid = x.xmlAttributes[k]></cfif>
            </cfloop>
            <cfset doc = xlsxEntryXml(zip, "xl/_rels/workbook.xml.rels")>
            <cfloop array="#xlsxChildren(doc.xmlRoot, 'Relationship')#" index="n">
                <cfif xlsxAttr(n, "Id") eq rid>
                    <cfset target = xlsxAttr(n, "Target")>
                </cfif>
            </cfloop>
            <cfif len(target)>
                <cfset sheetPath = (left(target, 1) eq "/") ? mid(target, 2, len(target)) : "xl/" & target>
            </cfif>
            <cfcatch type="any">
                <cfset sheetPath = "xl/worksheets/sheet1.xml">
            </cfcatch>
        </cftry>

        <cfset doc = xlsxEntryXml(zip, sheetPath)>
        <cfset sheetData = xlsxChildren(doc.xmlRoot, "sheetData")>
        <cfif NOT arrayLen(sheetData)>
            <cfthrow type="TAO.Import.XlsxNative" message="Sheet has no data">
        </cfif>

        <cfloop array="#xlsxChildren(sheetData[1], 'row')#" index="rowNode">
            <cfset vals = {}>
            <cfset maxCol = 0>
            <cfset nextCol = 1>
            <cfset hasValue = false>
            <cfloop array="#xlsxChildren(rowNode, 'c')#" index="cell">
                <cfset ref = xlsxAttr(cell, "r")>
                <cfset col = len(ref) ? xlsxColumnIndex(ref) : nextCol>
                <cfif col LT 1><cfset col = nextCol></cfif>
                <cfset nextCol = col + 1>
                <cfset t = xlsxAttr(cell, "t", "n")>
                <cfset s = val(xlsxAttr(cell, "s", "0"))>
                <cfset v = "">
                <cfif t eq "inlineStr">
                    <cfset cells = xlsxChildren(cell, "is")>
                    <cfif arrayLen(cells)><cfset v = xlsxText(cells[1])></cfif>
                <cfelse>
                    <cfset cells = xlsxChildren(cell, "v")>
                    <cfif arrayLen(cells)>
                        <cfset v = cells[1].xmlText>
                        <cfif t eq "s">
                            <cfif isNumeric(v) AND val(v) + 1 LTE arrayLen(shared)>
                                <cfset v = shared[val(v) + 1]>
                            <cfelse>
                                <cfset v = "">
                            </cfif>
                        <cfelseif t eq "b">
                            <cfset v = (v eq "1") ? "TRUE" : "FALSE">
                        <cfelseif t eq "n" AND structKeyExists(dateStyles, s) AND isNumeric(v) AND val(v) GT 0 AND val(v) LT 2958466>
                            <cfset v = dateFormat(dateAdd("d", int(val(v)), createDate(1899, 12, 30)), "yyyy-mm-dd")>
                        </cfif>
                    </cfif>
                </cfif>
                <cfif len(trim(v))><cfset hasValue = true></cfif>
                <cfset vals[col] = v>
                <cfif col GT maxCol><cfset maxCol = col></cfif>
            </cfloop>
            <cfif hasValue>
                <cfif headerCount EQ 0>
                    <cfset headerCount = maxCol>
                    <cfloop from="1" to="#maxCol#" index="i">
                        <cfset arrayAppend(result.headers, structKeyExists(vals, i) ? trim(vals[i]) : "")>
                    </cfloop>
                <cfelse>
                    <cfset outRow = []>
                    <cfloop from="1" to="#headerCount#" index="i">
                        <cfset arrayAppend(outRow, structKeyExists(vals, i) ? vals[i] : "")>
                    </cfloop>
                    <cfset arrayAppend(result.rows, outRow)>
                </cfif>
            </cfif>
        </cfloop>
        <cffinally>
            <cfset zip.close()>
        </cffinally>
    </cftry>
    <cfif NOT arrayLen(result.headers)>
        <cfthrow type="TAO.Import.XlsxNative" message="Workbook has no header row">
    </cfif>
    <cfreturn result>
</cffunction>
