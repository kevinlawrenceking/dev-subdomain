<cfinclude template="/include/perfcount.cfm" />
<cfset pageService = request.svc("PageService")>
<cfset FindResults = pageService.RESpgpages_24739(pgid=#pgid#)>