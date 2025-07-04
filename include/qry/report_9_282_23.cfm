<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_9 = auditionProjectService.SELaudprojects_24250(
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend,
    userid = userid
)>