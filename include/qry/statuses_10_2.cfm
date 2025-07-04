<cfset ticketService = createObject("component", "services.TicketService")>
<cfset statuses = ticketService.SELtickets()>