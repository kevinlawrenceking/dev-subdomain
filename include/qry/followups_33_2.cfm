<cfset eventService = request.svc("EventService")>
<cfset followup_contactid = eventService.SELevents(audprojectid=audprojectid)>