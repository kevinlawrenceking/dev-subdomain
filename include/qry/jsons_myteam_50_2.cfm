<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset jsons_myteam = eventService.SELevents_23803(userId=userid)>