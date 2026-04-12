<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset eventService.UPDevents_23725(eventStartTime=now())>