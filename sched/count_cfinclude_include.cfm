<cfquery result="result" name="getAllIncludeFiles" datasource="abod">
    SELECT id, `filename`, `path`
    FROM tao_files
    WHERE path = '/include'
</cfquery>

<cfloop query="getAllIncludeFiles">
    <!--- Construct the full file path --->
    <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized/include/#getAllIncludeFiles.filename#">

    <!--- Check if the file exists --->
    <cfif fileExists(fullFilePath)>

        <!--- Read the content of the file --->
        <cfset fileContent = ToString(fileRead(fullFilePath))>

        <!--- Count occurrences of <cfinclude> using REMatchNoCase --->
        <cfset includeCount = ArrayLen(REMatchNoCase("<cfinclude\b[^>]*>", fileContent))>

        <!--- Update the tao_files.no_includes column with the count --->
        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET no_includes = <cfqueryparam value="#includeCount#" cfsqltype="cf_sql_integer">
            WHERE id = <cfqueryparam value="#getAllIncludeFiles.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Output the filename and number of <cfinclude> tags found --->
        <cfoutput>
            File: #getAllIncludeFiles.filename# | Number of Includes: #includeCount#<br>
        </cfoutput>
    </cfif>
</cfloop>
