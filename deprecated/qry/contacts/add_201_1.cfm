<cfset contactService = createObject("component", "services.ContactService")>
<cfset contactid = contactService.INScontactdetails_24048(userid=userid, contactfullname=TRIM(contactfullname))>