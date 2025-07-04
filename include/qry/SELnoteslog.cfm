<cfset contactService = createObject("component", "services.ContactService")>

<cfset contactService.INScontactdetails(
    userid = userid,
    contactFullName = relationship
) />