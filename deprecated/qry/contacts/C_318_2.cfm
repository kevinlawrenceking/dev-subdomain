<cfset contactService = createObject("component", "services.ContactService")>
<cfset C = contactService.SELcontactdetails_24433(
    userId = users.userid,
    selectContactId = select_contactid
)>