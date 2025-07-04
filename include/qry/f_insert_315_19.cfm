<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset contactItemService.INScontactitems_24412(
    contactid = f.contactid,
    personal_email = f.personal_email
)>