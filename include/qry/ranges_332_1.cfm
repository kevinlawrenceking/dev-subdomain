<!--- This ColdFusion page retrieves active ranges from the audageranges table for display. --->

<cfquery name="ranges">
    <!--- Query to select range ID and name from audageranges where isdeleted is false, ordered by range ID. --->
    SELECT 
        rangeid,
        rangename 
    FROM 
        audageranges 
    WHERE 
        isdeleted IS FALSE
    ORDER BY 
        rangeid
</cfquery>
