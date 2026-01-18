<cfset datasource = "abod">

<!--- Query to get the tables ending with '_tbl' --->
<cfquery result="result" name="getTables" datasource="#datasource#">
    SELECT table_name, REPLACE(table_name, '_tbl', '') AS new_table
    FROM information_schema.tables
    WHERE table_schema = 'new_development'
    AND table_name LIKE '%_tbl'
</cfquery>

<!--- Loop through each table and update tao_files accordingly --->
<cfloop query="getTables">
    <cfset fullTableName = getTables.table_name>
    <cfset simplifiedTableName = getTables.new_table>

    <!--- Update tao_files to replace the simplified table name with the actual table name --->
    <cfquery result="result" datasource="#datasource#">
        UPDATE tao_files 
        SET qry_table = <cfqueryparam value="#fullTableName#" cfsqltype="cf_sql_varchar">
        WHERE qry_table = <cfqueryparam value="#simplifiedTableName#" cfsqltype="cf_sql_varchar">
    </cfquery>
</cfloop>

<cfoutput>
    Table update complete. Processed #getTables.recordCount# tables.
</cfoutput>
