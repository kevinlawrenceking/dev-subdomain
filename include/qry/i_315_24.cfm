<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset i = contactImportService.SELcontactsimport_i(uploadid=new_uploadid)>