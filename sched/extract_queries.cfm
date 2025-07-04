<cfquery result="result" name="getFilesWithMultipleQueries" datasource="abod">
    SELECT id, `path`, `filename`,qry_no
    FROM tao_files
    WHERE status <> 'deleted'
      AND qry_removed_yn = 1
      AND path = '/include'
      AND qry_no > 1
      and filename = 'exportcontacts.cfm'
    ORDER BY `filename`
</cfquery>

<cfloop query="getFilesWithMultipleQueries">
    <!--- Define the file path in the optimized folder --->
    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized/include/#getFilesWithMultipleQueries.filename#">
    
    <!--- Check if the file exists --->
    <cfif fileExists(fullFilePath)>
        <!--- Read the file content --->
        <cfset fileContent = ToString(fileRead(fullFilePath))>

        <!--- Loop through the number of queries (qry_no) in the file --->
        <cfset counter = 1>
        <cfset startPos = 1>
        <cfset queryFound = false>

        <cfloop condition="counter LTE getFilesWithMultipleQueries.qry_no">
            <!--- Find the start and end of the cfquery block --->
            <cfset startQuery = REFindNoCase("<cfquery\b[^>]*>", fileContent, startPos)>
            <cfset endQuery = REFindNoCase("</cfquery>", fileContent, startPos)>

            <!--- Check if both the start and end are valid --->
            <cfif startQuery GT 0 AND endQuery GT startQuery>
                <cfset queryFound = true>

                <!--- Extract the full cfquery block --->
                <cfset fullQueryBlock = mid(fileContent, startQuery, (endQuery + 9) - startQuery)>

                <!--- Extract the SQL code from inside the cfquery block --->
                <cfset queryStart = FindNoCase(">", fileContent, startQuery)>
                <cfset strippedQueryBlock = trim(mid(fileContent, queryStart + 1, endQuery - (queryStart + 1)))>

                <!--- Create a new file name for each extracted cfquery block --->
                <cfset newQueryFilename = "qry_block_" & getFilesWithMultipleQueries.id & "_" & counter & ".cfm">

                <!--- Save the extracted query to /extracted/qry --->
                <cfset newQueryFilePath = "C:/home/theactorsoffice.com/extracted/include/qry/#newQueryFilename#">
                <cffile action="write" file="#newQueryFilePath#" output="#fullQueryBlock#>">

                <cfoutput>QRY filename created: #newQueryFilename#<br></cfoutput>

                <!--- Replace the cfquery block in the original file with a cfinclude tag --->
                <cfset cfIncludeTag = '<cfinclude template="/extracted/qry/#newQueryFilename#" />'>
                <cfset fileContent = Replace(fileContent, fullQueryBlock, cfIncludeTag, "ALL")>

                <!--- Move the start position for the next query extraction --->
                <cfset startPos = endQuery + 9>

                <!--- Increment the counter --->
                <cfset counter++>
            <cfelse>
                <!--- No more queries found, break the loop --->
                <cfbreak>
            </cfif>
        </cfloop>

        <!--- Save the modified file to /extracted/cfinclude --->
        <cfif queryFound>
            <cfset newMainFilePath = "C:/home/theactorsoffice.com/extracted/include/#getFilesWithMultipleQueries.filename#">
            <cffile action="write" file="#newMainFilePath#" output="#fileContent#">
            <cfoutput>File modified and saved: #getFilesWithMultipleQueries.filename#<br></cfoutput>
        </cfif>

        <!--- Update the database to mark the file as processed --->
        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET qry_extract_yn = 1
            WHERE id = <cfqueryparam value="#getFilesWithMultipleQueries.id#" cfsqltype="cf_sql_integer">
        </cfquery>
    </cfif>
</cfloop>
