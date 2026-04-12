<cfinclude template="/include/perfcount.cfm" />
<cfset ticketStatusService = createObject("component", "services.TicketStatusService")>
<cfset statuses = ticketStatusService.SELticketstatuses_24766()>