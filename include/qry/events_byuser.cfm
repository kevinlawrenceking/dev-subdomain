<!--- This ColdFusion page retrieves event data for a specific user based on their ID and related contacts. --->

<cfinclude template="/include/qry/events_472_1.cfm" />

<!--- Additional check for currentid to filter events. --->
<cfif #isdefined('currentid')#>
    AND e.eventid IN (
        SELECT eventid 
        FROM eventcontactsxref 
        WHERE contactid = #currentid#
    )
</cfif>

