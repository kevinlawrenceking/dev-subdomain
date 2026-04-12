<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService") />
<cfset FINDz = contactItemService.SELcontactitems_23948(deletecontactid=deletecontactid) />