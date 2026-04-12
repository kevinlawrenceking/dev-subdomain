<cfinclude template="/include/perfcount.cfm" />
<cfset ticketTypeService = createObject("component", "services.TicketTypeService")>
<cfset types = ticketTypeService.SELtickettypes()>