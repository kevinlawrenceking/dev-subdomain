<cfset contactService = createObject("component", "services.ContactService")>
<cfset newContactId = contactService.INScontactdetails(userid=userid, contactfullname=TRIM(contactfullname))>


 
