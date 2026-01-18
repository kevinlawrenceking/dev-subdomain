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
