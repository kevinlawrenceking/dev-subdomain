<cfset ticketService = createObject("component", "services.TicketService")>
<cfset ticketService.UPDtickets_24335(
    ticketId = recid,
    userFirstName = uu.userfirstname,
    userLastName = uu.userlastname
)>