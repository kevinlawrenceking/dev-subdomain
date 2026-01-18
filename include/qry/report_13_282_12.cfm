<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_13 = auditionProjectService.SELaudprojects_24239(
    userid = userid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend
)>