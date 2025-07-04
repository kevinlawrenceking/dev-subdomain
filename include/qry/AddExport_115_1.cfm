<cfset objExportService = createObject("component", "services.ExportService")>
<cfset new_exportid = objExportService.INSexports(userid=userid)>