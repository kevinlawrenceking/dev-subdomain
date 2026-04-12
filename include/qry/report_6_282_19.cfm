<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService") />
<cfset report_6 = auditionProjectService.SELaudprojects_24246(
    rangeStart = rangeselected.rangestart,
    rangeEnd = rangeselected.rangeend,
    userId = userid
) />