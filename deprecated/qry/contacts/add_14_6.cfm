<cfset contactService = createObject("component", "services.ContactService")>

<cfset newcontactid = contactService.INScontactdetails(
    userid = userid,
    contactFullName = relationship
) />