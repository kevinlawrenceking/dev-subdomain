<cfinclude template="/include/perfcount.cfm" />
<cfset eventsService = request.svc("AuditionProjectService")>
<cfset events = eventsService.SELaudprojects_24062(audprojectid=#audprojectid#)>