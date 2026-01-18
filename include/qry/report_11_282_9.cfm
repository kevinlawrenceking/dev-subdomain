<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_11 = auditionProjectService.SELaudprojects_24236(
    userid = userid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend
)>