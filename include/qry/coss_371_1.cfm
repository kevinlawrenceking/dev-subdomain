<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset coss = auditionProjectService.SELaudprojects_24559(userid=userid, sel_coname=sel_coname)>