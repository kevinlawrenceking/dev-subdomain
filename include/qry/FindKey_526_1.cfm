<!--- This page retrieves fields from the pgfields table based on the provided pgid and a specific updatename. --->

<cfquery name="FindKey">
    <!--- Query to select all fields from pgfields where pgid matches the provided value and updatename is 'ID' --->
    SELECT * 
    FROM pgfields 
    WHERE pgid = #pgid# 
      AND updatename = 'ID'
</cfquery>
