<cfinclude template="/include/perfcount.cfm" />
<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset g = contactImportService.SELcontactsimport_g(uploadid=new_uploadid)>