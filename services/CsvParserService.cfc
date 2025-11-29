<!---
    Component: CsvParserService
    Purpose: Parse CSV files into ColdFusion query objects
    Author: TAO Development
    Date: 2025-11-26
    Phase: 1 - Contact Import Upgrade
--->

<cfcomponent displayname="CsvParserService" hint="Handles CSV parsing operations">

<!--- ========================================
      PUBLIC METHODS
     ======================================== --->

<cffunction name="csvToQuery" access="public" returntype="query" output="false"
            hint="Convert CSV content to a ColdFusion query object">
    <cfargument name="csvContent" type="string" required="true" hint="Raw CSV file content as string">
    <cfargument name="columnNames" type="string" required="true" hint="Comma-separated list of column names">
    <cfargument name="hasHeaderRow" type="boolean" required="false" default="true" hint="Whether CSV has a header row to skip">

    <!--- Local variables --->
    <cfset var lines = listToArray(arguments.csvContent, chr(10) & chr(13), true)>
    <cfset var result = queryNew(arguments.columnNames)>
    <cfset var headerProcessed = NOT arguments.hasHeaderRow>
    <cfset var lineNum = 0>
    <cfset var line = "">
    <cfset var fields = []>
    <cfset var colList = listToArray(arguments.columnNames)>
    <cfset var i = 0>

    <!--- Loop through each line --->
    <cfloop array="#lines#" index="line">
        <cfset lineNum++>

        <!--- Skip empty lines --->
        <cfif len(trim(line)) EQ 0>
            <cfcontinue>
        </cfif>

        <!--- Skip header row if present --->
        <cfif NOT headerProcessed>
            <cfset headerProcessed = true>
            <cfcontinue>
        </cfif>

        <!--- Parse CSV line (handle quoted fields and commas) --->
        <cfset fields = parseCsvLine(line)>

        <!--- Add row to query if we have data --->
        <cfif arrayLen(fields) GT 0>
            <cfset queryAddRow(result, 1)>

            <!--- Populate each column --->
            <cfloop from="1" to="#min(arrayLen(colList), arrayLen(fields))#" index="i">
                <cftry>
                    <cfset querySetCell(result, colList[i], fields[i], result.recordCount)>
                    <cfcatch>
                        <!--- If column doesn't exist or error, set to empty string --->
                        <cfset querySetCell(result, colList[i], "", result.recordCount)>
                    </cfcatch>
                </cftry>
            </cfloop>

            <!--- Fill remaining columns with empty strings if CSV has fewer columns --->
            <cfif arrayLen(fields) LT arrayLen(colList)>
                <cfloop from="#arrayLen(fields) + 1#" to="#arrayLen(colList)#" index="i">
                    <cfset querySetCell(result, colList[i], "", result.recordCount)>
                </cfloop>
            </cfif>
        </cfif>
    </cfloop>

    <cfreturn result>
</cffunction>

<cffunction name="csvFileToQuery" access="public" returntype="query" output="false"
            hint="Read a CSV file from disk and convert to query">
    <cfargument name="filePath" type="string" required="true" hint="Full path to CSV file">
    <cfargument name="columnNames" type="string" required="true" hint="Comma-separated list of column names">
    <cfargument name="hasHeaderRow" type="boolean" required="false" default="true">

    <!--- Read file content --->
    <cfset var csvContent = "">

    <cftry>
        <cffile action="read" file="#arguments.filePath#" variable="csvContent" charset="utf-8">

        <!--- Convert to query --->
        <cfreturn csvToQuery(csvContent, arguments.columnNames, arguments.hasHeaderRow)>

        <cfcatch>
            <cfthrow message="Failed to read CSV file: #cfcatch.message#"
                     detail="File: #arguments.filePath#">
        </cfcatch>
    </cftry>
</cffunction>

<cffunction name="validateCsvStructure" access="public" returntype="struct" output="false"
            hint="Validate that a CSV has the expected columns">
    <cfargument name="csvContent" type="string" required="true">
    <cfargument name="expectedColumns" type="string" required="true" hint="Comma-separated list of expected column names">

    <!--- Parse first line to get headers --->
    <cfset var lines = listToArray(arguments.csvContent, chr(10) & chr(13), true)>
    <cfset var result = {valid: false, message: "", headerColumns: "", missingColumns: []}>

    <cfif arrayLen(lines) EQ 0>
        <cfset result.message = "CSV file is empty">
        <cfreturn result>
    </cfif>

    <!--- Get header row --->
    <cfset var headerLine = lines[1]>
    <cfset var headerFields = parseCsvLine(headerLine)>
    <cfset result.headerColumns = arrayToList(headerFields)>

    <!--- Check for expected columns --->
    <cfset var expectedList = listToArray(arguments.expectedColumns)>
    <cfset var foundAll = true>

    <cfloop array="#expectedList#" index="expectedCol">
        <cfif NOT arrayContains(headerFields, expectedCol)>
            <cfset arrayAppend(result.missingColumns, expectedCol)>
            <cfset foundAll = false>
        </cfif>
    </cfloop>

    <cfif foundAll>
        <cfset result.valid = true>
        <cfset result.message = "CSV structure is valid">
    <cfelse>
        <cfset result.message = "Missing columns: " & arrayToList(result.missingColumns)>
    </cfif>

    <cfreturn result>
</cffunction>

<!--- ========================================
      PRIVATE HELPER METHODS
     ======================================== --->

<cffunction name="parseCsvLine" access="private" returntype="array" output="false"
            hint="Parse a single CSV line, handling quoted fields and embedded commas">
    <cfargument name="line" type="string" required="true">

    <!--- Handle different line endings --->
    <cfset var cleanLine = replace(arguments.line, chr(13), "", "ALL")>
    <cfset cleanLine = replace(cleanLine, chr(10), "", "ALL")>

    <cfset var fields = []>
    <cfset var inQuotes = false>
    <cfset var currentField = "">
    <cfset var i = 1>
    <cfset var char = "">
    <cfset var nextChar = "">

    <!--- Character-by-character parsing --->
    <cfloop condition="i LTE len(cleanLine)">
        <cfset char = mid(cleanLine, i, 1)>
        <cfset nextChar = (i LT len(cleanLine)) ? mid(cleanLine, i + 1, 1) : "">

        <cfif char EQ '"'>
            <!--- Handle escaped quotes ("") --->
            <cfif inQuotes AND nextChar EQ '"'>
                <cfset currentField &= '"'>
                <cfset i++> <!--- Skip next quote --->
            <cfelse>
                <!--- Toggle quote state --->
                <cfset inQuotes = NOT inQuotes>
            </cfif>
        <cfelseif char EQ ',' AND NOT inQuotes>
            <!--- Field delimiter found --->
            <cfset arrayAppend(fields, trim(currentField))>
            <cfset currentField = "">
        <cfelse>
            <!--- Regular character --->
            <cfset currentField &= char>
        </cfif>

        <cfset i++>
    </cfloop>

    <!--- Add last field --->
    <cfset arrayAppend(fields, trim(currentField))>

    <cfreturn fields>
</cffunction>

<cffunction name="arrayContains" access="private" returntype="boolean" output="false">
    <cfargument name="arr" type="array" required="true">
    <cfargument name="value" type="string" required="true">

    <cfloop array="#arguments.arr#" index="item">
        <cfif compareNoCase(item, arguments.value) EQ 0>
            <cfreturn true>
        </cfif>
    </cfloop>

    <cfreturn false>
</cffunction>

</cfcomponent>
