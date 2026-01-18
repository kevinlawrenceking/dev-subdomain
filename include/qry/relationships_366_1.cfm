<!--- This ColdFusion page retrieves contact details for the logged-in user, excluding empty record names, and orders the results by contact full name. --->

<cfquery name="relationships">
    <!--- Query to select contact details for the current user --->
    select * 
    from contactdetails d 
    where recordname <> '' 
      and userid = #userid# 
    order by d.contactfullname
</cfquery>
