<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>

<cfset eventService.updateEventData() />
