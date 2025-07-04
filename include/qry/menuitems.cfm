<cfset componentService = createObject("component", "services.ComponentService")>
<cfset menuItemsU = componentService.SELpgcomps()>

<cfset menuItemsCount = menuItemsU.recordCount>
