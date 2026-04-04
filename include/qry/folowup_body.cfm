<cfset eventService = request.svc("EventService")>
<cfset FOLLOWUP_CONTACTID = eventService.SELevents(audprojectid=audprojectid)>
