<cfinclude template="/include/perfcount.cfm" />
<cfset componentService = createObject("component", "services.ComponentService")>
<cfset menuItemsAud = componentService.menuItemsAud()>