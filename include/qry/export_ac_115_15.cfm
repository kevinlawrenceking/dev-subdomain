<cfset exportService = createObject("component", "services.ExportItemService") />
<cfset export_ac = exportService.SELexportitems(exportID=new_exportid) />