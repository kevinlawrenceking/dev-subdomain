<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.addContactItemsTag(contactid=tag2.contactid, new_tag=new_tag2)>
<cfdump var="#result#" >