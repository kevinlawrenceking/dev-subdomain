<cfset ticketService = createObject("component", "services.TicketService")>
<cfset ticketService.UPDtickets_24216(
    new_ticketname = new_ticketname,
    new_testingscript = new_testingscript,
    new_ticketType = new_ticketType,
    new_ticketStatus = new_ticketStatus,
    new_verid = new_verid,
    new_pgid = new_pgid,
    new_customtestpagename = new_customtestpagename,
    new_customtestpagelink = new_customtestpagelink,
    new_ticketPriority = new_ticketPriority,
    new_esthours = numberformat(new_esthours, '9.99'),
    ticketid = ticketid
)>