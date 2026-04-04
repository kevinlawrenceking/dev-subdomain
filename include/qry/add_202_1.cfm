<cfset contactService = request.svc("ContactService")>
<cfset newContactId = contactService.INScontactdetails(userid=userid, contactfullname=TRIM(contactfullname))>


 
