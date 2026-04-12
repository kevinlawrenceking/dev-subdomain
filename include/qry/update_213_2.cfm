<cfinclude template="/include/perfcount.cfm" />
<cfset ticketTestUserService = createObject("component", "services.TicketTestUserService")>
<cfset ticketTestUserService.UPDtickettestusers(
    new_teststatus = new_teststatus,
    new_rejectnotes = new_rejectnotes,
    testid = testid
)>