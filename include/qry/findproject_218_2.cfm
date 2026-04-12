<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService") />
<cfset findproject = auditionProjectService.SELaudprojects_24085(audprojectid=audprojectid) />