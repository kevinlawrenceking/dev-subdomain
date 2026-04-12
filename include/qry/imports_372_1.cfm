<cfinclude template="/include/perfcount.cfm" />
<cfset auditionImportService = createObject("component", "services.AuditionImportService")>
<cfset imports = auditionImportService.SELauditionsimport_24561(userid=userid)>