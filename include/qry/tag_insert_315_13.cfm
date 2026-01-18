<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset contactItemService.addContactItemsTag(contactid=tag2.contactid, new_tag=new_tag2)>
<cfdump var="#result#" >