<cfinclude template="/include/perfcount.cfm" />
<cfset reportItemService = createObject("component", "services.ReportItemService")>
<cfset finditems = reportItemService.RESreportitems(userId=userid)>