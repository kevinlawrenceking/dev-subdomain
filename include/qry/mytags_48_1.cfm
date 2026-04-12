<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset mytags = contactItemService.SELcontactitems(contactId=audcontacts.contactid)>