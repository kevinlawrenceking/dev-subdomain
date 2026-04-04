<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset auditionDetails = auditionProjectService.DETaudprojects(eventId=events.eventid)>