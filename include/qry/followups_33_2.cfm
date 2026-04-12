<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset followup_contactid = eventService.SELevents(audprojectid=audprojectid)>