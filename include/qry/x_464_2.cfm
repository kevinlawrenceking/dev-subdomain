<!--- This ColdFusion page retrieves all fields from the 'allfields' query excluding specific keys. --->
<cfquery dbtype="query" name="x">
    <!--- Select all fields from the 'allfields' query --->
    select *
    from allfields
    WHERE [key] <> 'pri' 
    and [extra] <> 'auto_increment'
</cfquery>
