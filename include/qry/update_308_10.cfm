<cfset componentPath = "/services/AuditionImportService">
<cfset auditionService = createObject("component", componentPath)>
<cfset auditionService.UPDauditionsimport(new_status=new_status, id=y.id)>