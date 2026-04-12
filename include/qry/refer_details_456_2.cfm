<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService") />
<cfset refer_details = contactService.DETcontactdetails_24625(refer_contact_id=details.refer_contact_id) />