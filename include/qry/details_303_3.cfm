<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset details = ticketService.REStickets(recid=recid)>