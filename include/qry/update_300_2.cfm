<cfset ticketService = createObject("component", "services.TicketService")>
<cfset ticketService.UPDtickets_24337(
    ticketresponse="#ticketresponse#",
    next_verid=#next_verid#,
    patchnote="#patchnote#",
    recid=#recid#
)>