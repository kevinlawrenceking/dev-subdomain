<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_3 = auditionProjectService.SELaudprojects_24240(
    userid = userid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend
)>