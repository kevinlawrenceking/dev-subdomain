<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset findt = contactItemService.SELcontactitems_24207(ContactID=ContactID, new_tagname=new_tagname)>