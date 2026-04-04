<cfset contactService = request.svc("ContactService")>

<cfset newcontactid = contactService.INScontactdetails(
    userid = userid,
    contactFullName = relationship
) />