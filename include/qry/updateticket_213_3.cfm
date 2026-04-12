<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset ticketService.UPDtickets_24076(new_ticketid=new_ticketid)>