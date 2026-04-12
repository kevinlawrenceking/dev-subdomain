<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset report_9 = auditionProjectService.SELaudprojects_24250(
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend,
    userid = userid
)>