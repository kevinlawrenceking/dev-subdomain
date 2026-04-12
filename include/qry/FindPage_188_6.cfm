<cfinclude template="/include/perfcount.cfm" />
<cfset pageService = request.svc("PageService")>
<cfset FindPage = pageService.SELpgpages_24003(thispage=trim(thispage))>