<cfset ticketTestUserService = createObject("component", "services.TicketTestUserService")>
<cfset ticketTestUserService.INStickettestusers(
    new_ticketid = new_ticketid,
    new_userid = new_userid,
    new_teststatus = new_teststatus,
    new_rejectnotes = new_rejectnotes
)>