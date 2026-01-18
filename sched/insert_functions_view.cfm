<cfquery result="result" name="getUniqueFunctions" datasource="abod">
SELECT DISTINCT c.id AS component_id, 'SELECT' as qry_type, t.qry_view
FROM tao_files t
INNER JOIN components c ON c.related_table = t.qry_table
WHERE t.qry_view IS NOT NULL 
AND t.function_id IS NULL
</cfquery>

<cfloop query="getUniqueFunctions">
    <!--- Build the function name dynamically --->
    <cfset functionName = "get" & getUniqueFunctions.qry_view />

    <!--- Insert into functions table --->
    <cfquery result="result" datasource="abod">
        INSERT INTO functions (component_id, displayname, qry_type, function_name)
        VALUES (
            <cfqueryparam value="#getUniqueFunctions.component_id#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#functionName#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#getUniqueFunctions.qry_type#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#functionName#" cfsqltype="cf_sql_varchar">
        );
    </cfquery>

    <!--- Retrieve the last inserted function ID --->
    <cfquery result="result" name="getNewFunctionId" datasource="abod" maxrows="1">
        SELECT id from functions order by id desc
    </cfquery>

    <!--- Update tao_files with the new function_id --->
    <cfquery result="result" datasource="abod">
        UPDATE tao_files
        SET function_id = <cfqueryparam value="#getNewFunctionId.id#" cfsqltype="cf_sql_integer">
        WHERE qry_view = <cfqueryparam value="#getUniqueFunctions.qry_view#" cfsqltype="cf_sql_varchar">
    </cfquery>
</cfloop>
