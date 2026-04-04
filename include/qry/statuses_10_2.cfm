<cfset ticketService = request.svc("TicketService")>
<cfset statuses = ticketService.SELtickets()>