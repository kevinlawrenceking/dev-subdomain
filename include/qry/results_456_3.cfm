<cfset contactService = createObject("component", "services.ContactService")>
<cfset results = contactService.REScontactdetails(userId=userid)>