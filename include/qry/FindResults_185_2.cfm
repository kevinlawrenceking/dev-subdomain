<cfinclude template="/include/perfcount.cfm" />
<cfset pageService = request.svc("PageService")>
<cfset FindResults = pageService.getDynamicQuery(rpgid=rpgid)>