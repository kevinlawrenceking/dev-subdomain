<cfset eventService = createObject("component", "services.EventService")>
<cfset find_events = eventService.SELevents_24379(
    eventtypename = linkdetails.eventtypename,
    userid = linkdetails.userid
)>