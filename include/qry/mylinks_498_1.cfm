<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset mylinks = contactItemService.SELcontactitems_24682(userContactID=userContactID)>