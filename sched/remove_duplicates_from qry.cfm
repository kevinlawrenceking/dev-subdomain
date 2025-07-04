    <cfquery result="result" name="getFilesWithComments" datasource="abod">
    SELECT id, qry_details
    FROM tao_files
    WHERE qry_details LIKE '%--- %'
</cfquery>

<cfloop query="getFilesWithComments">
    <!--- Use REReplace to remove the entire comment block, including the text inside it --->
    <cfset cleanQryDetails = REReplace(getFilesWithComments.qry_details, "--- (.*?) ---", "", "ALL")>

    <!--- Update the tao_files table with the cleaned qry_details --->
    <cfquery result="result" datasource="abod">
        UPDATE tao_files
        SET qry_details = <cfqueryparam value="#TRIM(QryDetails)#" cfsqltype="cf_sql_longvarchar">
        WHERE id = <cfqueryparam value="#getFilesWithComments.id#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfloop>
