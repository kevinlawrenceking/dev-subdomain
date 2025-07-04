<cfquery result="result" name="getColumnDetails" datasource="abod">
    SELECT 
        c.COLUMN_NAME,                          -- The name of the column
        c.DATA_TYPE,                            -- The data type of the column
        c.IS_NULLABLE,                          -- Indicates if the column allows NULL values
        c.COLUMN_DEFAULT,                       -- The default value of the column
        c.EXTRA,                                -- Extra information like 'auto_increment'
        m.CF_PARAM_TYPE                         -- The corresponding cfqueryparam type from your mapping
    FROM 
        information_schema.columns c
    LEFT JOIN 
        new_development.cfqueryparam_matrix m ON c.DATA_TYPE = m.DATA_TYPE
    WHERE 
        c.table_schema = 'new_development'   -- Replace with your actual database name
        AND c.table_name = 'vm_contactitems_social_profile'    -- Replace with your actual table name
    ORDER BY 
        c.ORDINAL_POSITION;
</cfquery>

<cfoutput>
    <h3>Column Details for Table: your_table_name</h3>
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
</cfoutput>
