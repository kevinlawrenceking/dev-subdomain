<cfset exportService = createObject("component", "services.ExportService")>
<cfset exportService.UPDexports(exportID=new_exportid, status="Active")>