<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset projectDetails = auditionProjectService.DETaudprojects_24089(audprojectID=audprojectID)>