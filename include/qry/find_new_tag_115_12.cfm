<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset find_new_tag = contactItemService.SELcontactitems_23898(contactID=new_contactid)>