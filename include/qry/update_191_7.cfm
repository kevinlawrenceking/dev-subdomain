<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset auditionProjectService.UPDaudprojects_24017(new_projdate=z.new_projdate, audprojectID=z.audprojectID)>
