<cfinclude template="/include/perfcount.cfm" />
<cfset auditionImportService = createObject("component", "services.AuditionImportService")>
<cfset x = auditionImportService.SELauditionsimport_24362(recordid = recordid)>