<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset profiles = contactItemService.SELcontactitems_24715(contactid=contactid, userid=userid)>