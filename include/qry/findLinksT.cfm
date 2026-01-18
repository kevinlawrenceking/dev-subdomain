<cfparam name="url.pgid" type="numeric" default="1">

<cfset pageAppLinksService = createObject("component", "services.PageAppLinks")>
<cfset FindLinksT = pageAppLinksService.GetPageAppLinks(pgid=pgid)>