<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService") />
<cfset findc = contactService.DETcontactdetails_24264(contactid=role_contactid) />