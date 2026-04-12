<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset eventresults = eventService.RESevents_24660(
    userID = userid
)>