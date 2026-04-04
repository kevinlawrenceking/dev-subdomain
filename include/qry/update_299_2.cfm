<cfset ticketService = request.svc("TicketService")>
<cfset ticketService.UPDtickets_24335(
    ticketId = recid,
    userFirstName = uu.userfirstname,
    userLastName = uu.userlastname
)>