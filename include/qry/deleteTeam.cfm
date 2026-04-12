<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = createObject("component", "services.contactItemService")>
<cfset contactItemService.deleteTeam(contactid=deletecontactid)>
