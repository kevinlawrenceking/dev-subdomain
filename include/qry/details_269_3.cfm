<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset details = contactService.DETcontactdetails(contactid=contactid)>