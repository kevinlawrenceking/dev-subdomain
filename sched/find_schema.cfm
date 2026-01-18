<!--- Query to get distinct table names from tao_files --->
<cfquery result="result" name="getDistinctTables" datasource="abod">
    SELECT DISTINCT qry_table
    FROM tao_files
    WHERE qry_table IS NOT NULL 
    AND qry_table <> ''
    AND qry_table <> 'Unknown'
</cfquery>

<!--- Loop through each distinct table and get its schema --->
<cfloop query="getDistinctTables">

    <!--- Query to get table schema from information_schema --->
    <cfquery result="result" name="getTableSchema" datasource="abod">
        SELECT COLUMN_NAME, DATA_TYPE, COLUMN_DEFAULT, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = 'new_development' 
        AND TABLE_NAME = <cfqueryparam value="#getDistinctTables.qry_table#" cfsqltype="cf_sql_varchar">
        ORDER BY ORDINAL_POSITION
    </cfquery>

    <!--- Initialize the create_script content for the current table --->
    <cfset createScriptContent = "CREATE TABLE #getDistinctTables.qry_table# (\n">

    <!--- Loop through each column and build the create script --->
    <cfloop query="getTableSchema">
        <cfset columnDef = "#getTableSchema.COLUMN_NAME# #getTableSchema.DATA_TYPE#">

        <!--- Check if the column has a character length limit and append if true --->
        <cfif len(getTableSchema.CHARACTER_MAXIMUM_LENGTH)>
            <cfset columnDef = columnDef & "(" & getTableSchema.CHARACTER_MAXIMUM_LENGTH & ")">
        </cfif>

        <!--- Check if the column can be NULL and append appropriate statement --->
        <cfif getTableSchema.IS_NULLABLE eq "NO">
            <cfset columnDef = columnDef & " NOT NULL">
        <cfelse>
            <cfset columnDef = columnDef & " NULL">
        </cfif>

        <!--- Add the default value if one exists --->
        <cfif not isNull(getTableSchema.COLUMN_DEFAULT)>
            <cfset columnDef = columnDef & " DEFAULT '" & getTableSchema.COLUMN_DEFAULT & "'">
        </cfif>

        <!--- Append the column definition to the create script --->
        <cfset createScriptContent = createScriptContent & "    " & columnDef & ",\n">
    </cfloop>

    <!--- Remove the last comma and close the table definition --->
    <cfset createScriptContent = Left(createScriptContent, Len(createScriptContent) - 2) & "\n);">

    <!--- Insert the table name and schema into the tao_tables table --->
    <cfquery result="result" datasource="abod">
        INSERT INTO tao_tables (qry_table, create_script)
        VALUES (
            <cfqueryparam value="#getDistinctTables.qry_table#" cfsqltype="cf_sql_varchar" maxlength="255">,
            <cfqueryparam value="#createScriptContent#" cfsqltype="cf_sql_varchar">
        )
    </cfquery>

</cfloop>
