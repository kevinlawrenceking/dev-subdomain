<cfset ContactItemService = createObject("component", "services.ContactItemService")>
<cfset result = contactItemService.addContactItemsTag(contactid=tag.contactid, new_tag=new_tag1)>
<cfdump var="#result#" label="tag1">