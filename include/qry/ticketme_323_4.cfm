<cfset ticketService = createObject("component", "services.TicketTestUserService")>
<cfset ticketme = ticketService.SELtickettestusers_24475(
    recid = results.recid,
    userid = userid
)>