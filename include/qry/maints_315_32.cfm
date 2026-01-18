<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset maints = contactImportService.SELcontactsimport_maints(uploadid=new_uploadid)>