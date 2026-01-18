<cfquery result="result" name="getDeletedFiles" datasource="abod">    
SELECT `id`, `filename`, `path`
    FROM `tao_files`
    WHERE `status` = 'deleted' and path='/include/qry'
</cfquery>

<cfloop query="getDeletedFiles">

<cfset sourceFilePath = "C:/home/theactorsoffice.com/optimized#path#/#filename#">
    <cfset destinationFilePath = "C:/home/theactorsoffice.com/extracted/deleted#path#/#filename#">

<CFOUTPUT>
SOURCEFILEPATH: #sourceFilePath#<br>
DESTINATIONFILEPATH: #destinationFilePath#<br>

</CFOUTPUT>
 
    <cfif fileExists(sourceFilePath)>

<cfset destinationDirectory = getDirectoryFromPath(destinationFilePath)>

<cffile action="move" source="#sourceFilePath#" destination="#destinationFilePath#" />

<cfoutput>Moved file: #filename# to #destinationFilePath#<br></cfoutput>
<cfoutput>path: /extracted/deleted#path#<br></cfoutput>
 
        <cfquery result="result" name="move" datasource="abod">    
           UPDATE `tao_files`
           SET path = '/extracted/deleted#path#'
           WHERE `id` = <cfqueryparam value="#getDeletedFiles.id#" cfsqltype="cf_sql_integer">
        </cfquery>

    <cfelse>
 
        <cfoutput>File not found: #sourceFilePath#<br></cfoutput>
    </cfif>

</cfloop>
