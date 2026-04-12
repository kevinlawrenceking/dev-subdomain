<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset details = contactService.DETcontactdetails_24685(rcontactid=rcontactid)>