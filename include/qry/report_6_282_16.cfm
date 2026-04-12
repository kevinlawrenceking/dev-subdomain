<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset report_6 = auditionProjectService.getAuditionData(rangeselected, userid)>