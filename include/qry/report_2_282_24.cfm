<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_2 = auditionProjectService.SELaudprojects_24251(
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend,
    userid = userid,
    new_audcatid = new_audcatid
)>