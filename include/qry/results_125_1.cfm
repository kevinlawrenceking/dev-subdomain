<cfset auditionImportService = createObject("component", "services.AuditionImportService")>
<cfset results = auditionImportService.RESauditionsimport(id=url.id)>