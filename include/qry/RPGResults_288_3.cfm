<cfinclude template="/include/perfcount.cfm" />
<cfset pageService = request.svc("PageService")>
<cfset RPGResults = pageService.RESpgpages_24302(rpgid=rpgid)>