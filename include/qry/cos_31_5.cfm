<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset cos = auditionProjectService.SELaudprojects_23795(userid=userid)>