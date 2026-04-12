<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset details = ticketService.DETtickets_24782(recid=recid)>