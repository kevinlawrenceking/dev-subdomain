<cfinclude template="/include/perfcount.cfm" />
<cfset auditionLinkService = createObject("component", "services.AuditionLinkService")>
<cfset audlink_details = auditionLinkService.DETaudlinks(linkid=linkid)>