<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_5 = auditionProjectService.SELaudprojects_24241(
    userid = userid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend
)>