<cfparam name="mr" default="3" />

<cfquery result="result" name="getFiles" datasource="#application.dsn#" maxrows="#mr#">
    SELECT id, `path`, `filename`
    FROM tao_files
    WHERE filename = 'account_info.cfm'
      AND status <> 'deleted'
      AND qry_removed_yn = 1
      AND path = '/include'
      AND qry_no > 1
    ORDER BY `filename`
</cfquery>

<cfloop query="getFiles">
    <!--- Corrected file path to read from optimized/include --->
    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized/include/#getFiles.filename#">
    <cfoutput><h3>#fullFilePath#</h3></cfoutput>

    <cfif fileExists(fullFilePath)>
        <cfset fileContent = fileRead(fullFilePath)>
        <cfset startPos = 1>
        <cfset counter = 0>
        <cfset queriesProcessed = false>

        <!--- Loop through the content and find queries --->
        <cfloop condition="startPos LTE len(fileContent)">
            <cfset startQuery = REFindNoCase("<cfquery\b[^>]*>", fileContent, startPos)>
            <cfset endQuery = REFindNoCase("</cfquery>", fileContent, startPos)>

            <!--- Ensure that both start and end of the query are valid --->
            <cfif startQuery GT 0 AND endQuery GT startQuery>
                <cfset counter++>
                <cfset queriesProcessed = true>

                <cfset fullQueryBlock = mid(fileContent, startQuery, (endQuery + 10) - startQuery)>
                <cfset queryStart = FindNoCase(">", fileContent, startQuery)>

                <!--- Check for valid queryStart before proceeding --->
                <cfif queryStart GT 0>
                    <cfset strippedQueryBlock = trim(mid(fileContent, queryStart + 1, endQuery - (queryStart + 1)))>

                    <!--- Extract query name --->
                    <cfset nameStart = FindNoCase('name="', fileContent, startQuery)>
                    <cfset nameEnd = FindNoCase('"', fileContent, nameStart + 6)>

                    <cfif nameStart GT 0 AND nameEnd GT 0>
                        <cfset qryName = mid(fileContent, nameStart + 6, nameEnd - (nameStart + 6))>
                    <cfelse>
                        <cfset qryName = "query_#counter#">
                    </cfif>

                    <cfset qryNameSanitized = REReplace(qryName, "[^a-zA-Z0-9_]", "", "ALL")>

                    <!--- Generate new query filename --->
                    <cfquery result="result" name="getNextId" datasource="#application.dsn#">
                        SELECT IFNULL(MAX(id), 0) + 1 AS nextId FROM tao_files
                    </cfquery>

                    <cfset newQueryFilename = qryNameSanitized & "_" & getNextId.nextId & "_" & counter & ".cfm">

                    <!--- Write the extracted query to a new file --->
                    <cfset newQueryFilePath = "C:/home/theactorsoffice.com/extracted/include/qry/#newQueryFilename#">
                    <cffile action="write" file="#newQueryFilePath#" output="#fullQueryBlock#">

                    <cfoutput>QRY filename created: #newQueryFilename#<br></cfoutput>

                  <!--- Replace the specific cfquery block with the cfinclude tag --->
<cfset cfIncludeTag = '<cfinclude template="/include/qry/#newQueryFilename#" />'>

