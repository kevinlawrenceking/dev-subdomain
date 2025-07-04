<cfset PageAppLinkService = createObject("component", "services.PageAppLinkService") />
<cfset FindLinksT = PageAppLinkService.SELpgapplinks(pgid=findpage.pgid) />