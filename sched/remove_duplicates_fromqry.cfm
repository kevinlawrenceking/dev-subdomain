 <cfquery result="result" name="getDuplicateQueries" datasource="abod">
    SELECT qry_details, COUNT(*) AS total_count
    FROM tao_files
    WHERE (qry_details IS NOT NULL AND qry_details <> '')
    AND path = '/include/qry'
    GROUP BY qry_details
    HAVING COUNT(*) > 1
    ORDER BY total_count DESC
</cfquery>

<cfloop query="getDuplicateQueries">
    <!--- Get all files with the current qry_details --->
    <cfquery result="result" name="getFilesForQuery" datasource="abod">
        SELECT id, parents
        FROM tao_files
        WHERE qry_details = <cfqueryparam value="#getDuplicateQueries.qry_details#" cfsqltype="cf_sql_longvarchar">
    </cfquery>

    <!--- Choose the first file to keep --->
    <cfset chosenFileId = getFilesForQuery.id[1]>

    <cfloop from="2" to="#getFilesForQuery.recordcount#" index="i">
        <!--- Update the status of duplicate files to "deleted" --->
        <cfquery result="result" datasource="abod">
            UPDATE tao_files
            SET status = 'deleted'
            WHERE id = <cfqueryparam value="#getFilesForQuery.id[i]#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- Find and update parent files to point to the chosen file --->
        <cfquery result="result" name="getParentFiles" datasource="abod">
            SELECT id, parents
            FROM tao_files
            WHERE FIND_IN_SET(<cfqueryparam value="#getFilesForQuery.id[i]#" cfsqltype="cf_sql_integer">, parents)
        </cfquery>

        <cfloop query="getParentFiles">
            <!--- Check if the parent list contains the duplicate file ID --->
            <cfif ListFind(getParentFiles.parents, getFilesForQuery.id[i])>
                <!--- Replace the duplicate file ID in the parents list with the chosen file ID --->
                <cfset newParents = ListReplace(getParentFiles.parents, getFilesForQuery.id[i], chosenFileId)>

                <!--- Update the parent file's parents field --->
                <cfquery result="result" datasource="abod">
                    UPDATE tao_files
                    SET parents = <cfqueryparam value="#newParents#" cfsqltype="cf_sql_varchar">
                    WHERE id = <cfqueryparam value="#getParentFiles.id#" cfsqltype="cf_sql_integer">
                </cfquery>
            </cfif>
        </cfloop>
    </cfloop>
</cfloop>
