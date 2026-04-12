<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page retrieves event types for a specific user from the database. --->

<cfquery name="types">
    SELECT eventtypename 
    FROM eventtypes_user 
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
    ORDER BY eventtypename
</cfquery>
