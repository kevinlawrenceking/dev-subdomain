<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_17 = auditionProjectService.SELaudprojects_24238(
    userid = userid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend
)>