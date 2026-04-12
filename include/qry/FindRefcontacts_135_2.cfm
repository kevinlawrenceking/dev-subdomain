<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset FindRefcontacts = contactService.SELcontactdetails_23913(contactid=contactid)>