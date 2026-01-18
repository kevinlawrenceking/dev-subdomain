<cfset qryDir = "C:/home/theactorsoffice.com/optimized/include/qry">
<cfset fileList = directoryList(qryDir, false, "files")>

<!--- Fetch the filenames from the database --->
<cfquery result="result" name="getDbFiles" datasource="abod">
    SELECT filename
    FROM tao_files
    WHERE path = '/include/qry'
</cfquery>

<!--- Convert the database result to an array --->
<cfset dbFilesArray = ValueList(getDbFiles.filename)>

<!--- Find missing files (in directory but not in DB) --->
<cfset missingFiles = ArrayNew(1)>

<cfloop array="#fileList#" index="dirFile">
    <!--- Extract the filename from the directory path --->
    <cfset fileName = listLast(dirFile, "/")>

    <!--- Check if the file from the directory is in the DB files array --->
    <cfif NOT ListFindNoCase(dbFilesArray, fileName)>
        <cfset ArrayAppend(missingFiles, fileName)>
    </cfif>
</cfloop>

<!--- Insert missing files into the database --->
<cfloop array="#missingFiles#" index="file">

<cfquery result="result" datasource="abod">
        INSERT INTO tao_files (filename, status, path, updated_timestamp)
        VALUES (
            <cfqueryparam value="#file#" cfsqltype="cf_sql_varchar" maxlength="255">,
            <cfqueryparam value="existing" cfsqltype="cf_sql_varchar" maxlength="20">,
            <cfqueryparam value="/include/qry" cfsqltype="cf_sql_varchar" maxlength="255">,
            NOW()
        );
    </cfquery>
</cfloop>

<cfoutput>Missing files inserted successfully.</cfoutput>
