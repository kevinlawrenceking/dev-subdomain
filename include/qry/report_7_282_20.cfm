<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_7 = auditionProjectService.getAuditionsData(userid, rangeselected, new_audcatid)>