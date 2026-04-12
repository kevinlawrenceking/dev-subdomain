<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset projectDetails = auditionProjectService.DETaudprojects_24543(audprojectID=audprojectID)>

<cfset current_queryResult = projectDetails />
<cfinclude template="/include/debugLog.cfm">