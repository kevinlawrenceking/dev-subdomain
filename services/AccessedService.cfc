<cfcomponent displayname="AccessedService" hint="Service to log accessed files">
    
    <!--- Method to log a file if not already logged --->
    <cffunction name="logFile" access="public" returntype="void" output="false" hint="Logs accessed files">
        <cfargument name="path" type="string" required="true" hint="Path to the file">
        <cfargument name="filename" type="string" required="true" hint="Filename of the accessed file">
        
        <!--- Insert the file into the database if it doesn't already exist --->
        <cfquery name="logAccessedFile">
            INSERT INTO AccessedFiles (path, filename)
            SELECT <cfqueryparam value="#arguments.path#" cfsqltype="cf_sql_varchar">,
                   <cfqueryparam value="#arguments.filename#" cfsqltype="cf_sql_varchar">
            WHERE NOT EXISTS (
                SELECT 1 FROM AccessedFiles 
                WHERE path = <cfqueryparam value="#arguments.path#" cfsqltype="cf_sql_varchar">
                  AND filename = <cfqueryparam value="#arguments.filename#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>

 <cfquery name="x">
        delete FROM `AccessedFiles` WHERE filename not like '%.cfm'
        </cfquery>
 <cfquery name="xu">
        UPDATE accessedfiles
SET path = '/qry'
WHERE path LIKE '%include%' AND path LIKE '%qry%';
</cfquery>
 <cfquery name="xu">
UPDATE accessedfiles
SET path = '/include'
WHERE path LIKE '%include%' AND path NOT LIKE '%qry%';
</cfquery>


    </cffunction>

</cfcomponent>
