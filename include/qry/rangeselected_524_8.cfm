<!--- This ColdFusion page retrieves a specific report range based on the provided range ID. --->

<cfquery name="rangeselected">
    <!--- Query to select range details from the reportranges table based on the new_rangeid. --->
    SELECT 
        rangeid, 
        rangename, 
        rangestart, 
        rangeend 
    FROM 
        reportranges 
    WHERE 
        rangeid = #new_rangeid#
</cfquery>
