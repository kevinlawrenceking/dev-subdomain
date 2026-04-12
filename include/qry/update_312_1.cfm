<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset ticketService.UPDtickets_24384(
    ticketid = ticketid,
    new_verid = new_verid,
    new_ticketpriority = new_ticketpriority
)>