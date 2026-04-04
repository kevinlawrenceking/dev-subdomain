<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_24412(
    contactid = f.contactid,
    personal_email = f.personal_email
)>