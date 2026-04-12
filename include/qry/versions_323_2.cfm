<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset versions = ticketService.SELtickets_24473(verid=results.verid, col6=numberformat(results.col6, '99999.99'))>