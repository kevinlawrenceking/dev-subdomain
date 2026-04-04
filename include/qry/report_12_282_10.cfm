<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset report_12 = auditionProjectService.SELaudprojects_24237(
    userid = userid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend
)>