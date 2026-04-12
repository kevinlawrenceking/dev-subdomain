<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset report_7 = auditionProjectService.getAuditionsData(userid, rangeselected, new_audcatid)>