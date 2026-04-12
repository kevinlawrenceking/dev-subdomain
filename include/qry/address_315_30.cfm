<cfinclude template="/include/perfcount.cfm" />
<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset address = contactImportService.SELcontactsimport_address(uploadid=new_uploadid)>