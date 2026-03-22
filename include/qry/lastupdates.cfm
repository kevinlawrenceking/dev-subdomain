<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = createObject("component", "services.ContactService")>

<cfset updates = contactService.getContactUpdates(
    userid = userid, 
    compid = 1
)>