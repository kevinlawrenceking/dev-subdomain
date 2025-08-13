<cfset auditionImportService = createObject("component", "services.AuditionImportService") />
<cfset upload_details = auditionImportService.DETauditionsimport(uploadid=uploadid) />