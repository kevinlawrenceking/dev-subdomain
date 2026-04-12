<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset cds = auditionProjectService.SELaudprojects(userid=userid)>