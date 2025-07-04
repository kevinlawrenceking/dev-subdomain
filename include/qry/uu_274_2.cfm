<!--- This ColdFusion page retrieves user information from the taousers table based on the provided userid. --->

<cfquery name="uu">
    <!--- Query to select all columns from the taousers table where userid matches the provided userid. --->
    select * 
    from taousers 
    where userid = #userid#
</cfquery>
