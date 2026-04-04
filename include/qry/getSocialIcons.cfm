<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset profiles = contactItemService.getSocialIcons(contactid=contactid, userid=userid)>