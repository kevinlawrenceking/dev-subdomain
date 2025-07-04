<cfset eventService = createObject("component", "services.EventService") />
<cfset details = eventService.DETevents(eventid=eventid) />