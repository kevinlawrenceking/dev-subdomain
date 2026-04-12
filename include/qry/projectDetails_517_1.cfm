<cfinclude template="/include/perfcount.cfm" />
<cfset projectService = request.svc("AuditionProjectService")>
<cfset projectDetails = projectService.DETaudprojects_24716(audprojectID=audprojectID)>