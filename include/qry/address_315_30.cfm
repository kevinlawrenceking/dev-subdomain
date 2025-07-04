<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset address = contactImportService.SELcontactsimport_address(uploadid=new_uploadid)>