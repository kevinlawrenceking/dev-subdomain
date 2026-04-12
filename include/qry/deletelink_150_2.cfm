<cfinclude template="/include/perfcount.cfm" />
<cfset linkService = createObject("component", "services.LinkService")>
<cfset linkService.UPDlinks(linkid=linkid)>