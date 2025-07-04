<cfset ticketTestUserService = createObject("component", "services.TicketTestUserService")>
<cfset ticketusers = ticketTestUserService.SELtickettestusers_24474(ticketId=results.recid, userId=userid)>