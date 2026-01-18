<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset u = contactImportService.SELcontactsimport_u(uploadid=new_uploadid)>