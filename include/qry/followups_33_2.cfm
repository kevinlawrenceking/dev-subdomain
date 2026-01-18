<cfset eventService = createObject("component", "services.EventService")>
<cfset followup_contactid = eventService.SELevents(audprojectid=audprojectid)>