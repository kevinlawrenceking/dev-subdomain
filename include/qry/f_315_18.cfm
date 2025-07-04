<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset f = contactImportService.SELcontactsimport_f(uploadid=new_uploadid)>