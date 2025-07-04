<cfset auditionImportService = createObject("component", "services.AuditionImportService")>
<cfset auditionImportService.INSauditionsimport(
    importdata = importdata,
    new_audsubcatid = new_audsubcatid,
    new_uploadid = new_uploadid
)>