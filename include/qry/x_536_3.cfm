<!--- This ColdFusion page filters fields from the allfields query excluding primary keys and auto-increment fields. --->
<cfquery dbtype="query" name="x">
    <!--- Select all fields from the allfields query while applying filters. --->
    SELECT *
    FROM allfields
    WHERE [key] <> 'pri' 
      AND [extra] <> 'auto_increment'
</cfquery>
