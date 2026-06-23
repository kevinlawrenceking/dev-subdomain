<cfcomponent displayname="FileParserService" hint="Handles CSV and Excel file parsing with tolerance for malformed data">

<!--- ========================================
      FILE PARSING SERVICE
      Purpose: Parse CSV and Excel files into
      structured data with error capture per
      row/cell. Never throws on bad data.
     ======================================== --->

<!--- ========================================
      FILE TYPE DETECTION
     ======================================== --->

<cffunction name="detectFileType" access="public" returntype="string" output="false"
    hint="Detect file type from extension and content">
    <cfargument name="filePath" type="string" required="true">

    <cfset var extension = lcase(listLast(arguments.filePath, "."))>

    <!--- Check by extension first --->
    <cfswitch expression="#extension#">
        <cfcase value="csv">
            <cfreturn "csv">
        </cfcase>
        <cfcase value="xls">
            <cfreturn "xls">
        </cfcase>
        <cfcase value="xlsx">
            <cfreturn "xlsx">
        </cfcase>
        <cfcase value="vcf">
            <cfreturn "vcf">
        </cfcase>
        <cfdefaultcase>
            <!--- Try to detect by content --->
            <cftry>
                <cffile action="read" file="#arguments.filePath#" variable="content" charset="utf-8">
                <!--- Check for Excel magic bytes (PK for xlsx, other for xls) --->
                <cfif left(content, 2) eq "PK">
                    <cfreturn "xlsx">
                <cfelseif left(content, 8) contains chr(208) & chr(207)>
                    <cfreturn "xls">
                <cfelseif findNoCase("BEGIN:VCARD", left(content, 100)) gt 0>
                    <!--- VCF file detected by vCard header --->
                    <cfreturn "vcf">
                <cfelse>
                    <!--- Assume CSV for text files --->
                    <cfreturn "csv">
                </cfif>
                <cfcatch>
                    <cfreturn "unknown">
                </cfcatch>
            </cftry>
        </cfdefaultcase>
    </cfswitch>
</cffunction>


<cffunction name="detectEncoding" access="public" returntype="string" output="false"
    hint="Detect file encoding, checking for BOM">
    <cfargument name="filePath" type="string" required="true">

    <cftry>
        <!--- Read first few bytes as binary --->
        <cffile action="readbinary" file="#arguments.filePath#" variable="bytes">

        <cfif arrayLen(bytes) gte 3>
            <!--- Check for UTF-8 BOM: EF BB BF --->
            <cfif bytes[1] eq 239 and bytes[2] eq 187 and bytes[3] eq 191>
                <cfreturn "utf-8-bom">
            </cfif>
        </cfif>

        <cfif arrayLen(bytes) gte 2>
            <!--- Check for UTF-16 LE BOM: FF FE --->
            <cfif bytes[1] eq 255 and bytes[2] eq 254>
                <cfreturn "utf-16le">
            </cfif>
            <!--- Check for UTF-16 BE BOM: FE FF --->
            <cfif bytes[1] eq 254 and bytes[2] eq 255>
                <cfreturn "utf-16be">
            </cfif>
        </cfif>

        <!--- Default to UTF-8 --->
        <cfreturn "utf-8">

        <cfcatch>
            <cfreturn "utf-8">
        </cfcatch>
    </cftry>
</cffunction>


<cffunction name="detectDelimiter" access="public" returntype="string" output="false"
    hint="Detect CSV delimiter by analyzing first few lines">
    <cfargument name="filePath" type="string" required="true">
    <cfargument name="encoding" type="string" required="false" default="utf-8">

    <cftry>
        <!--- Read first 5 lines --->
        <cfset var sampleLines = []>
        <cfset var lineCount = 0>
        <cfset var charset = arguments.encoding eq "utf-8-bom" ? "utf-8" : arguments.encoding>

        <cfloop file="#arguments.filePath#" index="line" charset="#charset#">
            <cfif lineCount lt 5>
                <cfset arrayAppend(sampleLines, line)>
                <cfset lineCount++>
            <cfelse>
                <cfbreak>
            </cfif>
        </cfloop>

        <!--- Count occurrences of common delimiters --->
        <cfset var tabChar = chr(9)>
        <cfset var delimiters = structNew()>
        <cfset delimiters[","] = 0>
        <cfset delimiters[tabChar] = 0>
        <cfset delimiters[";"] = 0>
        <cfset delimiters["|"] = 0>

        <cfloop array="#sampleLines#" index="line">
            <cfloop collection="#delimiters#" item="delim">
                <cfset delimiters[delim] += listLen(line, delim) - 1>
            </cfloop>
        </cfloop>

        <!--- Find the most common delimiter --->
        <cfset var maxCount = 0>
        <cfset var bestDelim = ",">

        <cfloop collection="#delimiters#" item="delim">
            <cfif delimiters[delim] gt maxCount>
                <cfset maxCount = delimiters[delim]>
                <cfset bestDelim = delim>
            </cfif>
        </cfloop>

        <cfreturn bestDelim>

        <cfcatch>
            <cfreturn ",">
        </cfcatch>
    </cftry>
