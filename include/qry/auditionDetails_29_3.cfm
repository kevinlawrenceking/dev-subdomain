<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset auditionDetails = auditionProjectService.DETaudprojects(eventId=events.eventid)>