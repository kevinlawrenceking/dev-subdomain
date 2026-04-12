<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset y = eventService.SELevents_24014(userid=userid)>