</cffunction>


<!--- ========================================
      CSV PARSING
     ======================================== --->

<cffunction name="parseCSV" access="public" returntype="struct" output="false"
    hint="Parse CSV file with tolerance for malformed data">
    <cfargument name="filePath" type="string" required="true">
    <cfargument name="options" type="struct" required="false" default="#{}#">

    <!--- Initialize result --->
    <cfset var result = {
        success: true,
        headers: [],
        rows: [],
        errors: [],
        totalRows: 0,
        parsedRows: 0
    }>

    <!--- Set default options --->
    <cfset var opts = {
        encoding: structKeyExists(arguments.options, "encoding") ? arguments.options.encoding : "auto",
        delimiter: structKeyExists(arguments.options, "delimiter") ? arguments.options.delimiter : "auto",
        hasHeader: structKeyExists(arguments.options, "hasHeader") ? arguments.options.hasHeader : true,
        quoteChar: structKeyExists(arguments.options, "quoteChar") ? arguments.options.quoteChar : '"',
        maxRows: structKeyExists(arguments.options, "maxRows") ? arguments.options.maxRows : 0
    }>

    <cftry>
        <!--- Detect encoding if auto --->
        <cfif opts.encoding eq "auto">
            <cfset opts.encoding = detectEncoding(arguments.filePath)>
        </cfif>

        <!--- Detect delimiter if auto --->
        <cfif opts.delimiter eq "auto">
            <cfset opts.delimiter = detectDelimiter(arguments.filePath, opts.encoding)>
        </cfif>

        <!--- Handle BOM --->
        <cfset var charset = opts.encoding eq "utf-8-bom" ? "utf-8" : opts.encoding>
        <cfset var skipBOM = opts.encoding eq "utf-8-bom">

        <!--- Read entire file --->
        <cffile action="read" file="#arguments.filePath#" variable="fileContent" charset="#charset#">

        <!--- Skip BOM if present --->
        <cfif skipBOM and len(fileContent) gte 1 and asc(left(fileContent, 1)) eq 65279>
            <cfset fileContent = mid(fileContent, 2, len(fileContent) - 1)>
        </cfif>

        <!--- Parse CSV content --->
        <cfset var parseResult = parseCSVContent(fileContent, opts.delimiter, opts.quoteChar)>
        <cfset var allRows = parseResult.rows>
        <cfset var parseErrors = parseResult.errors>

        <!--- Extract headers --->
        <cfif opts.hasHeader and arrayLen(allRows) gt 0>
            <cfset result.headers = allRows[1]>
            <cfset var dataStartRow = 2>
        <cfelse>
            <!--- Generate column headers --->
            <cfif arrayLen(allRows) gt 0>
                <cfloop from="1" to="#arrayLen(allRows[1])#" index="i">
                    <cfset arrayAppend(result.headers, "Column_" & i)>
                </cfloop>
            </cfif>
            <cfset var dataStartRow = 1>
        </cfif>

        <!--- Process data rows --->
        <cfset var rowNum = 0>
        <cfset var expectedColumns = arrayLen(result.headers)>

        <cfloop from="#dataStartRow#" to="#arrayLen(allRows)#" index="i">
            <cfset rowNum++>
            <cfset result.totalRows = rowNum>

            <!--- Apply max rows limit --->
            <cfif opts.maxRows gt 0 and rowNum gt opts.maxRows>
                <cfbreak>
            </cfif>

            <cfset var row = allRows[i]>

            <!--- Normalize row length to match headers --->
            <cfset var normalizedRow = {}>

            <cfloop from="1" to="#expectedColumns#" index="colIdx">
                <cfif colIdx lte arrayLen(row)>
                    <cfset normalizedRow[colIdx - 1] = trim(row[colIdx])>
                <cfelse>
                    <!--- Pad missing columns with empty string --->
                    <cfset normalizedRow[colIdx - 1] = "">
                </cfif>
            </cfloop>

            <!--- Check for extra columns --->
            <cfif arrayLen(row) gt expectedColumns>
                <cfset arrayAppend(result.errors, {
                    row_num: rowNum,
                    error_type: "extra_columns",
                    error_message: "Row has " & arrayLen(row) & " columns, expected " & expectedColumns & ". Extra data ignored.",
                    severity: "warning"
                })>
            </cfif>

            <cfset arrayAppend(result.rows, normalizedRow)>
            <cfset result.parsedRows++>
        </cfloop>

        <!--- Add parsing errors --->
        <cfloop array="#parseErrors#" index="err">
            <cfset arrayAppend(result.errors, err)>
        </cfloop>

        <cfcatch type="any">
            <cfset result.success = false>
            <cfset arrayAppend(result.errors, {
                row_num: 0,
                error_type: "file_error",
                error_message: "Failed to parse file: " & cfcatch.message,
                severity: "error"
            })>
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<cffunction name="parseCSVContent" access="private" returntype="struct" output="false"
    hint="Parse CSV content handling quoted fields and embedded newlines">
    <cfargument name="content" type="string" required="true">
    <cfargument name="delimiter" type="string" required="true">
    <cfargument name="quoteChar" type="string" required="true">

    <cfset var result = {
        rows: [],
        errors: []
    }>

    <cfset var currentRow = []>
    <cfset var currentField = "">
    <cfset var inQuotes = false>
    <cfset var rowNum = 1>
    <cfset var charIndex = 0>
    <cfset var contentLen = len(arguments.content)>
    <cfset var skipNext = false>

    <cfloop from="1" to="#contentLen#" index="i">
        <!--- Skip the second char of an escaped "" pair. A <cfloop from/to> ignores
              reassigning its index var (the old "<cfset i++>" was a no-op), which left
              inQuotes inverted and shifted/truncated every later column. --->
        <cfif skipNext>
            <cfset skipNext = false>
            <cfcontinue>
        </cfif>
        <cfset var char = mid(arguments.content, i, 1)>
        <cfset var nextChar = i lt contentLen ? mid(arguments.content, i + 1, 1) : "">

        <cfif inQuotes>
            <!--- Inside quoted field --->
            <cfif char eq arguments.quoteChar>
                <cfif nextChar eq arguments.quoteChar>
                    <!--- Escaped quote --->
                    <cfset currentField &= arguments.quoteChar>
                    <cfset skipNext = true>
                <cfelse>
                    <!--- End of quoted field --->
                    <cfset inQuotes = false>
                </cfif>
            <cfelse>
                <cfset currentField &= char>
            </cfif>
        <cfelse>
            <!--- Outside quoted field --->
            <cfif char eq arguments.quoteChar>
                <!--- Start of quoted field --->
                <cfset inQuotes = true>
            <cfelseif char eq arguments.delimiter>
                <!--- Field separator --->
                <cfset arrayAppend(currentRow, currentField)>
                <cfset currentField = "">
            <cfelseif char eq chr(13)>
                <!--- CR - skip if followed by LF --->
                <cfif nextChar neq chr(10)>
                    <!--- End of row (CR only) --->
                    <cfset arrayAppend(currentRow, currentField)>
                    <cfset arrayAppend(result.rows, currentRow)>
                    <cfset currentRow = []>
                    <cfset currentField = "">
                    <cfset rowNum++>
                </cfif>
            <cfelseif char eq chr(10)>
                <!--- End of row (LF) --->
                <cfset arrayAppend(currentRow, currentField)>
                <cfset arrayAppend(result.rows, currentRow)>
                <cfset currentRow = []>
                <cfset currentField = "">
                <cfset rowNum++>
            <cfelse>
                <cfset currentField &= char>
            </cfif>
        </cfif>
    </cfloop>

    <!--- Handle last field/row --->
    <cfif len(currentField) gt 0 or arrayLen(currentRow) gt 0>
        <cfset arrayAppend(currentRow, currentField)>
        <cfset arrayAppend(result.rows, currentRow)>
    </cfif>

    <!--- Check for unclosed quotes --->
    <cfif inQuotes>
        <cfset arrayAppend(result.errors, {
            row_num: rowNum,
            error_type: "unclosed_quote",
            error_message: "File contains unclosed quoted field. Data may be incorrectly parsed.",
            severity: "warning"
        })>
    </cfif>

    <cfreturn result>
