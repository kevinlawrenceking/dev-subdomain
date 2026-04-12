<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset questions_check = eventService.SELevents_23789(audprojectid=audprojectid)>