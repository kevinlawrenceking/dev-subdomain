<cfset eventService = request.svc("EventService")>

<!--- Ensure eventid is numeric before calling the service --->
<cfif isNumeric(eventid) and eventid gt 0>
    <cfset eventdetails = eventService.DETevents_24487(eventid=eventid)>
<cfelse>
    <!--- Create empty query if eventid is invalid --->
    <cfset eventdetails = queryNew("eventID,recid,eventTitle,eventDescription,eventLocation,eventStatus,eventCreation,eventStart,eventStop,eventTypeName,userid,eventStartTime,eventStopTime,contactid,dow,endRecur,eventDurationSeconds,durID,durName", "integer,integer,varchar,varchar,varchar,varchar,timestamp,timestamp,timestamp,varchar,integer,time,time,integer,varchar,timestamp,integer,integer,varchar")>
</cfif>