</cffunction>


<!--- ========================================
      EXCEL PARSING
     ======================================== --->

<cffunction name="parseExcel" access="public" returntype="struct" output="false"
    hint="Parse Excel file with tolerance for malformed data">
    <cfargument name="filePath" type="string" required="true">
    <cfargument name="options" type="struct" required="false" default="#{}#">

    <!--- Initialize result --->
    <cfset var result = {
        success: true,
        headers: [],
        rows: [],
        errors: [],
        totalRows: 0,
        parsedRows: 0,
        sheets: []
    }>

    <!--- Set default options --->
    <cfset var opts = {
        sheetIndex: structKeyExists(arguments.options, "sheetIndex") ? arguments.options.sheetIndex : 0,
        sheetName: structKeyExists(arguments.options, "sheetName") ? arguments.options.sheetName : "",
        hasHeader: structKeyExists(arguments.options, "hasHeader") ? arguments.options.hasHeader : true,
        maxRows: structKeyExists(arguments.options, "maxRows") ? arguments.options.maxRows : 0,
        preserveTypes: structKeyExists(arguments.options, "preserveTypes") ? arguments.options.preserveTypes : true
    }>

    <cftry>
        <!--- Get sheet info using SpreadsheetRead and SpreadsheetInfo functions --->
        <cfset var spreadsheetObj = SpreadsheetRead(arguments.filePath)>
        <cfset var spreadsheetInfo = SpreadsheetInfo(spreadsheetObj)>

        <!--- Store available sheets --->
        <cfset result.sheets = listToArray(spreadsheetInfo.sheetNames)>

        <!--- Determine which sheet to read --->
        <cfset var targetSheet = "">
        <cfif len(opts.sheetName)>
            <cfset targetSheet = opts.sheetName>
        <cfelseif opts.sheetIndex lt listLen(spreadsheetInfo.sheetNames)>
            <cfset targetSheet = listGetAt(spreadsheetInfo.sheetNames, opts.sheetIndex + 1)>
        <cfelse>
            <cfset targetSheet = listFirst(spreadsheetInfo.sheetNames)>
        </cfif>

        <!--- Read spreadsheet --->
        <cftry>
            <cfspreadsheet
                action="read"
                src="#arguments.filePath#"
                query="spreadsheetData"
                headerrow="#iif(opts.hasHeader, 1, 0)#"
                sheet="#targetSheet#">

            <cfcatch>
                <!--- Try without header row specification --->
                <cfspreadsheet
                    action="read"
                    src="#arguments.filePath#"
                    query="spreadsheetData"
                    sheet="#targetSheet#">
            </cfcatch>
        </cftry>

        <!--- Get column names --->
        <cfset var columnList = spreadsheetData.columnList>
        <cfset var columnArray = listToArray(columnList)>

        <!--- Process headers --->
        <cfif opts.hasHeader>
            <!--- Use first row values as headers if cfspreadsheet didn't extract them properly --->
            <cfloop from="1" to="#arrayLen(columnArray)#" index="i">
                <cfset var header = columnArray[i]>
                <!--- cfspreadsheet sometimes names columns COL_1, COL_2, etc --->
                <cfif reFindNoCase("^COL_\d+$", header) and spreadsheetData.recordCount gt 0>
                    <!--- Use actual first row value --->
                    <cfset header = toString(spreadsheetData[columnArray[i]][1])>
                </cfif>
                <cfset arrayAppend(result.headers, header)>
            </cfloop>
            <cfset var dataStartRow = 1>
        <cfelse>
            <!--- Generate column headers --->
            <cfloop from="1" to="#arrayLen(columnArray)#" index="i">
                <cfset arrayAppend(result.headers, "Column_" & i)>
            </cfloop>
            <cfset var dataStartRow = 1>
        </cfif>

        <!--- Process data rows --->
        <cfset var rowNum = 0>

        <cfloop query="spreadsheetData" startrow="#dataStartRow#">
            <cfset rowNum++>
            <cfset result.totalRows = rowNum>

            <!--- Apply max rows limit --->
            <cfif opts.maxRows gt 0 and rowNum gt opts.maxRows>
                <cfbreak>
            </cfif>

            <cfset var rowData = {}>

            <cfloop from="1" to="#arrayLen(columnArray)#" index="colIdx">
                <cfset var colName = columnArray[colIdx]>
                <cfset var cellValue = spreadsheetData[colName][spreadsheetData.currentRow]>

                <cftry>
                    <!--- Convert cell value to string, handling dates and numbers --->
                    <cfset var stringValue = convertCellValue(cellValue, opts.preserveTypes)>
                    <cfset rowData[colIdx - 1] = stringValue>

                    <cfcatch>
                        <!--- Capture error but continue --->
                        <cfset rowData[colIdx - 1] = "">
                        <cfset arrayAppend(result.errors, {
                            row_num: rowNum,
                            column_index: colIdx - 1,
                            column_name: result.headers[colIdx],
                            error_type: "cell_parse_error",
                            error_message: "Could not read cell value: " & cfcatch.message,
                            severity: "warning"
                        })>
                    </cfcatch>
                </cftry>
            </cfloop>

            <!--- Skip empty rows --->
            <cfset var hasData = false>
            <cfloop collection="#rowData#" item="key">
                <cfif len(trim(rowData[key]))>
                    <cfset hasData = true>
                    <cfbreak>
                </cfif>
            </cfloop>

            <cfif hasData>
                <cfset arrayAppend(result.rows, rowData)>
                <cfset result.parsedRows++>
            </cfif>
        </cfloop>

        <cfcatch type="any">
            <cfset result.success = false>
            <cfset arrayAppend(result.errors, {
                row_num: 0,
                error_type: "file_error",
                error_message: "Failed to parse Excel file: " & cfcatch.message,
                severity: "error"
            })>
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<cffunction name="convertCellValue" access="private" returntype="string" output="false"
    hint="Convert Excel cell value to string preserving data">
    <cfargument name="cellValue" type="any" required="true">
    <cfargument name="preserveTypes" type="boolean" required="false" default="true">

    <!--- Handle null/empty --->
    <cfif isNull(arguments.cellValue) or not isDefined("arguments.cellValue")>
        <cfreturn "">
    </cfif>

    <!--- Handle string --->
    <cfif isSimpleValue(arguments.cellValue)>
        <cfset var strValue = toString(arguments.cellValue)>

        <!--- Check for Excel date serial number --->
        <cfif arguments.preserveTypes and isNumeric(strValue)>
            <cfset var numValue = val(strValue)>

            <!--- Excel date serials are typically between 1 and 100000 --->
            <!--- And usually have decimals for time component --->
            <cfif numValue gte 1 and numValue lte 100000>
                <!--- Could be a date, but also could be a regular number --->
                <!--- Only convert if the value looks like an Excel date serial --->
                <!--- For now, preserve as-is and let validation handle it --->
            </cfif>
        </cfif>

        <cfreturn trim(strValue)>
    </cfif>

    <!--- Handle date --->
    <cfif isDate(arguments.cellValue)>
        <cfreturn dateFormat(arguments.cellValue, "yyyy-mm-dd")>
    </cfif>

    <!--- Handle numeric --->
    <cfif isNumeric(arguments.cellValue)>
        <!--- Preserve as string to prevent scientific notation --->
        <cfreturn toString(arguments.cellValue)>
    </cfif>

    <!--- Handle boolean --->
    <cfif isBoolean(arguments.cellValue)>
        <cfreturn arguments.cellValue ? "true" : "false">
    </cfif>

    <!--- Fallback --->
    <cfreturn toString(arguments.cellValue)>
