<cfset pagesService = createObject("component", "services.PageService")>
<cfset pages = pagesService.SELpgpages(ticketActive="Y")>