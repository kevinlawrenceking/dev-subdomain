<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_12 = auditionProjectService.SELaudprojects_24237(
    userid = userid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend
)>