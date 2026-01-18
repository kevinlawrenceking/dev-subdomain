<cfset componentPath = "/services/AuditionImportService">
<cfset auditionImportService = createObject("component", componentPath)>
<cfset auditionImportService.UPDauditionsimport_24374(
    new_status = new_status, 
    new_audprojectid = new_audprojectid, 
    id = x.id
)>