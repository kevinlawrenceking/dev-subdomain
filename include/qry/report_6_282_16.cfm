<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_6 = auditionProjectService.getAuditionData(rangeselected, userid)>