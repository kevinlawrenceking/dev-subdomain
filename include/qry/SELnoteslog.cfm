<cfset contactService = request.svc("ContactService")>

<cfset contactService.INScontactdetails(
    userid = userid,
    contactFullName = relationship
) />