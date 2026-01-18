<!--- This ColdFusion page retrieves the latest version ID from the taoversions table. --->

<cfquery name="find">
    <!--- Query to select the latest version ID from the taoversions table --->
    select verid 
    from taoversions 
    order by verid desc 
    limit 1
</cfquery>
