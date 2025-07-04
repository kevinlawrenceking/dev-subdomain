<cfset ticketService = createObject("component", "services.TicketService")>
<cfset details = ticketService.REStickets(recid=recid)>