</cffunction>


<!--- ========================================
      VCARD (VCF) PARSING
     ======================================== --->

<cffunction name="parseVCF" access="public" returntype="struct" output="false"
    hint="Parse vCard (.vcf) file exported from Apple/iCloud Contacts">
    <cfargument name="filePath" type="string" required="true">
    <cfargument name="options" type="struct" required="false" default="#{}#">

    <!--- Initialize result --->
    <cfset var result = {
        success: true,
        headers: [],
        rows: [],
        errors: [],
        totalRows: 0,
        parsedRows: 0
    }>

    <!--- VCF field mapping to internal headers --->
    <cfset var headerOrder = [
        "fn", "n_family", "n_given", "email_work", "email_home",
        "tel_work", "tel_cell", "tel_home", "org", "title",
        "adr_street", "adr_city", "adr_region", "adr_postal", "adr_country",
        "bday", "note", "url"
    ]>
    <cfset result.headers = headerOrder>

    <cfset var opts = {
        maxRows: structKeyExists(arguments.options, "maxRows") ? arguments.options.maxRows : 0
    }>

    <cftry>
        <!--- Read file content --->
        <cffile action="read" file="#arguments.filePath#" variable="fileContent" charset="utf-8">

        <!--- Handle BOM if present --->
        <cfif len(fileContent) gte 1 and asc(left(fileContent, 1)) eq 65279>
            <cfset fileContent = mid(fileContent, 2, len(fileContent) - 1)>
        </cfif>

        <!--- Normalize line endings to LF --->
        <cfset fileContent = replace(fileContent, chr(13) & chr(10), chr(10), "all")>
        <cfset fileContent = replace(fileContent, chr(13), chr(10), "all")>

        <!--- RFC 6350: Unfold lines (lines starting with space/tab are continuations) --->
        <!--- Process line folding BEFORE splitting into vCards for proper handling --->
        <cfset fileContent = reReplace(fileContent, "#chr(10)#[ #chr(9)#]", "", "all")>

        <!--- Handle quoted-printable soft line breaks (=\n continuation) --->
        <cfset fileContent = replace(fileContent, "=" & chr(10), "", "all")>

        <!--- Split into individual vCards --->
        <cfset var vcards = []>
        <cfset var currentVcard = "">
        <cfset var inVcard = false>

        <cfloop list="#fileContent#" delimiters="#chr(10)#" index="line">
            <cfset line = trim(line)>

            <cfif findNoCase("BEGIN:VCARD", line) gt 0>
                <cfset inVcard = true>
                <cfset currentVcard = "">
            <cfelseif findNoCase("END:VCARD", line) gt 0>
                <cfif inVcard and len(currentVcard)>
                    <cfset arrayAppend(vcards, currentVcard)>
                </cfif>
                <cfset inVcard = false>
            <cfelseif inVcard>
                <cfset currentVcard = currentVcard & chr(10) & line>
            </cfif>
        </cfloop>

        <cfset result.totalRows = arrayLen(vcards)>

        <!--- Parse each vCard --->
        <cfloop from="1" to="#arrayLen(vcards)#" index="vcardIdx">
            <!--- Apply max rows limit --->
            <cfif opts.maxRows gt 0 and vcardIdx gt opts.maxRows>
                <cfbreak>
            </cfif>

            <cfset var vcardContent = vcards[vcardIdx]>
            <cfset var rowData = {}>

            <!--- Initialize all fields to empty --->
            <cfloop from="0" to="#arrayLen(headerOrder) - 1#" index="i">
                <cfset rowData[i] = "">
            </cfloop>

            <cftry>
                <!--- Parse vCard properties --->
                <cfloop list="#vcardContent#" delimiters="#chr(10)#" index="propLine">
                    <cfset propLine = trim(propLine)>
                    <cfif not len(propLine)>
                        <cfcontinue>
                    </cfif>

                    <!--- Split property into name and value --->
                    <cfset var colonPos = find(":", propLine)>
                    <cfif colonPos eq 0>
                        <cfcontinue>
                    </cfif>

                    <cfset var propName = ucase(left(propLine, colonPos - 1))>
                    <cfset var propValue = mid(propLine, colonPos + 1, len(propLine) - colonPos)>

                    <!--- Decode quoted-printable if needed --->
                    <cfif findNoCase("ENCODING=QUOTED-PRINTABLE", propName) gt 0>
                        <cfset propValue = decodeQuotedPrintable(propValue)>
                    </cfif>

                    <!--- Extract base property name (before any parameters) --->
                    <cfset var baseProp = listFirst(propName, ";")>
                    <cfset var propParams = mid(propName, len(baseProp) + 1, len(propName))>

                    <!--- Map vCard properties to our fields --->
                    <cfswitch expression="#baseProp#">
                        <cfcase value="FN">
                            <cfset rowData[0] = propValue>
                        </cfcase>
                        <cfcase value="N">
                            <!--- N format: family;given;middle;prefix;suffix --->
                            <cfset var nameParts = listToArray(propValue, ";", true)>
                            <cfif arrayLen(nameParts) gte 1>
                                <cfset rowData[1] = nameParts[1]><!--- family --->
                            </cfif>
                            <cfif arrayLen(nameParts) gte 2>
                                <cfset rowData[2] = nameParts[2]><!--- given --->
                            </cfif>
                        </cfcase>
                        <cfcase value="EMAIL">
                            <!--- Check type parameter --->
                            <cfif findNoCase("TYPE=WORK", propParams) gt 0 or findNoCase("WORK", propParams) gt 0>
                                <cfset rowData[3] = propValue>
                            <cfelseif findNoCase("TYPE=HOME", propParams) gt 0 or findNoCase("HOME", propParams) gt 0>
                                <cfset rowData[4] = propValue>
                            <cfelseif not len(rowData[3])>
                                <!--- Default to business email if no type --->
                                <cfset rowData[3] = propValue>
                            <cfelseif not len(rowData[4])>
                                <cfset rowData[4] = propValue>
                            </cfif>
                        </cfcase>
                        <cfcase value="TEL">
                            <!--- Check type parameter --->
                            <cfif findNoCase("TYPE=WORK", propParams) gt 0 or findNoCase("WORK", propParams) gt 0>
                                <cfset rowData[5] = propValue>
                            <cfelseif findNoCase("TYPE=CELL", propParams) gt 0 or findNoCase("CELL", propParams) gt 0 or findNoCase("MOBILE", propParams) gt 0>
                                <cfset rowData[6] = propValue>
                            <cfelseif findNoCase("TYPE=HOME", propParams) gt 0 or findNoCase("HOME", propParams) gt 0>
                                <cfset rowData[7] = propValue>
                            <cfelseif not len(rowData[5])>
                                <!--- Default to work phone if no type --->
                                <cfset rowData[5] = propValue>
                            <cfelseif not len(rowData[6])>
                                <cfset rowData[6] = propValue>
                            <cfelseif not len(rowData[7])>
                                <cfset rowData[7] = propValue>
                            </cfif>
                        </cfcase>
                        <cfcase value="ORG">
                            <!--- ORG can have multiple components separated by ; --->
                            <cfset rowData[8] = listFirst(propValue, ";")>
                        </cfcase>
                        <cfcase value="TITLE">
                            <cfset rowData[9] = propValue>
                        </cfcase>
                        <cfcase value="ADR">
                            <!--- ADR format: PO;ext;street;city;region;postal;country --->
                            <cfset var adrParts = listToArray(propValue, ";", true)>
                            <cfif arrayLen(adrParts) gte 3>
                                <cfset rowData[10] = adrParts[3]><!--- street --->
                            </cfif>
                            <cfif arrayLen(adrParts) gte 4>
                                <cfset rowData[11] = adrParts[4]><!--- city --->
                            </cfif>
                            <cfif arrayLen(adrParts) gte 5>
                                <cfset rowData[12] = adrParts[5]><!--- region --->
                            </cfif>
                            <cfif arrayLen(adrParts) gte 6>
                                <cfset rowData[13] = adrParts[6]><!--- postal --->
                            </cfif>
                            <cfif arrayLen(adrParts) gte 7>
                                <cfset rowData[14] = adrParts[7]><!--- country --->
                            </cfif>
                        </cfcase>
                        <cfcase value="BDAY">
                            <!--- Birthday can be in various formats --->
                            <cfset var bdayValue = propValue>
                            <!--- Handle --MMDD format (no year) --->
                            <cfif left(bdayValue, 2) eq "--">
                                <cfset bdayValue = "1900" & mid(bdayValue, 3, len(bdayValue))>
                            </cfif>
                            <!--- Try to normalize to yyyy-mm-dd --->
                            <cfset bdayValue = reReplace(bdayValue, "^(\d{4})(\d{2})(\d{2})$", "\1-\2-\3")>
                            <cfset rowData[15] = bdayValue>
                        </cfcase>
                        <cfcase value="NOTE">
                            <!--- Notes may have escaped newlines --->
                            <cfset propValue = replace(propValue, "\n", chr(10), "all")>
                            <cfset rowData[16] = propValue>
                        </cfcase>
                        <cfcase value="URL">
                            <cfset rowData[17] = propValue>
                        </cfcase>
                    </cfswitch>
                </cfloop>

                <!--- Check if row has any data --->
                <cfset var hasData = false>
                <cfloop collection="#rowData#" item="key">
                    <cfif len(trim(rowData[key]))>
                        <cfset hasData = true>
                        <cfbreak>
                    </cfif>
                </cfloop>

                <cfif hasData>
                    <!--- Check for blank-name contacts and add warning --->
                    <cfset var hasName = len(trim(rowData[0])) gt 0 or len(trim(rowData[1])) gt 0 or len(trim(rowData[2])) gt 0>
                    <cfif not hasName>
                        <!--- Try to generate a name from email or phone --->
                        <cfif len(trim(rowData[3]))>
                            <cfset rowData[0] = listFirst(rowData[3], "@")><!--- Use email prefix as name --->
                        <cfelseif len(trim(rowData[4]))>
                            <cfset rowData[0] = listFirst(rowData[4], "@")>
                        <cfelseif len(trim(rowData[8]))>
                            <cfset rowData[0] = rowData[8]><!--- Use org as name --->
                        </cfif>

                        <cfset arrayAppend(result.errors, {
                            row_num: vcardIdx,
                            error_type: "missing_name",
                            error_message: "vCard " & vcardIdx & " has no name (FN or N fields). " & (len(trim(rowData[0])) ? "Generated name from available data." : "Contact may import without a name."),
                            severity: "warning"
                        })>
                    </cfif>

                    <cfset arrayAppend(result.rows, rowData)>
                    <cfset result.parsedRows++>
                </cfif>

                <cfcatch type="any">
                    <cfset arrayAppend(result.errors, {
                        row_num: vcardIdx,
                        error_type: "vcard_parse_error",
                        error_message: "Failed to parse vCard " & vcardIdx & ": " & cfcatch.message,
                        severity: "warning"
                    })>
                </cfcatch>
            </cftry>
        </cfloop>

        <cfcatch type="any">
            <cfset result.success = false>
            <cfset arrayAppend(result.errors, {
                row_num: 0,
                error_type: "file_error",
                error_message: "Failed to parse VCF file: " & cfcatch.message,
                severity: "error"
            })>
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>


