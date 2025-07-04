<cfset contactService = createObject("component", "services.ContactService")>
<cfset new_contactid = contactService.INScontactdetails_24000(
    userFirstName = finduser.userfirstname,
    userLastName = finduser.userlastname,
    userId = userid
)>