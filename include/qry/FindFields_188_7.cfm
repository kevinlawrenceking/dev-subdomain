<cfinclude template="/include/perfcount.cfm" />
<cfset pageService = request.svc("PageService")>
<cfset FindFields = pageService.SELpgpages_24004(thispage=trim(thispage))>