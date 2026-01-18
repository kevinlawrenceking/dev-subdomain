<cfquery result="result" name="getFilesWithBlankDetails" datasource="abod">
SELECT id, `path`, `filename`,qry_no FROM tao_files
WHERE (qry_details IS NULL OR qry_details = '') 
AND path = '/include/qry' and qry_no > 0 and status <> 'deleted'
ORDER BY `tao_files`.`qry_no` DESC
</cfquery>

<cfloop query="getFilesWithBlankDetails">
    <!--- Define the file path in the optimized directory ---> 
    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized/include/qry/#getFilesWithBlankDetails.filename#">
    <cfoutput>
        File path: #fullFilePath#<br></cfoutput>
    <!--- Check if the file exists ---> 
    <cfif fileExists(fullFilePath)>
        <!--- Read the file content ---> 
        <cfset fileContent = fileRead(fullFilePath)>
        
        <!--- Find the <cfquery result="result"> block ---> 
        <cfset startQuery = REFindNoCase("<cfquery\b[^>]*>", fileContent)>
        <cfset endQuery = REFindNoCase("</cfquery>", fileContent)>
        
        <!--- Ensure valid start and end of the query ---> 
        <cfif startQuery GT 0 AND endQuery GT startQuery>
            <!--- Remove the <cfquery result="result"> and </cfquery> tags ---> 
            <cfset queryStart = FindNoCase(">", fileContent, startQuery)>
            <cfset strippedQueryBlock = trim(mid(fileContent, queryStart + 1, endQuery - (queryStart + 1)))>
                <cfoutput>
        strippedQueryBlock: #strippedQueryBlock#<br></cfoutput>
            <!--- Clean the query by removing extra spaces ---> 
            <cfset cleanQuery = REReplace(strippedQueryBlock, "[\s]+", " ", "ALL")>
            
            <!--- Insert the cleaned query into the database ---> 
            <cfquery result="result" datasource="abod">
                UPDATE tao_files
                SET qry_details = <cfqueryparam value="#cleanQuery#" cfsqltype="cf_sql_varchar">
                WHERE id = <cfqueryparam value="#getFilesWithBlankDetails.id#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <!--- Output confirmation ---> 
            <cfoutput>
                File processed: #getFilesWithBlankDetails.filename#<br>
                Query extracted and cleaned.<br>
            </cfoutput>
        <cfelse>
            <!--- No valid query block found ---> 
            <cfoutput>
                No valid query found in file: #getFilesWithBlankDetails.filename#<br>
            </cfoutput>
        </cfif>
    <cfelse>
        <!--- File not found ---> 
        <cfoutput>
            File not found: #getFilesWithBlankDetails.filename#<br>
        </cfoutput>
    </cfif>
</cfloop>
