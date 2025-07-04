<cfcomponent displayname="BigBrotherService" hint="Handles operations for BigBrother table" > 
<cffunction output="false" name="INSbigbrother" access="public" returntype="numeric">
    <cfargument name="pgid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="remote_addr" type="string" required="true">
    <cfargument name="query_string" type="string" required="true">
    <cfargument name="remote_host" type="string" required="true">
    <cfargument name="script_name_include" type="string" required="true">
    <cfargument name="contactid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO bigbrother (
            pgid, userid, remote_addr, query_string, remote_host, script_name, contactid, isInclude
        ) VALUES (
            <cfqueryparam value="#arguments.pgid#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#arguments.remote_addr#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.query_string#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.remote_host#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.script_name_include#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.contactid#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="Y" cfsqltype="cf_sql_varchar">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="RESbigbrother" access="public" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            b.id, 
            b.id AS recid, 
            u.recordname AS col1, 
            'User' AS head1, 
            'Date' AS head2, 
            'Time' AS head3, 
            'Page' AS head4, 
            'URL' AS head5, 
            'Contact' AS head6, 
            'IP Address' AS head7, 
            b.timestamp AS col2, 
            DATE_SUB(b.timestamp, INTERVAL 2 HOUR) AS col3, 
            p.pgname AS col4, 
            CONCAT(b.script_name, "?", b.query_string) AS col5, 
            c.recordname AS col6, 
            b.remote_host AS col7
        FROM bigbrother b
        INNER JOIN taousers u ON u.userid = b.userid
        LEFT JOIN pgpages p ON p.pgid = b.pgid
        LEFT JOIN contactdetails c ON c.contactid = b.contactid
        WHERE u.userid <> <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY id DESC
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>