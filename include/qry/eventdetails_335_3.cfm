<cfset eventService = createObject("component", "services.EventService")>
<cfif isNumeric(eventid)>
    <cfset safeEventId = eventid>
<cfelse>
    <cfset safeEventId = 0>
</cfif>

<cfset eventdetails = eventService.DETevents_24492(eventid=safeEventId)>