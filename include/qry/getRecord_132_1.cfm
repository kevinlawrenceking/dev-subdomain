<cfinclude template="/include/perfcount.cfm" />
<cfset auditionImportService = createObject("component", "services.AuditionImportService")>
<cfset getRecord = auditionImportService.SELauditionsimport(id=id)>