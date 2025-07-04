<cfset eventService = createObject("component", "services.EventService")>
<cfset eventService.UPDevents_24540(
    new_eventLocation = trim(new_eventLocation),
    new_audlocadd1 = trim(new_audlocadd1),
    new_audlocadd2 = trim(new_audlocadd2),
    new_audcity = trim(new_audcity),
    new_region_id = new_region_id,
    new_audzip = trim(new_audzip),
    new_eventid = new_eventid
)>