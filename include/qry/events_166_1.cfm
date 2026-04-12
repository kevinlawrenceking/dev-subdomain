<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset events = auditionProjectService.SELaudprojects_23961(mediaid=mediaid)>