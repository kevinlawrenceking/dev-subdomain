<cfset ticketService = request.svc("TicketService")>
<cfset results = ticketService.REStickets_24768(statusList=["Implemented", "Testing"])>