<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset report_6 = auditionProjectService.SELaudprojects_24245(
    rangeStart = rangeselected.rangestart,
    rangeEnd = rangeselected.rangeend,
    userId = userid
)>