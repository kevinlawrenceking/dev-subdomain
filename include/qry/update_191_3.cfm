<cfset componentPath = "/services/AuditionProjectService">
<cfset auditionProjectService = createObject("component", componentPath)>
<cfset auditionProjectService.UPDaudprojects_24013(new_projdate=x.new_projdate, audprojectID=x.audprojectID)>