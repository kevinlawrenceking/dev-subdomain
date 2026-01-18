 <cfquery result="result" name="getQryFilesWithoutParents" datasource="abod">
    SELECT id, `filename`, `path`
from `tao_files` where isapp = 0
 and path = '/include'
   
      AND (parents IS NULL OR parents = '')
</cfquery>

<cfloop query="getQryFilesWithoutParents">
    <!--- Get the filename of the query file --->
    <cfset qryFilename = getQryFilesWithoutParents.filename>
    <cfset parentIds = "">

    <!--- Now loop through all files in /include and look for this query filename via cfinclude --->
    <cfquery result="result" name="getIncludeFiles" datasource="abod">
        SELECT id, `filename`, `path`
        FROM tao_files
        WHERE `path` = '/include'
    </cfquery>

    <cfloop query="getIncludeFiles">
        <!--- Get the content of the /include file --->
        <cfset fullFilePath = "C:/home/theactorsoffice.com/optimized/include/#getIncludeFiles.filename#">

        <cfif fileExists(fullFilePath)>
            <cfset fileContent = ToString(fileRead(fullFilePath))>

<cfif REFindNoCase("#qryFilename#", fileContent)>
                
                <cfif len(parentIds) EQ 0>
                    <!--- Start the list if it's the first parent found --->
                    <cfset parentIds = getIncludeFiles.id>
                <cfelse>
                    <!--- Append the id to the existing list --->
                    <cfset parentIds = listAppend(parentIds, getIncludeFiles.id)>
                </cfif>
            </cfif>
        </cfif>
    </cfloop>
 
    <cfif len(parentIds) GT 0>
        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET parents = <cfqueryparam value="#parentIds#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#getQryFilesWithoutParents.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfoutput>
            QRY File: #qryFilename# | Parent IDs: #parentIds#<br>
        </cfoutput>
    <cfelse>
        <cfoutput>
            QRY File: #qryFilename# | No parents found.<br>
        </cfoutput>
    </cfif>
</cfloop>
