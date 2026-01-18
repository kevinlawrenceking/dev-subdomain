<cfset eventService = createObject("component", "services.EventService")>
<cfset eventService.UPDevents_24108(
    eventId = findEvent.eventid,
    newEventStart = new_eventStart,
    newEventStartTime = new_eventStartTime,
    newEventStopTime = new_eventStopTime
)>