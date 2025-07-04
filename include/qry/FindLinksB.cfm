<cfparam name="url.pgid" type="numeric" default="1">

<cfset pageAppLinksService = createObject("component", "services.PageAppLinks")>
<cfset FindLinksB = pageAppLinksService.GetLinksForPageB(pgid=pgid)>