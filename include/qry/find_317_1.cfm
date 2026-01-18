<cfset componentPath = "/services/AuditionImportService">
<cfset auditionImportService = createObject("component", componentPath)>
<cfset auditionImportService.INSauditionsimport_24392(importdata=importdata, new_uploadid=new_uploadid)>