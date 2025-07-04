<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset contactItemService.INScontactitems_24327(contactID=CONTACTID, newValueText=left(new_valuetext, 40))>