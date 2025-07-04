<cfquery result="result" name="getColumns" datasource="abod">
    SELECT TABLE_NAME, COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'new_development'
    AND (DATA_TYPE = 'varchar' OR DATA_TYPE = 'text');
</cfquery>

<cfset tablesWithMatches = []>

<cfloop query="getColumns">
    <cfset dynamicQuery = "SELECT *  FROM new_development.#getColumns.TABLE_NAME# WHERE `#getColumns.COLUMN_NAME#` 
    LIKE #chr(39)#%.cfm#chr(39)#">
 
<Cfoutput>   #dynamicQuery#;<BR></cfoutput>

</cfloop>
 
