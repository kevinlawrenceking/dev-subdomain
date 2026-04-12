<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset ticketService.UPDtickets_24339(ticketId=recid, status="Pass")>