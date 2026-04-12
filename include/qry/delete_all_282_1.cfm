<cfinclude template="/include/perfcount.cfm" />
<cfset reportItemService = createObject("component", "services.ReportItemService")>
<cfset reportItemService.DELreportitems(userid=userid)>