<!--- Correct Mid() function usage with a calculated length --->
<cfset fileContent = Left(fileContent, startQuery - 1) & cfIncludeTag & Mid(fileContent, endQuery + 1, Len(fileContent) - endQuery)>


                    <!--- Update startPos to continue searching after the cfinclude tag --->
                    <cfset startPos = startQuery + Len(cfIncludeTag)>

                    <!--- Extract query details --->
                    <cfset qryDetails = trim(strippedQueryBlock)>

                    <!--- Determine query type --->
                    <cfset qryTypePattern = "^(SELECT|INSERT|UPDATE|DELETE)">
                    <cfset qryTypePosition = REFindNoCase(qryTypePattern, strippedQueryBlock)>
                    <cfif qryTypePosition GT 0>
                        <cfset qry_Type = UCase(mid(strippedQueryBlock, qryTypePosition, 6))>
                    <cfelse>
                        <cfset qry_Type = "UNKNOWN">
                    </cfif>

                    <!--- Determine table name based on query type --->
                    <cfif qry_Type EQ "SELECT" OR qry_Type EQ "DELETE">
                        <cfset fromPos = FindNoCase("FROM ", strippedQueryBlock)>
                        <cfif fromPos GT 0>
                            <!--- Calculate maxLength to avoid negative count --->
                            <cfset maxLength = len(strippedQueryBlock) - (fromPos + 4)>
                            <cfif maxLength GT 0>
                                <cfset tableName = ListFirst(
                                    mid(
                                        strippedQueryBlock,
                                        fromPos + 5,
                                        maxLength
                                    ),
                                    " "
                                )>
                            <cfelse>
                                <cfset tableName = "UNKNOWN">
                            </cfif>
                        <cfelse>
                            <cfset tableName = "UNKNOWN">
                        </cfif>
                    <cfelseif qry_Type EQ "UPDATE">
                        <cfset updatePos = FindNoCase("UPDATE ", strippedQueryBlock)>
                        <cfif updatePos GT 0>
                            <cfset maxLength = len(strippedQueryBlock) - (updatePos + 6)>
                            <cfif maxLength GT 0>
                                <cfset tableName = ListFirst(
                                    mid(
                                        strippedQueryBlock,
                                        updatePos + 7,
                                        maxLength
                                    ),
                                    " "
                                )>
                            <cfelse>
                                <cfset tableName = "UNKNOWN">
                            </cfif>
                        <cfelse>
                            <cfset tableName = "UNKNOWN">
                        </cfif>
                    <cfelseif qry_Type EQ "INSERT">
                        <cfset insertPos = FindNoCase("INSERT INTO ", strippedQueryBlock)>
                        <cfif insertPos GT 0>
                            <cfset maxLength = len(strippedQueryBlock) - (insertPos + 11)>
                            <cfif maxLength GT 0>
                                <cfset tableName = ListFirst(
                                    mid(
                                        strippedQueryBlock,
                                        insertPos + 12,
                                        maxLength
                                    ),
                                    " "
                                )>
                            <cfelse>
                                <cfset tableName = "UNKNOWN">
                            </cfif>
                        <cfelse>
                            <cfset tableName = "UNKNOWN">
                        </cfif>
                    <cfelse>
                        <cfset tableName = "UNKNOWN">
                    </cfif>

                    <cfset tableName = trim(tableName)>

                    <!--- Clean qryDetails --->
                    <cfset qryDetails = REReplace(qryDetails, "[\s]+", " ", "ALL")>

                    <!--- Insert into database --->
                    <cfquery result="result" datasource="#application.dsn#">
                        INSERT INTO tao_files (
                            filename,
                            status,
                            `path`,
                            qry_removed_yn,
                            qry_extract_yn,
                            qry_details,
                            qry_table,
                            qry_type,
                            parent_id,
                            qry_no
                        ) VALUES (
                            <cfqueryparam value="#newQueryFilename#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="new" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="/include/qry" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">,
                            <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">,
                            <cfqueryparam value="#qryDetails#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#tableName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#qry_Type#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#getFiles.id#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="1" cfsqltype="cf_sql_integer">
                        )
                    </cfquery>
                </cfif>
            <cfelse>
                <!--- No more queries found, break loop --->
                <cfbreak>
            </cfif>
        </cfloop>

        <!--- Save the modified main file to the correct directory --->
        <cfset newMainFilePath = "C:/home/theactorsoffice.com/extracted/include/#getFiles.filename#">
        <cffile action="write" file="#newMainFilePath#" output="#fileContent#">

        <!--- Mark file as processed --->
        <cfquery result="result" datasource="#application.dsn#">
            UPDATE tao_files
            SET qry_extract_yn = 1
            WHERE id = <cfqueryparam value="#getFiles.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Output result based on whether queries were processed --->
        <cfif counter GT 0>
            <cfoutput>File modified: #getFiles.filename#<br></cfoutput>
        <cfelse>
            <cfoutput>File not modified: #getFiles.filename#<br></cfoutput>
        </cfif>
    </cfif>
</cfloop>
