<cfset use_path = "/include">
<cfset qry_path = "/include/qry">
<cfset path_prefix = "C:/home/theactorsoffice.com/optimized">

<cfset includeDir = "#path_prefix##use_path#">
<cfoutput>INCLUDEDIR: #includeDir#<BR></cfoutput>
<cfset qryDir = "#path_prefix##qry_path#">
<cfoutput>QRYDIR: #qryDir#<BR></cfoutput>

<!--- Get the list of files in the /include directory (only files, ignoring subfolders) --->
<cftry>
    <cfset fileList = directoryList(includeDir, false, "query")>
    <cfoutput>File list fetched successfully.<br></cfoutput>
<cfcatch type="any">
    <cfoutput>Error fetching file list: #cfcatch.message#<br></cfoutput>
    <cfoutput>Error detail: #cfcatch.detail#<br></cfoutput>
</cfcatch>
</cftry>

<!--- Loop through the files in the /include directory --->
<cfif structKeyExists(variables, "fileList")>
    <cfloop query="fileList">
        <!--- Check if the current item is a file (not a directory) --->
        <cfif fileList.type EQ "file">
            <!--- Extract filename from the full file path --->
            <cfset filename = listLast(fileList.name, "/")>
            <cfoutput>Filename: #filename#<BR></cfoutput>
            
            <!--- Try to insert each file into the database --->
            <cftry>
                <cfquery result="result" datasource="abod">
                    INSERT INTO tao_files (`filename`, `status`, `path`, `updated_timestamp`)
                    VALUES (
                        <cfqueryparam value="#filename#" cfsqltype="cf_sql_varchar" maxlength="255">,
                        <cfqueryparam value="existing" cfsqltype="cf_sql_varchar" maxlength="20">,
                        <cfqueryparam value="#use_path#" cfsqltype="cf_sql_varchar" maxlength="255">,
                        NOW()
                    );
                </cfquery>
                <cfcatch type="any">
                    <!--- Catch any error but continue with the next file --->
                    <cfoutput>Error inserting #filename#: #cfcatch.message#<br></cfoutput>
                    <cfoutput>Error details: #cfcatch.detail#<br></cfoutput>
                    <cfoutput>Tag context: #cfcatch.tagContext[1].template#: Line #cfcatch.tagContext[1].line#<br></cfoutput>
                </cfcatch>
            </cftry>
        </cfif>
    </cfloop>
</cfif>

<!--- Now loop through the /include/qry directory --->
<cftry>
    <cfset fileListQry = directoryList(qryDir, false, "query")>
    <cfoutput>Qry file list fetched successfully.<br></cfoutput>
<cfcatch type="any">
    <cfoutput>Error fetching qry file list: #cfcatch.message#<br></cfoutput>
    <cfoutput>Error detail: #cfcatch.detail#<br></cfoutput>
</cfcatch>
</cftry>

<!--- Loop through the files in /include/qry directory --->
<cfif structKeyExists(variables, "fileListQry")>
    <cfloop query="fileListQry">
        <!--- Check if the current item is a file (not a directory) --->
        <cfif fileListQry.type EQ "file">
            <!--- Extract filename from the full file path --->
            <cfset filename = listLast(fileListQry.name, "/")>
            <cfoutput>Filename: #filename#<BR></cfoutput>
            
            <!--- Try to insert each file into the database --->
            <cftry>
                <cfquery result="result" datasource="abod">
                    INSERT INTO tao_files (`filename`, `status`, `path`, `updated_timestamp`)
                    VALUES (
                        <cfqueryparam value="#filename#" cfsqltype="cf_sql_varchar" maxlength="255">,
                        <cfqueryparam value="existing" cfsqltype="cf_sql_varchar" maxlength="20">,
                        <cfqueryparam value="#qry_path#" cfsqltype="cf_sql_varchar" maxlength="255">,
                        NOW()
                    );
                </cfquery>
                <cfcatch type="any">
                    <!--- Catch any error but continue with the next file --->
                    <cfoutput>Error inserting #filename#: #cfcatch.message#<br></cfoutput>
                    <cfoutput>Error details: #cfcatch.detail#<br></cfoutput>
                    <cfoutput>Tag context: #cfcatch.tagContext[1].template#: Line #cfcatch.tagContext[1].line#<br></cfoutput>
                </cfcatch>
            </cftry>
        </cfif>
    </cfloop>
</cfif>

<cfoutput>Insert complete.</cfoutput>
