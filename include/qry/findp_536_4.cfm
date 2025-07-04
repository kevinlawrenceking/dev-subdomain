<!--- This ColdFusion page retrieves the primary key field of the current table from the allfields query. --->
<cfquery dbtype="query" name="findp">
    <!--- Find the primary key field of the current table. --->
    SELECT *
    FROM allfields
    WHERE [key] = 'PRI'
</cfquery>
