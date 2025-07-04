<!--- This ColdFusion page queries the pgfields table to find records based on the provided pgid and a specific updatename. --->

<cfquery name="FindKey">
    <!--- Query the pgfields table for records matching the specified pgid and updatename 'ID' --->
    SELECT * 
    FROM pgfields 
    WHERE pgid = #rpgid# 
    AND updatename = 'ID'
</cfquery>
