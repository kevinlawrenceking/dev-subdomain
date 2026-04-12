<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page retrieves user information from the taousers table based on the provided userid. --->

<cfquery name="u">
    <!--- Query to select all fields from taousers where userid matches the provided userid. --->
    SELECT * 
    FROM taousers 
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer">
</cfquery>
