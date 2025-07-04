<cfset ticketService = createObject("component", "services.TicketService")>
<cfset ticketService.UPDtickets(
    ticketid = ticketid,
    new_ticketname = new_ticketname,
    new_ticketdetails = new_ticketdetails,
    new_ticketresponse = new_ticketresponse,
    new_ticketStatus = new_ticketStatus,
    new_ticketType = new_ticketType,
    new_testingscript = new_testingscript,
    new_patchNote = new_patchNote,
    new_environ = new_environ,
    new_ticketPriority = new_ticketPriority,
    new_userid = isNumeric(new_userid) AND new_userid NEQ "" ? new_userid : 0,
    new_verid = isNumeric(new_verid) AND new_verid NEQ "" ? new_verid : 0,
    new_pgid = isNumeric(new_pgid) AND new_pgid NEQ "" ? new_pgid : 0,
    new_esthours = isNumeric(new_esthours) AND new_esthours NEQ "" ? decimalformat(new_esthours) : 0
)>