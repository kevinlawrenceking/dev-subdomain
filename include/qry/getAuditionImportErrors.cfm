<cfset auditionImportErrorService = createObject("component", "services.AuditionImportErrorService")>
<cfset errs = auditionImportErrorService.SELauditionsimport_error(id=results.id)>