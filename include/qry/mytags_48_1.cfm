<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset mytags = contactItemService.SELcontactitems(contactId=audcontacts.contactid)>