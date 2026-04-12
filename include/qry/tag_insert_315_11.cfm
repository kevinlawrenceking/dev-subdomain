<cfinclude template="/include/perfcount.cfm" />
<cfset ContactItemService = request.svc("ContactItemService")>
<cfset result = contactItemService.addContactItemsTag(contactid=tag.contactid, new_tag=new_tag1)>
<cfdump var="#result#" label="tag1">