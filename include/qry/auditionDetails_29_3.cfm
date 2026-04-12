<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset auditionDetails = auditionProjectService.DETaudprojects(eventId=events.eventid)>