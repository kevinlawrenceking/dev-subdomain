<cfinclude template="/include/perfcount.cfm" />
<cfset reportItemService = createObject("component", "services.ReportItemService")>
<cfset reportitems_x = reportItemService.SELreportitems(userid=userid, reportid=reports.reportid)>