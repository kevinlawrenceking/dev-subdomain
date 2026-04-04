<cfset contactItemService = request.svc("ContactItemService")>
<cfset mytags = contactItemService.SELcontactitems(contactId=audcontacts.contactid)>