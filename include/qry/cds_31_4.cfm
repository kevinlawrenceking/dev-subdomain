<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset cds = auditionProjectService.SELaudprojects(userid=userid)>