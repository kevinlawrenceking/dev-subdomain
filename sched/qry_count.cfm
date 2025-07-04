<!--- Select files that have exactly one query --->
<cfquery result="result" name="getFiles" datasource="abod">
    SELECT id, filename, path
    FROM tao_files
    WHERE path = '/include/'

ORDER BY `filename`
</cfquery>

<cfloop query="getFiles">
    <!--- Set the full file path for the optimized file --->
    <cfset fullFilePath = "C:/home/theactorsoffice.com/extracted/include/qry/#getFiles.filename#">

    <!--- Output the file being processed --->
    <cfoutput>Processing file: #fullFilePath#<br></cfoutput>

    <!--- Check if the file exists --->
    <cfif fileExists(fullFilePath)>
        <!--- Read the file content --->
        <cfset fileContent = fileRead(fullFilePath)>
        
        <!--- Locate the query block --->
        <cfset startQuery = REFindNoCase("<cfquery\b[^>]*>", fileContent)>
        <cfset endQuery = REFindNoCase("</cfquery>", fileContent)>

        <!--- Ensure that both start and end of the query are valid --->
        <cfif startQuery GT 0 AND endQuery GT startQuery>
            <!--- Extract the SQL portion by removing the <cfquery result="result"> and </cfquery> tags --->
            <cfset queryStart = FindNoCase(">", fileContent, startQuery)>
            <cfif queryStart GT 0>
                <cfset strippedQueryBlock = trim(mid(fileContent, queryStart + 1, endQuery - (queryStart + 1)))>

                <!--- Clean and remove extra spaces and carriage returns from the stripped query --->
                <cfset qryDetails = REReplace(strippedQueryBlock, "[\s]+", " ", "ALL")>

                <!--- Determine query type (SELECT, INSERT, UPDATE, DELETE) --->
                <cfset qryTypePattern = "^(SELECT|INSERT|UPDATE|DELETE)">
                <cfif REFindNoCase(qryTypePattern, strippedQueryBlock)>
                    <cfset qry_Type = mid(strippedQueryBlock, REFindNoCase(qryTypePattern, strippedQueryBlock), 6)>
                <cfelse>
                    <cfset qry_Type = "UNKNOWN">
                </cfif>

                <!--- Determine the main table from the query based on the query type --->
                <cfif qry_type EQ "SELECT" OR qry_type EQ "DELETE">
                    <cfset fromPos = FindNoCase("FROM ", strippedQueryBlock)>
                    <cfif fromPos GT 0>
                        <cfset tableName = ListFirst(mid(strippedQueryBlock, fromPos + 5, Len(strippedQueryBlock) - fromPos - 4), " ")>
                    </cfif>
                <cfelseif qry_type EQ "UPDATE">
                    <cfset updatePos = FindNoCase("UPDATE ", strippedQueryBlock)>
                    <cfif updatePos GT 0>
                        <cfset tableName = ListFirst(mid(strippedQueryBlock, updatePos + 7, Len(strippedQueryBlock) - updatePos - 6), " ")>
                    </cfif>
                <cfelseif qry_type EQ "INSERT">
                    <cfset insertPos = FindNoCase("INSERT INTO ", strippedQueryBlock)>
                    <cfif insertPos GT 0>
                        <cfset tableName = ListFirst(mid(strippedQueryBlock, insertPos + 12, Len(strippedQueryBlock) - insertPos - 11), " ")>
                    </cfif>
                <cfelse>
                    <cfset tableName = "UNKNOWN">
                </cfif>

                <!--- Trim the table name --->
                <cfset tableName = trim(tableName)>

                <!--- Update the database with the query details --->
                <cfquery result="result" datasource="abod">
                    UPDATE tao_files
                    SET qry_details = <cfqueryparam value="#qryDetails#" cfsqltype="cf_sql_varchar">,
                        qry_table = <cfqueryparam value="#tableName#" cfsqltype="cf_sql_varchar">,
                        qry_type = <cfqueryparam value="#qry_Type#" cfsqltype="cf_sql_varchar">,
                        qry_extract_yn = 1
                    WHERE id = <cfqueryparam value="#getFiles.id#" cfsqltype="cf_sql_integer">
                </cfquery>

                <!--- Output success --->
                <cfoutput>Updated file: #getFiles.filename# with query details<br></cfoutput>

            <cfelse>
                <!--- Invalid query block --->
                <cfoutput>Error: Invalid query block in file #getFiles.filename#<br></cfoutput>
            </cfif>
        <cfelse>
            <!--- No valid query found --->
            <cfoutput>No valid query found in file: #getFiles.filename#<br></cfoutput>
        </cfif>
    <cfelse>
        <!--- File not found --->
        <cfoutput>Error: File #fullFilePath# not found!<br></cfoutput>
    </cfif>
</cfloop>
