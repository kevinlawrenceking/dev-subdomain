<cfset eventService = createObject("component", "services.EventService")>
<cfset FOLLOWUP_CONTACTID = eventService.SELevents(audprojectid=audprojectid)>
