<cfparam name="dbug" default="0" />

<cfset path_prefix = "C:/home/theactorsoffice.com/optimized">
<cfset path_save = "C:/home/theactorsoffice.com/extracted"> 
<cfset use_path = "/include">
<cfset qry_path = "/include/qry">

<cfquery result="result" name="getFiles" datasource="abod" maxrows="3">
    SELECT id, `path`, `filename`
    FROM tao_files
    WHERE path = '/include'
    and qry_extract_yn = 0
    ORDER BY `filename`
</cfquery>
 
<cfloop query="getFiles">
    
    <cfset fullFilePath = "#path_prefix##use_path#/#getFiles.filename#">

</cfloop>

<cfif #originalFileContent# is not "#fileContent#">
            <cfset newMainFilePath = "#path_save##use_path#/#getFiles.filename#">
            
        </cfif>

