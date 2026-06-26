<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset sources = auditionProjectService.SELauditionSources(userid=userid)>
