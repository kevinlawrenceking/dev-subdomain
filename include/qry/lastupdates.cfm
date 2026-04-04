<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>

<cfset updates = contactService.getContactUpdates(
    userid = userid, 
    compid = 1
)>