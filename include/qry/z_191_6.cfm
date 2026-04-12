<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset z = auditionProjectService.SELaudprojects_24016(userid=userid)>