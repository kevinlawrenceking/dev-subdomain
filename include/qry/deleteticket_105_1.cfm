<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset ticketService.UPDtickets_23866(recid=recid)>