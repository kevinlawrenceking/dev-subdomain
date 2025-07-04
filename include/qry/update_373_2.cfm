<cfset eventService = createObject("component", "services.EventService")>
<cfif new_region_id EQ "">
    <cfset new_region_id = 0>
</cfif>

<cfset eventService.UPDevents_24556(
    new_eventLocation = trim(new_eventLocation),
    new_audlocadd1 = trim(new_audlocadd1),
    new_audlocadd2 = trim(new_audlocadd2),
    new_audcity = trim(new_audcity),
    new_region_id = new_region_id,
    new_audzip = trim(new_audzip),
    new_eventid = new_eventid
)>
