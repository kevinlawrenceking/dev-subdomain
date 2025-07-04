<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>

<cfparam name="projectids" default="0" />
<cfset auditionProjectService.UPDaudprojects_24011(userid=userid, audprojectids=projectIds)>
