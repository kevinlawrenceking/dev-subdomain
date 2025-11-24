<!--- This ColdFusion page handles the insertion of contact details into the database. --->

<cfset contactService = createObject("component", "services.ContactService")>
<cfset contactId = contactService.INScontactdetails(
    userid=userid,
    contactFullName=cdfullname
)>
