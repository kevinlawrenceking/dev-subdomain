<cfset contactService = request.svc("ContactService")>
<cfset C = contactService.SELcontactdetails_24433(
    userId = users.userid,
    selectContactId = select_contactid
)>