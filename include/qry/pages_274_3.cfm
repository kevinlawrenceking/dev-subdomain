<cfinclude template="/include/perfcount.cfm" />
<cfset pagesService = request.svc("PageService")>
<cfset pages = pagesService.SELpgpages_24210(compactive="Y")>