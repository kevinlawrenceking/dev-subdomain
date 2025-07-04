<!--- This ColdFusion page retrieves system IDs from the fusystems table based on a specific system type and scope. --->

<cfquery name="findSystem">
    <!--- Query to select system IDs from the fusystems table based on system type and scope --->
    Select s.systemid
    from fusystems s
    where s.systemtype = 'Maintenance List' 
      and s.systemscope = '#newsystemscope#'
</cfquery>