<cffunction name="decodeQuotedPrintable" access="private" returntype="string" output="false"
    hint="Decode quoted-printable encoded string">
    <cfargument name="str" type="string" required="true">

    <cfset var result = arguments.str>

    <!--- Replace =XX hex codes --->
    <cfset var pos = 1>
    <cfloop condition="pos lte len(result)">
        <cfset var eqPos = find("=", result, pos)>
        <cfif eqPos eq 0>
            <cfbreak>
        </cfif>

        <!--- Check if this is a soft line break (= at end of line) --->
        <cfif eqPos eq len(result)>
            <cfset result = left(result, eqPos - 1)>
            <cfbreak>
        </cfif>

        <!--- Get the two characters after = --->
        <cfset var hexChars = mid(result, eqPos + 1, 2)>

        <!--- Check if valid hex --->
        <cfif reFindNoCase("^[0-9A-F]{2}$", hexChars)>
            <cfset var charCode = inputBaseN(hexChars, 16)>
            <cfset result = left(result, eqPos - 1) & chr(charCode) & mid(result, eqPos + 3, len(result))>
        </cfif>

        <cfset pos = eqPos + 1>
    </cfloop>

    <cfreturn result>
</cffunction>


<!--- ========================================
      UNIFIED PARSING INTERFACE
     ======================================== --->

