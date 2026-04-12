<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>

<cfparam name="projectids" default="0" />
<cfset auditionProjectService.UPDaudprojects_24011(userid=userid, audprojectids=projectIds)>
