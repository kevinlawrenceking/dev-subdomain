<cfinclude template="/include/perfcount.cfm" />
<cfset reportRangeService = createObject("component", "services.ReportRangeService")>
<cfset ranges = reportRangeService.getReportRanges({})>
