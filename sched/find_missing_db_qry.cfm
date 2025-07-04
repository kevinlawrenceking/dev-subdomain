<!--- Get a list of files in /extracted/include/qry --->
<cfdirectory action="list" directory="C:/home/theactorsoffice.com/extracted/include/qry" name="fileList">

<cfloop query="fileList">
    <!--- Check if the file already exists in tao_files --->
    <cfquery result="result" name="checkFileExists" datasource="abod">
        SELECT id
        FROM tao_files
        WHERE filename = <cfqueryparam value="#fileList.name#" cfsqltype="cf_sql_varchar">
        AND path = '/include/qry'
    </cfquery>

    <!--- If file doesn't exist in the database, insert it --->
    <cfif checkFileExists.recordcount EQ 0>
        <cfquery result="result" datasource="abod">
            INSERT INTO tao_files (
                filename,
                status,
                `path`,
                qry_removed_yn,
                qry_extract_yn,
                qry_details,
                qry_table,
                qry_type,
                parent_id
            ) VALUES (
                <cfqueryparam value="#fileList.name#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="new" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="/include/qry" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">,
                <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">,
                <cfqueryparam value="" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="UNKNOWN" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="0" cfsqltype="cf_sql_integer">
            )
        </cfquery>

        <!--- Output that a new file has been inserted --->
        <cfoutput>
            Inserted new record for file: #fileList.name#<br>
        </cfoutput>
    <cfelse>
        <!--- Output that the file already exists --->
        <cfoutput>
            File already exists: #fileList.name#<br>
        </cfoutput>
    </cfif>
</cfloop>
