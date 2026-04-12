<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset newContactId = contactService.INScontactdetails(userid=userid, contactfullname=TRIM(contactfullname))>


 
