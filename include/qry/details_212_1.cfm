<cfset ticketService = createObject("component", "services.TicketService")>
<cfset details = ticketService.DETtickets(recid=recid)>