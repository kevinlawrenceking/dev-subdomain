<cfinclude template="/include/perfcount.cfm" />
<cfset contactImportService = createObject("component", "services.ContactImportService")>
<cfset imports = contactImportService.getImportsByUserID(userid=userid)>