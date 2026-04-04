<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset report_6 = auditionProjectService.SELaudprojects_24244(
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend,
    userid = userid
)>