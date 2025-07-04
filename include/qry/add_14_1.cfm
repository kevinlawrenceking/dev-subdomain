<cfset eventService = createObject("component", "services.EventService")>

<!--- Ensure endRecur is a valid date or set it to null if not --->
<cfif NOT isDate(endRecur)>
    <cfset endRecur = JavaCast("null", "")>
</cfif>

<cfset new_eventid = eventService.INSevents(
    eventTitle = eventTitle,
    eventTypeName = eventTypeName,
    eventDescription = eventDescription,
    eventLocation = eventLocation,
    eventStart = eventStart,
    eventStartTime = eventStartTime,
    new_durseconds = new_durseconds,
    dow = dow,
    endRecur = endRecur,
    userid = userid
) />
