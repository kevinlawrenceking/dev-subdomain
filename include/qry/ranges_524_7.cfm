<cfset reportRangeService = createObject("component", "services.ReportRangeService")>
<cfset ranges = reportRangeService.getReportRanges({})>
