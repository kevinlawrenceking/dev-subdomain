<cfinclude template="/include/perfcount.cfm" />
<cfset auditionLinkService = createObject("component", "services.AuditionLinkService")>
<cfset auditionLinkService.UPDaudlinks(linkid=linkid)>