<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset j = contactImportService.SELcontactsimport_j(uploadid=new_uploadid)>