<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset events_nobooking = eventService.SELevents_24547(audroleid=#audroleid#)>