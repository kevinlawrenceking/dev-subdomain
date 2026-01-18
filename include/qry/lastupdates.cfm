<cfset contactService = createObject("component", "services.ContactService")>

<cfset updates = contactService.getContactUpdates(
    userid = userid, 
    compid = 1
)>