<cfset contactService = request.svc("ContactService")>
<cfset new_contactid = contactService.INScontactdetails_24000(
    userFirstName = finduser.userfirstname,
    userLastName = finduser.userlastname,
    userId = userid
)>