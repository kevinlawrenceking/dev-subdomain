<cfinclude template="/include/perfcount.cfm" />
<cfset auditionImportService = createObject("component", "services.AuditionImportService")>
<cfset x = auditionImportService.SELauditionsimport_24363(new_uploadid=new_uploadid)>