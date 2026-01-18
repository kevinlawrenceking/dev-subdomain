<cfset eventService = createObject("component", "services.EventService")>
<cfif NOT isDate(endRecur)>
    <cfset endRecur = "">
</cfif>

<cfset eventService.UPDevents_23733(
    eventTitle = eventTitle,
    eventTypeName = eventTypeName,
    eventDescription = eventDescription,
    eventLocation = eventLocation,
    eventStart = eventStart,
    eventStartTime = eventStartTime,
    dow = dow,
    eventStopTime = new_eventStopTime,
    endRecur = endRecur,
    eventid = eventid
)>