<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset profiles = contactItemService.getSocialIcons(contactid=contactid, userid=userid)>