<cfinclude template="/include/perfcount.cfm" />
<cfset linkService = createObject("component", "services.LinkService")>
<cfset find = linkService.SELlinks(linkid=linkid)>