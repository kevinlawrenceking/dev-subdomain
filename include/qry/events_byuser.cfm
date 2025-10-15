<!--- This ColdFusion page retrieves event data for a specific user based on their ID and related contacts. --->

<cfinclude template="/include/qry/events_472_1.cfm" />

<!--- Additional check for currentid to filter events - this SQL fragment should be integrated into the main query in events_472_1.cfm --->
<cfif isDefined('currentid')>
    <!--- 
    This SQL fragment should be added to the main query in events_472_1.cfm:
    AND e.eventid IN (
        SELECT eventid 
        FROM eventcontactsxref 
        WHERE contactid = <cfqueryparam value="#currentid#" cfsqltype="cf_sql_integer">
    )
    --->
</cfif>

