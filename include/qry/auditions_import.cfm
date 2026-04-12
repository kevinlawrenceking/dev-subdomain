<cfinclude template="/include/perfcount.cfm" />
<cfset AuditionImportService = createObject("component", "services.AuditionImportService")>
<cfset imports = AuditionImportService.auditionImports(userid=userid)>