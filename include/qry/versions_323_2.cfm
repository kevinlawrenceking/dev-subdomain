<cfset ticketService = createObject("component", "services.TicketService")>
<cfset versions = ticketService.SELtickets_24473(verid=results.verid, col6=numberformat(results.col6, '99999.99'))>