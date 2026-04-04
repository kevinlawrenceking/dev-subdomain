<!--- This ColdFusion page handles the insertion of contact details into the database. --->

<cfset contactService = request.svc("ContactService")>
<cfset contactId = contactService.INScontactdetails(
    userid=userid,
    contactFullName=cdfullname
)>
