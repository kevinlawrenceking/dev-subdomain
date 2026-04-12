<cfinclude template="/include/perfcount.cfm" />
<cfset ticketService = request.svc("TicketService")>
<cfset recid = ticketService.INStickets(
    new_verid = new_verid,
    new_ticketName = new_ticketName,
    new_ticketdetails = new_ticketdetails,
    new_tickettype = new_tickettype,
    new_userid = new_userid,
    qstring = qstring
)>