<cffunction name="parseFile" access="public" returntype="struct" output="false"
    hint="Parse any supported file type (CSV, XLS, XLSX, VCF)">
    <cfargument name="filePath" type="string" required="true">
    <cfargument name="options" type="struct" required="false" default="#{}#">

    <!--- Detect file type --->
    <cfset var fileType = detectFileType(arguments.filePath)>

    <!--- Route to appropriate parser --->
    <cfswitch expression="#fileType#">
        <cfcase value="csv">
            <cfset var result = parseCSV(arguments.filePath, arguments.options)>
            <cfset result.fileType = "csv">
        </cfcase>
        <cfcase value="xls,xlsx">
            <cfset var result = parseExcel(arguments.filePath, arguments.options)>
            <cfset result.fileType = fileType>
        </cfcase>
        <cfcase value="vcf">
            <cfset var result = parseVCF(arguments.filePath, arguments.options)>
            <cfset result.fileType = "vcf">
        </cfcase>
        <cfdefaultcase>
            <cfset var errorMsg = "Unsupported file type: " & fileType & ". Please upload CSV, XLS, XLSX, or VCF files.">
            <cfset var result = {
                success: false,
                headers: [],
                rows: [],
                errors: [],
                totalRows: 0,
                parsedRows: 0,
                fileType: fileType
            }>
            <cfset arrayAppend(result.errors, {
                row_num: 0,
                error_type: "unsupported_type",
                error_message: errorMsg,
                severity: "error"
            })>
        </cfdefaultcase>
    </cfswitch>

    <cfreturn result>
