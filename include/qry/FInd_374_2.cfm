<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset eventService.UPDevents_24558(
    new_eventid=new_eventid,
    eventStart=eventStart,
    eventStartTime=eventStartTime,
    eventStopTime=eventStopTime,
    durmins=durmins
)>