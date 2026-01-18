<cfquery result="result" name="getDistinctTables" datasource="abod">
    SELECT DISTINCT qry_table 
    FROM tao_files 
    WHERE qry_table IS NOT NULL;
</cfquery>

<cfloop query="getDistinctTables">

<!--- Insert into components table --->
    <cfquery result="result" datasource="abod">
        INSERT INTO models (tableName)
        VALUES (
          
            <cfqueryparam value="#getDistinctTables.qry_table#" cfsqltype="cf_sql_varchar">
      
        )
    </cfquery>
</cfloop>
