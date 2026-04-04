<!--- This ColdFusion page retrieves active ranges from the audageranges table for display. --->

<!--- PERF: Age ranges are reference data; cache for 60 minutes. --->
<cfquery name="ranges" cachedwithin="#createTimeSpan(0,1,0,0)#">
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
