<cfset pagesService = request.svc("PageService")>
<cfset pages = pagesService.SELpgpages(ticketActive="Y")>