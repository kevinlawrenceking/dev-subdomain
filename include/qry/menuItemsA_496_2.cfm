<cfinclude template="/include/perfcount.cfm" />
<cfset componentService = createObject("component", "services.ComponentService")>
<cfset menuItemsA = componentService.menuItemsA()>