</cffunction>


<!--- ========================================
      UTILITY METHODS
     ======================================== --->

<cffunction name="getFileSizeFormatted" access="public" returntype="string" output="false"
    hint="Format file size for display">
    <cfargument name="filePath" type="string" required="true">

    <cftry>
        <cfset var fileInfo = getFileInfo(arguments.filePath)>
        <cfset var bytes = fileInfo.size>

        <cfif bytes lt 1024>
            <cfreturn bytes & " B">
        <cfelseif bytes lt 1048576>
            <cfreturn numberFormat(bytes / 1024, "0.0") & " KB">
        <cfelseif bytes lt 1073741824>
            <cfreturn numberFormat(bytes / 1048576, "0.0") & " MB">
        <cfelse>
            <cfreturn numberFormat(bytes / 1073741824, "0.0") & " GB">
        </cfif>

        <cfcatch>
            <cfreturn "Unknown">
        </cfcatch>
    </cftry>
</cffunction>


<cffunction name="validateFileUpload" access="public" returntype="struct" output="false"
    hint="Validate uploaded file before processing">
    <cfargument name="filePath" type="string" required="true">
    <cfargument name="maxSizeBytes" type="numeric" required="false" default="52428800">
    <!--- Default 50MB --->

    <cfset var result = {
        valid: true,
        errors: []
    }>

    <!--- Check file exists --->
    <cfif not fileExists(arguments.filePath)>
        <cfset result.valid = false>
        <cfset arrayAppend(result.errors, "File not found")>
        <cfreturn result>
    </cfif>

    <!--- Check file size --->
    <cfset var fileInfo = getFileInfo(arguments.filePath)>
    <cfif fileInfo.size gt arguments.maxSizeBytes>
        <cfset result.valid = false>
        <cfset arrayAppend(result.errors, "File too large. Maximum size is " & numberFormat(arguments.maxSizeBytes / 1048576, "0") & " MB")>
    </cfif>

    <!--- Check file type --->
    <cfset var fileType = detectFileType(arguments.filePath)>
    <cfif not listFindNoCase("csv,xls,xlsx,vcf", fileType)>
        <cfset result.valid = false>
        <cfset arrayAppend(result.errors, "Unsupported file type. Please upload CSV, XLS, XLSX, or VCF files")>
    </cfif>

    <!--- Check for potentially malicious content --->
    <cfif fileType eq "csv">
        <cftry>
            <cffile action="read" file="#arguments.filePath#" variable="content" charset="utf-8">
            <!--- Check for formula injection attempts --->
            <cfif reFindNoCase("^[=+\-@]", content)>
                <cfset arrayAppend(result.errors, "Warning: File may contain formula content. Values starting with =, +, -, @ will be treated as text.")>
            </cfif>
            <cfcatch>
                <!--- Ignore read errors here, parser will handle them --->
            </cfcatch>
        </cftry>
    </cfif>

    <cfreturn result>
</cffunction>

</cfcomponent>
