<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset refer_details = contactService.DETcontactdetails_24629(details.refer_contact_id)>