<cfset auditionProjectService = createObject("component", "services.AuditionProjectService") />
<cfset report_10 = auditionProjectService.SELaudprojects_24230(
    userid = userid,
    new_rangestart = new_rangestart,
    new_rangeend = new_rangeend
) />