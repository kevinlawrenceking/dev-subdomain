<cfset eventService = createObject("component", "services.EventService")>
<cfset events_nobooking = eventService.SELevents_24547(audroleid=#audroleid#)>