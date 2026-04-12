<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset results = ticketService.REStickets_24785(recid=recid)>