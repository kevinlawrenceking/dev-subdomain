      <cfquery result="result" name="getReplacementFiles" datasource="abod">
    SELECT b.id AS bad_id, b.filename AS bad_filename, b.parents, b.replacement_id, 
           g.id AS good_id, g.filename AS good_filename
    FROM tao_files b 
    INNER JOIN tao_files g ON g.id = b.replacement_id
    WHERE b.status = 'deleted' 
    AND b.parents <> ''
</cfquery>

<cfloop query="getReplacementFiles">

    <cfset parentIDs = listToArray(getReplacementFiles.parents, ",")>

    <cfloop array="#parentIDs#" index="parentID">

<!--- Get the parent file details --->
        <cfquery result="result" name="getParentFile" datasource="abod">
            SELECT id, path, filename
            FROM tao_files
            WHERE id = <cfqueryparam value="#parentID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <Cfoutput>getParentFile: #getParentFile.filename#<br/></cfoutput>

        <!--- Construct the full path to the parent file --->
        <cfset parentFilePath = "C:/home/theactorsoffice.com/optimized" & getParentFile.path & "/" & getParentFile.filename>
<cfoutput>parentFilePath: #parentFilePath#<br/></cfoutput>
        <!--- Check if the parent file exists --->
        <cfif fileExists(parentFilePath)>
            <!--- Read the parent file content --->
            <cfset parentFileContent = fileRead(parentFilePath)>
file exists!<BR>
            <!--- Replace any instance of the bad filename with the good filename --->
            <cfset updatedFileContent = replace(parentFileContent, getReplacementFiles.bad_filename, getReplacementFiles.good_filename, "ALL")>

            <!--- Save the updated file to the extracted directory --->
            <cfset savePath = "C:/home/theactorsoffice.com/extracted" & getParentFile.path & "/" & getParentFile.filename>
            <Cfoutput>savePath: #savePath#<br/></cfoutput>
            
            <cffile action="write" file="#savePath#" output="#updatedFileContent#">

            <cfoutput>Updated parent file saved: #savePath#<br/></cfoutput>
        </cfif>
    </cfloop>

</cfloop>
