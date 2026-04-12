<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService") />
<cfset notes = ticketService.SELtickets_23997(recid=recid) />