<cfset auditionProjectService = createObject("component", "services.AuditionProjectService") />
<cfset report_6 = auditionProjectService.SELaudprojects_24246(
    rangeStart = rangeselected.rangestart,
    rangeEnd = rangeselected.rangeend,
    userId = userid
) />