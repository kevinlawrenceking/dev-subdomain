<cfset ticketTestUserService = createObject("component", "services.TicketTestUserService")>
<cfset find = ticketTestUserService.SELtickettestusers(recid=recid, userid=userid)>