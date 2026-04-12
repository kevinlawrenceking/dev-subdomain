<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService") />
<cfset findcompany = contactItemService.SELcontactitems_24663(currentid=currentid) />