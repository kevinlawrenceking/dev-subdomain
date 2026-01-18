<cfset pageService = createObject("component", "services.PageService")>
<cfset FindResults = pageService.getDynamicQuery(rpgid=rpgid)>