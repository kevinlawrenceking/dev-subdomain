<cfset ticketService = createObject("component", "services.TicketService")>
<cfset results = ticketService.REStickets_24768(statusList=["Implemented", "Testing"])>