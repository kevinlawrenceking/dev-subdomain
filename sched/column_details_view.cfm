<cfquery result="result" name="tables" datasource="abod">
    SELECT t.id, t.qry_view 
    FROM tao_files t
    WHERE t.qry_table IS NOT NULL 
        AND t.qry_table <> '' 
        AND t.qry_view IS not NULL 
        AND t.tableschema IS null
</cfquery>

<cfloop query="tables">

    <cfset new_view = tables.qry_view />
    <cfset new_id = tables.id />

    <!--- Fetch Column Details for the Current Table --->
    <cfquery result="result" name="getColumnDetails" datasource="abod">
        SELECT 
            c.COLUMN_NAME,                          
            c.DATA_TYPE,                            
            c.IS_NULLABLE,                          
            c.COLUMN_DEFAULT,                       
            c.EXTRA,                                
            m.CF_PARAM_TYPE                         
        FROM 
            information_schema.columns c
        LEFT JOIN 
            new_development.cfqueryparam_matrix m ON c.DATA_TYPE = m.DATA_TYPE
        WHERE 
            c.table_schema = 'new_development'   -- Replace with your actual database name
            AND c.table_name = <cfqueryparam value="#new_view#" cfsqltype="cf_sql_varchar">   
        ORDER BY 
            c.ORDINAL_POSITION;
    </cfquery>

    <!--- Generate Column Data for the Table --->
    <cfsavecontent variable="generatedColumnData"><cfoutput>
        <h3>Column Details for view: '#new_view#'</h3>
        <table border="1">
            <tr>
                <th>Column Name</th>
                <th>Data Type</th>
                <th>CF QueryParam Type</th>
                <th>Nullable</th>
                <th>Default Value</th>
            </tr>
            <cfloop query="getColumnDetails">
                <tr>
                    <td>#getColumnDetails.COLUMN_NAME#</td>
                    <td>#getColumnDetails.DATA_TYPE#</td>
                    <td>#getColumnDetails.CF_PARAM_TYPE#</td>
                    <td>#getColumnDetails.IS_NULLABLE#</td>
                    <td>#getColumnDetails.COLUMN_DEFAULT#</td>
                </tr>
            </cfloop>
        </table>
    </cfoutput></cfsavecontent>

    <!--- Check if column data is not empty before updating --->
    <cfif len(trim(generatedColumnData))>
        <cfquery result="result" name="update" datasource="abod">
            UPDATE tao_files   
            SET tableschema = <cfqueryparam value="#generatedColumnData#" cfsqltype="CF_SQL_LONGVARCHAR">
            WHERE id = <cfqueryparam value="#new_id#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cfif>

</cfloop>
