<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset locationDetails = eventService.DETevents_24675(audprojectid=audprojectid)>