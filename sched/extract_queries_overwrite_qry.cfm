<cfquery result="result" name="getFilesWithMultipleQueries" datasource="abod">
SELECT * FROM `tao_files` WHERE path = '/include/qry' and qry_no > 1
</cfquery>

<cfloop query="getFilesWithMultipleQueries">
    <!--- Define the file path in the optimized folder --->
    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized/include/qry/#getFilesWithMultipleQueries.filename#">
    
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

                <!--- Create a new file name for each optimized cfquery block --->
                <cfset newQueryFilename = "qry_block_" & getFilesWithMultipleQueries.id & "_" & counter & ".cfm">

                <!--- Save the optimized query to /optimized/qry --->
                <cfset newQueryFilePath = "C:/home/theactorsoffice.com/optimized/include/qry/#newQueryFilename#">
                <cffile action="write" file="#newQueryFilePath#" output="#fullQueryBlock#>" >

                <cfoutput>QRY filename created: #newQueryFilename#<br></cfoutput>

                <!--- Replace the cfquery block in the original file with a cfinclude tag --->
                <cfset cfIncludeTag = '<cfinclude template="/optimized/qry/#newQueryFilename#" />'>
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

        <!--- Save the modified file to /optimized/cfinclude --->
        <cfif queryFound>
            <cfset newMainFilePath = "C:/home/theactorsoffice.com/optimized/include/qry/#getFilesWithMultipleQueries.filename#">
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

<cfquery result="result" name="getAllIncludeFiles" datasource="abod">
    SELECT id, `filename`, `path`
    FROM tao_files
    WHERE path = '/include/qry'
</cfquery>

<cfloop query="getAllIncludeFiles">
    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized/include/qry/#getAllIncludeFiles.filename#">

    <cfif fileExists(fullFilePath)>
        <!--- Read the content of the file --->
        <cfset fileContent = ToString(fileRead(fullFilePath))>

        <!--- Count the number of <cfquery result="result"> blocks --->
        <cfset qryCount = ArrayLen(REMatchNoCase("<cfquery\b[^>]*>", fileContent))>

        <!--- Update the tao_files table with the qry_count (qry_no) --->
        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET qry_no = <cfqueryparam value="#qryCount#" cfsqltype="cf_sql_integer">
            WHERE id = <cfqueryparam value="#getAllIncludeFiles.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Output the result for debugging (optional) --->
        <cfoutput>
            File: #getAllIncludeFiles.filename# | Number of Queries: #qryCount#<br>
        </cfoutput>
    </cfif>
</cfloop>

