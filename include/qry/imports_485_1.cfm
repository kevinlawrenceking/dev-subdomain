<cfinclude template="/include/perfcount.cfm" />
<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset imports = contactImportService.SELcontactsimport_24668(userid=userid)>