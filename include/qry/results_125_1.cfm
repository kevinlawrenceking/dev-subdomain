<cfinclude template="/include/perfcount.cfm" />
<cfset auditionImportService = createObject("component", "services.AuditionImportService")>
<cfset results = auditionImportService.RESauditionsimport(id=url.id)>