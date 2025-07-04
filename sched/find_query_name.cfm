<cfquery result="result" name="getFiles" datasource="abod">
    SELECT `id`, `path`, `filename`
    FROM `tao_files`
    WHERE `qry_no` = 1 AND qry_name IS NULL
</cfquery>

<cfloop query="getFiles">
    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized#path#/#filename#">

    <!--- Check if the file exists before reading --->
    <cfif fileExists(fullFilePath)>
        <cfset fileContent = fileRead(fullFilePath)>

        <cfoutput>Processing file: #filename#<br/></cfoutput>

        <!--- Find the position of the 'name' attribute in the query --->
        <cfset nameStart = FindNoCase('name="', fileContent)>

        <!--- If 'name' is found in the file, extract the query name --->
        <cfif nameStart GT 0>
            <!--- Start of the query name --->
            <cfset nameStart = nameStart + 6> <!--- Moving past 'name="' --->

            <!--- Find the position of the closing quote --->
            <cfset nameEnd = FindNoCase('"', fileContent, nameStart)>

            <!--- Extract the query name --->
            <cfset extractedQueryName = Mid(fileContent, nameStart, nameEnd - nameStart)>

            <!--- Clean up whitespace (if any) --->
            <cfset extractedQueryName = Trim(extractedQueryName)>

            <cfoutput>Extracted query name: #extractedQueryName#<br/></cfoutput>

            <!--- Update the database with the extracted query name --->
            <cfquery result="result" datasource="abod">
                UPDATE tao_files
                SET qry_name = <cfqueryparam value="#extractedQueryName#" cfsqltype="cf_sql_varchar" maxlength="255">
                WHERE id = <cfqueryparam value="#getFiles.id#" cfsqltype="cf_sql_integer">
            </cfquery>
        <cfelse>
            <cfoutput>No query name found for file: #filename#<br/></cfoutput>
        </cfif>
    <cfelse>
        <cfoutput>File not found: #fullFilePath#<br/></cfoutput>
    </cfif>
</cfloop>
