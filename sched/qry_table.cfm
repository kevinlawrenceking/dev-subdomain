<!--- Query to select records with UNKNOWN qry_table --->
<cfquery result="result" name="getUnknownTableRecords" datasource="abod">
    SELECT id, qry_details, qry_table, qry_type
    FROM tao_files
    WHERE qry_extract_yn = 1
    AND PATH = '/include/qry'
    AND STATUS = 'existing'
    AND qry_table = 'UNKNOWN'
    ORDER BY qry_table, qry_type, qry_details
</cfquery>

<!--- Loop through each record to find and update qry_table based on qry_type --->
<cfloop query="getUnknownTableRecords">

    <!--- Initialize tableName as UNKNOWN --->
    <cfset tableName = "UNKNOWN">

    <!--- Use the known qry_type to determine the tableName --->
    <cfif getUnknownTableRecords.qry_type EQ "SELECT" OR getUnknownTableRecords.qry_type EQ "DELETE">
        <!--- Table name is after "FROM" --->
        <cfset fromPos = FindNoCase("FROM ", getUnknownTableRecords.qry_details)>
        <cfif fromPos GT 0>
            <cfset tableName = ListFirst(mid(getUnknownTableRecords.qry_details, fromPos + 5, Len(getUnknownTableRecords.qry_details) - fromPos - 4), " ")>
        </cfif>
    <cfelseif getUnknownTableRecords.qry_type EQ "UPDATE">
        <!--- Table name is immediately after "UPDATE" --->
        <cfset updatePos = FindNoCase("UPDATE ", getUnknownTableRecords.qry_details)>
        <cfif updatePos GT 0>
            <cfset tableName = ListFirst(mid(getUnknownTableRecords.qry_details, updatePos + 7, Len(getUnknownTableRecords.qry_details) - updatePos - 6), " ")>
        </cfif>
    <cfelseif getUnknownTableRecords.qry_type EQ "INSERT">
        <!--- Table name is after "INSERT INTO" --->
        <cfset insertPos = FindNoCase("INSERT INTO ", getUnknownTableRecords.qry_details)>
        <cfif insertPos GT 0>
            <cfset tableName = ListFirst(mid(getUnknownTableRecords.qry_details, insertPos + 12, Len(getUnknownTableRecords.qry_details) - insertPos - 11), " ")>
        </cfif>
    </cfif>

    <!--- Trim the table name --->
    <cfset tableName = trim(tableName)>

    <!--- Update the record in tao_files with the new qry_table value --->
    <cfquery result="result" datasource="abod">
        UPDATE tao_files
        SET qry_table = <cfqueryparam value="#tableName#" cfsqltype="cf_sql_varchar">
        WHERE id = <cfqueryparam value="#getUnknownTableRecords.id#" cfsqltype="cf_sql_integer">
    </cfquery>

</cfloop>
