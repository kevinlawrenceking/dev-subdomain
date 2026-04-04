<cfset contactService = request.svc("ContactService")>
<cfset details = contactService.DETcontactdetails(contactid=FOLLOWUP_CONTACTID)>