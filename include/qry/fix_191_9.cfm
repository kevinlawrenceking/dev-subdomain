<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfparam name="projdate" default="" />
<cfset auditionProjectService.UPDaudprojects_24019(projDate=projDate)>
